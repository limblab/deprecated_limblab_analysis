function appendNEVNSx2cds(cds,NEVNSx,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %appendNEVNSx2cds(NEVNSx,varargin)
    %appends data from the NEVNSx object to the end of the cds. To ensure 
    %that data is processed correctly, the NEVNSx will be converted to a 
    %new cds object using the flags passed the new NEVNSx will be time 
    %shifted by the length of the source data in the cds plus a 1 s lag. 
    %After time shifting all fields will be appended to the end of the 
    %matching fields of the original cds and the new cds deleted
    
    cds2=commonDataStructure();
    cds2.NEVNSx2cds(NEVNSx,varargin{:});
    
    if cds.meta.cdsVersion~=cds2.meta.cdsVersion
        error('appendNEVNSx2cds:mismatchedCDSVersion','The version of the current CDS is not the same as the version of the cds containing the old data')
    end
    
    tshift=cds.meta.duration+1;
    
    %% get our list of fields to timeshift and append:
    %list of all fields:
    fieldList=fieldnames(cds);
    %get rid of fields we know are not data fields:
    fieldList=fieldList(~strcmp(fieldList,'FR') && ...
                        ~strcmp(fieldList,'kinFilterConfig') && ...
                        ~strcmp(fieldList,'EMGFilterConfig') && ...
                        ~strcmp(fieldList,'LFPFilterConfig') && ...
                        ~strcmp(fieldList,'binConfig') && ...
                        ~strcmp(fieldList,'meta') && ...
                        ~strcmp(fieldList,'aliasList') && ...
                        ~strcmp(fieldList,'scratch'));
                    
    %% loop through fields and append new data to old cds
    for i=1:length(fieldList)
        if xor(isempty(cds.(fieldList{i})),isempty(cds.(fieldList{i})));
            error('appendNEVNSx:fieldMismatch',['The field: ',fieldList{i}, ' from the target cds is not in the new data.'])
        end
        if strcmp(fieldList{i},'analog')
            %analog is a special case and is a cell array of tables
            %rather than a table, so we need to treat it specially
            if length(cds.analog)~=length(cds2.analog)
                error('appendNEVNSx2cds:analogMismatch','There is a mismatch in the analog data between the original cds and the new data. Possible cause is data collected at different frequency')
            end
            for j=1:length(cds.analog)
                if size(cds.analog{j},2)~=size(cds2.analog{j},2)
                    error('appendNEVNSx2cds:analogMismatch',['There are different numbers of columns in analog data cell',num2str(j),' between the old and new data'])
                end
                temp2=cds2.analog{j};
                %timeshift analog data:
                mask=cell2mat({strcmp(cds.(fieldList{i}).Properties.VariableNames,'t')});
                temp2{:,mask}=temp{:,mask}+tshift;
                temp(j)={[cds.analog{j};temp2]};
            end
            set(cds,'analog',temp);
            clear temp
        end
        if strcmp(fieldList{i},'units')
            %units is a special case and is not a table so we must merge it
            %specially:
            temp=cds.units;
            %loop through all units in the old cds and append any 
            %timestamps and waveforms for the same unit found in the new 
            %data
            for j=1:size(temp)
                mask= cell2mat({cds2.units.unit})==temp(j).unit && cell2mat({cds2.units.chan})==temp(j).chan;
                if isempty(find(mask,1,'first'))
                    warning('appendNEVNSx2cds:missingUnit',['unit ',num2str(j),' is not found in the new data. Possible causes are a low-firing neuron or a change in sorting between files'])
                    disp(['this unit had ',num2str(size(cds.units(j).spikes.ts,1)),' spikes in the original cds'])
                    disp(['this unit had a mean firing rate of ',num2str(size(cds.units(j).spikes.ts,1)/cds.meta.duration),'hz in the original cds'])
                end
                temp2=cds2.units(mask).spikes;
                mask=cell2mat({strcmp(cds.units(i).spikes.Properties.VariableNames,'ts')});
                temp2{:,mask}=temp2{:,mask}+tshift;
                temp(j).spikes=[temp(j).spikes;temp2];
            end
            %now check to see if there were any units in the new data that
            %did not appear in the original data
            for j=1:size(cds2.units)
                mask= cell2mat({temp.unit})==cds2.units(j).unit && cell2mat({temp.chan})==cds2.units(j).chan;
                if ~isempty(find(mask,1,'first'))
                    warning('appendNEVNSx2cds:extraUnit',['unit ',num2str(j),' in the new data is not found in the old cds, and a new unit field will be added to cds.units. Possible causes are a low-firing neuron or a change in sorting between files'])
                    disp(['this unit had ',num2str(size(cds2.units(j).spikes.ts,1)),' spikes in the new data'])
                    disp(['this unit had a mean firing rate of ',num2str(size(cds2.units(j).spikes.ts,1)/cds2.meta.duration),'hz in the new data'])
                    temp(end+1)=cds2.units(j);
                    mask=cell2mat({strcmp(cds.units(i).spikes.Properties.VariableNames,'ts')});
                    temp(end).spikes{:,mask}=temp(end).spikes{:,mask}+tshift;
                end
            end
            set(cds,'units',temp)
            clear temp
        end
        if istable(cds.(fieldList{i}))
            temp=cds.(fieldList{i});
            %get the column index of timestamp or time, whichever this
            %table is using:
            mask=cell2mat({strcmp(cds.(fieldList{i}).Properties.VariableNames,'t')})+ cell2mat({strcmp(cds.(fieldList{i}).Properties.VariableNames,'ts')});
            temp{:,mask}=temp{:,mask}+tshift;
            set(cds,fieldList{i},[cds.(fieldList{i}),temp]);
        else
            warning('appendNEVNSx:fieldNotTable',['The field: ',fieldList{i}, ' is not a table and will be skipped'])
        end
    end
    %% update our metadata by stacking the fields from the old cds and the
    %new data:
    m=cds.meta;
    %the numbers:
    m.duration=m.duration+cds2.meta.duration+1;
    m.percentStill=(m.percentStill*cds.meta.duration+cds2.meta.percentStill*cds2.meta.duration)/m.duration;
    m.stillTime=m.stillTime+cds2.stillTime;
    m.dataWindow=[m.dataWindow(1) cds.meta.dataWindow(2)+tshift];
    m.trials.num=m.trials.num+cds2.meta.trials.num;
    m.trials.reward=m.trials.reward+cds2.meta.trials.reward;
    m.trials.abort=m.trials.abort+cds2.meta.trials.abort;
    m.trials.fail=m.trials.fail+cds2.meta.trials.fail;
    m.trials.incomplete=m.trials.incomplete+cds2.meta.trials.incomplete;
    m.fileSepTime=[m.fileSepTime;cds2.meta.fileSepTime];
    
    %the stuff that needs to be cell arrays:
    fields={'rawFileName','dataSource','lab','task','array','monkey','knownProblems','processedWith','dateTime'};
    for i=1:length(fields)
        if iscell(m.(fields{i}))
            m.dataSource=[m.(fields{i});{cds2.meta.(fields{i})}];
        else
            m.dataSource=[{m.(fields{i})};{cds2.meta.(fields{i})}];
        end
    end
    
    %skip the includedData field since this shouldn't have changed
    
    cds.addOperation(mfilename('fullpath'))
end