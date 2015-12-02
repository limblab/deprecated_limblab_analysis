function emgFromNEVNSx(cds,NEVNSx,NSxInfo)
    %retrieves emg information from a NEVNSx object and inserts it into the
    %cds. Because cds is a member of the handle superclass, nothing is
    %returned from this function
    emgList = find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'emg_')));
    emgnames = NSxInfo.NSx_labels(emgList);
    emgfreq = NSxInfo.NSx_sampling(emgList);

    % ensure all emg channels have the same frequency
    emgfreq = unique(emgfreq);
    if numel(emgfreq)>1         
        error('BDF:unequalEmgFreqs','Not all EMG channels have the same frequency');
    end

    for i = length(emgList):-1:1
        if NSxInfo.NSx_sampling(emgList(i))==1000
            data(:,i+1) = double(NEVNSx.NS2.Data(NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
        elseif NSxInfo.NSx_sampling(emgList(i))==2000
            data(:,i+1) = double(NEVNSx.NS3.Data(NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
        elseif NSxInfo.NSx_sampling(emgList(i))==10000
            data(:,i+1) = double(NEVNSx.NS4.Data(NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
        elseif NSxInfo.NSx_sampling(emgList(i))==30000
            data(:,i+1) = double(NEVNSx.NS5.Data(NSxInfo.NSx_idx(emgList(i)),:))/6.5584993;
        end
    end        

    data(:,1) = double(0:1/emgfreq:(size(data,1)-1)/emgfreq);

    emgnames=[{'t'},emgnames];
    %build table of emgs:
    emg=array2table(data,'VariableNames',emgnames);
    emg.Properties.VariableUnits=[{'s'},repmat({'mV'},1,length(emgnames)-1)];
    emg.Properties.VariableDescriptions=[{'time'},repmat({'filtered EMG'},1,length(emgnames)-1)];
    emg.Properties.Description='EMG voltage. Filtered, but not rectified or otherwise processed';
    %cds.setField('EMG',emg)
    set(cds,'EMG',emg);
    cds.addOperation(mfilename('fullpath'))
end