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
windowStart = 2;
windowEnd = 2;
[SuccessMovetimes,SuccessTrialInds,Successtimes]= moveonsetfromBDF(out_struct.vel,gotimes,Successtimes,SuccessTrialInds,words,windowStart,windowEnd);
SuccessTrialInds(SuccessMovetimes < windowStart) = [];
SuccessTrialInds(SuccessTrialInds < 3) = [];
% Successtimes(SuccessMovetimes < windowStart) = [];
SuccessMovetimes(SuccessMovetimes < windowStart) = [];

%% Calc move times for failed trials
if isempty(GoFailInds) == 0 & length(GoFailInds) > 1
    gotimes = out_struct.words(GoFailInds,1);
    Failtimes = out_struct.words(FailTrialInds,1);
    try
    [FailMovetimes,FailTrialInds,Failtimes]=moveonsetfromBDF(out_struct.vel,gotimes,Failtimes,FailTrialInds,words,windowStart,windowEnd);
    FailTrialInds(FailMovetimes < windowStart) = [];
    FailTrialInds(FailTrialInds < 3) = [];
    %     Failtimes(FailMovetimes < windowStart) = [];
    FailMovetimes(FailMovetimes < windowStart) = [];
    end
end

%% Calc move times for incomplete trials
if isempty(GoIncompleteInds) == 0 & length(GoIncompleteInds) > 1
    gotimes = out_struct.words(GoIncompleteInds,1);
    Incompletetimes = out_struct.words(IncompleteTrialInds,1);
    try
    [IncompleteMovetimes, IncompleteTrialInds,Incompletetimes]=moveonsetfromBDF(out_struct.vel,gotimes,Incompletetimes,IncompleteTrialInds,words,windowStart,windowEnd);
    IncompleteTrialInds(IncompleteMovetimes < windowStart) = [];
    IncompleteTrialInds(IncompleteTrialInds < 3) = [];
    %     Incompletetimes(IncompleteMovetimes < windowStart) = [];
    IncompleteMovetimes(IncompleteMovetimes < windowStart) = [];
    end
end
% plotIt = 0;
j = 1;
n = 1;
l = 1;
t = 1;

TrialWTargetWord = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TempTargetID = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);

TrialStartIndexFP = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TrialStartIndexKin = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);
TrialEndIndexFP = zeros(length(SuccessTrialInds)+length(FailTrialInds)+length(IncompleteTrialInds),1);

%% Parse successful trials
for i = 1:length(SuccessTrialInds)
    
    TimeEnd = eval(vpa(out_struct.words(SuccessTrialInds(i),1),6));
    TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
    
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
    
    if t <= length(SuccessMovetimes)
        TrialStartIndexFP(j) = round((SuccessMovetimes(t)-fpstarttime)/.001);
        
        % Check if HC or BC by looking at increment in kinematic variable (1 ms --HC, 50 ms --BC)
        if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
            TrialStartIndexKin(j) = round((SuccessMovetimes(t)-1)/.001);
            if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 % If HC trial index goes past end of file, skip it
                j = j+1;
                t = t+1;
                continue
            else
                % 2000 is size of window around movement onset, should
                % make this a variable instead of hard coding it
                Trial.Path_Whole{t} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                Trial.Vel_Whole{t} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
            end
        else
            TrialStartIndexKin(j) = round((SuccessMovetimes(t)-1)/.05);
            
            % If BC trial index goes past end of file, or before beginning skip it
            if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0  
                j = j+1;
                t = t+1;
                continue
            else
                Trial.Path_Whole{t} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                Trial.Vel_Whole{t} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
            end
        end
        Trial.TargetID(t) = TempTargetID(j);
    else
        % Trial is too close to end of file to be of interest
        j = j+1;
        t = t+1;
        continue
    end
    
    if nnz(TrialWTargetWord) == j % Ran into a weird
        % 2/5/14 bug where there was a reward without any Go cue
        % word (49) or the outer target ON word itself (64-67)
        
        % MRS 5/29/14 Added this logic because the TrialEndIndex
        % exceeded the length of the fp matrix
        
        if TrialEndIndexFP(j) < length(fp)
            for B = 1:size(fp,3)
                Trial.FPstart{t,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
                Trial.FPend{t,B} = fp(TrialEndIndexFP(j)-2000:TrialEndIndexFP(j),1,B);
            end
        else
            j = j+1;
            t = t+1;
            continue
        end
        
        % In case there's no spikes at the end of this trial
        % MRS 2/7/14
        StartTrial_SpikeTimes = ts((ts >= SuccessMovetimes(t)-2 & ts<=SuccessMovetimes(t)+2)) - (SuccessMovetimes(t));
        EndTrial_SpikeTimes = ts((ts >= TimeEnd-2 & ts<=TimeEnd)) - (TimeEnd-2);
        if isempty(EndTrial_SpikeTimes) == 0
            Trial.tsstart(t).times = StartTrial_SpikeTimes;
            Trial.tsend(t).times = EndTrial_SpikeTimes;
        else
            Trial.tsstart(t).times = [];
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
        
        TimeEnd = eval(vpa(out_struct.words(IncompleteTrialInds(i),1),6));
        TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
        
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
        if n <= length(IncompleteMovetimes)
            TrialStartIndexFP(j) = round((IncompleteMovetimes(n)-fpstarttime)/.001);
            if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                TrialStartIndexKin(j) = round((IncompleteMovetimes(n)-1)/.001);
                
                if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 
                    j = j+1;
                    n = n+1;
                    continue
                else
                    Trial.Incomplete_Path_Whole{n} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                    Trial.Incomplete_Vel_Whole{n} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                end
            else
                TrialStartIndexKin(j) = round((IncompleteMovetimes(n)-1)/.05);
                
                if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0 
                    j = j+1;
                    n = n+1;
                    continue
                else
                    Trial.Incomplete_Path_Whole{n} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                    Trial.Incomplete_Vel_Whole{n} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                end
            end
            Trial.IncompleteTargetID(n) = TempTargetID(j);
        else
            continue
        end
        
        if nnz(TrialWTargetWord) == j % Copied from above
            if TrialEndIndexFP(j) < length(fp)
                for B = 1:size(fp,3)
                    Trial.Incomplete_FPstart{n,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
                    Trial.Incomplete_FPend{n,B} = fp(TrialEndIndexFP(j)-2000:TrialEndIndexFP(j),1,B); % Signal pos/vel
                end
            else
                j = j+1;
                n = n+1;
                continue
            end
            % Copied from above
            StartTrial_SpikeTimes = ts((ts >= IncompleteMovetimes(n)-2 & ts<=IncompleteMovetimes(n)+2)) - (IncompleteMovetimes(n));
            Incomplete_SpikeTimes = ts((ts >= TimeEnd-2 & ts<=TimeEnd)) - (TimeEnd-2);
            if isempty(Incomplete_SpikeTimes) == 0
                Trial.Incomplete_tsstart(n).times = StartTrial_SpikeTimes;
                Trial.Incomplete_tsend(n).times = Incomplete_SpikeTimes;
            else
                Trial.Incomplete_tsstart(n).times = [];
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
        
        TimeEnd = eval(vpa(out_struct.words(FailTrialInds(i),1),6));
        TrialEndIndexFP(j) = round((TimeEnd-fpstarttime)/.001);
        
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
        
        if n <= length(IncompleteMovetimes)
            TrialStartIndexFP(j) = round((FailMovetimes(l)-fpstarttime)/.001);
            
            if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                TrialStartIndexKin(j) = round((FailMovetimes(l)-1)/.001);
                if TrialStartIndexKin(j)+2000 > length(out_struct.pos) | TrialStartIndexKin(j)-2000 < 0 
                    j = j+1;
                    l = l+1;
                    continue
                else
                    Trial.Fail_Path_Whole{l} = out_struct.pos(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                    Trial.Fail_Vel_Whole{l} = out_struct.vel(TrialStartIndexKin(j)-2000:TrialStartIndexKin(j)+2000,:);
                end
            else
                TrialStartIndexKin(j) = round((FailMovetimes(l)-1)/.05);
                if TrialStartIndexKin(j)+40 > length(out_struct.pos) | TrialStartIndexKin(j)-40 < 0 
                    j = j+1;
                    l = l+1;
                    continue
                else
                    Trial.Fail_Path_Whole{l} = out_struct.pos(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                    Trial.Fail_Vel_Whole{l} = out_struct.vel(TrialStartIndexKin(j)-40:TrialStartIndexKin(j)+40,:);
                end
            end
            Trial.FailTargetID(l) = TempTargetID(j);
        else
            j = j+1;
            l = l+1;
            continue
        end
        
        if nnz(TrialWTargetWord) == j % Copied from above
            
            if TrialEndIndexFP(j) < length(fp)
                for B = 1:size(fp,3)
                    Trial.Fail_FPstart{l,B} = fp(TrialStartIndexFP(j)-2000:TrialStartIndexFP(j)+2000,1,B);
                    Trial.Fail_FPend{l,B} = fp(TrialEndIndexFP(j)-2000:TrialEndIndexFP(j),1,B);
                end
            else
                j = j+1;
                l = l+1;
                continue
            end
            
            % Copied from above
            StartTrial_SpikeTimes = ts((ts >= FailMovetimes(l)-2 & ts<=FailMovetimes(l)+2)) - (FailMovetimes(l));
            Fail_SpikeTimes = ts((ts >= TimeEnd-2 & ts<=TimeEnd)) - (TimeEnd-2);
            if isempty(Fail_SpikeTimes) == 0
                Trial.Fail_tsstart(l).times = StartTrial_SpikeTimes;
                Trial.Fail_tsend(l).times = Fail_SpikeTimes;
            else
                Trial.Fail_tsstart(l).times = [];
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
%         clear Time* TrialStartIndex TrialEndIndex

%         if round(out_struct.targets.corners(i,2)) == 8
%         if round(out_struct.words(FirstTrialInds(i)+2,2)) == 64 || round(out_struct.words(FirstTrialInds(i)+2,2)) == 66 %down == 66 % words 64 = target position UP
%             %if 1D in Y change this to 64 and 65 and
%             %put dummy values in x
%             if plotIt
%                 figure(1)
%                 plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'b') % use to plot all trials
%             end
%             TrialPathY{jY} = y(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
%             TrialInputY{jY} = xOnline(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
%             jY = jY+1;
%             %           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','b') %use to scan though trials
%         elseif round(out_struct.words(FirstTrialInds(i)+2,2)) == 65 || round(out_struct.words(FirstTrialInds(i)+2,2)) == 67 % words 65 = target position RIGHT or = 67 to the LEFT
%             %if 1D in X change this to 64 and 65
%             %put dummy values in y
%             if plotIt
%                 figure(2)
%                 plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'r') % use to plot all trials
%             end
%
%             TrialPathX{jX} = y(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
%             TrialInputX{jX} = xOnline(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
%             jX = jX+1;
%             %           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','k') %use to scan though trials
%
%         elseif round(out_struct.words(FirstTrialInds(i)+2,2)) == 66 % words 65 = target position RIGHT or = 67 presumably to the LEFT
%
%             if plotIt
%                 figure(3)
%                 plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'c') % use to plot all trials
%             end
%
%             TrialPathnegY{jnegY} = y(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
%             TrialInputnegY{jnegY} = xOnline(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
%             jnegY = jnegY+1;
%             %           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','k') %use to scan though trials
%         elseif round(out_struct.words(FirstTrialInds(i)+2,2)) == 67 % words 65 = target position RIGHT or = 67 presumably to the LEFT
%             if plotIt
%                 figure(4)
%                 plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'m') % use to plot all trials
%             end
%
%             TrialPathnegX{jnegX} = y(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
%             TrialInputnegX{jnegX} = xOnline(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
%             jnegX = jnegX+1;
%             %           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','k') %use to scan though trials
%         end



%         figure(2)
%             plot(TrialInput{j}(:,1),TrialInput{j}(:,2),'k.') % use to plot all trials
%         hold on
%         pause(2) % use to plot all trials

%else
%fprintf('Trial Excluded\n')

%end
end

% fprintf('Number of Trials = %3.0f \n', j-1)
% fprintf('Number of Trials = %3.0f \n', jX-1)
% fprintf('Number of Trials = %3.0f \n', jY-1)
% %% Average correlation coefficient across all trials
% for j = 1:length(TrialPath)
%     [rtrialSig(j),pSig(j)] = corr(TrialPath{j}(:,2),TrialPath{j}(:,3));
%     [rtrialInput(j),pInput(j)] = corr(TrialInput{j}(:,1),TrialInput{j}(:,2));
% end
% fprintf('Average R across trials - Predicted Position = %6.4f +- %4.2f \n',mean(rtrialSig) ,std(rtrialSig))
% fprintf('Average R across trials - Input Signals = %6.4f +- %4.2f \n',mean(rtrialInput) ,std(rtrialInput))
% %% Correlation across all trials concatenated
% TrialPathCat=cat(1,TrialPath{:});
% [rtrialpathcat,pCatPath] = corr(TrialPathCat(:,2),TrialPathCat(:,3));
% fprintf('Average R across trials - Predicted Position Concatenated = %6.4f \n',rtrialpathcat)
% TrialInputCat=cat(1,TrialInput{:});
% [rtrialinputcat,pCatInput] = corr(TrialInputCat(:,1),TrialInputCat(:,2));
% fprintf('Average R across trials - Input Signals Concatenated = %6.4f \n',rtrialinputcat)