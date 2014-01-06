% assumes a BDF formatted structure called out_struct
temp=cellfun(@min,out_struct.raw.analog.ts);
if iscell(temp)
    allFPstartTS=cat(2,temp{:}); clear temp
else
    allFPstartTS=temp; clear temp
end

disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)),1);
if ~isempty(disJoint)
    disp('mismatched lengths in out_struct.raw.analog.data.  attempting to correct...')
    % whichever one starts later, we want to make that the start point (and
    % keep it in mind!)
    earlyStarters=find(allFPstartTS < max(allFPstartTS));
    if ~isempty(earlyStarters)
        for n=1:length(earlyStarters)
            out_struct.raw.analog.data{earlyStarters(n)}= ...
                out_struct.raw.analog.data{earlyStarters(n)}(2:end);
        end, clear n
    else
        setLength=min(unique(cellfun(@length,out_struct.raw.analog.data)));
        for n=1:length(out_struct.raw.analog.data)
            out_struct.raw.analog.data{n}=out_struct.raw.analog.data{n}(1:setLength);
        end, clear n
    end
end
disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)));
if ~isempty(disJoint)
    disp('still mismatched lengths in out_struct.raw.analog.data.  trying again...')
    setLength=min(unique(cellfun(@length,out_struct.raw.analog.data)));
    for n=1:length(out_struct.raw.analog.data)
        out_struct.raw.analog.data{n}=out_struct.raw.analog.data{n}(1:setLength);
    end, clear n
    disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)));                       %#ok<*EFIND>
    if ~isempty(disJoint)
        error('all attempts to equalize fp length across channels have failed')
    end
end

fpchans=find(cellfun(@isempty,regexp(out_struct.raw.analog.channels,'FP[0-9]+'))==0);
if isempty(fpchans)
    fpChanNums=regexp(out_struct.raw.analog.channels,'[0-9]+(?= - [0-9]+ kS/s)','match','once');
    if any(cellfun(@isempty,fpChanNums)==0)
        fpchans=find(str2double(fpChanNums)<=96);
    else
        fpChanNums=regexp(out_struct.raw.analog.channels,'(?<=elec)[0-9]{1,2}','match','once');
        if any(cellfun(@isempty,fpChanNums)==0)
            fpchans=find(str2double(fpChanNums)<=96);
        else
            fpChanNums=regexp(out_struct.raw.analog.channels,'(?<=chan)[0-9]{1,2}','match','once');
            if any(cellfun(@isempty,fpChanNums)==0)
            fpchans=find(str2double(fpChanNums)<=96);
            else
            error(['no fp chans were found by ',mfilename])
            end
        end
    end
end
fp=double(cat(2,out_struct.raw.analog.data{fpchans}))';
samprate=out_struct.raw.analog.adfreq(fpchans(1));

% are all ts values the same for all channels?  Could be different on
% different preamps.
fptimes=max(allFPstartTS):1/samprate: ...
    (size(out_struct.raw.analog.data{1},1)/samprate + max(allFPstartTS));
if length(fptimes)==(size(fp,2)+1), fptimes(end)=[]; end
clear earlyStarters allFPstartTS disJoint setLength