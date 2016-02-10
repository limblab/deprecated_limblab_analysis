%% New plot code
HCi = [1 2];
BC1Dsi = [3 4];
BC1Dg3i = [9 11];
BC2Di = [23 25];

for t = 1:size(Coherency,1)
    
CoherencyCAT(t,1).AllFiles = cat(3,Coherency(t,HCi(1):HCi(2)).AllFiles);
CoherencyCAT(t,1).Error = cat(3,Coherency(t,HCi(1):HCi(2)).Error);
CoherencyCAT(t,2).AllFiles = cat(3,Coherency(t,BC1Dsi(1):BC1Dsi(2)).AllFiles);
CoherencyCAT(t,2).Error = cat(3,Coherency(t,BC1Dsi(1):BC1Dsi(2)).Error);
CoherencyCAT(t,3).AllFiles = cat(3,Coherency(t,BC1Dg3i(1):BC1Dg3i(2)).AllFiles);
CoherencyCAT(t,3).Error = cat(3,Coherency(t,BC1Dg3i(1):BC1Dg3i(2)).Error);
CoherencyCAT(t,4).AllFiles = cat(3,Coherency(t,BC2Di(1):BC2Di(2)).AllFiles);
CoherencyCAT(t,4).Error = cat(3,Coherency(t,BC2Di(1):BC2Di(2)).Error);

end
colors = ['r';'b'; 'k'; 'g'];

y = 1;
% for y = 1 : size(CoherencyCAT,1)
%     
%     subplot(size(CoherencyCAT,1),1, y)
    
    for x = 1: size(CoherencyCAT,2)

        CoherencyMAT = nanmean(CoherencyCAT(y,x).AllFiles,3);
        
        freq = cell2mat(f);     
        CoherencyMATGamma(:,x) = CoherencyMAT(freq>200 & freq<300)    
%        plot(CoherencyMAT)

%         CoherencyAVG = nanmean(CoherencyMAT,2)
        m(x) = plot(CoherencyMAT)
        hold on
        set(m(x),'LineWidth',2.0,'Color',sprintf('%s',colors(x)))
%         ErrorMAT = nanmean(nanmean(CoherencyCAT(y,x).Error(:,f{y} > 200 & f{y} < 300,:),2),3)';
        ErrorMAT = nanstd(CoherencyMAT,0,2)./sqrt(size(CoherencyMAT,2));
        
      
%         Upperbound = CoherencyAVG + ErrorMAT;
%         Lowerbound = CoherencyAVG - ErrorMAT;
%         e = plot([Upperbound Lowerbound],'--')
%         set(e,'LineWidth',2.0,'Color',sprintf('%c',colors(x)))
        bandLabelsX= round(f{y});
        uBandXticks=[1:floor(length(f{y})/10):length(f{y})];
        set(gca,'XTick',uBandXticks,'XTickLabel',bandLabelsX(uBandXticks))
        
        title(['Bin size = ',sprintf('%g',binsizes(y))])

        clear CoherencyMAT ErrorMAT e
        
    end
%     
% end
% subplot(size(CoherencyCAT,1),1, 1)
legend(m,[{'HC'},{'1D Spike'},{'1D gamma'},{'2D BC'}])

[p,table,stats] = anova1(CoherencyMATGamma)

    for t = 1:size(Cohgram,1)
    
CohgramCAT(t,1).AllFiles   = cat(3,Cohgram(t,HCi(1):HCi(2)).Success);
CohgramCAT(t,1).Fail       = cat(3,Cohgram(t,HCi(1):HCi(2)).Fail);
CohgramCAT(t,1).Incomplete = cat(3,Cohgram(t,HCi(1):HCi(2)).Incomplete);
CohgramCAT(t,1).Error      = cat(3,Cohgram(t,HCi(1):HCi(2)).Error);

CohgramCAT(t,2).Success    = cat(3,Cohgram(t,BC1Dsi(1):BC1Dsi(2)).Success);
CohgramCAT(t,2).Fail       = cat(3,Cohgram(t,BC1Dsi(1):BC1Dsi(2)).Fail);
CohgramCAT(t,2).Incomplete = cat(3,Cohgram(t,BC1Dsi(1):BC1Dsi(2)).Incomplete);
CohgramCAT(t,2).Error      = cat(3,Cohgram(t,BC1Dsi(1):BC1Dsi(2)).Error);

CohgramCAT(t,3).AllFiles   = cat(3,Cohgram(t,BC1Dg3i(1):BC1Dg3i(2)).Success);
CohgramCAT(t,3).Fail       = cat(3,Cohgram(t,BC1Dg3i(1):BC1Dg3i(2)).Fail);
CohgramCAT(t,3).Incomplete = cat(3,Cohgram(t,BC1Dg3i(1):BC1Dg3i(2)).Incomplete);
CohgramCAT(t,3).Error      = cat(3,Cohgram(t,BC1Dg3i(1):BC1Dg3i(2)).Error);


CohgramCAT(t,4).AllFiles   = cat(3,Cohgram(t,BC2Di(1):BC2Di(2)).Success);
CohgramCAT(t,4).Fail       = cat(3,Cohgram(t,BC2Di(1):BC2Di(2)).Fail);
CohgramCAT(t,4).Incomplete = cat(3,Cohgram(t,BC2Di(1):BC2Di(2)).Incomplete);
CohgramCAT(t,4).Error      = cat(3,Cohgram(t,BC2Di(1):BC2Di(2)).Error);

end

figure
for y = 1 : size(Cohgram,1)
    for x = 1: size(Cohgram,2)

        CohgramMAT = mean(cat(3,CohgramCAT(y,x).Success,CohgramCAT.Fail(y,x),CohgramCAT(y,x).Incomplete),3);

        subplot(size(Cohgram,1), size(Cohgram,2), (y-1)*size(Cohgram,2)+x)
        plot(CohgramMAT)
        
    end
end

figure
for y = 1 : size(Cohgram,1)
    for x = 1: size(Cohgram,2)

        CohgramMAT = mean(Cohgram(y,x).Success,3);

        subplot(size(Cohgram,1), size(Cohgram,2), (y-1)*size(Cohgram,2)+x)
        plot(CohgramMAT)
        
    end
end
binsizes = [0.05 0.1 0.15 0.2 .25 0.5 1.0];

for i= 1:size(C_AllFiles,2)
 
    subplot(3,3,i)
    
    imagesc(C_AllFiles{1,i,4}')
    title(sprintf('Bin size %d',binsizes(i)))
    caxis([0 .1])
    hold on
    
end


%% For HC, 1D/2D BC comparison
if 0
    HCi = [1 2];
    BC1Dsi = [5 6];
    BC1Dg3i = [3 4];
    BC2Di = [7 9];
    C_AllFiles = reshape(C_AllFiles,1,1,9);

    C_all{1} = nanmean(cell2mat(C_AllFiles(HCi(1):HCi(2))),3);
    C_all{2} = nanmean(cell2mat(C_AllFiles(BC1Dsi(1):BC1Dsi(2))),3);
    C_all{3}= nanmean(cell2mat(C_AllFiles(BC1Dg3i(1):BC1Dg3i(2))),3);
    C_all{4} = nanmean(cell2mat(C_AllFiles(BC2Di(1):BC2Di(2))),3);
    
    C{1} = C_all{1}(17:20,27:39);
    C{2} = C_all{2}(17:20,27:39);
    C{3} = C_all{3}(17:20,27:39);
    C{4} = C_all{4}(17:20,27:39);   
    
    freq = cell2mat(f);  
     C_mean_vector_overfreq = NaN([8 4])
    for i = 1:size(CoherencyCAT,2)
%         C_mean_overfreq{i} = mean(C{i},1);
        C_mean_overfreq{i} = mean(CoherencyCAT(i).AllFiles(freq>200 & freq<300),2);
%         if i < 4
        C_mean_vector_overfreq(1:8,i) = reshape(C_mean_overfreq{i},8,1);
%         else
%             C_mean_vector_overfreq(1:12,i) = reshape(C_mean_overfreq{i},12,1);
%         end
    end
    
    subplot(3,4,1)
    hold on
    for j = HCi(1):HCi(2)
        for i = 1:length(Trial_Path_Whole_File{j})
            if length(Trial_Path_Whole_File{j}{i}) < 120
                plot(Trial_Path_Whole_File{j}{i}(:,2),Trial_Path_Whole_File{j}{i}(:,3))
                hold on
            end
        end
    end
    title('Hand Control')
    xlabel('X cursor position')
    ylabel('Y cursor position')
    
    subplot(3,4,2)
    hold on
    for j = BC1Dsi(1):BC1Dsi(2)
        for i = 1:length(Trial_Path_Whole_File{j})
            if length(Trial_Path_Whole_File{j}{i}) < 120
                plot(Trial_Path_Whole_File{j}{i}(:,2),Trial_Path_Whole_File{j}{i}(:,3))
            end
        end
    end
    title('1D Spike Brain Control')
    
    subplot(3,4,3)
    hold on
    for j = BC1Dg3i(1):BC1Dg3i(2)
        for i = 1:length(Trial_Path_Whole_File{j})
            if length(Trial_Path_Whole_File{j}{i}) < 120
                plot(Trial_Path_Whole_File{j}{i}(:,2),Trial_Path_Whole_File{j}{i}(:,3))
            end
        end
    end
    title('1D Gamma Brain Control')
    
    subplot(3,4,4)
    hold on
    for j = BC2Di(1):BC2Di(2)
        for i = 1:length(Trial_Path_Whole_File{j})
            if length(Trial_Path_Whole_File{j}{i}) < 120
                plot(Trial_Path_Whole_File{j}{i}(:,2),Trial_Path_Whole_File{j}{i}(:,3))
            end
        end
    end
    title('2D Brain Control')
    
    subplot(3,4,4)
    h = fill([-2,-2,2,2],[12,8,8,12],'r');
    set(h,'FaceAlpha',.3)
    hold on
    p = fill([8,8,12,12],[2,-2,-2,2],'r');
    set(p,'FaceAlpha',.3)
    m = fill([2,2,-2,-2],[2,-2,-2,2],'r');
    set(m,'FaceAlpha',.3)
    axis square
    
    for j = 1:length(C)
        subplot(3,4,j+4)
        imagesc(C_all{j}')
        q = q+1;
       % caxis([0 .25])
        uBandYticks=[1:5:36];
        allBands={'10','50','90','140','180','220','260','300'};
        set(gca,'YTick',uBandYticks,'YTickLabel',allBands)
        uBandXticks=[4:4:20];
        allBands={'1.0','0.75','0.5','0.25','0.05'};
        set(gca,'XTick',uBandXticks,'XTickLabel',allBands)
    end
    subplot(3,4,5)
    ylabel('Freq (2 Hz bins)')
    xlabel('Time before Reward (50 ms bins)')

    
    subplot(3,4,[9 10 11 12])
    boxplot(C_mean_vector)
    xticks = [1 2 3 4];
    xlabels = {'HC', '1D Spike','1D Gamma', '2D'};
    set(gca,'XTick',xticks,'XTickLabel',xlabels)
    ylabel('Coherence')

    
%     [~,C_1Dgamma_2D_p] = ttest(C_2D_file_mean_vector,C_1D_gamma_file_mean_vector)
%     [~,C_1Dspike_2D_p] = ttest(C_2D_file_mean_vector,C_1D_spike_file_mean_vector)
%     [~,C_HC_2D_p] = ttest(C_2D_file_mean_vector,C_HC_file_mean_vector)
%     [~,C_HC_1Dspike_p] = ttest(C_1D_spike_file_mean_vector,C_HC_file_mean_vector)
    
end

% if 0
%
%     for i = 1:size(C_AllFiles,3)
%         C{i} = C_AllFiles(13:16,103:end,i);
%         C_mean{i} = mean(C{i},3);
%         C_mean_vector(:,i) = reshape(C_mean{i},208,1);
%
%     end
%
%     [p,table,stats] = anova1(C_mean_vector)
%
%     hist(C_mean_vector(:,1),[0:.005:.4])
%     set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
%     hold on
%
%     hist(C_mean_vector(:,2),[0:.005:.5])
%     set(gco,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
%
%     hist(C_mean_vector(:,3),[0:.005:.4])
%     set(gco,'FaceColor','none','EdgeColor','y','LineWidth',2.0)
%
%     hist(C_mean_vector(:,4),[0:.005:.4])
%     set(gco,'FaceColor','none','EdgeColor','g','LineWidth',2.0)
% end


%% For learning comparison

k = 1;
for j = [1, 2, 4]%length(Trial_Success_Path_Whole_File)
    subplot(3,3,k)
    h = fill([-2,-2,2,2],[12,8,8,12],'r');
    set(h,'FaceAlpha',.3)
    hold on
    p = fill([8,8,12,12],[2,-2,-2,2],'r');
    set(p,'FaceAlpha',.3)
    m = fill([2,2,-2,-2],[2,-2,-2,2],'r');
    set(m,'FaceAlpha',.3)
    axis square
    if j ==1
        xlabel('X cursor position')
        ylabel('Y cursor position')
    end
    for i = 1:length(Trial_Success_Path_Whole_File{j})
        if length(Trial_Success_Path_Whole_File{j}{i}) < 120
            plot(Trial_Success_Path_Whole_File{j}{i}(:,2),Trial_Success_Path_Whole_File{j}{i}(:,3))
        end
    end
    k = k +1;
end
subplot(3,3,1)
title('Early Learning')
subplot(3,3,2)
title('Middle Learning')
subplot(3,3,3)
title('Late Learning')

q= 1;
for j = [1,2,3]%:length(Trial_Success_Path_Whole_File)
    subplot(3,3,j+3)
    imagesc(C_AllFiles(:,:,j)')
    q = q+1;
    caxis([0 .2])
    uBandYticks=[9:40:150];
    allBands={'20','100','180','260'};
    set(gca,'YTick',uBandYticks,'YTickLabel',allBands)
    uBandXticks=[4:4:16];
    allBands={'0.65','0.45','0.25','0.05'};
    set(gca,'XTick',uBandXticks,'XTickLabel',allBands)
end

subplot(3,3,4)
ylabel('Freq (2 Hz bins)')
xlabel('Time before Reward (50 ms bins)')

subplot(3,3,[7 8 9])
figure; errorbar(mean(C_mean_vector(:,[1 2 4])),std(C_mean_vector(:,[1 2 4]))/sqrt(size(C_mean_vector,1)),'o');
xticks = [1 2 3];
xlabels = {'Session 1', 'Session 3', 'Session 7'};
set(gca,'XTick',xticks,'XTickLabel',xlabels)

hold on;
[AX,H1,H2] = plotyy([1:3],mean(C_mean_vector(:,[1 2 4])),[1:3],PercentSuccess_File([1 2 4]));

xlabel('Days Since Starting 2D-NF Task')

set(get(AX(1),'Ylabel'),'String','Coherence') 
set(get(AX(2),'Ylabel'),'String','Percent Success')

xticks = [1 2 3];
xlabels = {'Early', 'Middle ', 'Late'};
set(gca,'XTick',xticks,'XTickLabel',xlabels)
ylabel('Coherence')

%% For changing colors on the fly (in the loop)
% if 0
%     colors = [0 0 1; 0 1 0; 1 0 0; .5 .5 0]
%     for j = 1:length(Trial_Success_Path_Whole_File)
%         h = hist(C_mean_vector(:,j),[0:.005:.4])
%         b = bar(h)
%         set(b,'FaceColor','none','EdgeColor',colors(j,:),'LineWidth',4.0)
%         hold on
%     end
%
%     hist(C_2D_file_mean_vector,[0:.005:.4])
%     set(gco,'FaceColor','none','EdgeColor','b','LineWidth',4.0)
%     hold on
%
%     hist(C_HC_file_mean_vector,[0:.005:.5])
%     set(gco,'FaceColor','none','EdgeColor','r','LineWidth',4.0)
%
%     hist(C_1D_gamma_file_mean_vector,[0:.005:.4])
%     set(gco,'FaceColor','none','EdgeColor','y','LineWidth',2.0)
%
%     hist(C_1D_spike_file_mean_vector,[0:.005:.4])
%     set(gco,'FaceColor','none','EdgeColor','g','LineWidth',2.0)
%
%     hist(C_1D_file_mean_vector)
%
%     legend('2D Brain Control','Hand Control','1D Gamma Control','1D Spike Control')
%     title('Distribution of Spike-[200-300] Hz File Avgeraged Coherence in last 200 ms of Successful Trials')
% end