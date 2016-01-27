function calcFR(cds,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %cds.calcFR() computes the firing rate for each unit and puts all the
    %firing rates into a table in the cds.FR field
    for i=1:2:length(varargin)
        switch varargin{i}
            case 'method'
                method=varargin{i+1};
            case 'SR'
                SR=varargin{i+1};
            case 'offset'
                offset=varargin{i+1};
            case 'kernelWidth'
                kw=varargin{i+1};
            otherwise
                if ~ischar(varargin{i})
                    error('calcFR:badOptionFormat','calcFR takes options in key-value pairs. Keys must be strings specifying a valid option, e.g. method')
                else
                    error('calcFR:unrecognizedOption',['The option: ',varargin{i},'is not recognized'])
                end
        end
    end
    
    if ~exist('method','var')
        method=bin;
    end
    if ~exist('SR','var')
        SR=20;
    end
    if ~exist('offset','var')
        offset=0;
    end
    if ~exist('kw','var')
        kw=1/SR;
    end
    
    if offset==0
        warning('calcFR:zeroOffset','There is no offset between neural and external data. Normally you want some offset to account for effernt/affernt latency')
    end
    %build time vector from SR
    ti=1:1/SR:cds.meta.duration;
    %loop through units and get FR for each one:
    FR=zeros(length(ti),length(cds.units));
    for j=1:length(cds.units)
        %get timestamps for unit i
        ts=cds.units(j).waves.ts+offset;
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
                rate=hist(ts,ti)*SR;
            case 'triangle'
                disp('Triangle is not implemented yet');

        end

        if size( rate, 1) < size(rate,2),
            FR(:,j) = rate';
        else
            FR(:,j)=rate;
        end
        clear rate
    end
    if ~isempty(FR)
        %put FR into cds.FR field:
        FR=table(ti,FR,'VariableNames',{'t','r'});
        FR.Properties.VariableUnits={'s','hz'};
        FR.Properties.VariableDescriptions={'time','firing rate of neurons in cds.units'};
        FR.Properties.Description='a table with the firing rate for each neuron in cds.units. Order of columns is the same as the order of units in cds.units';
        set(cds,'FR',FR)
        cds.addOperation(mfilename('fullpath'),struct('method',method,'SR',SR,'offset',offset))
    end
end


