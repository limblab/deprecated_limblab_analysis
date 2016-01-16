function mergecds2cds(cds,cds2)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %mergecds2cds(cds,cds2)
    %loops through data fields in cds2 and merges the data in each field
    %with the data in the appropriate field of cds. The result will be that
    %cds contains the original data from both cds and cds2. At present only
    %the following fields are merged:
    %pos
    %vel
    %acc
    %force
    %EMG
    %LFP
    %analog
    %triggers
    %units
    %FR
    %trials         note, trial data is assumed to exist on only one cerebus
    %               and therefore cannot be merged in any useful sense.
    %               Instead this function will look at cds and cds2 and use
    %               whichever trials structure is not empty. If both contain
    %               non-empty trials structures then a warning will be issued
    %               and the structure from cds will be used
    %words          note, words are assumed to exist on only one cerebus
    %               and therefore cannot be merged in any useful sense.
    %               Instead this function will look at cds and cds2 and use
    %               whichever word structure is not empty. If both contain
    %               non-empty word structures then a warning will be issued
    %               and the structure from cds will be used
    %
    %
    %mergecds2cds cannot handle multiple columns in the same structure
    %having the same label. If cds and cds2 have duplicate column labels
    %then mergecds2cds will fail with an warning. and move on to the next
    %structure to merge
    
    %% merge units
        if isempty(cds.units)
            set(cds,'units',cds2.units)
        elseif ~isempty(cds2.units)
            %sanity check that the arrays have different labels
            if strcmp(cds.units(1).array,cds2.units(1).array)
                error('mergecds2cds:sameArrayName','Both structures you are merging have the same array name, which will result in duplicate entries in the units field. Re-load one of the data files using a different array name to avoid this problem')
            end
            set(cds,'units',[cds.units,cds2.units])
        end
    %% merge analog
        if isempty(cds.analog)
            set(cds,'analog',cds2.analog)
        elseif ~isempty(cds2.analog)
            toMerge=1:length(cds2.analog);
            for i=1:length(cds.analog)
                for j=1:length(cds2.analog)
                    %if the frequency of cds.analog{i} is the same as
                    %cds2.analog{j}, then merge cds2.analog{j} into
                    %cds.analog{i}
                    if (cds.analog{i}.t(2)-cds.analog{i}.t(1))==(cds2.analog{j}.t(2)-cds2.analog{j}.t(1))
                        toMerge(j)=-1;
                        analog{i}=[cds.analog{i},cds2.analog{j}(:,2:end)];
                    end
                end

            end
            analog=[analog,cds2.analog(toMerge(toMerge>0))];
            set(cds,'analog',analog)
            clear analog
        end
    %% merge things that *should* exist in only one of the cds structures and we have no merge scheme for
        dataList={'trials','words'};
        for i=1:length(dataList)
            incds=~isempty(cds.(dataList{i}));
            incds2=~isempty(cds2.(dataList{i}));
            
            if incds && incds2
                error('mergecds2dcs:fieldInBothSources',['the field: ',dataList{i},'is populated in both cds and cds2. This field should exist in only one of the cds strutures as we only collect digital data on one cerebus.'])
            end
            if incds2
                set(cds,dataList{i},cds2.(dataList{i}))
            end
        end
    %% merge everything that is a simple table
        dataList={'pos','vel','acc','force','EMG','LFP','analog','triggers','FR'};
        for i=1:length(dataList)
            if ~isempty(cds2.(dataList{i}))
                if isempty(cds.(dataList{i}))
                    set(cds,dataList{i},cds2.(dataList{i}))
                else 
                    %we need to take care of time column which exists in both fields
                    tstart=cds.(dataList{i}).t(1);
                    tend=cds.(dataList{i}).t(end);
                    dt=cds.(dataList{i}).t(2)-tstart;
                    tstart2=cds2.(dataList{i}).t(1);
                    tend2=cds2.(dataList{i}).t(end);
                    dt2=cds.(dataList{i}).t(2)-tstart;
                    %check our frequencies
                    if dt~=dt2
                        error('mergecds2cds:differentFrequency',['Field: ',dataList{i},' was collected at different frequencies in cds and cds2 and cannot be merged. Either re-load both data sets using the same filterspec, or refilter the data in one of the cds structures using decimation to get to the frequencies to match'])
                    end
                    %check if we have duplicate columns:
                    for j=1:length(cds.(dataList{i}).Properties.VariableNames)
                        if ~isempty(find(cell2mat({strcmp(cds2.dataList{i}.Properties.VariableNames,cds.dataList{i}.Properties.VariableNames{j})}),1,'first'))
                            error('mergecds2cds:duplicateColumns',['the column label: ',cds.dataList{i}.Properties.VariableNames{j},' exists in the ',dataList{i},' field of both cds and cds2. All columns in the same field except time must have different labels in order to merge 2 cds structures'])
                        end
                    end
                    mask=cell2mat({~strcmp(cds.dataList{i}.Properties.VariableNames,'t')});
                    set(cds,dataList{i},...
                        [cds.(dataList{i})(find(cds.(dataList{i}).t>=max(tstart,tstart2),1,'first'):find(cds.(dataList{i}).t>=min(tend,tend2),1,'first'),:),...
                        cds2.(dataList{i})(find(cds2.(dataList{i}).t>=max(tstart,tstart2),1,'first'):find(cds2.(dataList{i}).t>=min(tend,tend2),1,'first'),(mask))])
                    
                end
            end
        end
        
    %% log the merge operation
        cds.addOperation(mfilename('fullpath'),cds2.meta)
end