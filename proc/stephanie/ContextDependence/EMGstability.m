function EMGstability(binnedData_2F, binnedData_3F, foldername)


for EMGind = 1:length(binnedData_2F.emgdatabin(1,:))
    
    [EMGmeans_F2T1 EMgstdplus_F2T1 EMGstdminus_F2T1 time] = EMGpeth(binnedData_2F,'contextdep',1,EMGind);
    [EMGmeans_F3T1 EMgstdplus_F3T1 EMGstdminus_F3T1 time] = EMGpeth(binnedData_3F,'contextdep',1,EMGind);
    
    figure
    hold on
    
    h1 = plot(time,EMGmeans_F2T1,'b', 'LineWidth', 2);
    plot(time,EMgstdplus_F2T1,'b-')
    plot(time,EMGstdminus_F2T1,'b-')
    hold on
    
    h2 = plot(time,EMGmeans_F3T1,'g', 'LineWidth', 2);
    plot(time,EMgstdplus_F3T1,'g-')
    plot(time,EMGstdminus_F3T1,'g-')
    
    xlabel('Time (seconds)')
    title(strcat(['Target 1 | ', binnedData_2F.emgguide(EMGind,:)]))
    legend([h1 h2], '2 Force Task','3 Force Task')
    
    
    set(gca,'TickDir','out')
    box off
    
    %saveas(gcf, strcat(foldername, 'Target1_', binnedData_2F.emgguide(EMGind,:), '.fig'))
    %saveas(gcf, strcat(foldername, 'Target1_', binnedData_2F.emgguide(EMGind,:), '.eps'))
    %saveas(gcf, strcat(foldername, 'Target1_', binnedData_2F.emgguide(EMGind,:), '.jpg'))
    close
    
    %----------------------------------------------------------------------------------------------
    
    [EMGmeans_F2T2 EMgstdplus_F2T2 EMGstdminus_F2T2 time] = EMGpeth(binnedData_2F,'contextdep',2,EMGind);
    [EMGmeans_F3T2 EMgstdplus_F3T2 EMGstdminus_F3T2 time] = EMGpeth(binnedData_3F,'contextdep',2,EMGind);
    
    figure
    hold on
    
    h1 = plot(time,EMGmeans_F2T2,'b', 'LineWidth', 2);
    plot(time,EMgstdplus_F2T2,'b-')
    plot(time,EMGstdminus_F2T2,'b-')
    hold on
    
    h2 = plot(time,EMGmeans_F3T2,'g', 'LineWidth', 2);
    plot(time,EMgstdplus_F3T2,'g-')
    plot(time,EMGstdminus_F3T2,'g-')
    
    xlabel('Time (seconds)')
    title(strcat(['Target 2 | ', binnedData_2F.emgguide(EMGind,:)]))
    legend([h1 h2], '2 Force Task','3 Force Task')
    
    set(gca,'TickDir','out')
    box off
    
    %saveas(gcf, strcat(foldername, 'Target2_', binnedData_2F.emgguide(EMGind,:), '.fig'))
    %saveas(gcf, strcat(foldername, 'Target2_', binnedData_2F.emgguide(EMGind,:), '.eps'))
    %saveas(gcf, strcat(foldername, 'Target2_', binnedData_2F.emgguide(EMGind,:), '.jpg'))
    close
    
    
end
