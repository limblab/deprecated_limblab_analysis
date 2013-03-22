% assumes a BDF formatted structure called out_struct

disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)),1);
if ~isempty(disJoint)
    disp('error, mismatched lengths in out_struct.raw.analog.data.  attempting to correct...')
	setLength=min(unique(cellfun(@length,out_struct.raw.analog.data)));
    for n=1:length(out_struct.raw.analog.data)
        out_struct.raw.analog.data{n}=out_struct.raw.analog.data{n}(1:setLength);
    end, clear n
end
disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)));
if ~isempty(disJoint)
    disp('still mismatched lengths in out_struct.raw.analog.data.  quitting...')
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
            error(['no fp chans were found by ',mfilename])
        end
    end
end
fp=double(cat(2,out_struct.raw.analog.data{fpchans}))';
samprate=out_struct.raw.analog.adfreq(fpchans(1));

% are all ts values the same for all channels?  Could be different on
% different preamps.
fptimes=out_struct.raw.analog.ts{1}(1):1/samprate: ...
    (size(out_struct.raw.analog.data{1},1)/samprate+out_struct.raw.analog.ts{1}(1));
if length(fptimes)==(size(fp,2)+1), fptimes(end)=[]; end