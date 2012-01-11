function [PL,TTT,hitRate]=kinematicsHandControl(out_struct,opts)

% syntax PL=kinematicsHandControl(out_struct,opts);
%
% calculates the path length & time-to-target for each 
% successful trial (RW) in a BDF-formatted out_struct
%
% out_struct.words should follow something like
%
%     1.7975   18
%     1.8654   49
%     2.7623   49
%     3.5522   49
%     4.2851   49
%     5.1169   49
%     5.8098   49
%     6.4248   32
%    ...
%    40.2363   18
%    40.3043   49
%    40.4573   33
%
% for a successful (6-target) trial (code 32), followed some time later
% by a new trial that ended with an abort (code 33) after the 
% presentation of the first target (code 49).  
% out_struct.words(...,2)=[18; 49; 18] would be a timeout.  
%
% opts is a structure to deal with versioning, since the original (up until
% 9/2011) RW task had no code for target entry.  In that case, this function
% must be supplied the hold time applicable for the recording.  
% opts should have, at minimum, the field 'version', and a number.  
% As of 09/22/2011, version can be 1 or 2. v2 is the default.  
% v1 requires an additional field, hold_time, to be present.

if nargin==1
    opts.version=2;             % assume target_entry_word is present
end

if opts.version==1              % if target_entry_word is not present,
    hold_time=opts.hold_time;   % must supply hold time
    target_entry_word=32;
else
    hold_time=0;
    target_entry_word=160;
end

% extract times of occurrences of target_entry_word, and 1 
% target_presentation word that preceeded each occurrence.

if out_struct.words(1,2)==32
    % account for the freak accident where the very first recorded event is
    % a success indicator with no trial begin or target presentation
    % preceeding it.
    out_struct.words(1,:)=[];
end

% make sure to start with the first complete trial in the recording
beginFirstTrial=find(out_struct.words(:,2)==18,1,'first');
if beginFirstTrial > 1
    out_struct.words(1:beginFirstTrial-1,:)=[];
end
% make sure to end with the last complete trial in the recording
endLastTrial=find(out_struct.words(:,2)==32,1,'last');
if endLastTrial < size(out_struct.words,1)
    out_struct.words(endLastTrial+1:end,:)=[];
end
hitRate=nnz(out_struct.words(:,2)==32)/nnz(out_struct.words(:,2)==18);

startEndReachesMatrix=out_struct.words(sort([find(out_struct.words(:,2)==target_entry_word); ...
    find(out_struct.words(:,2)==target_entry_word)-1]),:);
% don't let things start (or end) on the wrong note.
if startEndReachesMatrix(1,2)==target_entry_word, startEndReachesMatrix(1,:)=[]; end
if startEndReachesMatrix(end,2)==49, startEndReachesMatrix(end,:)=[]; end

% start_reaches=out_struct.words(diff(out_struct.words(:,2))==0 | ...
% 	diff(out_struct.words(:,2))==-17,1);
% end_reaches=out_struct.words(find(diff(out_struct.words(:,2))==0 | ...
% 	diff(out_struct.words(:,2))==-17)+1,1);

if mod(size(startEndReachesMatrix,1),2)
    error('kinematicsHandControl:badStartEndReaches', ...
        'malformed matrix of start reach / end reach pairs')
end

start_reaches=startEndReachesMatrix(1:2:end,1);
end_reaches=startEndReachesMatrix(2:2:end,1)-hold_time;

disp('Normalizing path length, time-to-target')
disp('Requiring >2 time points to be included in the reach')
% see below

PL=zeros(size(start_reaches));
TTT=zeros(size(start_reaches));
for n=1:length(start_reaches)
	included_points=find(out_struct.pos(:,1)>=start_reaches(n) & ...
		out_struct.pos(:,1)<=end_reaches(n));
    % experience teaches that when normalizing PL, TTT it's necessary to
    % ensure that there are enough included_points to ensure lucky
    % successes (where the target randomly appeared on top of where the
    % cursor already was) are not counted.
	if length(included_points)>2
		for k=2:length(included_points)
			PL(n)=PL(n)+ ...
				sqrt((out_struct.pos(included_points(k),2)-out_struct.pos(included_points(k-1),2))^2 + ...
				(out_struct.pos(included_points(k),3)-out_struct.pos(included_points(k-1),3))^2);
		end
		% normalize by the straight-line distance between the start and end
		% points, as in Hatsopoulos paper.
		interTargetDistance=sqrt(sum(diff(out_struct.pos(included_points([1 end]),2:3)).^2));
		PL(n)=PL(n)/interTargetDistance;
		TTT(n)=(end_reaches(n)-start_reaches(n))/interTargetDistance;
	end
end
% PL(PL==0)=[];
% TTT(TTT==0)=[];
