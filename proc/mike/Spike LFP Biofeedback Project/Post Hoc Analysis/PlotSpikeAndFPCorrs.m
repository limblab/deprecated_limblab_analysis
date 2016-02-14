plotLGHG = 0;
plotSpHG = 0;

ControlCh =  66;
HC_I = [1:6];
BC_I = [17:26];

%% Find Sig and Insig correlations around MOVEMENT ONSET %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find all significant correlations for spike-high gamma
Sig   = AvgP.MovementOnset(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) <= .05;
Insig = AvgP.MovementOnset(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) >= .05;
Onset_Corr = AvgCorr.MovementOnset(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]);
Onset_Corr_Sig = Onset_Corr(Sig);
Onset_Corr_Insig = Onset_Corr(Insig);
clear Onset_Corr Sig Insig

% Same for low-gamma and high-gamma
Sig   = AvgP.LG_HG_MovementOnset(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) <= .05;
Insig = AvgP.LG_HG_MovementOnset(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) >= .05;
LGHG_Onset_Corr   = AvgCorr.LG_HG_MovementOnset(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]);
LGHG_Onset_Corr_Sig = LGHG_Onset_Corr(Sig);
LGHG_Onset_Corr_Insig = LGHG_Onset_Corr(Insig);
clear LGHG_Onset_Corr Sig Insig

%% Now Find all Spike and High-Gamma FP traces of significant correlations
if length(ControlCh) == 1
    Sig = zeros(ControlCh,BC_I(end));
end

fi = 1;
for j = [HC_I(1):HC_I(end) BC_I(1):BC_I(end)]
    Sig(ControlCh,j) = AvgP.MovementOnset(ControlCh,j) <= .05;
    if length(ControlCh) == 1
%         if Sig(ControlCh,j) == 1
        if j == BC_I(1)
            BC_Ind = fi;
        end
        if isempty(AvgCorr.FPTraceStart{j}) == 0
            % If just looking at control ch you're looking at all traces
            % not just sig ones
            Onset_Gam3Trace_Sig(:,fi) = AvgCorr.FPTraceStart{j}(:,ControlCh,3);
            Onset_SpTrace_Sig(:,fi)   = AvgCorr.SpTraceStart{j}(:,ControlCh);
            
            Onset_Gam3Trace_STE_Sig(:,fi) = AvgCorr.FPTraceStartSTE{j}(:,ControlCh,3);
            Onset_SpTrace_STE_Sig(:,fi)   = AvgCorr.SpTraceStartSTE{j}(:,ControlCh);
            fi = fi+1;
        else
            continue
        end
    else
        Onset_Gam3Trace_Sig(:,:,fi) = AvgCorr.FPTraceStart{j}(:,Sig(:,j)'==1,3);
        Onset_SpTrace_Sig(:,:,fi) = AvgCorr.SpTraceStart{j}(:,Sig(:,j)==1);
        
        Onset_Gam3Trace_STE_Sig(:,:,fi) = AvgCorr.FPTraceStartSTE{j}(:,Sig(:,j)'==1,3);
        Onset_SpTrace_STE_Sig(:,:,fi) = AvgCorr.SpTraceStartSTE{j}(:,Sig(:,j)==1);
        fi = fi+1;
    end
end
clear Sig fi

fi = 1;
for j = [HC_I(1):HC_I(end) BC_I(1):BC_I(end)]
    Sig(ControlCh,j) = AvgP.LG_HG_MovementOnset(ControlCh,j) <= .05;
    if length(ControlCh) == 1
%         if Sig(ControlCh,j) == 1
        if isempty(AvgCorr.FPTraceStart{j}) == 0
            Onset_LowGamTrace_Sig(:,fi) = AvgCorr.FPTraceStart{j}(:,ControlCh,1);
            Onset_Gam2Trace_Sig(:,fi)   = AvgCorr.FPTraceStart{j}(:,ControlCh,2);
            fi = fi+1;
        else
            continue
        end
    else
        Onset_LowGamTrace_Sig(:,:,fi) = AvgCorr.FPTraceStart{j}(:,Sig(:,j)'==1,1);
        Onset_Gam2Trace_Sig(:,:,fi)   = AvgCorr.FPTraceStart{j}(:,Sig(:,j)'==1,2);
        fi = fi+1;
    end
end
clear Sig fi
% Now separate out the negative correlations so we can look at their
% traces
Onset_Gam3Trace_Sig_Neg = Onset_Gam3Trace_Sig(:,Onset_Corr_Sig < 0);
Onset_SpTrace_Sig_Neg = Onset_SpTrace_Sig(:,Onset_Corr_Sig < 0);

Onset_LowGamTrace_Sig_Neg = Onset_LowGamTrace_Sig(:,LGHG_Onset_Corr_Sig < 0);
Onset_Gam2Trace_Sig_Neg = Onset_Gam2Trace_Sig(:,LGHG_Onset_Corr_Sig < 0);


%% Find Sig and Insig Correlations PRIOR TO REWARD %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Repeat for window before reward
Sig   = AvgP.PriorToReward(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) <= .05;
Insig = AvgP.PriorToReward(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) >= .05;
Reward_Corr = AvgCorr.PriorToReward(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]);
Reward_Corr_Sig = Reward_Corr(Sig);
Reward_Corr_Insig = Reward_Corr(Insig);
clear Reward_Corr Sig Insig

% Same for low-gamma and high-gamma
Sig   = AvgP.LG_HG_PriorToReward(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) <= .05;
Insig = AvgP.LG_HG_PriorToReward(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]) >= .05;
LGHG_Reward_Corr   = AvgCorr.LG_HG_PriorToReward(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)]);
LGHG_Reward_Corr_Sig = LGHG_Reward_Corr(Sig);
LGHG_Reward_Corr_Insig = LGHG_Reward_Corr(Insig);
clear LGHG_Reward_Corr Sig Insig

%% Now Find all Spike and High-Gamma FP traces of significant correlations
if length(ControlCh) == 1
    Sig = zeros(ControlCh,BC_I(end));
end

fi = 1;
for j = [HC_I(1):HC_I(end) BC_I(1):BC_I(end)]
    Sig(ControlCh,j) = AvgP.PriorToReward(ControlCh,j) <= .05;
    if length(ControlCh) == 1
%         if Sig(ControlCh,j) == 1
        if isempty(AvgCorr.FPTraceEnd{j}) == 0
            Reward_Gam3Trace_Sig(:,fi) = AvgCorr.FPTraceEnd{j}(:,ControlCh,3);
            Reward_SpTrace_Sig(:,fi)   = AvgCorr.SpTraceEnd{j}(:,ControlCh);
            fi = fi+1;
        else
            continue
        end
    else
        Reward_Gam3Trace_Sig(:,:,fi) = AvgCorr.FPTraceEnd{j}(:,Sig(:,j)'==1,3);
        Reward_SpTrace_Sig(:,:,fi) = AvgCorr.SpTraceEnd{j}(:,Sig(:,j)==1);
        fi = fi+1;
    end
end
clear Sig fi

fi = 1;
for j = [HC_I(1):HC_I(end) BC_I(1):BC_I(end)]
    Sig(ControlCh,j) = AvgP.LG_HG_PriorToReward(ControlCh,j) <= .05;
    if length(ControlCh) == 1
%         if Sig(ControlCh,j) == 1
        if isempty(AvgCorr.FPTraceEnd{j}) == 0
            Reward_LowGamTrace_Sig(:,fi) = AvgCorr.FPTraceEnd{j}(:,ControlCh,1);
            Reward_Gam2Trace_Sig(:,fi)   = AvgCorr.FPTraceEnd{j}(:,ControlCh,2);
            fi = fi+1;
        else
            continue
        end
    else
        Reward_LowGamTrace_Sig(:,:,fi) = AvgCorr.FPTraceEnd{j}(:,Sig(:,j)'==1,1);
        Reward_Gam2Trace_Sig(:,:,fi)   = AvgCorr.FPTraceEnd{j}(:,Sig(:,j)'==1,2);
        fi = fi+1;
    end
end
clear Sig fi
% Now separate out the negative correlations so we can look at their
% correlations
Reward_Gam3Trace_Sig_Neg = Reward_Gam3Trace_Sig(:,Reward_Corr_Sig < 0);
Reward_SpTrace_Sig_Neg = Reward_SpTrace_Sig(:,Reward_Corr_Sig < 0);

Reward_LowGamTrace_Sig_Neg = Reward_LowGamTrace_Sig(:,LGHG_Reward_Corr_Sig < 0);
Reward_Gam2Trace_Sig_Neg = Reward_Gam2Trace_Sig(:,LGHG_Reward_Corr_Sig < 0);

Reward_Corr_Sig    = AvgCorr.PriorToReward(AvgP.PriorToReward <= .05);
Reward_Corr_Insig  = AvgCorr.PriorToReward(AvgP.PriorToReward >= .05);

% %% Repeat using Ray method
% Ray_Start_Corr_Sig   = AvgCorr(i).Ray_Start(AvgP(i).Ray_Start <= .05);
% Ray_Start_Corr_Insig = AvgCorr(i).Ray_Start(AvgP(i).Ray_Start >= .05);
% 
% % Low-Gamma and High-Gamma
% LGHG_Ray_Start_Corr_Sig   = AvgCorr(i).Ray_Start(AvgP(i).LG_HG_Ray_Start <= .05);
% LGHG_Ray_Start_Corr_Insig = AvgCorr(i).Ray_Start(AvgP(i).LG_HG_Ray_Start >= .05);
% 
% Ray_End_Corr_Sig   = AvgCorr(i).Ray_End(AvgP(i).Ray_End <= .05);
% Ray_End_Corr_Insig = AvgCorr(i).Ray_End(AvgP(i).Ray_End >= .05);
% 
% % Low-Gamma and High-Gamma
% LGHG_Ray_End_Corr_Sig   = AvgCorr(i).Ray_End(AvgP(i).LG_HG_Ray_End <= .05);
% LGHG_Ray_End_Corr_Insig = AvgCorr(i).Ray_End(AvgP(i).LG_HG_Ray_End >= .05);

if plotSpHG == 1
    figure
    subplot(2,2,1)
    hist(Onset_Corr_Sig,-1:.1:1)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(Onset_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Spike Rate and 200-300 Hz Power Correlations during 500 ms centered around Movement Onset')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during BRAIN CONTROL (Bin size ',sprintf('%g',BinsizeCorr(i)),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    
    subplot(2,2,2)
    hist(Reward_Corr_Sig,-1:.1:1)
    h2 = findobj(gca,'Type','patch');
    set(h2,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(Reward_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Spike Rate and 200-300 Hz Power Correlations during 150 ms prior to Reward')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during HAND CONTROL (sig HC vs BC, p =  ',sprintf('%g',p),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    
    subplot(2,2,3)
    hist(Ray_Start_Corr_Sig,-1:.1:1)
    h4 = findobj(gca,'Type','patch');
    set(h4,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(Ray_Start_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Spike Rate and 200-300 Hz Power Correlations using Ray Method with 500 ms centered around Movement Onset')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during HAND CONTROL (sig HC vs BC, p =  ',sprintf('%g',p),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    
    subplot(2,2,4)
    hist(Ray_End_Corr_Sig,-1:.1:1)
    h6 = findobj(gca,'Type','patch');
    set(h6,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(Ray_End_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Spike Rate and 200-300 Hz Power Correlations using Ray Method with 150 ms prior to Reward')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during HAND CONTROL (sig HC vs BC, p =  ',sprintf('%g',p),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    clear h*
end
if plotLGHG == 1
    
    figure
    subplot(2,2,1)
    hist(LGHG_Onset_Corr_Sig,-1:.1:1)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(LGHG_Onset_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Low Gamma (30-50 Hz) and High Gamma (120-200 Hz) Power Correlations during 500 ms centered around Movement Onset')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during BRAIN CONTROL (Bin size ',sprintf('%g',BinsizeCorr(i)),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    
    subplot(2,2,2)
    hist(LGHG_Reward_Corr_Sig,-1:.1:1)
    h2 = findobj(gca,'Type','patch');
    set(h2,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(LGHG_Reward_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Low Gamma (30-50 Hz) and High Gamma (120-200 Hz) Power Correlations during 150 ms prior to Reward')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during HAND CONTROL (sig HC vs BC, p =  ',sprintf('%g',p),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    
    subplot(2,2,3)
    hist(LGHG_Ray_Start_Corr_Sig,-1:.1:1)
    h4 = findobj(gca,'Type','patch');
    set(h4,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(LGHG_Ray_Start_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Low Gamma (30-50 Hz) and High Gamma (120-200 Hz) Power Correlations using Ray Method with 500 ms centered around Movement Onset')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during HAND CONTROL (sig HC vs BC, p =  ',sprintf('%g',p),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    
    subplot(2,2,4)
    hist(LGHG_Ray_End_Corr_Sig,-1:.1:1)
    h6 = findobj(gca,'Type','patch');
    set(h6,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
    
    hold on
    
    hist(LGHG_Ray_End_Corr_Insig,-1:.1:1)
    set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
    
    title('Low Gamma (30-50 Hz) and High Gamma (120-200 Hz) Power Correlations using Ray Method with 150 ms prior to Reward')
    %     title(['Spike Rate and 200-300 Hz Power Correlations during HAND CONTROL (sig HC vs BC, p =  ',sprintf('%g',p),' )'])
    legend('Significant Correlations','Insignificant Correlations')
    xlim([-1 1])
    clear h*
end



% figure
% for i = 1 : size(Reward_Gam2Trace_Sig,2)
%     
%     Rows = ceil(size(Reward_Gam2Trace_Sig,2)/4);
%     subplot(Rows,4,i)
%     [AX,H1,H2] = plotyy([0:150],Reward_Gam2Trace_Sig(:,i),[0:150],Reward_LowGamTrace_Sig(:,i))
%     set(AX(1),'Xlim',[0 150])
%     set(AX(1),'XTick',[0,50,100,150],'XTickLabel',{'-150','-100','-50','0'})
%     set(H1,'Color','b')
%     set(AX(2),'Xlim',[0 150])
%     set(AX(2),'XTick',[0,50,100,150],'XTickLabel',{'-150','-100','-50','0'})
%     set(H2,'LineWidth',3.0)
%     if i == BC_Ind
%         title('Brain Control')
%     end
% end
% legend('Gamma 130-200 Hz','Low Gamma')
% figure
% for i = 1 : size(Onset_Gam2Trace_Sig,2)
%     
%     Rows = ceil(size(Onset_Gam2Trace_Sig,2)/4);
%     subplot(Rows,4,i)
%     [AX,H1,H2] = plotyy([0:500],Onset_Gam2Trace_Sig(:,i),[0:500],Onset_LowGamTrace_Sig(:,i))
%     set(AX(1),'Xlim',[0 500])
%     set(AX(1),'XTick',[0,250,500],'XTickLabel',{'-0.25','0','.25'})
%     set(H1,'Color','b')
%     set(AX(2),'Xlim',[0 500])
%     set(AX(2),'XTick',[0,250,500],'XTickLabel',{'-0.25','0','.25'})
%     set(H2,'LineWidth',3.0)
%     if i == BC_Ind
%         title('Brain Control')
%     end
% end
% legend('Gamma 130-200 Hz','Low Gamma')

figure
for i = 1 : size(Onset_Gam3Trace_Sig,2)
    
    Rows = ceil(size(Onset_Gam3Trace_Sig,2)/4);
    subplot(Rows,4,i)
%     [AX,H1,H2] = plotyy([0:500],Onset_Gam3Trace_Sig(:,i),[0:500],Onset_SpTrace_Sig(:,i))
    [ax H]= shadedErrorBaryy([0:500],Onset_Gam3Trace_Sig(:,i),Onset_Gam3Trace_STE_Sig(:,i),'g',[0:500],Onset_SpTrace_Sig(:,i),Onset_SpTrace_STE_Sig(:,i),'r')
    set(ax(1),'Xlim',[0 500])
    set(ax(1),'XTick',[0,250,500],'XTickLabel',{'-0.25','0','.25'})
%     set(H(1),'Color','b')
    set(ax(2),'Xlim',[0 500])
    set(ax(2),'XTick',[0,250,500],'XTickLabel',{'-0.25','0','.25'})
%     set(H(2),'LineWidth',3.0)
    if i == BC_Ind
        title('Brain Control')
    end
    ah = findobj(gca,'TickDirMode','auto')
    set(ah,'Box','off')
    set(ah,'TickLength',[0,0])
end
legend('High Gamma 200-300 Hz','Spikes')

figure
for i = 1 : size(Reward_Gam3Trace_Sig,2)
    
    Rows = ceil(size(Reward_Gam3Trace_Sig,2)/4);
    subplot(Rows,4,i)
    [AX,H1,H2] = plotyy([0:150],Reward_Gam3Trace_Sig(:,i),[0:150],Reward_SpTrace_Sig(:,i))
    set(AX(1),'Xlim',[0 150])
    set(AX(1),'XTick',[0,50,100,150],'XTickLabel',{'-150','-100','-50','0'})
    set(H1,'Color','b')
    set(AX(2),'Xlim',[0 150])
    set(AX(2),'XTick',[0,50,100,150],'XTickLabel',{'-150','-100','-50','0'})
    set(H2,'LineWidth',3.0)
    if i == BC_Ind
        title('Brain Control')
    end
end

legend('High Gamma 200-300 Hz','Spikes')

% [h p ] = ttest2(HC_Correlations_Sig,BC_Correlations_Sig)