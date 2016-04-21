function calcFiringRate(ex,varargin)
    %this is a method function for the experiment class, and
    %should be located in a folder '@experiment' with the class
    %definition file and other method files
    %
    %ex.calcFR() computes the firing rate for each unit and puts all the
    %firing rates into a table.
    %calcFR accepts several inputs to configure operation. If those inputs
    %are not passed, calcFR will pull appropriate values from the 
    %ex.binConfig field. INputs are passed as key-value pairs. the
    %following pairs are implemented:
    %
    for i=1:2:length(varargin)
        switch varargin{i}
            case 'method'
                method=varargin{i+1};
            case 'sampleRate'
                sampleRate=varargin{i+1};
            case 'offset'
                offset=varargin{i+1};
            case 'kernelWidth'
                kw=varargin{i+1};
            case 'lags'
                lags=varargin{i+1};
            case 'lagSteps'
                lagSteps=varargin{i+1};
            case 'cropType'
                cropType=varargin{i+1};
            otherwise
                if ~ischar(varargin{i})
                    error('calcFR:badOptionFormat','calcFR takes options in key-value pairs. Keys must be strings specifying a valid option, e.g. method')
                else
                    error('calcFR:unrecognizedOption',['The option: ',varargin{i},'is not recognized'])
                end
        end
    end
    %if any variables weren't passed get them from the experiment.frConfig
    %field:
    if ~exist('method','var')
        method=ex.firingRateConfig.method;
    end
    if ~exist('SR','var')
        sampleRate=ex.firingRateConfig.sampleRate;
    end
    if ~exist('offset','var')
        offset=ex.firingRateConfig.offset;
    end
    if ~exist('kw','var')
        kw=ex.firingRateConfig.kernelWidth;
    end
    if ~exist('lags','var')
        lags=ex.firingRateConfig.lags;
    end
    if ~exist('lagSteps','var')
        lagSteps=ex.firingRateConfig.lagSteps;
    end
    if ~exist('cropType','var')
        cropType=ex.firingRateConfig.cropType;
    end
    
    if offset==0
        warning('calcFiringRate:zeroOffset','There is no offset between neural and external data. Normally you want some offset to account for effernt/affernt latency')
    elseif offset>.1
        warning('calcFiringRate:largeOffset',['The offset specified is very large: (',num2str(offset),'). Normal offsets are .015s to .05s. It is possible that the offset is entered in ms rather than s'])
    end
    
    %loop through units and get FR for each one:
    FR=zeros(length(ex.meta.dataWindow(1):1/sampleRate:ex.meta.dataWindow(2)),length(ex.units.data));
    for j=1:length(ex.units.data)
        %if this unit is invalid, skip it:
        if ex.units.data(j).ID==255
            continue
        end
        %get timestamps for unit i
        ts=ex.units.data(j).spikes.ts+offset;
        %convert timestamps into firing rate sampled on the time vector ti
        switch method,
            case 'boxcar',
                %standard rate histogram method
                %build time vector from sampleRate
                ti=ex.meta.dataWindow(1):1/sampleRate:ex.meta.dataWindow(2);
        %         rate = hist( ts, ti ) ./ kw;
                for i = 1:length(ti),
                    tStart = ti(i) - kw/2;
                    tEnd = ti(i) + kw/2;
                    rate(i) = sum(ts >= tStart & ts < tEnd)/kw;
                end
            case 'gaussian',
                %build time vector from sampleRate
                ti=ex.meta.dataWindow(1):1/sampleRate:ex.meta.dataWindow(2);
                sigma = kw/pi;
                for i = 1:length( ti ),
                    curT = ti(i);
                    tau = curT - ts( find( ts >= curT-5*sigma & ts < curT+5*sigma) );
                    rate(i) = sum( exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma) );
                end
                
                %alternate code. This works but is slow, and has close
                %to singular matrix problems due to very high sample rate
                %also throws a warning for every unit which is dumb
%                 warning('calcFiringRate:gaussianAssumes30khz','the gaussian convolution method assumes that spike timestamps are collected at 30khz. Data collected a lower sample rates may cause ripples in the computed FR if the output frequency is high enough')
%                 %get gaussian kernel:
%                 spikeSamplePeriod=1/30000;
%                 tau=-kw/2:spikeSamplePeriod:kw/2;
%                 sigma=kw/pi;
%                 kernel=exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma);
%                 %convolve the kernel with a 30000hz histogram to get rate
%                 %at 30khz
%                 t=min(ti):double(spikeSamplePeriod):max(ti);
%                 rate=conv(hist(ts,t),kernel,'same');
%                 %now decimate the data to get firing rate at our desired frequency:
%                 tmp=decimateData([t',rate'],filterConfig('poles',8,'cutoff',sampleRate/2,'sampleRate',sampleRate));
%                 rate=tmp(:,2);
            case 'bin'
                %build time vector from sampleRate:
                %to do this we must shift ti so that bins are centered on 
                %sample times (hence padding the ends with 1/2 the 
                %sample frequency):
                ti=ex.meta.dataWindow(1)-1/(sampleRate*2):1/sampleRate:ex.meta.dataWindow(2)+1/(sampleRate*2);
                rate=histc(ts,ti)*sampleRate;
                %remove the odd extra sample from histc and re- align time:
                rate=rate(1:end-1);
                ti=ti(1:end-1) +1/(sampleRate*2);
            otherwise
                error('calcFiringRate:methodNotImplemented',['the ',method,' method of firing rate computation is not implemented in calcFiringRate'])
        end

        if size( rate, 1) < size(rate,2),
            FR(:,j) = rate';
        else
            FR(:,j)=rate;
        end
        clear rate
        %now make our variable names for each unit:
        unitNames{j}=[ex.units.data(j).array,'CH',num2str(ex.units.data(j).chan),'ID',num2str(ex.units.data(j).ID)];
    end
    %clear out columns that were due to invalid units:
    mask=([ex.units.data.ID]==255);
    FR(:,mask)=[];
    unitNames=unitNames(~mask);
    
    if ~isempty(FR)
        %add lags and put FR into a table
        for i=1:length(unitNames)
            [temp{i},lagRange,t]=ex.timeShiftBins(FR(:,i),lags,'time',ti,'lagSteps',lagSteps,'cropType',cropType);
        end
        FRTable=table(temp{:},'VariableNames',unitNames);
        FRTable=[table(t,'VariableNames',{'t'}),FRTable];
        FRTable.Properties.VariableUnits=[{'s'},repmat({'hz'},1,length(unitNames))];
        FRTable.Properties.VariableDescriptions=[{'time'},repmat({'firing rate'},1,length(unitNames))];
        FRTable.Properties.Description='a table with the firing rate for each neuron in ex.units. Order of columns is the same as the order of units in ex.units';
        ex.firingRate.appendTable(FRTable,'overWrite',true)
        m.offset=offset;
        m.method=method;
        m.lagSteps=ex.firingRateConfig.lagSteps;
        m.cropType=ex.firingRateConfig.cropType;
        m.sampleRate=sampleRate;
        m.kernelWidth=kw;
        m.lags=lagRange;
        ex.firingRate.updateMeta(m)
    end
    evntData=loggingListenerEventData('calcFiringRate',ex.firingRate.meta);
    notify(ex,'ranOperation',evntData)
end


