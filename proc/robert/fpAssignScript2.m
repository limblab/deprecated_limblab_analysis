% assumes a BDF formatted structure called out_struct

if ~isfield(out_struct.raw.analog,'fn')
    disp('there is no .fn field in out_struct.raw.analog')
    fprintf(1,'numel(ts)=%d\n',max(cellfun(@numel,out_struct.raw.analog.ts)));
    disp('running fpAssignScript.m...')
    fpAssignScript
    return
end

fpchans=find(cellfun(@isempty,regexp(out_struct.raw.analog.channels,'FP[0-9]+'))==0);
if isempty(fpchans)
    fpChanNums=regexp(out_struct.raw.analog.channels,'[0-9]+(?= - [0-9]+ kS/s)','match','once');
    if any(cellfun(@isempty,fpChanNums)==0)
        fpchans=find(str2double(fpChanNums)<=96);                                                       %#ok<*NASGU>
    else
        fpChanNums=regexp(out_struct.raw.analog.channels,'(?<=elec)[0-9]{1,2}','match','once');
        if any(cellfun(@isempty,fpChanNums)==0)
            fpchans=find(str2double(fpChanNums)<=96);
        else
            fpChanNums=regexp(out_struct.raw.analog.channels,'(?<=chan)[0-9]{1,2}','match','once');
            if any(cellfun(@isempty,fpChanNums)==0)
                fpchans=find(str2double(fpChanNums)<=96);
                out_struct.raw.analog.adfreq=out_struct.raw.analog.adfreq(fpchans);
                out_struct.raw.analog.channels=out_struct.raw.analog.channels(fpchans);
                out_struct.raw.analog.data=out_struct.raw.analog.data(fpchans);
                out_struct.raw.analog.fn=out_struct.raw.analog.fn(fpchans);
                out_struct.raw.analog.ts=out_struct.raw.analog.ts(fpchans);
            else
                error(['no fp chans were found by ',mfilename])
            end
        end
    end
end, clear fpChanNums

%%
fpCell=cell(1,length(out_struct.raw.analog.data));
fptimesCell=fpCell;
samprate=zeros(size(fpCell));
FPstop_time=samprate; FPstart_time=FPstop_time;
if max(cellfun(@numel,out_struct.raw.analog.ts))>500
    warning('fpAssignScript2:bigTS','very large number of time stamps in FPs')
end
for n=1:length(out_struct.raw.analog.ts)
    samprate(n)=out_struct.raw.analog.adfreq(n);
    % time will be in units of integer ticks of a clock that's running at
    % samprate(n) Hz.
    FPstop_time(n)=floor(out_struct.raw.analog.ts{n}(end)*samprate(n)+ ...
        out_struct.raw.analog.fn{n}(end));
    FPstart_time(n)=floor(samprate(n)*out_struct.raw.analog.ts{n}(1));    
    tsArray=[floor(samprate(n)*out_struct.raw.analog.ts{n}); FPstop_time(n)];
    fnArray=[0; out_struct.raw.analog.fn{n}];
    % since the arrays are padded out appropriately (previous 2 lines), it
    % is okay to start k at 2.
    for k=2:(length(tsArray)-1)
        fpCell{n}=[fpCell{n}; ...
            out_struct.raw.analog.data{n}((sum(fnArray(1:k-1))+1):sum(fnArray(1:k)))];
        % fnIdeal is the number of points that should have been in the
        % current data segment (fnArray(k) tells how many are actually
        % there).  To calculate fnIdeal, use time and sampling rate.  Be
        % sure to subtract off 1 sample from tsArray(k), because that is
        % the time of the start of the next block, and we want the last 
        % sample that should have been in this block, not the first 
        % sample of the next block.
        fnIdeal=floor(tsArray(k) - tsArray(k-1)); % - 1/samprate(n), was in the middle
%         fnIdeal=length(tsArray(k-1):1/samprate(n):(tsArray(k)-1/samprate(n)));
        fnActual=out_struct.raw.analog.fn{n}(k-1);
        if fnIdeal > fnActual
            % if there is a gap, fill it with interpolated values between
            % the last real point, and the first point of the next
            % segment.  Since we don't have data for any of that stretch,
            % we need to build a temp vector that overlaps with our actual
            % data, by:
            %           1. Selecting the last point of the previous good-
            %               data section, and the 1st point of the next
            %               good-data section.
            %           2. Interpolating across the gap (store this data
            %               as a temp array).
            %           3. Cutting out the first and last points of the 
            %               temp arrray, to avoid repeats.
            %           4. Tack on the temp array to the end of the
            %               previous section of good data.
            % Then, as the loop comes back around, the next section of good
            % data will be concatenated on next, and repeat as necessary.
            clear temp
            temp=interp1([fnActual fnIdeal+1], ...
                out_struct.raw.analog.data{n}([0 1]+sum(fnArray(1:k))), ...
                fnActual:(fnIdeal+1))';
            fpCell{n}=[fpCell{n}; temp(2:end-1)];
            % differences(k)=tsArray(k)-(numel(fpCell{n})+tsArray(1));
        end
    end
    % add in the last data segment.
    k=length(tsArray);
    stopInd=sum(fnArray(1:k));              % stopInd is for the real data, not the interpolated data.
    if stopInd > length(out_struct.raw.analog.data{n})
        stopInd=length(out_struct.raw.analog.data{n});
    end
    fpCell{n}=[fpCell{n}; ...
        out_struct.raw.analog.data{n}((sum(fnArray(1:k-1))+1):stopInd)];
    fptimesCell{n}=(FPstart_time(n):(FPstop_time(n)-1))/samprate(n);
    while length(fptimesCell{n}) < length(fpCell{n})
        fptimesCell{n}=[fptimesCell{n}, fptimesCell{n}(end)+1/samprate(n)];
    end
end, clear n k fnA* fnI* tsArray stopInd

if ~nnz(diff(samprate)~=0)
    samprate=samprate(1);
else
    error(['Different sampling rates on different fp channels!\n' ...
        'No common fp time base can be established.'])
end

clear temp
% temp=cat(2,out_struct.raw.analog.ts{:});
% .ts array can be different lengths for different channels
temp=cellfun(@min,out_struct.raw.analog.ts);
fptimes=max(temp):1/samprate:(min(FPstop_time)/samprate);
fp=zeros(length(fpCell),length(fptimes));
for n=1:length(fpCell)
    fp(n,:)=interp1(fptimesCell{n},fpCell{n},fptimes);
end, clear n fpCell fptimesCell 
clear FPstart_time FPstop_time temp

% if the sampling rate is >1kHz, the delta band will be empty at 256Hz
% window size, which means that 1/6 of the SFDs will be all NaNs.  To avoid
% this, adjust the sampling rate downward for higher-sampled LFPs.
if samprate > 1000
    % want final fs to be 1000
    disp('downsampling to 1 kHz')
    samp_fact=samprate/1000;
    downsampledTimeVector=linspace(fptimes(1),fptimes(end),length(fptimes)/samp_fact);
    fp=interp1(fptimes,fp',downsampledTimeVector)';
    fptimes=downsampledTimeVector;
    downsampledTimeVector=linspace(out_struct.vel(1,1),out_struct.vel(end,1), ...
        size(out_struct.vel,1)/samp_fact);
    out_struct.vel=[rowBoat(downsampledTimeVector), ...
        interp1(out_struct.vel(:,1),out_struct.vel(:,2:3),downsampledTimeVector)];
    out_struct.pos=[rowBoat(downsampledTimeVector), ...
        interp1(out_struct.pos(:,1),out_struct.pos(:,2:3),downsampledTimeVector)];
    clear downsampledTimeVector
    samprate=1000;
end

