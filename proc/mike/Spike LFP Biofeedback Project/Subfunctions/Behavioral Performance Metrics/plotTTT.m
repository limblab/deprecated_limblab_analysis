function [meanTTT, steTTT] = plotTTT(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG, ...
    Trials, AvgCorr, FileList, segment, ~, WinLen, overlap, monkey_name,Num)
% Caclulate time to target for center out task
DayAvg = 0;

% Input
% HC_I - index for hand control files
% BC_I - index for brain control files
% ControlCh - channels of interest
% flag_SpHG - look at Spike-High Gamma correlations
% flag_LGHG - look at low-high gamma correlations
% Trials - parsed data from CreateONF_TrialFormat script

% Output
% Plot of TTT

xInd = 1:size(BC_I,2)

for i = 1:size(Trials,2)
    AllTTT = [];
    if isfield(Trials{ControlCh,i},'TTT')
            AllTTT = Trials{ControlCh,i}.TTT;
    end 
    
    % Add Failed trials to mean TTT calc
%     if isfield(Trials{ControlCh,i},'Fail_TTT')
%         AllTTT = [AllTTT Trials{ControlCh,i}.Fail_TTT]
%     end
    % Add incomplete trials
    if isfield(Trials{ControlCh,i},'Incomplete_TTT')
        AllTTT = [AllTTT Trials{ControlCh,i}.Incomplete_TTT]
    end
    if exist('AllTTT','var')
        meanTTT(i) = mean(AllTTT)
        steTTT(i)  = std(AllTTT)/sqrt(length(AllTTT))
    else
        continue
    end
    clear AllTTT
end

%% Now plot TTT
% 
% figure
% shadedErrorBar(xInd,meanTTT(BC_I),steTTT(BC_I),'b')
% hold on
% 
% ylabel('Time to Target (mean +/- STE)')
% if segment == 1
%     % WinLen and overlap come from CreateONF_TrialFormat script
%     xlabel(['Exposure to ONF (',sprintf('%d',WinLen/60),'min sliding window, ',...
%         sprintf('%d',overlap/60),'min overlap)'])
% else
%     xlabel('Minutes of Exposure to ONF (10 min segments)')
% end
% 
% ah = findobj(gca,'TickDirMode','auto')
% set(ah,'Box','off')
% set(ah,'TickLength',[0,0])
% ylim(gca,[0 30])

%% Figure out when a new day occurs and plot lines
[FileList, DateNames] = CalcDecoderAge(FileList, ['01-29-2015']);
di = 1; % day index
meanTTT_byDay = cell([size(FileList,1) 1]);
AvgCorr_byDay = cell([size(FileList,1) 1]);
PercentSuccess_byDay = cell([size(FileList,1) 1]);
NumSuccess_byDay = cell([size(FileList,1) 1]);

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
                meanTTT_byDay{di} = [meanTTT_byDay{di} meanTTT(i)];
                if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
                end
                PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} Num.PercentSuccess_File(i)];
                NumSuccess_byDay{di} = [NumSuccess_byDay{di} Num.Success_File(i)];
                NewDay(i) = 1;
                continue
            end
        end
        if FileList{i+1,2} ~= FileList{i,2}
            if i == BC_I(end)
                meanTTT_byDay{di} = [meanTTT_byDay{di} meanTTT(i)];
                if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
                end
                if Num.PercentSuccess_File(i) == 0
                    PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} NaN];
                    NumSuccess_byDay{di} = [NumSuccess_byDay{di} NaN];
                    NewDay(i) = 1;
                else
                    PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} Num.PercentSuccess_File(i)];
                    NumSuccess_byDay{di} = [NumSuccess_byDay{di} Num.Success_File(i)];
               
                end
                NewDay(i) = 1;
                continue
            end
            
            meanTTT_byDay{di} = [meanTTT_byDay{di} meanTTT(i)];
            if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
            end
            if Num.PercentSuccess_File(i) == 0
                PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} NaN];
                NumSuccess_byDay{di} = [NumSuccess_byDay{di} NaN];
                NewDay(i) = 1;
            else
                PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} Num.PercentSuccess_File(i)];
                NumSuccess_byDay{di} = [NumSuccess_byDay{di} Num.Success_File(i)];
            end
            di = di +1;
            NewDay(i) = 1;
            
        else
            meanTTT_byDay{di} = [meanTTT_byDay{di} meanTTT(i)];
            if flag_SpHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.PriorToReward_AllTrials(ControlCh,i)];
                elseif flag_LGHG == 1
                    AvgCorr_byDay{di} = [AvgCorr_byDay{di} AvgCorr.LG_HG_PriorToReward_AllTrials(ControlCh,i)];
            end
            
            if Num.PercentSuccess_File(i) == 0
                PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} NaN];
                NumSuccess_byDay{di} = [NumSuccess_byDay{di} NaN];
                NewDay(i) = 1;
            else
                PercentSuccess_byDay{di} = [PercentSuccess_byDay{di} Num.PercentSuccess_File(i)];
                NumSuccess_byDay{di} = [NumSuccess_byDay{di} Num.Success_File(i)];
            end            
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
%     set(ax(1),'Xlim',[0 500])
%      set(gca,'XTick',[1,3,5,7,9,11,13,15,17],'XTickLabel',{'10','30','50','70','90','110','130','150','170'})
%      set(gca,'XTick',[2,4,6,8],'XTickLabel',{'20','40','60','80'})


%% TTT vs correlation
if DayAvg == 1
    meanTTT_byDayMAT = cellfun(@nanmean,meanTTT_byDay);
    stdTTT_byDayMAT  = cellfun(@nanstd,meanTTT_byDay)./sqrt(cellfun(@length,meanTTT_byDay));
    if iscell(AvgCorr_byDay{1,1})
        AvgCorr_byDayMAT = zeros(length(meanTTT_byDayMAT),1)
        STDCorr_byDayMAT = zeros(length(meanTTT_byDayMAT),1)
    else
        AvgCorr_byDayMAT = cellfun(@nanmean,AvgCorr_byDay);
        STDCorr_byDayMAT = cellfun(@nanstd,AvgCorr_byDay);
    end
    PercentSuccess_byDayMAT = cellfun(@nanmean,PercentSuccess_byDay);
    PercentSuccessSTD_byDayMAT = cellfun(@nanstd,PercentSuccess_byDay)./sqrt(cellfun(@length,PercentSuccess_byDay));
    NumSuccess_byDayMAT = cellfun(@nanmean,NumSuccess_byDay);
    NumSuccessSTD_byDayMAT = cellfun(@nanstd, NumSuccess_byDay)./sqrt(cellfun(@length,NumSuccess_byDay));
    
    % uppLim = max(AvgCorr_byDayMAT(1:di)+STDCorr_byDayMAT(1:di));
    % lowLim = min(AvgCorr_byDayMAT(1:di)-STDCorr_byDayMAT(1:di));
    
    di = di - nnz(isnan(meanTTT_byDayMAT(1:di)))
    meanTTT_byDayMAT(isnan(meanTTT_byDayMAT(1:di))) = [];
    stdTTT_byDayMAT(isnan(stdTTT_byDayMAT(1:di))) = [];
    AvgCorr_byDayMAT(isnan(AvgCorr_byDayMAT(1:di))) = [];
    STDCorr_byDayMAT(isnan(STDCorr_byDayMAT(1:di))) = [];
    PercentSuccess_byDayMAT(isnan(PercentSuccess_byDayMAT(1:di))) = [];
    PercentSuccessSTD_byDayMAT(isnan(PercentSuccessSTD_byDayMAT(1:di))) = [];
    NumSuccess_byDayMAT(isnan(NumSuccess_byDayMAT(1:di))) = [];
    NumSuccessSTD_byDayMAT(isnan(NumSuccessSTD_byDayMAT(1:di))) = [];
else
    di = sum(cellfun(@length,meanTTT_byDay));
    TTT_byFile = meanTTT(BC_I(1):BC_I(end));
    steTTT_byFile  = steTTT(BC_I(1):BC_I(end));
    
    PercentSuccess_byFile = cell2mat(PercentSuccess_byDay');
    NumSuccess_byFile = cell2mat(NumSuccess_byDay');
   
    
    figure
    h = plot(1:di, TTT_byFile,'o-',...
        1:di, TTT_byFile+steTTT_byFile,'b--',...
        1:di, TTT_byFile-steTTT_byFile,'b--')
    set(h(1),'MarkerSize',15.0)
    set(h(1),'LineWidth',4.0)
    set(h(2),'LineWidth',2.0)
    set(h(3),'LineWidth',2.0)
    ylim([0 15])
    set(gca,'Ytick',[0,5,10,15],'YTicklabel',{'0','5','10','15'})
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
    xlabel('Session')
    ylabel('TTT')
    
    figure
    h = plot(1:di, PercentSuccess_byFile(1:di),'o-')
    set(h(1),'MarkerSize',15.0)
    set(h(1),'LineWidth',4.0)
    ylim([0 100])
    set(gca,'Ytick',[0,50,100],'YTicklabel',{'0','50','100'})
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
    xlabel('Session')
    ylabel('Percent Success')
    
    figure
    h = plot(1:di, NumSuccess_byFile(1:di),'o-')
    set(h(1),'MarkerSize',15.0)
    set(h(1),'LineWidth',4.0)
    ylim([0 100])
    set(gca,'Ytick',[0,30,60,90],'YTicklabel',{'0','30','60','90'})
    title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
    xlabel('Session')
    ylabel('Number of Successes')
    return
end

%% TTT, %Succ, #Succ with error bars
figure

h = plot(1:di, meanTTT_byDayMAT(1:di),'o-',...
    1:di, meanTTT_byDayMAT(1:di)+stdTTT_byDayMAT(1:di),'b--',...
    1:di, meanTTT_byDayMAT(1:di)-stdTTT_byDayMAT(1:di),'b--')
set(h(1),'MarkerSize',15.0)
set(h(1),'LineWidth',4.0)
set(h(2),'LineWidth',2.0)
set(h(3),'LineWidth',2.0)
ylim([0 10])
set(gca,'Ytick',[0,5,10],'YTicklabel',{'0','5','10'})
title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
xlabel('Session')
ylabel('TTT (s)')

figure
h = plot(1:di, PercentSuccess_byDayMAT(1:di),'o-',...
    1:di, PercentSuccess_byDayMAT(1:di)+PercentSuccessSTD_byDayMAT(1:di),'b--',...
    1:di, PercentSuccess_byDayMAT(1:di)-PercentSuccessSTD_byDayMAT(1:di),'b--')
set(h(1),'MarkerSize',15.0)
set(h(1),'LineWidth',4.0)
set(h(2),'LineWidth',2.0)
set(h(3),'LineWidth',2.0)
ylim([0 100])
set(gca,'Ytick',[0,50,100],'YTicklabel',{'0','50','100'})
title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
xlabel('Session')
ylabel('Percent Success')

figure
h = plot(1:di, NumSuccess_byDayMAT(1:di),'o-',...
    1:di, NumSuccess_byDayMAT(1:di)+NumSuccessSTD_byDayMAT(1:di),'b--',...
    1:di, NumSuccess_byDayMAT(1:di)-NumSuccessSTD_byDayMAT(1:di),'b--')
set(h(1),'MarkerSize',15.0)
set(h(1),'LineWidth',4.0)
set(h(2),'LineWidth',2.0)
set(h(3),'LineWidth',2.0)
ylim([0 100])
set(gca,'Ytick',[0,30,60,90],'YTicklabel',{'0','30','60','90'})
title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh)])
xlabel('Session')
ylabel('Number of Successes')

%% TTT by day fig
% figure
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Path Length' ])
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, meanTTT_byDayMAT(1:di),1:di,AvgCorr_byDayMAT(1:di))
% set(hLine1,'Marker','o')
% set(hLine1,'MarkerSize',15.0)
% set(hLine2,'Marker','x')
% set(hLine2,'MarkerSize',15.0)
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1.0, 0, 1.0],'YTicklabel',{'-01.0','0','01.0'})
% set(hLine1,'LineWidth',4.0)
% set(hLine2,'LineWidth',4.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% xlabel('Session')
% 
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, meanTTT_byDayMAT(1:di)+stdTTT_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)+STDCorr_byDayMAT(1:di))
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1.0, 0, 1.0],'YTicklabel',{'-01.0','0','01.0'})
% set(hLine1,'LineStyle','--')
% set(hLine2,'LineStyle','--')
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, meanTTT_byDayMAT(1:di)-stdTTT_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)-STDCorr_byDayMAT(1:di))
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% 
% ylabel(hAx(1),'TTT (s)')
% set(hLine1,'LineStyle','--')
% ylim(hAx(1),[0 10])
% set(hAx(1),'Ytick',[0,5,10],'YTicklabel',{'0','5','10'})
% 
% if flag_SpHG == 1
%     ylabel(hAx(2),'Spike-HG Spearmann Rank Correlation (R)')
% elseif flag_LGHG == 1
%     ylabel(hAx(2),'LG-HG Spearmann Rank Correlation (R)')
% end
% set(hLine2,'LineStyle','--')
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-01.0, 0, 1.0],'YTicklabel',{'-01.0','0','01.0'})
% 
% %% Percent success by day fig
% figure
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Path Length' ])
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, PercentSuccess_byDayMAT(1:di),1:di,AvgCorr_byDayMAT(1:di))
% set(hLine1,'Marker','o')
% set(hLine1,'MarkerSize',15.0)
% set(hLine2,'Marker','x')
% set(hLine2,'MarkerSize',15.0)
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-01.0','0','01.0'})
% set(hLine1,'LineWidth',4.0)
% set(hLine2,'LineWidth',4.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% xlabel('Session')
% 
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, PercentSuccess_byDayMAT(1:di)+PercentSuccessSTD_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)+STDCorr_byDayMAT(1:di))
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-01.0','0','01.0'})
% set(hLine1,'LineStyle','--')
% set(hLine2,'LineStyle','--')
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% 
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, PercentSuccess_byDayMAT(1:di)-PercentSuccessSTD_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)-STDCorr_byDayMAT(1:di))
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% 
% ylabel(hAx(1),'Percent Success')
% set(hLine1,'LineStyle','--')
% ylim(hAx(1),[0 100])
% set(hAx(1),'Ytick',[0,50,100],'YTicklabel',{'0','50','100'})
% 
% if flag_SpHG == 1
%     ylabel(hAx(2),'Spike-HG Spearmann Rank Correlation (R)')
% elseif flag_LGHG == 1
%     ylabel(hAx(2),'LG-HG Spearmann Rank Correlation (R)')
% end
% 
% set(hLine2,'LineStyle','--')
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-01.0','0','01.0'})
% 
% %% Num by day fig
% figure
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Path Length' ])
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, NumSuccess_byDayMAT(1:di),1:di,AvgCorr_byDayMAT(1:di))
% set(hLine1,'Marker','o')
% set(hLine1,'MarkerSize',15.0)
% set(hLine2,'Marker','x')
% set(hLine2,'MarkerSize',15.0)
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-01.0','0','01.0'})
% set(hLine1,'LineWidth',4.0)
% set(hLine2,'LineWidth',4.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% xlabel('Session')
% 
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, NumSuccess_byDayMAT(1:di)+NumSuccessSTD_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)+STDCorr_byDayMAT(1:di))
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-01.0','0','01.0'})
% set(hLine1,'LineStyle','--')
% set(hLine2,'LineStyle','--')
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% 
% hold on
% [hAx,hLine1,hLine2] = plotyy(1:di, NumSuccess_byDayMAT(1:di)-NumSuccessSTD_byDayMAT(1:di),1:di,...
%     AvgCorr_byDayMAT(1:di)-STDCorr_byDayMAT(1:di))
% set(hLine1,'LineWidth',2.0)
% set(hLine2,'LineWidth',2.0)
% set(hAx(1),'Xtick',1:di,'XTicklabel',{1:di})
% set(hAx(2),'Xtick',1:di,'XTicklabel',{1:di})
% 
% ylabel(hAx(1),'Number of Successes')
% set(hLine1,'LineStyle','--')
% ylim(hAx(1),[0 100])
% set(hAx(1),'Ytick',[0,50,100],'YTicklabel',{'0','50','100'})
% 
% if flag_SpHG == 1
%     ylabel(hAx(2),'Spike-HG Spearmann Rank Correlation (R)')
% elseif flag_LGHG == 1
%     ylabel(hAx(2),'LG-HG Spearmann Rank Correlation (R)')
% end
% set(hLine2,'LineStyle','--')
% ylim(hAx(2),[-1.0 1.0])
% set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-01.0','0','01.0'})
