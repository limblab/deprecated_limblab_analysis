function emgFromNSx(cds)
    %retrieves emg information from a NEVNSx object and inserts it into the
    %cds. Because cds is a member of the handle superclass, nothing is
    %returned from this function
    emgList = find(~cellfun('isempty',strfind(lower(cds.NSxInfo.NSx_labels),'emg_')));
    if ~isempty(emgList)
        emgNames = cds.NSxInfo.NSx_labels(emgList);
        emgFreq = cds.NSxInfo.NSx_sampling(emgList);

        % ensure all emg channels have the same frequency
        emgFreq = unique(emgFreq);
        if numel(emgFreq)>1         
            error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
        end

        for i = length(emgList):-1:1
            if cds.NSxInfo.NSx_sampling(emgList(i))==500
                data(:,i+1) = double(cds.NS1.Data(cds.NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(emgList(i))==1000
                data(:,i+1) = double(cds.NS2.Data(cds.NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(emgList(i))==2000
                data(:,i+1) = double(cds.NS3.Data(cds.NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(emgList(i))==10000
                data(:,i+1) = double(cds.NS4.Data(cds.NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
            elseif cds.NSxInfo.NSx_sampling(emgList(i))==30000
                data(:,i+1) = double(cds.NS5.Data(cds.NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
            end
        end        

        data(:,1) = double(0:1/emgFreq:(size(data,1)-1)/emgFreq);

        emgNames=[{'t'},emgNames];
        %build table of emgs:
        emg=array2table(data,'VariableNames',emgNames);
        emg.Properties.VariableUnits=[{'s'},repmat({'mV'},1,length(emgNames)-1)];
        emg.Properties.VariableDescriptions=[{'time'},repmat({'EMG'},1,length(emgNames)-1)];
        emg.Properties.Description='EMG voltage. Filtered, but not rectified or otherwise processed';
        if isempty(cds.emg)
            set(cds,'emg',emg);
        elseif ~isempty(emg)
            cds.mergeTable('emg',emg)
        end
        evntData=loggingListenerEventData('emgFromNSx',[]);
        notify(cds,'ranOperation',evntData)
    end
end