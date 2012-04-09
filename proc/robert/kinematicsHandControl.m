function [PL,TTT,hitRate,hitRate2,speedProfile,pathReversals]=kinematicsHandControl(out_struct,opts)

% syntax [PL,TTT,hitRate,hitRate2,speedProfile,pathReversals]=kinematicsHandControl(out_struct,opts);
%
% calculates the path length & time-to-target for each 
% successful trial (RW) in a out_struct-formatted out_struct
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
%
% hitRate2 is (aborts+rewards)/trials since both successfully reached
% the target.  hitRate is just rewards/trials
%
% speedProfile a cell array, each cell contains the speedProfile for 1
% trial.

if nargin==1
    opts.version=2;             % assume target_entry_word is present
end

if opts.version==1              % if target_entry_word is not present,
    hold_time=opts.hold_time;   % must supply hold time
    target_entry_word=49;       % delay between completion of 1 reach 
else                            % and target presentation of next has been
                                % found to be reliable in testing.
    hold_time=0;
    target_entry_word=160;
end

% % determine number of targets.  Pick the last successful trial; if the
% % success code is there we know it completes, and being the last trial it
% % probably has a valid beginning.
% succesTrialEnd=find(out_struct.words(:,2)==32,1,'last');
% succesTrialStart=find(out_struct.words(1:succesTrialEnd,2)==18,1,'last');
% numTargets=nnz(out_struct.words(succesTrialStart:successTrialEnd,2)==target_entry_word);

% make sure to start with the first complete trial in the recording
beginFirstTrial=find(out_struct.words(:,2)==18,1,'first');
if beginFirstTrial > 1
    out_struct.words(1:beginFirstTrial-1,:)=[];
end
% make sure to end with the last complete trial in the recording 
% all of the following codes are valid trial-end codes: success (32),
% abort (33), fail (34)
endLastTrial=find(out_struct.words(:,2)==32 | out_struct.words(:,2)==33 | out_struct.words(:,2)==34,1,'last');  
if endLastTrial < size(out_struct.words,1)
    out_struct.words(endLastTrial+1:end,:)=[];
end

% to avoid problems in brain control files where there can be exit &
% re-entry without a trial reset (e.g. aborts disabled), only take the
% first confirmed successful reach following trial initiation.
% trial initiation:
trialOnset=find(out_struct.words(:,2)==18);
% this should never happen, unless there's a glitch in the system or the
% recording was cut off just exactly between the trial initiation word and
% the presentation of the first target (should be exceedingly rare):
trialOnset(out_struct.words(trialOnset+1,2)~=49)=[];
% the first reach to the first target of a trial (the only reach, in brain 
% control) never reached the target (i.e., an abort/fail):
numAfirst=nnz(out_struct.words(trialOnset+2,2)==33);
trialOnset(out_struct.words(trialOnset+2,2)~=target_entry_word)=[];
% for v1, the above code cuts out aborts on the first reach (hand control).  
% for v2, an extra step is required to cut out aborts on the first reach.
if opts.version==2
    numAfirst=nnz(out_struct.words(trialOnset+3,2)==33);
    trialOnset(out_struct.words(trialOnset+3,2)==33)=[];
end
% if there was an abort on the 1st trial, it will be removed from
% trialOnset, and thus when hitRates are tallied up these trials will not
% be counted as successes.  Leaving the flag in place means those trials
% will be counted as aborts/fails, and the success trials + the abort/fail
% trials should add up to all the trials.  EXCEPT...
% if an abort occurs on a reach later than the first one (this 
% can only happen during hand control), that trial will
% be counted as a success (since kinematics are only calculated on the
% first reach of a trial), but also as an abort because the 33 flag is
% still there.  So, we want to ignore these trials.  Since
% kinematics calculations should only depend on trialOnset, which is not
% modified, kinematics values should be unaffected by this action.

% hold_time will be subtracted below
startEndReachesMatrix=out_struct.words(sort([trialOnset+1; trialOnset+2]),:);

% % don't let things start (or end) on the wrong note.
% if startEndReachesMatrix(1,2)==target_entry_word, startEndReachesMatrix(1,:)=[]; end
% if startEndReachesMatrix(end,2)==49, startEndReachesMatrix(end,:)=[]; end

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
speedProfile=cell(size(start_reaches));
pathReversals=zeros(size(start_reaches));
for n=1:length(start_reaches)
	included_points=find(out_struct.pos(:,1)>=start_reaches(n) & ...
		out_struct.pos(:,1)<=end_reaches(n));    
    
    % experience teaches that when normalizing PL, TTT it's necessary to
    % ensure that there are enough included_points to ensure lucky
    % successes (where the target randomly appeared on top of where the
    % cursor already was) are not counted.
	if length(included_points)>2
        % for the path reversals analysis, will have need of a vector pointing
        % from the origination point of the movement to the termination point
        % of the movment, against which all path segments will be projected to
        % determine their velocity along this vector.
        PosTvx=out_struct.pos(included_points([1 length(included_points)]),2);
        PosTvy=out_struct.pos(included_points([1 length(included_points)]),3);
        PosTv=[diff(PosTvx) diff(PosTvy)];
    
        CposAlongT=zeros(length(included_points)-1,1);
        CvelAlongT=CposAlongT;

%         figure, plot(out_struct.pos(included_points,2),out_struct.pos(included_points,3))
%         hold on, plot(PosTvx,PosTvy,'g')

        for k=2:length(included_points)
            PLpoint=sqrt((out_struct.pos(included_points(k),2)- ...
                out_struct.pos(included_points(k-1),2))^2 + ...
                (out_struct.pos(included_points(k),3)- ...
                out_struct.pos(included_points(k-1),3))^2);
            
            PL(n)=PL(n)+PLpoint;
            
            % path reversals.  Find the current 2-point cursor position 
            % vector PosCv.
            PosCvx=out_struct.pos(included_points(k-1:k),2);
            PosCvy=out_struct.pos(included_points(k-1:k),3);
            PosCv=[diff(PosCvx) diff(PosCvy)];

%             plot(PosCvx,PosCvy,'LineWidth',2,'Color',rand(1,3))

            CposAlongT(k-1)=dot(PosCv,PosTv)/sqrt(sum(PosTv.^2));            
        end
        CvelAlongT=rowBoat(CposAlongT)./rowBoat(diff(out_struct.pos(included_points,1)));
        % path reversals for the trial is the number of negative-going 
        % zero crossings
        pathReversals(n)=nnz(CvelAlongT(2:end)<0 & CvelAlongT(1:end-1)>=0);
        speedProfile{n}=sqrt((out_struct.vel(included_points,2)).^2+ ...
            (out_struct.vel(included_points,3)).^2);
		% normalize by the straight-line distance between the start and end
		% points, as in Hatsopoulos paper.
		interTargetDistance=sqrt(sum(diff(out_struct.pos(included_points([1 end]),2:3)).^2));
		PL(n)=PL(n)/interTargetDistance;
		TTT(n)=(end_reaches(n)-start_reaches(n))/interTargetDistance;
        pathReversals(n)=pathReversals(n)/interTargetDistance;
	end
end
% exclude_trials corresponds to trials were length(included_points) < 2,
% therefore indicating that the target appeared on top of the cursor or was
% hit by it as a matter of chance most likely.  Exclude these altogether.
exclude_trials=find(PL==0);
PL(exclude_trials)=[];
TTT(exclude_trials)=[];
speedProfile(exclude_trials)=[];
pathReversals(exclude_trials)=[];

% success trials are success trials, whether they were successful by
% accident or by design.  Success-by-accident never happens under hand
% control, but it sometimes does under brain control (marked by
% exclude_trials)
hitRate=length(trialOnset)/nnz(out_struct.words(:,2)==18);
if nargout > 3
    hitRate2=(length(trialOnset)+numAfirst)/nnz(out_struct.words(:,2)==18);
end
