%% For HC, 1D/2D BC comparison
if 0
    HCi = [1 2];
    BC1Dsi = [5 6];
    BC1Dg3i = [3 4];
    BC2Di = [7 9];
    C_all{1} = mean(C_AllFiles(:,:,HCi(1):HCi(2)),3);
    C_all{2} = mean(C_AllFiles(:,:,BC1Dsi(1):BC1Dsi(2)),3);
    C_all{3}= mean(C_AllFiles(:,:,BC1Dg3i(1):BC1Dg3i(2)),3);
    C_all{4} = mean(C_AllFiles(:,:,BC2Di(1):BC2Di(2)),3);
    
    C{1} = C_AllFiles(13:16,103:end,HCi(1):HCi(2));
    C{2} = C_AllFiles(13:16,103:end,BC1Dsi(1):BC1Dsi(2));
    C{3}= C_AllFiles(13:16,103:end,BC1Dg3i(1):BC1Dg3i(2));
    C{4} = C_AllFiles(13:16,103:end,BC2Di(1):BC2Di(2));   
    
    for i = 1:size(C,2)
        C_mean{i} = mean(C{i},3);
        C_mean_vector(:,i) = reshape(C_mean{i},208,1);
    end
    
    subplot(3,4,1)
    hold on
    for j = HCi(1):HCi(2)
        for i = 1:length(Trial_Success_Path_Whole_File{j})
            if length(Trial_Success_Path_Whole_File{j}{i}) < 120
                plot(Trial_Success_Path_Whole_File{j}{i}(:,2),Trial_Success_Path_Whole_File{j}{i}(:,3))
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
        for i = 1:length(Trial_Success_Path_Whole_File{j})
            if length(Trial_Success_Path_Whole_File{j}{i}) < 120
                plot(Trial_Success_Path_Whole_File{j}{i}(:,2),Trial_Success_Path_Whole_File{j}{i}(:,3))
            end
        end
    end
    title('1D Spike Brain Control')
    
    subplot(3,4,3)
    hold on
    for j = BC1Dg3i(1):BC1Dg3i(2)
        for i = 1:length(Trial_Success_Path_Whole_File{j})
            if length(Trial_Success_Path_Whole_File{j}{i}) < 120
                plot(Trial_Success_Path_Whole_File{j}{i}(:,2),Trial_Success_Path_Whole_File{j}{i}(:,3))
            end
        end
    end
    title('1D Gamma Brain Control')
    
    subplot(3,4,4)
    hold on
    for j = BC2Di(1):BC2Di(2)
        for i = 1:length(Trial_Success_Path_Whole_File{j})
            if length(Trial_Success_Path_Whole_File{j}{i}) < 120
                plot(Trial_Success_Path_Whole_File{j}{i}(:,2),Trial_Success_Path_Whole_File{j}{i}(:,3))
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
        imagesc(C_all{j})
        caxis([0 .4])
    end
    subplot(3,4,5)
    xlabel('Time (50 ms bins)')
    ylabel('Freq (2 Hz bins)')

    
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

q= 1;
for j = [1,2,3]%:length(Trial_Success_Path_Whole_File)
    subplot(3,3,j+3)
    imagesc(C_AllFiles(:,:,j))
    q = q+1;
    caxis([0 .2])
end

subplot(3,3,4)
xlabel('Time (50 ms bins)')
ylabel('Freq (2 Hz bins)')


subplot(3,3,[7 8 9])
boxplot(C_mean_vector(:,[1,2,4]))

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