function [Trial] = parseTrials(out_struct,fp,fpstarttime,ts)

% To Do -
% - make window around movement onset and reward a variable instead
%   of hard coded

% Have to do this check because Chewie's max trial time was 15 sec, and
% Mini and Jaco's are 25.
if regexp(out_struct.meta.filename,'Chewie')
    MaxTrialTime = 15;
else
    MaxTrialTime = 25;
end

% Find beginning of all trials
FirstTrialInds=find(out_struct.words(:,2)==17);
GoInds=find(out_struct.words(:,2)==49);
if isempty(GoInds) == 0
    if GoInds(end) + 1 > length(out_struct.words)
        GoInds(end) = [];
    end
end

if size(out_struct.words,1) < 2
    Trial = [];
    return
end
GoSuccessInds = GoInds(out_struct.words(GoInds + 1,2) == 32);
GoFailInds = GoInds(out_struct.words(GoInds + 1,2) == 34);
GoIncompleteInds = GoInds(out_struct.words(GoInds + 1,2) == 35);

SuccessTrialInds = find(out_struct.words(:,2)==32);
Trial.SuccessTrialInds = SuccessTrialInds;
FailTrialInds = find(out_struct.words(:,2)==34);
Trial.FailTrialInds = FailTrialInds;
IncompleteTrialInds = find(out_struct.words(:,2)==35);
Trial.IncompleteTrialInds = IncompleteTrialInds;

% remove last trial in case trial is cut off or short
if isempty(FirstTrialInds) == 1
    FirstTrialInds = find(out_struct.words(:,2)==18);
    if  isempty(FirstTrialInds) ==0
        disp('This is a random walk file')
    end
    return
end

%% Calculate move times for successful trials
gotimes = out_struct.words(GoSuccessInds,1);
Successtimes = out_struct.words(SuccessTrialInds,1);
words = out_struct.words;
windowStart = 3;
windowEnd = 2;

if isempty(GoSuccessInds) == 0 & length(GoSuccessInds) >= 1
    try
    [SuccessMovetimes,SuccessTrialInds,Successtimes,MaxVelT]= moveonsetfromBDF_MRS(out_struct.vel,gotimes,Successtimes,SuccessTrialInds,words,windowStart,windowEnd);
    
    SuccessTrialInds(SuccessMovetimes < windowStart) = [];
    SuccessTrialInds(SuccessTrialInds <= 3) = [];
    % Successtimes(SuccessMovetimes < windowStart) = [];
    SuccessMovetimes(SuccessMovetimes <= windowStart) = [];
    MaxVelT(MaxVelT < windowStart) = [];
    
    GoSuccessInds(gotimes <= windowStart) = [];
    gotimes(gotimes <= windowStart) = [];
    
    GoSuccessInds(gotimes > out_struct.vel(end,1)-3) = [];
    end
end
%% Calc move times for failed trials
if isempty(GoFailInds) == 0 & length(GoFailInds) >= 1
    gotimes = out_struct.words(GoFailInds,1);
    Failtimes = out_struct.words(FailTrialInds,1);
    try
        [FailMovetimes,FailTrialInds,Failtimes,MaxVelFailT]=moveonsetfromBDF_MRS(out_struct.vel,gotimes,Failtimes,FailTrialInds,words,windowStart,windowEnd);
        FailTrialInds(FailMovetimes < windowStart) = [];
        FailTrialInds(FailTrialInds <= 3) = [];
        %     Failtimes(FailMovetimes < windowStart) = [];
        FailMovetimes(FailMovetimes < windowStart) = [];
%         MaxVelFailT(MaxVelFailT < windowStart) = [];
    end
end

%% Calc move times for incomplete trials
if isempty(GoIncompleteInds) == 0 & length(GoIncompleteInds) >= 1
    gotimes = out_struct.words(GoIncompleteInds,1);
    Incompletetimes = out_struct.words(IncompleteTrialInds,1);
    try
        [IncompleteMovetimes, IncompleteTrialInds,Incompletetimes,MaxVelIncmpT]=moveonsetfromBDF_MRS(out_struct.vel,gotimes,Incompletetimes,IncompleteTrialInds,words,windowStart,windowEnd);
        IncompleteTrialInds(IncompleteMovetimes < windowStart) = [];
        IncompleteTrialInds(IncompleteTrialInds <= 3) = [];
        %     Incompletetimes(IncompleteMovetimes < windowStart) = [];
        IncompleteMovetimes(IncompleteMovetimes < windowStart) = [];
%         MaxVelIncmpT(MaxVelIncmpT < windowStart) = [];
    end
end
% plotIt = 0;
j = 1;
n = 1;
l = 1;
t = 1;
Alloffsets = 0;
offset = 0;
goOffset = 0;

TrialWTargetWord = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TempTargetID = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);

TrialStartIndexFP = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TrialStartIndexKin = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TrialEndIndexFP = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);

%% Parse successful trials
if exist('SuccessMovetimes','var')
    for i = 1:length(SuccessTrialInds)
        
        if i + goOffset > length(GoSuccessInds)
            Trial.goOffset = goOffset;
            Trial.offset = offset;
            continue
        end
        
        if i+offset > length(SuccessTrialInds)
            Trial.offset = offset;
            Trial.goOffset = goOffset;
            continue
        end
        if  round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 64 || ...
                round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 65 ||...
                round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 66 || ...
                round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 67
            %words 64-65 indicate outer target on
            TempTargetID(j) = out_struct.words(SuccessTrialInds(i+offset)-2,2);
            TimeStart = eval(vpa(out_struct.words(SuccessTrialInds(i+offset)-2,1),6));
            TrialWTargetWord(j) = 1;
            
        elseif  round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 64 || ...
                round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 65 ||...
                round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 66 || ...
                round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 67
            
            TempTargetID(j) = out_struct.words(SuccessTrialInds(i+offset)-2,2);
            TimeStart = eval(vpa(out_struct.words(SuccessTrialInds(i+offset)-3,1),6));
            TrialWTargetWord(j) = 1;
        end
        
        if TrialWTargetWord(i) == 1 % Ran into a weird
            % 2/5/14 bug where there was a reward without any Go cue
            % word (49) or the outer target ON word itself (64-67)
            
            
            % MRS 5/29/14 Added this logic because the TrialEndIndex
            % exceeded the length of the fp matrix
            
            % Determine start index of FP trial segment to extract centered on
            % movement onset
            
            
            % Determine start index of FP trial segment to extract centered on
            % maximum velocity
%             TrialMVIndexFP(j) = round((MaxVelT(t)-fpstarttime)/.001);
            
            
            TimeGo = eval(vpa(out_struct.words(GoSuccessInds(i+goOffset),1),6));
            TimeEnd = eval(vpa(out_struct.words(SuccessTrialInds(i+offset),1),6));
            
            if TimeGo < TimeEnd
                %% Begin checking that go cue and reward cue are appropriately matched up
                if TimeEnd - TimeGo < MaxTrialTime
                    % Calculate time to target (TTT) by subtracting go time from reward
                    % time
                    Trial.TTT(t) = TimeEnd - TimeGo;
                    Trial.TargetID(t) = TempTargetID(j);
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1 % If HC (increment is 1 ms)
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                        
                        Trial.Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        Trial.Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                    else %If BC increment is 50 ms
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                        
                        Trial.Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        Trial.Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                    end
                    
                    
                    Trial.Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    
                    
                else
                    %% If the go cue appears too early find the next one that matches
                    % If the go cue is way too early look to see if a later go
                    % cue matches up better
                    %                 goOffset= 0; % Need to reset offset in each loop iteration
                    % since the counter 'i' is incremented in each loop anyway,
                    % otherwise you will end up skipping trials.
                    while TimeEnd - TimeGo > MaxTrialTime
                        goOffset = goOffset + 1;
                        if i + goOffset > length(GoSuccessInds)
                            Trial.goOffset = goOffset;
                            Trial.offset = offset;
                            break
                        end
                        TimeGo = eval(vpa(out_struct.words(GoSuccessInds(i+goOffset),1),6));
                        
                    end
                    
                    % Get out of this loop if offset exceeds length of trial
                    % indexes
                    if isfield(Trial,'offset')
                        break
                    end
                    
                    if TimeEnd - TimeGo < MaxTrialTime && TimeEnd - TimeGo > 0
                        
                        Trial.TTT(t) = TimeEnd - TimeGo;
                        Trial.TargetID(t) = TempTargetID(j);
                        
                        if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                            
                            Trial.Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                            Trial.Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        else
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                            
                            Trial.Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                            Trial.Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        end
                        Trial.Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                        Trial.Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    end
                end
            else
                %% If a go time is missing or misaligned, skip forward in reward
                % time until you find one that matches up
                
                %             offset = 0; % Need to reset offset in each loop iteration
                % since the counter 'i' is incremented in each loop anyway,
                % otherwise you will end up skipping trials.
                while TimeGo > TimeEnd
                    offset = offset + 1;
                    if i+offset > length(SuccessTrialInds)
                        Trial.offset = offset;
                        Trial.goOffset = goOffset;
                        break
                    end
                    TimeEnd = eval(vpa(out_struct.words(SuccessTrialInds(i+offset),1),6));
                    
                end
                % Get out of this loop if offset exceeds length of trial
                % indexes
                if isfield(Trial,'offset')
                    break
                end
                
                %Correct the reward target ID and start time for this offset
                % ** This logic could be smarter by using find in a clever
                % way **
                if  round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 64 || ...
                        round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 65 ||...
                        round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 66 || ...
                        round(out_struct.words(SuccessTrialInds(i+offset)-2,2)) == 67
                    %words 64-65 indicate outer target on
                    
                    TempTargetID(j) = out_struct.words(SuccessTrialInds(i+offset)-2,2);
                    TimeStart = eval(vpa(out_struct.words(SuccessTrialInds(i+offset)-2,1),6));
                    Trial.TargetID(t) = TempTargetID(j);
                    
                elseif  round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 64 || ...
                        round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 65 ||...
                        round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 66 || ...
                        round(out_struct.words(SuccessTrialInds(i+offset)-3,2)) == 67
                    
                    TempTargetID(j) = out_struct.words(SuccessTrialInds(i+offset)-3,2);
                    TimeStart = eval(vpa(out_struct.words(SuccessTrialInds(i+offset)-3,1),6));
                    Trial.TargetID(t) = TempTargetID(j);
                end
                
                if TimeEnd - TimeGo < MaxTrialTime && TimeEnd - TimeGo > 0 % Make sure go cue matches up to
                    % proper reward and not next trials' reward
                    Trial.TTT(t) = TimeEnd - TimeGo;
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                        
                        Trial.Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        Trial.Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                    else
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                        
                        Trial.Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        Trial.Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                    end
                    Trial.Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                end
            end
            
            % Now extract those segments
            TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
            TrialStartIndexFP(j) = round((TimeGo-fpstarttime)/.001);
            
            if TrialEndIndexFP(j) < length(fp)
                for B = 1:size(fp,3)
                    Trial.FPstart{t,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
%                     Trial.FPMaxV{t,B} = fp(TrialMVIndexFP(j)-2000:TrialMVIndexFP(j)+2000,1,B);
                    Trial.FPend{t,B} = fp(TrialStartIndexFP(j):TrialEndIndexFP(j)+2000,1,B);
                end
            else
                j = j+1;
                t = t+1;
                %             offset = 0;
                %             goOffset = 0;
                continue
            end
            % In case there's no spikes at the end of this trial
            % MRS 2/7/14
            StartTrial_SpikeTimes = ts((ts >= TimeGo-2 & ts<=TimeGo+2)) - (TimeGo);
%             MaxVTrial_SpikeTimes = ts((ts >= MaxVelT(t)-2 & ts<=MaxVelT(t)+2)) - (MaxVelT(t));
            EndTrial_SpikeTimes = ts((ts >= TimeGo & ts<=TimeEnd+2)) - (TimeEnd);
            if isempty(EndTrial_SpikeTimes) == 0
                Trial.tsstart(t).times = StartTrial_SpikeTimes;
%                 Trial.tsMaxV(t).times = MaxVTrial_SpikeTimes;
                Trial.tsend(t).times = EndTrial_SpikeTimes;
            else
                Trial.tsstart(t).times = [];
%                 Trial.tsMaxV(t).times = [];
                Trial.tsend(t).times = [];
            end
            %% Don't really need this section but keeping it so I don't have to edit other code
            if t <= length(SuccessMovetimes) && TrialWTargetWord(i) == 1
                
                
                % Check if HC or BC by looking at increment in kinematic variable (1 ms --HC, 50 ms --BC)
                if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                    TrialStartIndexKin(j) = round((SuccessMovetimes(t)-1)/.001);
%                     TrialMVIndexKin(j) = round((MaxVelT(t)-fpstarttime)/.001);
                    
                    if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 
%                             TrialMVIndexKin(j)+2000 > length(out_struct.pos) | TrialMVIndexKin(j)-2000 < 0
                        % If HC trial index goes past end of file, skip it
                        j = j+1;
                        t = t+1;
                        continue
                    else
                        % 2000 is size of window around movement onset, should
                        % make this a variable instead of hard coding it
                        Trial.Path_MO{t} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                        Trial.Vel_MO{t} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                        
%                         Trial.Path_MV{t} = out_struct.pos(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
%                         Trial.Vel_MV{t} = out_struct.vel(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
                    end
                else
                    TrialStartIndexKin(j) = round((SuccessMovetimes(t)-1)/.05);
%                     TrialMVIndexKin(j) = round((MaxVelT(t)-fpstarttime)/.05);
                    
                    % If BC trial index goes past end of file, or before beginning skip it
                    if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0
%                             TrialMVIndexKin(j)+40 > length(out_struct.pos) | TrialMVIndexKin(j)-40 < 0
                        j = j+1;
                        t = t+1;
                        continue
                    else
                        Trial.Path_MO{t} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                        Trial.Vel_MO{t} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                        
%                         Trial.Path_MV{t} = out_struct.pos(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
%                         Trial.Vel_MV{t} = out_struct.vel(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
                    end
                end
                Trial.TargetID(t) = TempTargetID(j);
                
                %% Begin useful code again
            else
                % Trial is too close to end of file to be of interest
                j = j+1;
                t = t+1;
                continue
            end
            
        else
            j = j+1;
            t = t+1;
            %         offset = 0;
            %         goOffset = 0;
            continue
        end
        
        clear TimeStart_OTargetOn
        %     offset = 0;
        %     goOffset = 0;
        t = t+1;
        j = j +1;
        
    end
end
% Reset Counters
j = 1;
t = 1;
offset = 0;
goOffset = 0;
%% Now parse Incomplete Trials
if exist('IncompleteMovetimes','var')
    for i = 1:length(IncompleteTrialInds)
        
        if i + goOffset > length(GoIncompleteInds)
            Trial.Incomplete_goOffset = goOffset;
            Trial.Incomplete_offset = offset;
            continue
        end
        
        if i+offset > length(IncompleteTrialInds)
            Trial.Incomplete_offset = offset;
            Trial.Incomplete_goOffset = goOffset;
            continue
        end
        if  round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 64 || ...
                round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 65 ||...
                round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 66 || ...
                round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 67
            %words 64-65 indicate outer target on
            TempTargetID(j) = out_struct.words(IncompleteTrialInds(i+offset)-2,2);
            TimeStart = eval(vpa(out_struct.words(IncompleteTrialInds(i+offset)-2,1),6));
            TrialWTargetWord(j) = 1;
            
        elseif  round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 64 || ...
                round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 65 ||...
                round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 66 || ...
                round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 67
            
            TempTargetID(j) = out_struct.words(IncompleteTrialInds(i+offset)-2,2);
            TimeStart = eval(vpa(out_struct.words(IncompleteTrialInds(i+offset)-3,1),6));
            TrialWTargetWord(j) = 1;
        end
        
        if TrialWTargetWord(i) == 1 % Ran into a weird
            % 2/5/14 bug where there was a reward without any Go cue
            % word (49) or the outer target ON word itself (64-67)
            
            
            % MRS 5/29/14 Added this logic because the TrialEndIndex
            % exceeded the length of the fp matrix
            
            % Determine start index of FP trial segment to extract centered on
            % movement onset
            TrialStartIndexFP(j) = round((IncompleteMovetimes(t)-fpstarttime-1)/.001);
            
            % Determine start index of FP trial segment to extract centered on
            % maximum velocity
%             TrialMVIndexFP(j) = round((MaxVelT(t)-fpstarttime)/.001);
            
            
            TimeGo = eval(vpa(out_struct.words(GoIncompleteInds(i+goOffset),1),6));
            TimeEnd = eval(vpa(out_struct.words(IncompleteTrialInds(i+offset),1),6));
            
            if TimeGo < TimeEnd
                %% Begin checking that go cue and reward cue are appropriately matched up
                if TimeEnd - TimeGo < MaxTrialTime
                    % Calculate time to target (TTT) by subtracting go time from reward
                    % time
                    Trial.Incomplete_TTT(t) = TimeEnd - TimeGo;
                    Trial.Incomplete_TargetID(t) = TempTargetID(j);
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1 % If HC (increment is 1 ms)
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                        
                        Trial.Incomplete_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        Trial.Incomplete_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                    else %If BC increment is 50 ms
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                        
                        Trial.Incomplete_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        Trial.Incomplete_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                    end
                    
                    
                    Trial.Incomplete_Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Incomplete_Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    
                    
                else
                    %% If the go cue appears too early find the next one that matches
                    % If the go cue is way too early look to see if a later go
                    % cue matches up better
                    %                 goOffset= 0; % Need to reset offset in each loop iteration
                    % since the counter 'i' is incremented in each loop anyway,
                    % otherwise you will end up skipping trials.
                    while TimeEnd - TimeGo > MaxTrialTime
                        goOffset = goOffset + 1;
                        if i + goOffset > length(GoIncompleteInds)
                            Trial.Incomplete_goOffset = goOffset;
                            Trial.Incomplete_offset = offset;
                            break
                        end
                        TimeGo = eval(vpa(out_struct.words(GoIncompleteInds(i+goOffset),1),6));
                        
                    end
                    
                    % Get out of this loop if offset exceeds length of trial
                    % indexes
                    if isfield(Trial,'offset')
                        break
                    end
                    
                    if TimeEnd - TimeGo < MaxTrialTime && TimeEnd - TimeGo > 0
                        
                        Trial.Incomplete_TTT(t) = TimeEnd - TimeGo;
                        Trial.Incomplete_TargetID(t) = TempTargetID(j);
                        
                        if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                            
                            Trial.Incomplete_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                            Trial.Incomplete_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        else
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                            
                            Trial.Incomplete_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                            Trial.Incomplete_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        end
                        Trial.Incomplete_Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                        Trial.Incomplete_Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    end
                end
            else
                %% If a go time is missing or misaligned, skip forward in reward
                % time until you find one that matches up
                
                %             offset = 0; % Need to reset offset in each loop iteration
                % since the counter 'i' is incremented in each loop anyway,
                % otherwise you will end up skipping trials.
                while TimeGo > TimeEnd
                    offset = offset + 1;
                    if i+offset > length(IncompleteTrialInds)
                        Trial.Incomplete_offset = offset;
                        Trial.Incomplete_goOffset = goOffset;
                        break
                    end
                    TimeEnd = eval(vpa(out_struct.words(IncompleteTrialInds(i+offset),1),6));
                    
                end
                % Get out of this loop if offset exceeds length of trial
                % indexes
                if isfield(Trial,'Incomplete_offset')
                    break
                end
                
                %Correct the reward target ID and start time for this offset
                if  round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 64 || ...
                        round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 65 ||...
                        round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 66 || ...
                        round(out_struct.words(IncompleteTrialInds(i+offset)-2,2)) == 67
                    %words 64-65 indicate outer target on
                    
                    TempTargetID(j) = out_struct.words(IncompleteTrialInds(i+offset)-2,2);
                    TimeStart = eval(vpa(out_struct.words(IncompleteTrialInds(i+offset)-2,1),6));
                    Trial.Incomplete_TargetID(t) = TempTargetID(j);
                    
                elseif  round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 64 || ...
                        round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 65 ||...
                        round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 66 || ...
                        round(out_struct.words(IncompleteTrialInds(i+offset)-3,2)) == 67
                    
                    TempTargetID(j) = out_struct.words(IncompleteTrialInds(i+offset)-3,2);
                    TimeStart = eval(vpa(out_struct.words(IncompleteTrialInds(i+offset)-3,1),6));
                    Trial.Incomplete_TargetID(t) = TempTargetID(j);
                end
                
                if TimeEnd - TimeGo < MaxTrialTime && TimeEnd - TimeGo > 0 % Make sure go cue matches up to
                    % proper reward and not next trials' reward
                    Trial.Incomplete_TTT(t) = TimeEnd - TimeGo;
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                        
                        Trial.Incomplete_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        Trial.Incomplete_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                    else
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                        
                        Trial.Incomplete_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        Trial.Incomplete_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                    end
                    Trial.Incomplete_Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Incomplete_Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                end
            end
            
            % Now extract those segments
            TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
            TrialStartIndexFP(j) = round((TimeGo-fpstarttime)/.001);
            
            if TrialEndIndexFP(j) < length(fp)
                for B = 1:size(fp,3)
                    Trial.Incomplete_FPstart{t,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
%                     Trial.Incomplete_FPMaxV{t,B} = fp(TrialMVIndexFP(j)-2000:TrialMVIndexFP(j)+2000,1,B);
                    Trial.Incomplete_FPend{t,B} = fp(TrialStartIndexFP(j):TrialEndIndexFP(j)+2000,1,B);
                end
            else
                j = j+1;
                t = t+1;
                %             offset = 0;
                %             goOffset = 0;
                continue
            end
            % In case there's no spikes at the end of this trial
            % MRS 2/7/14
            StartTrial_SpikeTimes = ts((ts >= TimeGo-2 & ts<=TimeGo+2)) - (TimeGo);
%             MaxVTrial_SpikeTimes = ts((ts >= MaxVelT(t)-2 & ts<=MaxVelT(t)+2)) - (MaxVelT(t));
            EndTrial_SpikeTimes = ts((ts >= TimeGo & ts<=TimeEnd+2)) - (TimeEnd);
            if isempty(EndTrial_SpikeTimes) == 0
                Trial.Incomplete_tsstart(t).times = StartTrial_SpikeTimes;
%                 Trial.Incomplete_tsMaxV(t).times = MaxVTrial_SpikeTimes;
                Trial.Incomplete_tsend(t).times = EndTrial_SpikeTimes;
            else
                Trial.Incomplete_tsstart(t).times = [];
%                 Trial.Incomplete_tsMaxV(t).times = [];
                Trial.Incomplete_tsend(t).times = [];
            end
                %% Begin useful code agai
           
        else
            j = j+1;
            t = t+1;
            %         offset = 0;
            %         goOffset = 0;
            continue
        end
    end
end

j = 1;
t = 1;
offset = 0;
goOffset = 0;
%% Now parse failed trials
if exist('FailMovetimes','var')
    for i = 1:length(FailTrialInds)-1
        
        if i + goOffset > length(GoFailInds)
            Trial.Fail_goOffset = goOffset;
            Trial.Fail_offset = offset;
            continue
        end
        
        if i+offset > length(FailTrialInds)
            Trial.Fail_offset = offset;
            Trial.Fail_goOffset = goOffset;
            continue
        end
        if  round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 64 || ...
                round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 65 ||...
                round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 66 || ...
                round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 67
            %words 64-65 indicate outer target on
            TempTargetID(j) = out_struct.words(FailTrialInds(i+offset)-2,2);
            TimeStart = eval(vpa(out_struct.words(FailTrialInds(i+offset)-2,1),6));
            TrialWTargetWord(j) = 1;
            
        elseif  round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 64 || ...
                round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 65 ||...
                round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 66 || ...
                round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 67
            
            TempTargetID(j) = out_struct.words(FailTrialInds(i+offset)-2,2);
            TimeStart = eval(vpa(out_struct.words(FailTrialInds(i+offset)-3,1),6));
            TrialWTargetWord(j) = 1;
        end
        
        if TrialWTargetWord(i) == 1 % Ran into a weird
            % 2/5/14 bug where there was a reward without any Go cue
            % word (49) or the outer target ON word itself (64-67)
            
            
            % MRS 5/29/14 Added this logic because the TrialEndIndex
            % exceeded the length of the fp matrix
            
            % Determine start index of FP trial segment to extract centered on
            % movement onset
            TrialStartIndexFP(j) = round((FailMovetimes(t)-fpstarttime-1)/.001);
            
            % Determine start index of FP trial segment to extract centered on
            % maximum velocity
%             TrialMVIndexFP(j) = round((MaxVelT(t)-fpstarttime)/.001);
            
            
            TimeGo = eval(vpa(out_struct.words(GoFailInds(i+goOffset),1),6));
            TimeEnd = eval(vpa(out_struct.words(FailTrialInds(i+offset),1),6));
            
            if TimeGo < TimeEnd
                %% Begin checking that go cue and reward cue are appropriately matched up
                if TimeEnd - TimeGo < MaxTrialTime
                    % Calculate time to target (TTT) by subtracting go time from reward
                    % time
                    Trial.Fail_TTT(t) = TimeEnd - TimeGo;
                    Trial.Fail_TargetID(t) = TempTargetID(j);
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1 % If HC (increment is 1 ms)
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                        
                        Trial.Fail_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        Trial.Fail_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                    else %If BC increment is 50 ms
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                        
                        Trial.Fail_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        Trial.Fail_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                    end
                    
                    
                    Trial.Fail_Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Fail_Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    
                    
                else
                    %% If the go cue appears too early find the next one that matches
                    % If the go cue is way too early look to see if a later go
                    % cue matches up better
                    %                 goOffset= 0; % Need to reset offset in each loop iteration
                    % since the counter 'i' is incremented in each loop anyway,
                    % otherwise you will end up skipping trials.
                    while TimeEnd - TimeGo > MaxTrialTime
                        goOffset = goOffset + 1;
                        if i + goOffset > length(GoFailInds)
                            Trial.Fail_goOffset = goOffset;
                            Trial.Fail_offset = offset;
                            break
                        end
                        TimeGo = eval(vpa(out_struct.words(GoFailInds(i+goOffset),1),6));
                        
                    end
                    
                    % Get out of this loop if offset exceeds length of trial
                    % indexes
                    if isfield(Trial,'Fail_offset')
                        break
                    end
                    
                    if TimeEnd - TimeGo < MaxTrialTime && TimeEnd - TimeGo > 0
                        
                        Trial.Fail_TTT(t) = TimeEnd - TimeGo;
                        Trial.Fail_TargetID(t) = TempTargetID(j);
                        
                        if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                            
                            Trial.Fail_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                            Trial.Fail_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        else
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                            
                            Trial.Fail_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                            Trial.Fail_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        end
                        Trial.Fail_Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                        Trial.Fail_Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    end
                end
            else
                %% If a go time is missing or misaligned, skip forward in reward
                % time until you find one that matches up
                
                %             offset = 0; % Need to reset offset in each loop iteration
                % since the counter 'i' is incremented in each loop anyway,
                % otherwise you will end up skipping trials.
                while TimeGo > TimeEnd
                    offset = offset + 1;
                    if i+offset > length(FailTrialInds)
                        Trial.Fail_offset = offset;
                        Trial.Fail_goOffset = goOffset;
                        break
                    end
                    TimeEnd = eval(vpa(out_struct.words(FailTrialInds(i+offset),1),6));
                    
                end
                % Get out of this loop if offset exceeds length of trial
                % indexes
                if isfield(Trial,'offset')
                    break
                end
                
                %Correct the reward target ID and start time for this offset
                if  round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 64 || ...
                        round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 65 ||...
                        round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 66 || ...
                        round(out_struct.words(FailTrialInds(i+offset)-2,2)) == 67
                    %words 64-65 indicate outer target on
                    
                    TempTargetID(j) = out_struct.words(FailTrialInds(i+offset)-2,2);
                    TimeStart = eval(vpa(out_struct.words(FailTrialInds(i+offset)-2,1),6));
                    Trial.Fail_TargetID(t) = TempTargetID(j);
                    
                elseif  round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 64 || ...
                        round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 65 ||...
                        round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 66 || ...
                        round(out_struct.words(FailTrialInds(i+offset)-3,2)) == 67
                    
                    TempTargetID(j) = out_struct.words(FailTrialInds(i+offset)-3,2);
                    TimeStart = eval(vpa(out_struct.words(FailTrialInds(i+offset)-3,1),6));
                    Trial.Fail_TargetID(t) = TempTargetID(j);
                end
                
                if TimeEnd - TimeGo < MaxTrialTime && TimeEnd - TimeGo > 0 % Make sure go cue matches up to
                    % proper reward and not next trials' reward
                    Trial.Fail_TTT(t) = TimeEnd - TimeGo;
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.001);
                        
                        Trial.Fail_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                        Trial.Fail_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-2000:TrialEndIndexKin(j)+2000,:);
                    else
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime-1)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime-1)/.05);
                        
                        Trial.Fail_Path_Reward{t} = out_struct.pos(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                        Trial.Fail_Vel_Reward{t} = out_struct.vel(TrialEndIndexKin(j)-40:TrialEndIndexKin(j)+40,:);
                    end
                    Trial.Fail_Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Fail_Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                end
            end
            
            % Now extract those segments
            TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
            TrialStartIndexFP(j) = round((TimeGo-fpstarttime-1)/.001);
            
            if TrialEndIndexFP(j) < length(fp)
                for B = 1:size(fp,3)
                    Trial.Fail_FPstart{t,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
%                     Trial.Fail_FPMaxV{t,B} = fp(TrialMVIndexFP(j)-2000:TrialMVIndexFP(j)+2000,1,B);
                    Trial.Fail_FPend{t,B} = fp(TrialStartIndexFP(j):TrialEndIndexFP(j)+2000,1,B);
                end
            else
                j = j+1;
                t = t+1;
                %             offset = 0;
                %             goOffset = 0;
                continue
            end
            % In case there's no spikes at the end of this trial
            % MRS 2/7/14
            StartTrial_SpikeTimes = ts((ts >= TimeGo-2 & ts<=TimeGo+2)) - (TimeGo);
%             MaxVTrial_SpikeTimes = ts((ts >= MaxVelT(t)-2 & ts<=MaxVelT(t)+2)) - (MaxVelT(t));
            EndTrial_SpikeTimes = ts((ts >= TimeGo & ts<=TimeEnd+2)) - (TimeEnd);
            if isempty(EndTrial_SpikeTimes) == 0
                Trial.Fail_tsstart(t).times = StartTrial_SpikeTimes;
%                 Trial.Fail_tsMaxV(t).times = MaxVTrial_SpikeTimes;
                Trial.Fail_tsend(t).times = EndTrial_SpikeTimes;
            else
                Trial.Fail_tsstart(t).times = [];
%                 Trial.Fail_tsMaxV(t).times = [];
                Trial.Fail_tsend(t).times = [];
            end
            %% Don't really need this section but keeping it so I don't have to edit other code
            
        else
            % Trial is too close to end of file to be of interest
            j = j+1;
            t = t+1;
            continue
        end
        

        
        clear TimeStart_OTargetOn
        %     offset = 0;
        %     goOffset = 0;
        t = t+1;
        j = j +1;
    end
end