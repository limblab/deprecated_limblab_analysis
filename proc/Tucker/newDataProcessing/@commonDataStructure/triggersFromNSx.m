function triggersFromNSx(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    triggerList = find(~cellfun('isempty',strfind(lower(cds.NSxInfo.NSx_labels),'trigger')));
    if ~isempty(triggerList)
        triggerNames = cds.NSxInfo.NSx_labels(triggerList);
        triggerFreq = cds.NSxInfo.NSx_sampling(triggerList);

        % ensure all trigger channels have the same frequency
        triggerFreq = unique(triggerFreq);
        if numel(triggerFreq)>1         
            error('triggersFromNSx:unequalEmgFreqs','Not all trigger channels have the same frequency, please implement something to handle this!');
        end

        for i = length(triggerList):-1:1
            if cds.NSxInfo.NSx_sampling(triggerList(i))==500
                data(:,i+1) = double(cds.NS1.Data(cds.NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(triggerList(i))==1000
                data(:,i+1) = double(cds.NS2.Data(cds.NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(triggerList(i))==2000
                data(:,i+1) = double(cds.NS3.Data(cds.NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(triggerList(i))==10000
                data(:,i+1) = double(cds.NS4.Data(cds.NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(triggerList(i))==30000
                data(:,i+1) = double(cds.NS5.Data(cds.NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            end
        end        

        data(:,1) = double(0:1/triggerFreq:(size(data,1)-1)/triggerFreq);

        triggerNames=[{'t'},triggerNames];
        %build table of emgs:
        triggers=array2table(data,'VariableNames',triggerNames);
        triggers.Properties.VariableUnits=[{'s'},repmat({'V'},1,length(triggerNames)-1)];
        triggers.Properties.VariableDescriptions=[{'time'},repmat({'trigger voltage'},1,length(triggerNames)-1)];
        triggers.Properties.Description='Unfiltered trigger voltage.';
        
        if isempty(cds.triggers)
            set(cds,'triggers',triggers);
        elseif ~isempty(triggers)
            cds.mergeTable('triggers',triggers)
        end
        evntData=loggingListenerEventData('triggersFromNSx',[]);
        notify(cds,'ranOperation',evntData)
    end
    
end