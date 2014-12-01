function [Trial] = parseTrials(out_struct,fp,fpstarttime,ts)

% To Do -
% - make window around movement onset and reward a variable instead
%   of hard coded

% Find beginning of all trials
FirstTrialInds=find(out_struct.words(:,2)==17);
GoInds=find(out_struct.words(:,2)==49);
if GoInds(end) + 1 > length(out_struct.words)
    GoInds(end) = [];
end
GoSuccessInds = GoInds(out_struct.words(GoInds + 1,2) == 32);
GoFailInds = GoInds(out_struct.words(GoInds + 1,2) == 34);
GoIncompleteInds = GoInds(out_struct.words(GoInds + 1,2) == 35);

SuccessTrialInds=find(out_struct.words(:,2)==32);
FailTrialInds=find(out_struct.words(:,2)==34);
IncompleteTrialInds=find(out_struct.words(:,2)==35);

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

[SuccessMovetimes,SuccessTrialInds,Successtimes,MaxVelT]= moveonsetfromBDF_MRS(out_struct.vel,gotimes,Successtimes,SuccessTrialInds,words,windowStart,windowEnd);

SuccessTrialInds(SuccessMovetimes < windowStart) = [];
SuccessTrialInds(SuccessTrialInds <= 3) = [];
% Successtimes(SuccessMovetimes < windowStart) = [];
SuccessMovetimes(SuccessMovetimes <= windowStart) = [];
MaxVelT(MaxVelT < windowStart) = [];

GoSuccessInds(gotimes < windowStart) = [];
gotimes(gotimes <= windowStart+2) = [];
GoSuccessInds(GoSuccessInds <= 3) = [];
GoSuccessInds(gotimes > out_struct.vel(end,1)-3) = [];


%% Calc move times for failed trials
if isempty(GoFailInds) == 0 & length(GoFailInds) > 1
    gotimes = out_struct.words(GoFailInds,1);
    Failtimes = out_struct.words(FailTrialInds,1);
    try
    [FailMovetimes,FailTrialInds,Failtimes,MaxVelFailT]=moveonsetfromBDF_MRS(out_struct.vel,gotimes,Failtimes,FailTrialInds,words,windowStart,windowEnd);
    FailTrialInds(FailMovetimes < windowStart) = [];
    FailTrialInds(FailTrialInds <= 3) = [];
    %     Failtimes(FailMovetimes < windowStart) = [];
    FailMovetimes(FailMovetimes < windowStart) = [];
    MaxVelFailT(MaxVelFailT < windowStart) = [];
    end
end

%% Calc move times for incomplete trials
if isempty(GoIncompleteInds) == 0 & length(GoIncompleteInds) > 1
    gotimes = out_struct.words(GoIncompleteInds,1);
    Incompletetimes = out_struct.words(IncompleteTrialInds,1);
    try
    [IncompleteMovetimes, IncompleteTrialInds,Incompletetimes,MaxVelIncmpT]=moveonsetfromBDF_MRS(out_struct.vel,gotimes,Incompletetimes,IncompleteTrialInds,words,windowStart,windowEnd);
    IncompleteTrialInds(IncompleteMovetimes < windowStart) = [];
    IncompleteTrialInds(IncompleteTrialInds <= 3) = [];
    %     Incompletetimes(IncompleteMovetimes < windowStart) = [];
    IncompleteMovetimes(IncompleteMovetimes < windowStart) = [];
    MaxVelIncmpT(MaxVelIncmpT < windowStart) = [];
    end
end
% plotIt = 0;
j = 1;
n = 1;
l = 1;
t = 1;
Alloffsets = 0;

TrialWTargetWord = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TempTargetID = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);

TrialStartIndexFP = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TrialStartIndexKin = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TrialEndIndexFP = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);

%% Parse successful trials
for i = 1:length(SuccessTrialInds)
    
    if  round(out_struct.words(SuccessTrialInds(i)-2,2)) == 64 || ...
            round(out_struct.words(SuccessTrialInds(i)-2,2)) == 65 ||...
            round(out_struct.words(SuccessTrialInds(i)-2,2)) == 66 || ...
            round(out_struct.words(SuccessTrialInds(i)-2,2)) == 67
        %words 64-65 indicate outer target on
        
        TempTargetID(j) = out_struct.words(SuccessTrialInds(i)-2,2);
        TrialWTargetWord(j) = 1;
        
    elseif  round(out_struct.words(SuccessTrialInds(i)-3,2)) == 64 || ...
            round(out_struct.words(SuccessTrialInds(i)-3,2)) == 65 ||...
            round(out_struct.words(SuccessTrialInds(i)-3,2)) == 66 || ...
            round(out_struct.words(SuccessTrialInds(i)-3,2)) == 67
        TempTargetID(j) = out_struct.words(SuccessTrialInds(i)-3,2);
        TrialWTargetWord(j) = 1;
    end
    
    if t <= length(SuccessMovetimes) && TrialWTargetWord(i) == 1
       
        
        % Check if HC or BC by looking at increment in kinematic variable (1 ms --HC, 50 ms --BC)
        if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
            TrialStartIndexKin(j) = round((SuccessMovetimes(t)-1)/.001);
            TrialMVIndexKin(j) = round((MaxVelT(t)-fpstarttime)/.001);
            
            if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 |...
                    TrialMVIndexKin(j)+2000 > length(out_struct.pos) | TrialMVIndexKin(j)-2000 < 0 
                % If HC trial index goes past end of file, skip it
                j = j+1;
                t = t+1;
                continue
            else
                % 2000 is size of window around movement onset, should
                % make this a variable instead of hard coding it
                Trial.Path_MO{t} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                Trial.Vel_MO{t} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                
                Trial.Path_MV{t} = out_struct.pos(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
                Trial.Vel_MV{t} = out_struct.vel(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
            end
        else
            TrialStartIndexKin(j) = round((SuccessMovetimes(t)-1)/.05);
            TrialMVIndexKin(j) = round((MaxVelT(t)-fpstarttime)/.05);
            
            % If BC trial index goes past end of file, or before beginning skip it
            if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0|...
                    TrialMVIndexKin(j)+40 > length(out_struct.pos) | TrialMVIndexKin(j)-40 < 0    
                j = j+1;
                t = t+1;
                continue
            else
                Trial.Path_MO{t} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                Trial.Vel_MO{t} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                
                Trial.Path_MV{t} = out_struct.pos(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
                Trial.Vel_MV{t} = out_struct.vel(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
            end
        end
        Trial.TargetID(t) = TempTargetID(j);
    else
        % Trial is too close to end of file to be of interest
        j = j+1;
        t = t+1;
        continue
    end
    
    if TrialWTargetWord(i) == 1 % Ran into a weird
        % 2/5/14 bug where there was a reward without any Go cue
        % word (49) or the outer target ON word itself (64-67)
        
        
        % MRS 5/29/14 Added this logic because the TrialEndIndex
        % exceeded the length of the fp matrix    
        
        % Determine start index of FP trial segment to extract centered on
        % movement onset
        TrialStartIndexFP(j) = round((SuccessMovetimes(t)-fpstarttime)/.001);
        
        % Determine start index of FP trial segment to extract centered on
        % maximum velocity
        TrialMVIndexFP(j) = round((MaxVelT(t)-fpstarttime)/.001);
        
        % Determine start index of FP trial segment to extract aligned to
        % reward time.
        TimeEnd = eval(vpa(out_struct.words(SuccessTrialInds(i),1),6));
        TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);

        % Now extract those segments
        if TrialEndIndexFP(j) < length(fp)
            for B = 1:size(fp,3)
                Trial.FPstart{t,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
                Trial.FPMaxV{t,B} = fp(TrialMVIndexFP(j)-2000:TrialMVIndexFP(j)+2000,1,B);
                Trial.FPend{t,B} = fp(TrialEndIndexFP(j)-2000:TrialEndIndexFP(j),1,B);
            end
        else
            j = j+1;
            t = t+1;
            continue
        end
        
        % Calculate time to target (TTT) by subtracting go time from reward
        % time
        if i <= length(GoSuccessInds)
            TimeGo = eval(vpa(out_struct.words(GoSuccessInds(i),1),6));
            if TimeGo < TimeEnd
                if TimeEnd - TimeGo < 10
                    Trial.TTT(t) = TimeEnd - TimeGo;
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime)/.001);
                    else
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime)/.05);
                    end
                    Trial.Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                
                else
                    % If the go cue is way too early look to see if a later go
                    % cue matches up better
                    goOffset = 1;
                    while TimeEnd - TimeGo > 10
                        if i - goOffset < 1
                            break
                        end
                        TimeGo = eval(vpa(out_struct.words(GoSuccessInds(i+goOffset),1),6));
                        goOffset = goOffset + 1;
                        
                    end
                    
                    if TimeEnd - TimeGo < 10 && TimeEnd - TimeGo > 0 
                        Trial.TTT(t) = TimeEnd - TimeGo;
                        if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime)/.001);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime)/.001);
                        else
                            TrialEndIndexKin(j) = round((TimeEnd-fpstarttime)/.05);
                            TrialGoIndexKin(j) = round((TimeGo-fpstarttime)/.05);
                        end
                        Trial.Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                        Trial.Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    end
                end
            else
                % If a go time is missing or misaligned, skip forward in reward
                % time until you find one that matches up
                offset = 0;
                while TimeGo > TimeEnd
                    TimeEnd = eval(vpa(out_struct.words(SuccessTrialInds(i+offset),1),6));
                    offset = offset + 1;
                    
                    if i+offset > length(SuccessTrialInds)
                        break
                    end
                end
                
                if TimeEnd - TimeGo < 10 && TimeEnd - TimeGo > 0 % Make sure go cue matches up to
                    % proper reward and not next trials' reward
                    Trial.TTT(t) = TimeEnd - TimeGo;
                    
                    if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime)/.001);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime)/.001);
                    else
                        TrialEndIndexKin(j) = round((TimeEnd-fpstarttime)/.05);
                        TrialGoIndexKin(j) = round((TimeGo-fpstarttime)/.05);
                    end
                    Trial.Path_Whole{t} = out_struct.pos(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                    Trial.Vel_Whole{t} = out_struct.vel(TrialGoIndexKin(j):TrialEndIndexKin(j),:);
                end
            end
        end
        % In case there's no spikes at the end of this trial
        % MRS 2/7/14
        StartTrial_SpikeTimes = ts((ts >= SuccessMovetimes(t)-2 & ts<=SuccessMovetimes(t)+2)) - (SuccessMovetimes(t));
        MaxVTrial_SpikeTimes = ts((ts >= MaxVelT(t)-2 & ts<=MaxVelT(t)+2)) - (MaxVelT(t));
        EndTrial_SpikeTimes = ts((ts >= TimeEnd-2 & ts<=TimeEnd)) - (TimeEnd-2);
        if isempty(EndTrial_SpikeTimes) == 0
            Trial.tsstart(t).times = StartTrial_SpikeTimes;
            Trial.tsMaxV(t).times = MaxVTrial_SpikeTimes;
            Trial.tsend(t).times = EndTrial_SpikeTimes;
        else
            Trial.tsstart(t).times = [];
            Trial.tsMaxV(t).times = [];
            Trial.tsend(t).times = [];
        end
        
    else
        j = j+1;
        t = t+1;
        continue
    end
    
    clear TimeStart_OTargetOn
    t = t+1;
    j = j +1;
    
end

%% Now parse Incomplete Trials
if exist('IncompleteMovetimes','var')
    for i = 1:length(IncompleteTrialInds)
            
        if  round(out_struct.words(IncompleteTrialInds(i)-2,2)) == 64 || ...
                round(out_struct.words(IncompleteTrialInds(i)-2,2)) == 65 ||...
                round(out_struct.words(IncompleteTrialInds(i)-2,2)) == 66 || ...
                round(out_struct.words(IncompleteTrialInds(i)-2,2)) == 67
            %words 64-65 indicate outer target on
            
            TempTargetID(j) = out_struct.words(IncompleteTrialInds(i)-2,2);
            TrialWTargetWord(j) = 1;
            
        elseif  round(out_struct.words(IncompleteTrialInds(i)-3,2)) == 64 || ...
                round(out_struct.words(IncompleteTrialInds(i)-3,2)) == 65 ||...
                round(out_struct.words(IncompleteTrialInds(i)-3,2)) == 66 || ...
                round(out_struct.words(IncompleteTrialInds(i)-3,2)) == 67
            TempTargetID(j) = out_struct.words(IncompleteTrialInds(i)-3,2);
            TrialWTargetWord(j) = 1;
        end
        
        % If trial is too close to end of file, skip it
        if n <= length(IncompleteMovetimes) && TrialWTargetWord(i) == 1
            
            if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                TrialStartIndexKin(j) = round((IncompleteMovetimes(n)-1)/.001);
                TrialMVIndexKin(j) =round((MaxVelIncmpT(n)-fpstarttime)/.001);            
                
                if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 |...
                    TrialMVIndexKin(j)+2000 > length(out_struct.pos) | TrialMVIndexKin(j)-2000 < 0 
                    j = j+1;
                    n = n+1;
                    continue
                else
                    Trial.Incomplete_Path_MO{n} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                    Trial.Incomplete_Vel_MO{n} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                    
                    Trial.Incomplete_Path_MV{n} = out_struct.pos(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
                    Trial.Incomplete_Vel_MV{n} = out_struct.vel(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);                                
                end
            else
                TrialStartIndexKin(j) = round((IncompleteMovetimes(n)-1)/.05);
                TrialMVIndexKin(j) =round((MaxVelIncmpT(n)-fpstarttime)/.05);
                
                if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0 |...
                    TrialMVIndexKin(j)+40 > length(out_struct.pos) | TrialMVIndexKin(j)-40 < 0 
                    j = j+1;
                    n = n+1;
                    continue
                else
                    Trial.Incomplete_Path_MO{n} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                    Trial.Incomplete_Vel_MO{n} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                    
                    Trial.Incomplete_Path_MV{n} = out_struct.pos(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
                    Trial.Incomplete_Vel_MV{n} = out_struct.vel(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
                end
            end
            Trial.IncompleteTargetID(n) = TempTargetID(j);
        else
            continue
        end
        
        if TrialWTargetWord(i) == 1 % Copied from above
            
            TimeEnd = eval(vpa(out_struct.words(IncompleteTrialInds(i),1),6));
            TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
            
            if TrialEndIndexFP(j) < length(fp)
                
                TrialStartIndexFP(j) = round((IncompleteMovetimes(n)-fpstarttime)/.001);
                
                TrialMVIndexFP(j) = round((MaxVelIncmpT(n)-fpstarttime)/.001);
                
                for B = 1:size(fp,3)
                    Trial.Incomplete_FPstart{n,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
                    Trial.Incomplete_FPMaxV{t,B} = fp(TrialMVIndexFP(j)-2000:TrialMVIndexFP(j)+2000,1,B);
                    Trial.Incomplete_FPend{n,B} = fp(TrialEndIndexFP(j)-2000:TrialEndIndexFP(j),1,B); % Signal pos/vel
                end
            else
                j = j+1;
                n = n+1;
                continue
            end
            % Copied from above
            StartTrial_SpikeTimes = ts((ts >= IncompleteMovetimes(n)-2 & ts<=IncompleteMovetimes(n)+2)) - (IncompleteMovetimes(n));
            MaxVIncmpTrial_SpikeTimes = ts((ts >= MaxVelIncmpT(n)-2 & ts<=MaxVelIncmpT(n)+2)) - (MaxVelIncmpT(n));
            Incomplete_SpikeTimes = ts((ts >= TimeEnd-2 & ts<=TimeEnd)) - (TimeEnd-2);
            if isempty(Incomplete_SpikeTimes) == 0
                Trial.Incomplete_tsstart(n).times = StartTrial_SpikeTimes;
                Trial.Incomplete_tsMaxV(n).times = MaxVIncmpTrial_SpikeTimes;
                Trial.Incomplete_tsend(n).times = Incomplete_SpikeTimes;
            else
                Trial.Incomplete_tsstart(n).times = [];
                Trial.Incomplete_tsMaxV(n).times = [];
                Trial.Incomplete_tsend(n).times = [];
            end
            
        else
            j = j+1;
            n = n+1;
            continue
        end
        
        clear TimeStart_OTargetOn
        n = n +1;
        j = j + 1;
    end
end
%% Now parse failed trials
if exist('FailMovetimes','var')
    for i = 1:length(FailTrialInds)-1
        
        if  round(out_struct.words(FailTrialInds(i)-2,2)) == 64 || ...
                round(out_struct.words(FailTrialInds(i)-2,2)) == 65 ||...
                round(out_struct.words(FailTrialInds(i)-2,2)) == 66 || ...
                round(out_struct.words(FailTrialInds(i)-2,2)) == 67
            %words 64-65 indicate outer target on
            
            TempTargetID(j) = out_struct.words(FailTrialInds(i)-2,2);
            TrialWTargetWord(j) = 1;
            
        elseif  round(out_struct.words(FailTrialInds(i)-3,2)) == 64 || ...
                round(out_struct.words(FailTrialInds(i)-3,2)) == 65 ||...
                round(out_struct.words(FailTrialInds(i)-3,2)) == 66 || ...
                round(out_struct.words(FailTrialInds(i)-3,2)) == 67
            TempTargetID(j) = out_struct.words(FailTrialInds(i)-3,2);
            TrialWTargetWord(j) = 1;
        end
        
        if n <= length(FailMovetimes) && TrialWTargetWord(i) == 1
            
            if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                TrialStartIndexKin(j) = round((FailMovetimes(l)-1)/.001);
                TrialMVIndexKin(j) = round((MaxVelFailT(l)-fpstarttime)/.001);
                
                if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 |...
                    TrialMVIndexKin(j)+2000 > length(out_struct.pos) | TrialMVIndexKin(j)-2000 < 0 
                    j = j+1;
                    l = l+1;
                    continue
                else
                    Trial.Fail_Path_MO{l} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                    Trial.Fail_Vel_MO{l} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                    
                    Trial.Fail_Path_MV{l} = out_struct.pos(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
                    Trial.Fail_Vel_MV{l} = out_struct.vel(TrialMVIndexKin(j)-2000:TrialMVIndexKin(j)+2000,:);
                end
            else
                TrialStartIndexKin(j) = round((FailMovetimes(l)-1)/.05);
                TrialMVIndexKin(j) = round((MaxVelFailT(l)-fpstarttime)/.05);
                
                if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0 |...
                    TrialMVIndexKin(j)+40 > length(out_struct.pos) | TrialMVIndexKin(j)-40 < 0 
                    j = j+1;
                    l = l+1;
                    continue
                else
                    Trial.Fail_Path_MO{l} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                    Trial.Fail_Vel_MO{l} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                    
                    Trial.Fail_Path_MV{l} = out_struct.pos(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
                    Trial.Fail_Vel_MV{l} = out_struct.vel(TrialMVIndexKin(j)-40:TrialMVIndexKin(j)+40,:);
                end
            end
            Trial.FailTargetID(l) = TempTargetID(j);
        else
            j = j+1;
            l = l+1;
            continue
        end
        
        if TrialWTargetWord(i) == 1 % Copied from above
            
            TrialStartIndexFP(j) = round((FailMovetimes(l)-fpstarttime)/.001);
            TrialMVIndexFP(j) = round((MaxVelFailT(l)-fpstarttime)/.001);
            
            
            TimeEnd = eval(vpa(out_struct.words(FailTrialInds(i),1),6));
            TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
        
            if TrialEndIndexFP(j) < length(fp)
                
                for B = 1:size(fp,3)
                    Trial.Fail_FPstart{l,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
                    Trial.Fail_FPMaxV{t,B} = fp(TrialMVIndexFP(j)-2000:TrialMVIndexFP(j)+2000,1,B);
                    Trial.Fail_FPend{l,B} = fp(TrialEndIndexFP(j)-2000:TrialEndIndexFP(j),1,B);
                end
            else
                j = j+1;
                l = l+1;
                continue
            end
            
            % Copied from above
            StartTrial_SpikeTimes = ts((ts >= FailMovetimes(l)-2 & ts<=FailMovetimes(l)+2)) - (FailMovetimes(l));
            MaxVFailTrial_SpikeTimes = ts((ts >= MaxVelFailT(l)-2 & ts<=MaxVelFailT(l)+2)) - (MaxVelFailT(l));
            Fail_SpikeTimes = ts((ts >= TimeEnd-2 & ts<=TimeEnd)) - (TimeEnd-2);
            if isempty(Fail_SpikeTimes) == 0
                Trial.Fail_tsstart(l).times = StartTrial_SpikeTimes;
                Trial.Fail_tsMaxV(l).times  = MaxVFailTrial_SpikeTimes; 
                Trial.Fail_tsend(l).times = Fail_SpikeTimes;
            else
                Trial.Fail_tsstart(l).times = [];
                Trial.Fail_tsMaxV(l).times = [];
                Trial.Fail_tsend(l).times = [];
            end
            
        else
            j = j+1;
            l = l+1;
            continue
        end
        
        clear TimeStart_OTargetOn
        l = l +1;
        j = j+1;
        
    end
end

end