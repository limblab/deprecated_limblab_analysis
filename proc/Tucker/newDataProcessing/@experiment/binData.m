function binData(ex,varargin)
    %binData is a method of the experiment class, and should be found
    %in the @experiment folder with the main class definition. bin data
    %produces a binnedData object and inserts it in the experiment.bins
    %field of the experiment.
    
    %% handle variable inputs
    for i=1:2:length(varargin)
        switch varargin{i}
            case 'recalcFiringRate'
                recalcFR=true;
            otherwise
        end
    end
    if ~exist('recalcFR','var')
        recalcFR=false;
    end
    
    %% get the units into a table:
    if isempty(ex.firingRate) || recalcFR
        if ex.binConfig.filterConfig.sampleRate>ex.firingRateConfig.sampleRate;
            error('binData:frequencyMismatch','The sample rate of the firing rates must be equal to or greater than the sample rate of the binned data. Recompute the firing rates with a higher sample rate, or set a lower binning frequency')
        end
        ex.calcFR;
    end
    
    %% get the continuous data into a table:
    %start with our difined fields
    bins=[];
    for i=1:length(ex.binConfig.include)
        currLabel=ex.binConfig.field{i};
        if strcmp(currLabel,'units') || strcmp(currLabel,'units') 
            continue
        end
        currNames=ex.(currLabel).data.Properties.VariableNames;
        if isempty(ex.binconfig(i).which)
            temp=decimateData(ex.(currLabel).data{:,:},ex.binConfig.filterConfig);
        else
            temp=zeros(numel(ex.(currLabel).data.t),numel(ex.binConfig(i).which)+1);
            temp(:,1)=ex.(currLabel).data.t;
            for j=1:length(ex.binConfig(i).which)
                temp(:,j+1)=ex.(currLabel).data.(ex.binConfig(i).which{i});
            end
        end
        if isempty(bins)
            %if we don't have a time column yet
            bins=table(temp(:,1),'VariableNames',{'t'});
        end
        %now append the non-time columns of the current data set to the
        %continousBins:
        bins=[bins,array2table(temp(:,2:end),'VariableNames',currNames(2:end))];
    end
    %now get anything in 'analog' if necessary:
    analogIdx=find([strcmp({ex.binConfig.field},'analog')],1);
    if ~isempty(analogIdx)
        for i=1:numel(ex.analog.data)
            mask=zeros(1,numel(ex.analog{i}.data.Properties.VariableNames));
            for j=1:length(ex.binConfig(analogIdx).which)
                mask=mask && [strcmp(ex.analog.data{i}.Properties.VariableNames,ex.binConfig(analogIdx).which{j})];
            end
            if ~isempty(find(mask,1))
                temp=ex.analog{i}.data{:,mask};
                bins=[bins,array2table(temp,'VariableNames',ex.analog{i}.data.Properties.VariableNames(mask))];
            end
        end
    end
    %% get unit data if necessary:
    unitIdx=find([strcmp({ex.binConfig.field},'units')],1);
    if ~isempty(unitIdx)
        %decimate the Fr data if necessary:
        if ex.binConfig.filterConfig.sampleRate<ex.firingRate.meta.sampleRate
            temp=decimateData(ex.firingRate.data{:,:},ex.binConfig.filterConfig);
            temp=table2mat(temp,'VariableNames',ex.firingRate.data.Properties.VariableNames);
            temp.Properties.VariableUnits=ex.firingRate.data.Properties.VariableUnits;
            temp.Properties.VariableDescriptions=ex.firingRate.data.Properties.VariableDescriptions;
            temp.Properties.Description=ex.firingRate.data.Properties.Description;
            ex.bin.updateBins([bins,temp])
        else
            temp=ex.firingRate.data;
        end
        %now find the common time range:
        tFR=temp.t(find(sum(isnan(temp{:,:}),2),1));%first row without nans- nans will be from lags and should occur at start and end
        tCont=bins.t(1);
        tStart=max(tFR,tCont);
        tFR=temp.t(find(sum(~isnan(temp{:,:})==size(temp,2),2),1,'last'));
            %last row without nans-> sum(~isnan(temp{:,:}) will generate a col
            %vector where each element is N-m (where N is the number of columns
            %in temp and m is the number of NaN values in that row of temp) The
            %above line finds the last time that we have a complete row with no
            %NaN values by checking that the sum of ~isnan for the rows is
            %equal to the number of cols
        tCont=bins.t(end);
        tEnd=min(tFR,tCont);
        contStart=find(bins.t>=tStart,1);
        contEnd=find(bins.t<tEnd,1,'last');
        FRStart=find(temp.t>=tStart,1);
        FREnd=find(temp.t<tEnd,1,'last');
        bins=[bins(contStart:contEnd,:),temp(FRStart:FREnd,:)];
    end
    %% put the binned data into ex.bin.bins
    %finally update ex.bin.bins with a table of the continuous and FR data
    %that exist in the common time window:
    ex.bin.updateBins(bins);
end