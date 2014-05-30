function [Trial, TargetID] = parseTrials(out_struct,fp,ts)

% Find beginning of all trials
FirstTrialInds=find(out_struct.words(:,2)==17);

SuccessTrialInds=find(out_struct.words(:,2)==32);
FailTrialInds=find(out_struct.words(:,2)==34);
IncompleteTrialInds=find(out_struct.words(:,2)==35);

% Trial.FPend = cell(1,length(SuccessTrialInds));
% Trial.Fail_FPend = cell(1,length(FailTrialInds));
% Trial.Incomplete_FPend = cell(1,length(IncompleteTrialInds));
% 
% Trial.Path_Whole = cell(length(SuccessTrialInds),1);
% Trial.Fail_Path_Whole = cell(length(FailTrialInds),1);
% Trial.Incomplete_Path_Whole = cell(length(IncompleteTrialInds),1);
 
NumTrials = length(FirstTrialInds);
% remove last trial in case trial is cut off or short
if isempty(FirstTrialInds) == 1
    FirstTrialInds = find(out_struct.words(:,2)==18);
    if  isempty(FirstTrialInds) ==0
        disp('This is a random walk file')
    end
    return
else
    FirstTrialInds(end) = [];
end

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
        
        TimeStart_OTargetOn = eval(vpa(out_struct.words(FirstTrialInds(i)+2,1),3));  % Comes out as a symbolic number so it needs to be converted to a double using eval 
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
            
            Trial.Path_Whole{t} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:); 
            TargetID((t+n+l)-2,1) = out_struct.words(FirstTrialInds(i)+2,2);
            
            if length(TrialStart_OTOn_IndexFP) == j % Ran into a weird
                % 2/5/14 bug where there was a reward without any outer target ON
                % word (49) or the target word itself (64-67)
                
                % MRS 5/29/14 Added this logic because the TrialEndIndex
                % exceeded the length of the fp matrix
                if TrialEndIndexFP(j) < length(fp)
                Trial.FPend{t} = fp(TrialEndIndexFP(j)-1000:TrialEndIndexFP(j));
                else
                    continue
                end
%                Trial.FPbegin{t} = fp(TrialStart_OTOn_IndexFP(j):TrialStart_OTOn_IndexFP(j)+1000);
                
                % In case there's no spikes at the end of this trial
                % MRS 2/7/14
                EndTrial_SpikeTimes = ts((ts >= TimeEnd-1 & ts<=TimeEnd)) - (TimeEnd-1);
                if isempty(EndTrial_SpikeTimes) == 0
                    Trial.tsend(t).times = EndTrial_SpikeTimes; 
                end
                
            else
                continue
            end
            
            clear TimeStart_OTargetOn
            t = t+1;
            
        elseif out_struct.words(FirstTrialInds(i+1)-1,2) == 35
            
            Trial.Incomplete_Path_Whole{n} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
            TargetID((t+n+l)-2,2) = out_struct.words(FirstTrialInds(i)+2,2);
            
            if length(TrialStart_OTOn_IndexFP) == j % Copied from above
%                Trial.Incomplete_FPbegin{n} = fp(TrialStart_OTOn_IndexFP(j):TrialStart_OTOn_IndexFP(j)+1000); % Signal pos/vel
                if TrialEndIndexFP(j) < length(fp)
                    Trial.Incomplete_FPend{n} = fp(TrialEndIndexFP(j)-1000:TrialEndIndexFP(j)); % Signal pos/vel 
                else
                    continue
                end
                % Copied from above
                Incomplete_SpikeTimes = ts((ts >= TimeEnd-1 & ts<=TimeEnd)) - (TimeEnd-1);
                if isempty(Incomplete_SpikeTimes) == 0
                    Trial.Incomplete_tsend(n).times = Incomplete_SpikeTimes;
                else
                    Trial.Incomplete_tsend(n).times = [];
                end
                
            else
                continue
            end
            
            clear TimeStart_OTargetOn
            n = n +1;
            
        elseif out_struct.words(FirstTrialInds(i+1)-1,2) == 34
            
            Trial.Fail_Path_Whole{l} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
            TargetID((t+n+l)-2,3) = out_struct.words(FirstTrialInds(i)+2,2);
            
            if length(TrialStart_OTOn_IndexFP) == j % Copied from above
%                Trial.Fail_FPbegin{l} = fp(TrialStart_OTOn_IndexFP(j):TrialStart_OTOn_IndexFP(j)+1000); % Signal pos/vel
                
                if TrialEndIndexFP(j) < length(fp)
                    Trial.Fail_FPend{l} = fp(TrialEndIndexFP(j)-1000:TrialEndIndexFP(j));
                else
                    continue
                end
                
                
                % Copied from above
%                 if isempty(vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3)) == 0
%                     Trial_Fail_tsbegin(l).times = eval(vpa(ts((ts >= TimeStart_OTargetOn & ts<=TimeStart_OTargetOn+1))- TimeStart_OTargetOn,3)); % Input LFP power/spike rate
%                 end

                % Copied from above
                Fail_SpikeTimes = ts((ts >= TimeEnd-1 & ts<=TimeEnd)) - (TimeEnd-1); 
                if isempty(Fail_SpikeTimes) == 0
                    Trial.Fail_tsend(l).times = Fail_SpikeTimes;
                else
                    Trial.Fail_tsend(l).times = [];
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