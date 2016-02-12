function [] = plotPathLength(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG,...
    Trials, AvgCorr, FileList, segment, monkey_name)
% Calculates path length based on Trials structure created in
% script 'CrossFreqCoupling'
dayAvg = 0;
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
                if sqrt(sum(diff(Trials{ControlCh,i}.Path_Whole{k}([1 end],2:3)).^2)) == 0
                    continue
                else
                    interTargetDistance{i}(k)=sqrt(sum(diff(Trials{ControlCh,i}.Path_Whole{k}([1 end],2:3)).^2));
                end
                PL{i}(k)=PL{i}(k)/interTargetDistance{i}(k);
            end
        end
    end
    
    PLind = length(PL{i})+1;
    % Add Failed trials to mean PL calc
%     if isfield(Trials{ControlCh,i},'Fail_Path_Whole')
%         PL{i}=[PL{i}; zeros([length(Trials{ControlCh,i}.Fail_Path_Whole) 1])];
%         
%         for k = 2:length(Trials{ControlCh,i}.Fail_Path_Whole)
%             for j=2:length(Trials{ControlCh,i}.Fail_Path_Whole{k})
%                 % Caclulate Euclidean distance point to point
%                 PLpoint=sqrt((Trials{ControlCh,i}.Fail_Path_Whole{k}(j,2)- ...
%                     Trials{ControlCh,i}.Fail_Path_Whole{k}(j-1,2))^2 + ...
%                     (Trials{ControlCh,i}.Fail_Path_Whole{k}(j,3)- ...
%                     Trials{ControlCh,i}.Fail_Path_Whole{k}(j-1,3))^2);
%                 
%                 PL{i}(PLind)=PL{i}(PLind)+PLpoint;
%                 
%             end
%             if ~isempty(Trials{ControlCh,i}.Fail_Path_Whole{k})
%                 % Calculate distance from center of center target to center 
%                 % of any outer target, this is the straight line distance
%                 interTargetDistance{i}(PLind)=sqrt(sum([mean(TC(1,[1 3])).^2 mean(TC(1,[2 4])).^2]));
%                 PL{i}(PLind)=PL{i}(PLind)/interTargetDistance{i}(PLind);
%             end
%         end
%     end
    
    PLind = length(PL{i})+1;
    % Add incomplete trials
    if isfield(Trials{ControlCh,i},'Incomplete_Path_Whole')
        PL{i}=[PL{i}; zeros([length(Trials{ControlCh,i}.Incomplete_Path_Whole) 1])];
        
        for k = 2:length(Trials{ControlCh,i}.Incomplete_Path_Whole)
            for j=2:length(Trials{ControlCh,i}.Incomplete_Path_Whole{k})
                % Caclulate Euclidean distance point to point
                PLpoint=sqrt((Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j,2)- ...
                    Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j-1,2))^2 + ...
                    (Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j,3)- ...
                    Trials{ControlCh,i}.Incomplete_Path_Whole{k}(j-1,3))^2);
                
                PL{i}(PLind)=PL{i}(PLind)+PLpoint;
                
            end
            if ~isempty(Trials{ControlCh,i}.Incomplete_Path_Whole{k})
                % Calculate distance from center of center target to center 
                % of any outer target, this is the straight line distance
                interTargetDistance{i}(PLind)=sqrt(sum([mean(TC(1,[1 3])).^2 mean(TC(1,[2 4])).^2]));
                PL{i}(PLind)=PL{i}(PLind)/interTargetDistance{i}(PLind);
            end
        end
    end
    
    
end

meanPL = cellfun(@mean,PL);
stePL  = cellfun(@std,PL)./sqrt(cellfun(@length,PL));
% 
% figure
% shadedErrorBar(xInd,meanPL(BC_I),stePL(BC_I),'b')
% ylabel('Path Length')
% xlabel('Minutes of Exposure to ONF (10 min intervals)')
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Path Length' ])
% ylim(gca,[0 30])
% hold on

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

% k = 1;
% for i = BC_I(1):BC_I(end)
%     
%     if NewDay(i) == 1
%         plot([k k],[0 100],'k--')
%     end
%     k = k+1;
% end

%% Figure out when a new day occurs and plot lines
di = 1; % day index
meanPL = cellfun(@mean,PL);
meanPL_byDay = cell([size(FileList,1) 1]);
AvgCorr_byDay = cell([size(FileList,1) 1]);

for i = BC_I(1):BC_I(end)%2:size(Trials,2) 
    if segment == 1
        if strcmpi(Trials{ControlCh,i-1}.meta.filename(1:end-7),Trials{ControlCh,i}.meta.filename(1:end-7)) == 0
            NewDay(i) = 1;
        else
            NewDay(i) = 0;
        end
    else       
        if size(FileList,1)+1 > i
            if i == BC_I(end)
                meanPL_byDay{di} = [meanPL_byDay{di} meanPL(i)];
                if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
                end
                NewDay(i) = 1;
                continue
            end
        end
        if FileList{i+1,2} ~= FileList{i,2}
            if i == BC_I(end)
                meanPL_byDay{di} = [meanPL_byDay{di} meanPL(i)];
                if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
                end
                NewDay(i) = 1;
                continue
            end
            meanPL_byDay{di} = [meanPL_byDay{di} meanPL(i)];            
            if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
            end
            di = di +1;
            NewDay(i) = 1;
            
        else
            meanPL_byDay{di} = [meanPL_byDay{di} meanPL(i)];            
            if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
            end
            NewDay(i) = 0;
        end
    end
end

%% PL vs corr
if dayAvg == 1
    meanPL_byDayMAT = cellfun(@nanmean,meanPL_byDay);
    stdPL_byDayMAT  = cellfun(@nanstd,meanPL_byDay)./sqrt(cellfun(@length,meanPL_byDay));
    if iscell(AvgCorr_byDay{1,1})
        AvgCorr_byDayMAT = zeros(length(meanPL_byDayMAT),1)
        STDCorr_byDayMAT = zeros(length(meanPL_byDayMAT),1)
    else
        AvgCorr_byDayMAT = cellfun(@nanmean,AvgCorr_byDay);
        STDCorr_byDayMAT = cellfun(@nanstd,AvgCorr_byDay);
    end
    di = di - nnz(isnan(meanPL_byDayMAT(1:di)))
    meanPL_byDayMAT(isnan(meanPL_byDayMAT(1:di))) = [];
    stdPL_byDayMAT(isnan(stdPL_byDayMAT(1:di))) = [];
    AvgCorr_byDayMAT(isnan(AvgCorr_byDayMAT(1:di))) = [];
    STDCorr_byDayMAT(isnan(STDCorr_byDayMAT(1:di))) = [];
    
    figure
    h = plot(1:di, meanPL_byDayMAT(1:di),'o-',...
        1:di, meanPL_byDayMAT(1:di)+stdPL_byDayMAT(1:di),'b--',...
        1:di, meanPL_byDayMAT(1:di)-stdPL_byDayMAT(1:di),'b--')
    set(h(1),'MarkerSize',15.0)
    set(h(1),'LineWidth',4.0)
    set(h(2),'LineWidth',2.0)
    set(h(3),'LineWidth',2.0)
    ylim([0 10])
    set(gca,'Ytick',[0,5,10],'YTicklabel',{'0','5','10'})
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
    xlabel('Session')
    ylabel('Path Length')
else
    di = sum(cellfun(@length,meanPL_byDay));
    PL_byFile = meanPL(BC_I(1):BC_I(end));
    stePL_byFile  = stePL(BC_I(1):BC_I(end));
    
    figure
    h = plot(1:di, PL_byFile','o-',...
        1:di, (PL_byFile+stePL_byFile)','b--',...
        1:di, (PL_byFile-stePL_byFile)','b--')
    set(h(1),'MarkerSize',15.0)
    set(h(1),'LineWidth',4.0)
    set(h(2),'LineWidth',2.0)
    set(h(3),'LineWidth',2.0)
    ylim([0 10])
    set(gca,'Ytick',[0,5,10],'YTicklabel',{'0','5','10'})
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
    xlabel('Session')
    ylabel('Path Length')
end
%% PL by day fig
% figure
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, meanPL_byDayMAT(1:di)) %,1:di, AvgCorr_byDayMAT(1:di))
% set(hLine1,'Marker','o')
% set(hLine1,'MarkerSize',15.0)
% set(hLine2,'Marker','x')
% set(hLine2,'MarkerSize',15.0)
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1.0, 0, 1.0],'YTicklabel',{'-1.0','0','01.0'})
% set(hLine1,'LineWidth',4.0)
% set(hLine2,'LineWidth',4.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% xlabel('Session')
% hold on
% 
% [hAx,hLine1,hLine2] = plotyy(1:di, meanPL_byDayMAT(1:di)+stdPL_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)+STDCorr_byDayMAT(1:di))
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1.0, 0, 1.0],'YTicklabel',{'-1.0','0','01.0'})
% set(hLine1,'LineStyle','--')
% set(hLine2,'LineStyle','--')
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% hold on
% 
% [hAx,hLine1,hLine2] = plotyy(1:di, meanPL_byDayMAT(1:di)-stdPL_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)-STDCorr_byDayMAT(1:di))
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% 
% ylabel(hAx(1),'PL (s)')
% set(hLine1,'LineStyle','--')
% ylim(hAx(1),[0 10])
% set(hAx(1),'Ytick',[0,5,10],'YTicklabel',{'0','5','10'})
% 
% ylabel(hAx(2),'Spike-HG Spearmann Rank Correlation (R)')
% set(hLine2,'LineStyle','--')
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-01.0, 0, 1.0],'YTicklabel',{'-1.0','0','01.0'})
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Path Length' ])
