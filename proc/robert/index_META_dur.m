function [durations,logical_dur]=index_META_dur(META_struct,durIn)

% syntax [durations,logical_dur]=index_META_dur(META_struct,durIn);
%
% indexes a META_struct data digest, looking for files whose meta.duration
% parameter maches durIn (s).
%
%   INPUT:
%
%       durIn   -   1 or 2 element vector
%                       1 element:  duration must be greater than this
%                                   number
%                       2 elements: duration must be between the two given
%                                   numbers

if length(durIn)==1
    durIn=[durIn, Inf];
end

durFlag=zeros(length(META_struct),1);
m=1;
for n=1:length(META_struct)
    durFlag(n)=META_struct(n).meta.duration >= durIn(1) && ...
        META_struct(n).meta.duration <= durIn(2);
    if durFlag(n)
        durations(m)=META_struct(n).meta.duration;
        m=m+1;
    end
end

if nargout > 1
    logical_dur=durFlag;
end
