function [Trial_FPend, Trial_tsend, Trial_Path_Whole, TargetID, varargout] = parseTrials(out_struct,y,xOnline,fp,ts)

% Find beginning of all trials
FirstTrialInds=find(out_struct.words(:,2)==17);
SuccessTrialInds=find(out_struct.words(:,2)==32);
FailTrialInds=find(out_struct.words(:,2)==34);
IncompleteTrialInds=find(out_struct.words(:,2)==35);

Trial_FPend = cell(1,length(SuccessTrialInds));
Trial_Fail_FPend = cell(1,length(FailTrialInds));
Trial_Incomplete_FPend = cell(1,length(IncompleteTrialInds));

Trial_Path_Whole = cell(length(SuccessTrialInds),1);
Trial_Fail_Path_Whole = cell(length(FailTrialInds),1);
Trial_Incomplete_Path_Whole = cell(length(IncompleteTrialInds),1);
 
NumTrials = length(FirstTrialInds);
% remove last trial in case trial is cut off or short
FirstTrialInds(end) = [];
TargetID = zeros(NumTrials,3);

% plotIt = 0;
j = 1;
n = 1;
l = 1;
t = 1;
% jX =1;
% jY =1;
% jnegX =1;
% jnegY =1;
% TrialPathY ={};
% TrialPathX ={};
% TrialInputY ={};
% TrialInputX ={};
% TrialPathnegY ={};
% TrialPathnegX ={};
% TrialInputnegY ={};
% TrialInputnegX ={};
TrialStartIndexPos = [];
TrialEndIndexPos = [];
TrialStartIndexIn = [];
TrialEndIndexIn = [];
for i = 1:length(FirstTrialInds)-1
    
    %if out_struct.words(FirstTrialInds(i)+4,2) > 30 && out_struct.words(FirstTrialInds(i)+4,2) < 40 %out_struct.words(FirstTrialInds(i)+4,2) == 32 %%skip unrewarded trials
    
    % [out_struct.words(FirstTrialInds(i),2) out_struct.words(FirstTrialInds(i)+1,2) out_struct.words(FirstTrialInds(i)+2,2) out_struct.words(FirstTrialInds(i)+3,2) out_struct.words(FirstTrialInds(i)+4,2)]
    
    if out_struct.words(FirstTrialInds(i+1)-1,2) == 33
        continue
    end
    
    TimeStart = eval(vpa(out_struct.words(FirstTrialInds(i),1),6));
    TimeEnd = eval(vpa(out_struct.words(FirstTrialInds(i+1)-1,1),6));
    
    if round(out_struct.words(FirstTrialInds(i)+2,2)) == 64 || ...
            round(out_struct.words(FirstTrialInds(i)+2,2)) == 65 ||...
            round(out_struct.words(FirstTrialInds(i)+2,2)) == 66 || ...
            round(out_struct.words(FirstTrialInds(i)+2,2)) == 67 ||...
            round(out_struct.words(FirstTrialInds(i)+3,2)) == 64 || ...
            round(out_struct.words(FirstTrialInds(i)+3,2)) == 65 ||...
            round(out_struct.words(FirstTrialInds(i)+3,2)) == 66 || ...
            round(out_struct.words(FirstTrialInds(i)+3,2)) == 67
        %words 64-65 indicate outer target on
        % 2/5/14 added extra 4 conditons because the target word (64-67) can
        % appear either 2 or 3 places after the begin trial word (17)
        % because of the appearance of a (96) word.
        
        TimeStart_OTargetOn = eval(vpa(out_struct.words(FirstTrialInds(i)+2,1),3));
        TrialStart_OTOn_IndexFP(j) = round((TimeStart_OTargetOn - 1)/.001);
        TrialStart_OTOn_IndexPath(j) = round((TimeStart_OTargetOn - 1)/.05);
    end
    
    
    TrialStartIndexPos(j) = round((TimeStart - 1)/.05);
    TrialEndIndexPos(j) = round((TimeEnd - 1)/.05);
    TrialStartIndexIn(j) = round((TimeStart - 1)/.05);
    TrialEndIndexIn(j) = round((TimeEnd - 1)/.05);
    TrialStartIndexFP(j) = round((TimeStart - 1)/.001);
    
    TrialEndIndexFP(j) = round((TimeEnd - 1)/.001);
    
    if TrialEndIndexPos(j) > length(out_struct.pos);  %% can probably add in TrialEndIndexIn > length(Input) as another check.
        continue
    else
        %             TrialPath{j} = y(TrialStartIndexPos(j):TrialEndIndexPos(j),:); % Signal pos/vel
        %             TrialInput{j} = xOnline(TrialStartIndexIn(j):TrialEndIndexIn(j),:); % Input LFP power/spike rate
        
        if out_struct.words(FirstTrialInds(i+1)-1,2) == 32
            
            Trial_Path_Whole{t} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:); 
            TargetID(t,1) = out_struct.words(FirstTrialInds(i)+2,2);
            
            if length(TrialStart_OTOn_IndexFP) == j % Ran into a weird
                % 2/5/14 bug where there was a reward without any outer target ON
                % word (49) or the target word itself (64-67)
                Trial_FPend{t} = fp(TrialEndIndexFP(j)-1000:TrialEndIndexFP(j)); % Signal pos/vel
%                Trial_FPbegin{t} = fp(TrialStart_OTOn_IndexFP(j):TrialStart_OTOn_IndexFP(j)+1000); % Signal pos/vel
                
                
%                 % In case there's no spikes in the beginning of this
%                 % trial MRS 2/7/14
%                 SpikeTimes = vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3);
%                 if isempty(SpikeTimes) == 0
%                     Trial_tsbegin(t).times = eval(SpikeTimes); % Input LFP power/spike rate
%                 end
                
                % In case there's no spikes at the end of this trial
                % MRS 2/7/14
                EndTrial_SpikeTimes = ts((ts >= TimeEnd-1 & ts<=TimeEnd)) - (TimeEnd-1);
                if isempty(EndTrial_SpikeTimes) == 0
                    Trial_tsend(t).times = EndTrial_SpikeTimes;  % Comes out as a symbolic number so it needs to be converted to a double using eval 
                end
                
            else
                continue
            end
            
            clear TimeStart_OTargetOn
            t = t+1;
            
        elseif out_struct.words(FirstTrialInds(i+1)-1,2) == 35
            
            Trial_Incomplete_Path_Whole{n} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
            TargetID(n,2) = out_struct.words(FirstTrialInds(i)+2,2);
            
            if length(TrialStart_OTOn_IndexFP) == j % Copied from above
%                Trial_Incomplete_FPbegin{n} = fp(TrialStart_OTOn_IndexFP(j):TrialStart_OTOn_IndexFP(j)+1000); % Signal pos/vel
                Trial_Incomplete_FPend{n} = fp(TrialEndIndexFP(j)-1000:TrialEndIndexFP(j)); % Signal pos/vel
                
                % Copied from above
%                 if isempty(vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3)) == 0
%                     Trial_Incomplete_tsbegin(n).times = eval(vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3)); % Input LFP power/spike rate
%                 end

                % Copied from above
                Incomplete_SpikeTimes = ts((ts >= TimeEnd-1 & ts<=TimeEnd)) - (TimeEnd-1);
                if isempty(Incomplete_SpikeTimes) == 0
                    Trial_Incomplete_tsend(n).times = Incomplete_SpikeTimes;
                end
                
            else
                continue
            end
            
            clear TimeStart_OTargetOn
            n = n +1;
            
        elseif out_struct.words(FirstTrialInds(i+1)-1,2) == 34
            
            Trial_Fail_Path_Whole{l} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
            TargetID(l,3) = out_struct.words(FirstTrialInds(i)+2,2);
            
            if length(TrialStart_OTOn_IndexFP) == j % Copied from above
%                Trial_Fail_FPbegin{l} = fp(TrialStart_OTOn_IndexFP(j):TrialStart_OTOn_IndexFP(j)+1000); % Signal pos/vel
                Trial_Fail_FPend{l} = fp(TrialEndIndexFP(j)-1000:TrialEndIndexFP(j)); % Signal pos/vel
                
                % Copied from above
%                 if isempty(vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3)) == 0
%                     Trial_Fail_tsbegin(l).times = eval(vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3)); % Input LFP power/spike rate
%                 end

                % Copied from above
                Fail_SpikeTimes = ts((ts >= TimeEnd-1 & ts<=TimeEnd)) - (TimeEnd-1); 
                if isempty(Fail_SpikeTimes) == 0
                    Trial_Fail_tsend(l).times = Fail_SpikeTimes;
                end
                
            else
                continue
            end
            
            clear TimeStart_OTargetOn
            l = l +1;
            
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
    
    
    j = j+1;
    %else
    %fprintf('Trial Excluded\n')
    
    %end
end


if isempty(Trial_Incomplete_Path_Whole) == 0
    varargout{1} = Trial_Incomplete_FPend;
    varargout{2} = Trial_Incomplete_tsend;
    varargout{3} = Trial_Incomplete_Path_Whole;
else
    varargout{1} = [];
    varargout{2} = [];
    varargout{3} = [];
end

if isempty(Trial_Fail_Path_Whole) == 0
    varargout{4} = Trial_Fail_FPend;
    varargout{5} = Trial_Fail_tsend;
    varargout{6} = Trial_Fail_Path_Whole;
else
    
    varargout{4} = [];
    varargout{5} = [];
    varargout{6} = [];
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
end