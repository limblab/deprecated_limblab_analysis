function [] = plotPathLength(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG,...
    Trials, FileList, segment, monkey_name)
% Calculates path length based on Trials structure created in
% script 'CrossFreqCoupling'

% Input
% HC_I - index for hand control files
% BC_I - index for brain control files
% ControlCh - channels of interest
% flag_SpHG - look at Spike-High Gamma correlations
% flag_LGHG - look at low-high gamma correlations
% Trials - parsed data from CreateONF_TrialFormat script

% Output
% Plot of path length 

xInd = 1:size(BC_I,2)
l = 1;
m = 1;
PL = cell([BC_I(end) 1]);

for i = BC_I(1):BC_I(end)
    if isempty(Trials{ControlCh,i})
        continue
    end
    % Need to do this to calculate straight line distance to target in
    % order to normalize path length for failed and incomplete trials
    TC = unique(Trials{ControlCh,i}.Targets.corners(:,2:5),'rows');
    
    % Need this to remove junk targets that come in the
    % Targets.Corners of the bdf
    if sum(sum(abs(TC),2)) > 1000
        TC = TC(sum(abs(TC),2) < 100,:)
    end
    
    if sum(sum(abs(TC) < 0.01,2))
        TC = TC(sum(abs(TC) < 0.01,2) == 0,:)
    end

    if isfield(Trials{ControlCh,i},'Path_Whole')
        PL{i}=zeros([length(Trials{ControlCh,i}.Path_Whole) 1]);
        
        for k=2:length(Trials{ControlCh,i}.Path_Whole)
            for j=2:length(Trials{ControlCh,i}.Path_Whole{k})
                % Caclulate Euclidean distance point to point
                PLpoint=sqrt((Trials{ControlCh,i}.Path_Whole{k}(j,2)- ...
                    Trials{ControlCh,i}.Path_Whole{k}(j-1,2))^2 + ...
                    (Trials{ControlCh,i}.Path_Whole{k}(j,3)- ...
                    Trials{ControlCh,i}.Path_Whole{k}(j-1,3))^2);
                
                PL{i}(k)=PL{i}(k)+PLpoint;
                
            end
            if ~isempty(Trials{ControlCh,i}.Path_Whole{k})
                interTargetDistance{i}(k)=sqrt(sum(diff(Trials{ControlCh,i}.Path_Whole{k}([1 end],2:3)).^2));
                PL{i}(k)=PL{i}(k)/interTargetDistance{i}(k);
            end
        end
    end
        
    % Add Failed trials to mean PL calc
    if isfield(Trials{ControlCh,i},'Fail_Path_Whole')
        PL{i}=[PL{i}; zeros([length(Trials{ControlCh,i}.Fail_Path_Whole) 1])];
        
        for k=2:length(Trials{ControlCh,i}.Fail_Path_Whole)
            for j=2:length(Trials{ControlCh,i}.Fail_Path_Whole{k})
                % Caclulate Euclidean distance point to point
                PLpoint=sqrt((Trials{ControlCh,i}.Fail_Path_Whole{k}(j,2)- ...
                    Trials{ControlCh,i}.Fail_Path_Whole{k}(j-1,2))^2 + ...
                    (Trials{ControlCh,i}.Fail_Path_Whole{k}(j,3)- ...
                    Trials{ControlCh,i}.Fail_Path_Whole{k}(j-1,3))^2);
                
                PL{i}(k)=PL{i}(k)+PLpoint;
                
            end
            if ~isempty(Trials{ControlCh,i}.Fail_Path_Whole{k})
                % Calculate distance from center of center target to center 
                % of any outer target, this is the straight line distance
                interTargetDistance{i}(k)=sqrt(sum([mean(TC(1,[1 3])).^2 mean(TC(1,[2 4])).^2]));
                PL{i}(k)=PL{i}(k)/interTargetDistance{i}(k);
            end
        end
    end
    
    % Add incomplete trials
    if isfield(Trials{ControlCh,i},'Incomplete_Path_Whole')
        PL{i}=[PL{i}; zeros([length(Trials{ControlCh,i}.Incomplete_Path_Whole) 1])];
        
        for k=2:length(Trials{ControlCh,i}.Incomplete_Path_Whole)
            for j=2:length(Trials{ControlCh,i}.Incomplete_Path_Whole{k})
                % Caclulate Euclidean distance point to point
                PLpoint=sqrt((Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j,2)- ...
                    Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j-1,2))^2 + ...
                    (Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j,3)- ...
                    Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j-1,3))^2);
                
                PL{i}(k)=PL{i}(k)+PLpoint;
                
            end
            if ~isempty(Trials{ControlCh,i}.Incomplete_Path_Whole{k})
                % Calculate distance from center of center target to center 
                % of any outer target, this is the straight line distance
                interTargetDistance{i}(k)=sqrt(sum([mean(TC(1,[1 3])).^2 mean(TC(1,[2 4])).^2]));
                PL{i}(k)=PL{i}(k)/interTargetDistance{i}(k);
            end
        end
    end
    
    
end

meanPL = cellfun(@mean,PL);
stePL  = cellfun(@std,PL)./sqrt(cellfun(@length,PL));

figure
shadedErrorBar(xInd,meanPL(BC_I),stePL(BC_I),'b')
ylabel('Path Length')
xlabel('Minutes of Exposure to ONF (10 min intervals)')
title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Path Length' ])
ylim(gca,[0 30])
hold on

%% Figure out when a new day occurs and plot lines
[FileList, DateNames] = CalcDecoderAge(FileList, ['01-29-2015']) 

for i = 2:size(Trials,2) 
    if segment == 1
        if strcmpi(Trials{ControlCh,i-1}.meta.filename(1:end-7),Trials{ControlCh,i}.meta.filename(1:end-7)) == 0
            NewDay(i) = 1;
        else
            NewDay(i) = 0;
        end
    else       
        if FileList{i-1,2} ~= FileList{i,2}
            NewDay(i) = 1;
        else
            NewDay(i) = 0;
        end
    end
end

k = 1;
for i = BC_I(1):BC_I(end)
    
    if NewDay(i) == 1
        plot([k k],[0 100],'k--')
    end
    k = k+1;
end


% meanSlopeX = cellfun(@nanmean,TrialVectorSlope.X);
% meanSlopeY = cellfun(@nanmean,TrialVectorSlope.Y);
% 
% steSlopeX = cellfun(@nanstd,TrialVectorSlope.X)./sqrt(cellfun(@length, TrialVectorSlope.X));
% steSlopeY = cellfun(@nanstd,TrialVectorSlope.Y)./sqrt(cellfun(@length, TrialVectorSlope.Y));
% 

% Caclulate slopes of cursor trajectory for each trial
%             % (separately to each target)
%             if Trials{ControlCh,i}.TargetID(k) == 65
%                 p = polyfit(Trials{ControlCh,i}.Path_Whole{k}(:,2),Trials{ControlCh,i}.Path_Whole{k}(:,3),1);
%                 TrialVectorSlope.X{i}(m,:) = p(1);
%                 m = m + 1;
%                 clear p
%             else
%                 p = polyfit(Trials{ControlCh,i}.Path_Whole{k}(:,2),Trials{ControlCh,i}.Path_Whole{k}(:,3),1);
%                 TrialVectorSlope.Y{i}(l,:) = p(1);
%                 l = l + 1;
%                 clear p
%             end
% figure
% errorbar(AvgCorr.PriorToReward(LFPInds{1}(1),BC_I(1:end)), meanSlopeX(BC_I),steSlopeX(BC_I),'or')
% xlabel('Reward Correlation Coefficient (R)')
% ylabel('Mean Slope Y targ')
%
% figure
% errorbar(AvgCorr.PriorToReward(LFPInds{1}(1),BC_I(1:end)), meanSlopeY(BC_I),steSlopeY(BC_I),'or')
% xlabel('Reward Correlation Coefficient (R)')
% ylabel('Mean Slope X targ')
%
% meanPL = cellfun(@mean,PL);
% stePL = cellfun(@std, PL)./sqrt(cellfun(@length, PL))
% figure
% errorbar(AvgCorr.PriorToReward(LFPInds{1}(1),BC_I(1:end)), meanPL(BC_I),stePL(BC_I),'or')
% xlabel('Reward Correlation Coefficient (R)')
% ylabel('Path Length')
%
% figure
% errorbar(AvgCorr.MovementOnset(LFPInds{1}(1),BC_I(1:end)), meanPL(BC_I),stePL(BC_I),'or')
% xlabel('Movement Onset Correlation Coefficient (R)')
% ylabel('Path Length')