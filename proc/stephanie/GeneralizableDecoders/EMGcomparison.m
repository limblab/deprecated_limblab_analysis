function EMGcomparison(binnedData1, binnedData2)


for EMGind = 1:length(binnedData1.emgdatabin(1,:))
    for tgtNo = 1:6
        
    %F for file, T for target
    [EMGmeans1{EMGind,tgtNo} EMGstdplus1{EMGind,tgtNo} EMGstdminus1{EMGind,tgtNo} time] = EMGpeth(binnedData1,'generalize',tgtNo,EMGind);
    [EMGmeans2{EMGind,tgtNo} EMGstdplus2{EMGind,tgtNo} EMGstdminus2{EMGind,tgtNo} time] = EMGpeth(binnedData2,'generalize',tgtNo,EMGind);
    end

   SpringStdPlusMax = (cellfun(@(x) max(x),EMGstdplus1,'UniformOutput',true)); 
    maxY = max(SpringStdPlusMax(EMGind,:))+3;
    
    figure
    hold on
    subplot(2,3,1); hold on
    xlabel('Target 1 | Extension')
    plot(time,EMGmeans1{EMGind,1},'b', 'LineWidth', 2);
       plot(time,EMGmeans2{EMGind,1},'g', 'LineWidth', 2);
    plot(time,EMGstdplus1{EMGind,1},'b-')
    plot(time,EMGstdminus1{EMGind,1},'b-')
    plot(time,EMGmeans2{EMGind,1},'g', 'LineWidth', 2);
    plot(time,EMGstdplus2{EMGind,1},'g-')
    plot(time,EMGstdminus2{EMGind,1},'g-')
    legend('Iso','Spr')
    MillerFigure
    ylim([0 maxY])
    
    
    hold on
    subplot(2,3,2); hold on
   title(strcat([binnedData1.meta.datetime(1:1:10) ' | '  binnedData1.emgguide(EMGind,:) ' | ' ]))
    xlabel('Target 2 | Extension')
    plot(time,EMGmeans1{EMGind,2},'b', 'LineWidth', 2);
        plot(time,EMGmeans2{EMGind,2},'g', 'LineWidth', 2);
    plot(time,EMGstdplus1{EMGind,2},'b-')
    plot(time,EMGstdminus1{EMGind,2},'b-')
    plot(time,EMGstdplus2{EMGind,2},'g-')
    plot(time,EMGstdminus2{EMGind,2},'g-')
    MillerFigure
    ylim([0 maxY])
    
    hold on
    subplot(2,3,3); hold on
    xlabel('Target 3 | Extension')
    plot(time,EMGmeans1{EMGind,3},'b', 'LineWidth', 2);
     plot(time,EMGmeans2{EMGind,3},'g', 'LineWidth', 2);
    plot(time,EMGstdplus1{EMGind,3},'b-')
    plot(time,EMGstdminus1{EMGind,3},'b-')

    plot(time,EMGstdplus2{EMGind,3},'g-')
    plot(time,EMGstdminus2{EMGind,3},'g-')
    MillerFigure
    ylim([0 maxY])
    
     hold on
    subplot(2,3,4); hold on
    xlabel('Target 4 | Flexion')
    plot(time,EMGmeans1{EMGind,4},'b', 'LineWidth', 2);
      plot(time,EMGmeans2{EMGind,4},'g', 'LineWidth', 2);
    plot(time,EMGstdplus1{EMGind,4},'b-')
    plot(time,EMGstdminus1{EMGind,4},'b-')
    plot(time,EMGstdplus2{EMGind,4},'g-')
    plot(time,EMGstdminus2{EMGind,4},'g-')
    MillerFigure
    ylim([0 maxY])
    
    
     hold on
    subplot(2,3,5); hold on
    xlabel('Target 5 | Flexion')
    plot(time,EMGmeans1{EMGind,5},'b', 'LineWidth', 2);
         plot(time,EMGmeans2{EMGind,5},'g', 'LineWidth', 2);
    plot(time,EMGstdplus1{EMGind,5},'b-')
    plot(time,EMGstdminus1{EMGind,5},'b-')
    plot(time,EMGstdplus2{EMGind,5},'g-')
    plot(time,EMGstdminus2{EMGind,5},'g-')
    MillerFigure
    ylim([0 maxY])
    
      hold on
    subplot(2,3,6); hold on
    xlabel('Target 6 | Flexion')
    plot(time,EMGmeans1{EMGind,6},'b', 'LineWidth', 2);
      plot(time,EMGmeans2{EMGind,6},'g', 'LineWidth', 2);
    plot(time,EMGstdplus1{EMGind,6},'b-')
    plot(time,EMGstdminus1{EMGind,6},'b-')
    plot(time,EMGstdplus2{EMGind,6},'g-')
    plot(time,EMGstdminus2{EMGind,6},'g-')
    MillerFigure
    ylim([0 maxY])
end
    
%     
%     h1 = plot(time,EMGmeans_F1T1,'b', 'LineWidth', 2);
%     plot(time,EMgstdplus_F1T1,'b-')
%     plot(time,EMGstdminus_F1T1,'b-')
%     hold on
%     
%     h2 = plot(time,EMGmeans_F2T1,'g', 'LineWidth', 2);
%     plot(time,EMgstdplus_F2T1,'g-')
%     plot(time,EMGstdminus_F2T1,'g-')
%     
%     xlabel('Time (seconds)')
%     title(strcat(['Target 1 | ', binnedData1.emgguide(EMGind,:)]))
%     legend([h1 h2], 'Isometric','Spring')
%     MillerFigure
    
    
    %saveas(gcf, strcat(foldername, 'Target1_', binnedData_2F.emgguide(EMGind,:), '.fig'))
    %saveas(gcf, strcat(foldername, 'Target1_', binnedData_2F.emgguide(EMGind,:), '.eps'))
    %saveas(gcf, strcat(foldername, 'Target1_', binnedData_2F.emgguide(EMGind,:), '.jpg'))
    %close
    
    %----------------------------------------------------------------------------------------------
  
    
   
    
end
