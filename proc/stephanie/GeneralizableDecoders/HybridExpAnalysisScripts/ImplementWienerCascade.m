ImplementWienerCascade


 %--------------------------------------------------------------------------------
 %Polynomial plotting
%  PolyOrder = 2;PlotFlag=0;
%  
%  
% Act = IsoTest.emgdatabin(numlags:end,emgInd);
% [P] = WienerNonlinearity(HonIpred,Act,PolyOrder,PlotFlag);
% HonIcascade = polyval(P,HonIpred);
% HcascadeonI_vaf = calculateVAF(HonIcascade,Act);


% linewidth = 1.5;
% x = (0:0.05:length(HonIpred)*.05-0.05)';
% % Plot predictions of isometric data---------------------------------------
% %--------------------------------------------------------------------------
% figure;hold on;
% plot(x,IsoTest.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
% plot(x,HonIpred,'g','LineWidth', linewidth)
% %plot(x,HonIcascade,'b','LineWidth', linewidth)
% xlabel('Time (sec)');
% title(strcat(foldername, ':', num2str(IsoTest.emgguide(emgInd,:)), ' Predictions | Isometric data'))
% set(gca,'TickDir','out'); box off;
% legend('Actual', strcat('Hybrid Linear | vaf=', num2str(HonI_vaf)), strcat('Hybrid 2nd Order | vaf=',num2str(HcascadeonI_vaf)));
% 


%Save figure
% saveas(gcf, strcat(foldername, '_PredOnIsoDataWCascade_',  num2str(IsoTest.emgguide(emgInd,:)),'.fig'))
% xlim([30 50]);
% saveas(gcf, strcat(foldername, '_PredOnIsoDataWCascade_',  num2str(IsoTest.emgguide(emgInd,:)),'.tif'))


%------------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Act = WmTest.emgdatabin(numlags:end,emgInd);
% [P] = WienerNonlinearity(HonWpred,Act,PolyOrder,PlotFlag);
% HonWcascade = polyval(P,HonWpred);
% HcascadeonW_vaf = calculateVAF(HonWcascade,Act);
% 
% % Plot predictions of movement data----------------------------------------
% %--------------------------------------------------------------------------
% figure;hold on;
% plot(x,WmTest.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
% plot(x,HonWpred,'g','LineWidth', linewidth)
% plot(x,HonWcascade,'b','LineWidth', linewidth)
% title(strcat(foldername, ':', num2str(WmTest.emgguide(emgInd,:)), ' Predictions | Movement data'))
% legend('Actual', strcat('Hybrid Linear | vaf=', num2str(HonW_vaf)), strcat('Hybrid 2nd Order | vaf=',num2str(HcascadeonW_vaf)));
% set(gca,'TickDir','out')
%  box off
%   
