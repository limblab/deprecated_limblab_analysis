function [PL,TTT,hitRate,hitRate2,speedProfile,pathReversals,trialTS,interTargetDistance,slidingAccuracy,slidingTime]=kinematicsHandControl2(out_struct,opts)

% syntax [PL,TTT,hitRate,hitRate2,speedProfile,pathReversals,trialTS,interTargetDistance,slidingAccuracy,slidingTime]=kinematicsHandControl2(out_struct,opts);
%
% calculates the path length & time-to-target for each trial (RW) in a 
% out_struct-formatted BDF
%
% v2 calculates stats for all trials, including fail trials but not aborts
% 
% out_struct.words in the RW should follow something like
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
% out_struct.words(:,2)=[18; 49; 35; 18] would be a timeout on the first 
% trial of a hand control file. For failures of subsequent trials it would
% look like out_struct.words(:,2)=[18; 49; 160; 32; 18; 49; 34]
% The first kind of fail (fail on the first trial) is known as an
% incomplete, and is the only kind of fail that is represented in the brain
% control files.  The second type of failure is called a fail, and can show
% up only for hand control files.
%
% opts is a structure to deal with versioning, since the original (up until
% 9/2011) RW task had no code for target entry.  In that case, this function
% must be supplied the hold time applicable for the recording.  
% opts should have, at minimum, the field 'version', and a number.  
% As of 09/22/2011, version can be 1 or 2. v2 is the default.  
% v1 requires an additional field, hold_time, to be present.
%
% hitRate2 is (aborts+rewards+fails)/trials since both successfully reached
% the target.  hitRate is just (rewards+fails)/trials
%
% speedProfile a cell array, each cell contains the speedProfile for 1
% trial.
%
% slidingAccuracy is a moving average of sucesses, with a window size of
% 20.

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

if nargout < 8
    % don't worry about it
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
% abort (33), fail (34), incomplete (35)
endLastTrial=find(out_struct.words(:,2)==32 | out_struct.words(:,2)==33 | ...
    out_struct.words(:,2)==34 | out_struct.words(:,2)==35,1,'last');  
if endLastTrial < size(out_struct.words,1)
    out_struct.words(endLastTrial+1:end,:)=[];
end
% if the last file is a an incomplete (35), then the attempt to remove
% aborts, below, will error because the last trial doesn't have an 
% onset(n)+3, only an [18; 49; 35].  Just duplicate the last line, to avoid
% the error or having to treat the last trial different from all the rest
% later on in the code.
if out_struct.words(endLastTrial,2)==35
    out_struct.words(endLastTrial+1,:)=out_struct.words(endLastTrial,:);
end

% to avoid problems in brain control files where there can be exit &
% re-entry without a trial reset (e.g. aborts disabled), only take the
% first confirmed successful reach following trial initiation.
% trial initiation:
trialOnset=find(out_struct.words(:,2)==18);
% the following should never happen, unless there's a glitch in the system or the
% recording was cut off just exactly between the trial initiation word and
% the presentation of the first target (should be exceedingly rare):
trialOnset(out_struct.words(trialOnset+1,2)~=49)=[];
TO_original=trialOnset;
% the first reach to the first target of a trial (the only reach, in brain 
% control) was an abort.  Horrors!  For opts v1, this is the only code
% necessary to track aborts.  For opts v2, this will be empty every time.
numAfirst=nnz(out_struct.words(trialOnset+2,2)==33);
if ~opts.includeFails
    % This line cuts out fails and incompletes for both hand and brain 
    % control.  It works because only for fails,incompletes are the 
    % target_entry_word completely absent.  For success,abort reaches, the
    % target_entry_word is always there.
    trialOnset(out_struct.words(trialOnset+2,2)~=target_entry_word)=[];
end
% TO_nofail=trialOnset;
% for opts v2, an extra step is required to cut out aborts on the first reach.
if opts.version==2
    numAfirst=nnz(out_struct.words(trialOnset+3,2)==33);
    trialOnset(out_struct.words(trialOnset+3,2)==33)=[];
end
% When reading the following, keep in mind: a "trial" includes all the
% targets and all the reaches between a trial start code (18) and a trial
% end code (32|33|34|35).  Now...
% If there was an abort on the 1st trial, it will be removed from
% trialOnset, and thus when hitRates are tallied up these trials will not
% be counted as successes.  Leaving the flag in place means those trials
% will be counted as aborts/fails, and the success trials + the abort/fail
% trials should add up to all the trials.  EXCEPT...
% if an abort occurs on a reach later than the first one, but still within
% the first trial (this can only happen during hand control), that trial will
% be counted as a success (since kinematics are only calculated on the
% first reach of a trial), but also as an abort because the 33 flag is
% still there.  So, we want to ignore these trials.  Since
% kinematics calculations should only depend on trialOnset, which is not
% modified, kinematics values should be unaffected by this action.

% since a fail (34) trial still has a successful first reach, and 
% since we only calculate kinematics on first reache of any given trial,
% the fail (34) trials were never excluded from the kinematics calculations
% (these can only occur during hand control).  Incomplete (35) trials are
% what will change the length of the TT,PL, etc. vectors.  

% compute a sliding window average of succeses
windowSize=20;
slidingAccuracy=zeros(numel(TO_original)-windowSize,1);
slidingTime=slidingAccuracy;
for n=windowSize:length(TO_original)
    slidingAccuracy(n-windowSize+1)= ...              % TO_nofail  
        length(intersect(TO_original(n-windowSize+1:n),trialOnset))/windowSize;
    slidingTime(n-windowSize+1)= ...
        mean(out_struct.words(TO_original(n-windowSize+1:n),1));
end

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
end_reaches=startEndReachesMatrix(2:2:end,1)-hold_time; % see line 61.  Not an error.

if isempty(start_reaches)
    % probably a CO file
    [start_reaches,end_reaches,hitRate,hitRate2,~,~, ...
        slidingAccuracy,slidingTime]=COtrialTimes(out_struct);
    if isempty(start_reaches) % or, could be an error.
        PL=[];
        TTT=[];
        hitRate=0;
        hitRate2=0;
        speedProfile=cell(1,1);
        pathReversals=[];
        trialTS=[];
        interTargetDistance=[];
%         error('kinematicsHandControl:badStartEndReaches', ...
%         'malformed matrix of start reach / end reach pairs')
    end
end


disp('Normalizing path length, time-to-target')
disp('Requiring >2 time points to be included in the reach')

PL=zeros(size(start_reaches));
TTT=zeros(size(start_reaches));
speedProfile=cell(size(start_reaches));
pathReversals=zeros(size(start_reaches));
interTargetDistance=zeros(size(start_reaches));
% temporary
% assignin('base','kinReachTimes',end_reaches)
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
		interTargetDistance(n)=sqrt(sum(diff(out_struct.pos(included_points([1 end]),2:3)).^2));
		PL(n)=PL(n)/interTargetDistance(n);
		TTT(n)=(end_reaches(n)-start_reaches(n))/interTargetDistance(n);
        pathReversals(n)=pathReversals(n)/interTargetDistance(n);
	end
end
% exclude_trials corresponds to trials where length(included_points) < 2,
% therefore indicating that the target appeared on top of the cursor or was
% hit by it as a matter of chance most likely.  Exclude these from
% consideration for kinematics properties.
exclude_trials=find(PL==0);
PL(exclude_trials)=[];
TTT(exclude_trials)=[];
speedProfile(exclude_trials)=[];
pathReversals(exclude_trials)=[];
interTargetDistance(exclude_trials)=[];

if exist('hitRate','var')~=1 % if CO, hitRate and hitRate2 were already calculated.
    % success trials are success trials, whether they were successful by
    % accident or by design.  Use quantities that pre-date exclude_trials in
    % order to score hitRates
    hitRate=length(trialOnset)/nnz(out_struct.words(:,2)==18);
    if nargout > 3
        hitRate2=(length(trialOnset)+numAfirst)/nnz(out_struct.words(:,2)==18);
    end
end

trialTS=[out_struct.words(trialOnset,1) start_reaches end_reaches];
% check
trialTS(exclude_trials,:)=[];
