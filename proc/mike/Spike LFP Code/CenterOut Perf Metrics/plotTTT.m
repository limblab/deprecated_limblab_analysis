function [meanTTT, steTTT] = plotTTT(HC_I, BC_I, ControlCh, ~, ~, ...
    Trials, AvgCorr, FileList, segment, ~, WinLen, overlap, monkey_name)
% Caclulate time to target for center out task


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
    if isfield(Trials{ControlCh,i},'Fail_TTT')
        AllTTT = [AllTTT Trials{ControlCh,i}.Fail_TTT]
    end
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

figure
shadedErrorBar(xInd,meanTTT(BC_I),steTTT(BC_I),'b')
hold on

ylabel('Time to Target (mean +/- STE)')
if segment == 1
    % WinLen and overlap come from CreateONF_TrialFormat script
    xlabel(['Exposure to ONF (',sprintf('%d',WinLen/60),'min sliding window, ',...
        sprintf('%d',overlap/60),'min overlap)'])
else
    xlabel('Minutes of Exposure to ONF (10 min segments)')
end

ah = findobj(gca,'TickDirMode','auto')
set(ah,'Box','off')
set(ah,'TickLength',[0,0])
ylim(gca,[0 30])

%% Figure out when a new day occurs and plot lines
[FileList, DateNames] = CalcDecoderAge(FileList, ['01-29-2015']);

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
%     set(ax(1),'Xlim',[0 500])
%      set(gca,'XTick',[1,3,5,7,9,11,13,15,17],'XTickLabel',{'10','30','50','70','90','110','130','150','170'})
%      set(gca,'XTick',[2,4,6,8],'XTickLabel',{'20','40','60','80'})


%% TTT vs correlation
figure
[hAx,hLine1,hLine2] = plotyy(1:length(BC_I), meanTTT(BC_I),1:length(BC_I),AvgCorr.PriorToReward_AllTrials(ControlCh,BC_I))

ylabel(hAx(1),'TTT')
set(hLine1,'Marker','o')
set(hLine1,'MarkerSize',15.0)
ylim(hAx(1),[0 30])
set(hAx(1),'Ytick',[0,15,30],'YTicklabel',{'0','15','30'})

ylabel(hAx(2),'Spike-HG Spearmann Rank Correlation (R)')
set(hLine2,'Marker','x')
set(hLine2,'LineStyle','--')
ylim(hAx(2),[-1 1])
set(hAx(2),'Ytick',[-1, 0, 1],'YTicklabel',{'-1','0','1'})

if segment == 1
    % WinLen and overlap come from CreateONF_TrialFormat script
    xlabel(['Minutes of Exposure to ONF (',sprintf('%d',WinLen/60),'min sliding window, ',...
        sprintf('%d',overlap/60),'min overlap)'])
else
    xlabel('Minutes of Exposure to ONF (10 min segments)')
end

hold on

title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' TTT and Spike - High Gamma Correlations (All Trials)' ])
 
% %% Percent success vs correlation
% figure
% [hAx,hLine1,hLine2] = plotyy(1:length(BC_I),Num.PercentSuccess_File(BC_I(1):BC_I(end)),1:length(BC_I),AvgCorr.PriorToReward_AllTrials(ControlCh,BC_I))
% set(hLine2,'Marker','x')
% legend('Percent Success','Spike-HG Correlation')
% hold on
% 
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Percent Success and Spike - High Gamma Correlations (All Trials)' ])
% 
% %% Number of successes vs correlation
% figure
% [hAx,hLine1,hLine2] = plotyy(1:length(BC_I),Num.Success_File(BC_I(1):BC_I(end)),1:length(BC_I),AvgCorr.PriorToReward_AllTrials(ControlCh,BC_I))
% set(hLine2,'Marker','x')
% legend('Number Successes','Spike-HG Correlation')
% hold on
% 
% title([sprintf('%s',monkey_name),' Ch ',sprintf('%d',ControlCh),' Number of Successes and Spike - High Gamma Correlations (All Trials)' ])
% 
% legend('High Gamma 200-300 Hz','Spikes')
% figure
% errorbar(AvgCorr.PriorToReward(ControlCh,BC_I(1:end)), meanTTT(BC_I), steTTT(BC_I),'or')
% xlabel('Correlation Coefficient (R)')
% ylabel('TTT')