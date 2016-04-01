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
        method=ex.frConfig.method;
    end
    if ~exist('SR','var')
        sampleRate=ex.frConfig.sampleRate;
    end
    if ~exist('offset','var')
        offset=ex.frConfig.offset;
    end
    if ~exist('kw','var')
        kw=ex.frConfig.kernelWidth;
    end
    if ~exist('lags','var')
        lags=ex.frConfig.lags;
    end
    if ~exist('lagSteps','var')
        lagSteps=ex.frConfig.lagSteps;
    end
    if ~exist('cropType','var')
        cropType=ex.frConfig.cropType;
    end
    
    if offset==0
        warning('calcFR:zeroOffset','There is no offset between neural and external data. Normally you want some offset to account for effernt/affernt latency')
    end
    %build time vector from SR
    ti=ex.meta.dataWindow(1):1/sampleRate:ex.meta.dataWindow(2);
    %loop through units and get FR for each one:
    FR=zeros(length(ti),length(ex.units.data));
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
        %         rate = hist( ts, ti ) ./ kw;
                for i = 1:length(ti),
                    tStart = ti(i) - kw/2;
                    tEnd = ti(i) + kw/2;
                    rate(i) = sum(ts >= tStart & ts < tEnd)/kw;
                end
            case 'gaussian',      
                sigma = kw/pi;
                for i = 1:length( ti ),
                    curT = ti(i);
                    tau = curT - ts( find( ts >= curT-5*sigma & ts < curT+5*sigma) );
                    rate(i) = sum( exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma) );
                end
            case 'bin'
                rate=hist(ts,ti)*sampleRate;
            otherwise
                error('calcFR:methodNotImplemented',['the ',method,' method of firing rate computation is not implemented in calcFR'])
        end

        if size( rate, 1) < size(rate,2),
            FR(:,j) = rate';
        else
            FR(:,j)=rate;
        end
        clear rate
        %now make our variable names for each unit:
        unitNames{j}=[ex.units.data(j).array,'_CH',num2str(ex.units.data(j).chan),'_ID',num2str(ex.units.data(j).ID)];
    end
    if ~isempty(FR)
        %add lags and put FR into a table
        FRTable=table(ti','VariableNames',{'t'});
        for i=1:length(unitNames)
            [temp,lagRange]=timeShiftBins(FR(:,i),lags,'lagSteps',lagSteps,'cropType',cropType);
            FRTable=[FRTable,table(temp,'VariableNames',unitNames(i))];
        end
        FRTable.Properties.VariableUnits=[{'s'},repmat({'hz'},1,length(unitNames))];
        FRTable.Properties.VariableDescriptions=[{'time'},repmat({'firing rate'},1,length(unitNames))];
        FRTable.Properties.Description='a table with the firing rate for each neuron in ex.units. Order of columns is the same as the order of units in ex.units';
        ex.fr.appendTable(FRTable,'overWrite',true)
        m.offset=offset;
        m.method=method;
        m.lagSteps=ex.frConfig.lagSteps;
        m.cropType=ex.frConfig.cropType;
        m.sampleRate=sampleRate;
        m.kernelWidth=kw;
        m.lags=lagRange;
        ex.fr.updateMeta(m)
    end
end


