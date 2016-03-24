function triggersFromNEVNSx(cds,NEVNSx,NSxInfo)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    triggerList = find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'emg_')));
    if ~isempty(triggerList)
        triggerNames = NSxInfo.NSx_labels(triggerList);
        triggerFreq = NSxInfo.NSx_sampling(triggerList);

        % ensure all emg channels have the same frequency
        triggerFreq = unique(triggerFreq);
        if numel(triggerFreq)>1         
            error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
        end

        for i = length(triggerList):-1:1
            if NSxInfo.NSx_sampling(triggerList(i))==1000
                data(:,i+1) = double(NEVNSx.NS2.Data(NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif NSxInfo.NSx_sampling(triggerList(i))==2000
                data(:,i+1) = double(NEVNSx.NS3.Data(NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif NSxInfo.NSx_sampling(triggerList(i))==10000
                data(:,i+1) = double(NEVNSx.NS4.Data(NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
            elseif NSxInfo.NSx_sampling(triggerList(i))==30000
                data(:,i+1) = double(NEVNSx.NS5.Data(NSxInfo.NSx_idx(triggerList(i)),:))/6.5584993;
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
        cds.addOperation(mfilename('fullpath'))
    end
    
end