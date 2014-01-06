% assumes a BDF formatted structure called out_struct

if ~isfield(out_struct.raw.analog,'fn')
    disp('there is no .fn field in out_struct.raw.analog')
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
for n=1:length(out_struct.raw.analog.ts)
    samprate(n)=out_struct.raw.analog.adfreq(n);
    FPstop_time=out_struct.raw.analog.ts{n}(end)+ ...
        out_struct.raw.analog.fn{n}(end)/samprate(n);
    tsArray=[out_struct.raw.analog.ts{n}; FPstop_time];
    fnArray=[0; out_struct.raw.analog.fn{n}];
    for k=2:(length(tsArray)-1)
        fpCell{n}=[fpCell{n}; ...
            out_struct.raw.analog.data{n}((sum(fnArray(1:k-1))+1):sum(fnArray(1:k)))];
        fnIdeal=floor((tsArray(k)-1/samprate(n)-tsArray(k-1))*samprate(n));
%         fnIdeal=length(tsArray(k-1):1/samprate(n):(tsArray(k)-1/samprate(n)));
        fnActual=out_struct.raw.analog.fn{n}(k-1);
        if fnIdeal > fnActual
            % if there is a gap, fill it with interpolated values between
            % the last real point, and the first point of the next
            % segment.  Since we don't have data for any of that stretch,
            % we need to build a temp vector that overlaps with our actual
            % data, then cut out the first and last points (so that we're
            % not repeating as we build the array out).  e.g., 
            % +1 in the next line is necssary to reache into the next data 
            % fragment (where there is good data).
            temp=interp1([fnActual fnIdeal+1], ... 
                out_struct.raw.analog.data{n}([0 1]+sum(fnArray(1:k))), ...
                fnActual:(fnIdeal+1))';
            fpCell{n}=[fpCell{n}; temp(2:end-1)]; clear temp
        end
    end
    % add in the last data segment.
    k=length(tsArray);
    stopInd=sum(fnArray(1:k));
    if stopInd > length(out_struct.raw.analog.data{n})
        stopInd=length(out_struct.raw.analog.data{n});
    end
    fpCell{n}=[fpCell{n}; ...
        out_struct.raw.analog.data{n}((sum(fnArray(1:k-1))+1):stopInd)];
    fptimesCell{n}=tsArray(1):1/samprate(n):(length(fpCell{n})/samprate(n));
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

fptimes=(1:max(cellfun(@length,fpCell)))/samprate;
fp=zeros(length(fpCell),length(fptimes));
for n=1:length(fpCell)
    fp(n,:)=interp1(fptimesCell{n},fpCell{n},fptimes);
end, clear n fpCell fptimesCell


%   0.0017  181547
% 181.9737  2227
% 184.2067	9648
% 193.8767	330638
% 524.8387	1965
% 526.9357	1135
% 528.4497	31203
% 559.7197	1136
% 561.0807	94517



