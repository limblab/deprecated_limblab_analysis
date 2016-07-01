LineWidth = 3;
date = '08192014';

%FCR

HvM_FCR = figure;
plot(PullingWeight_WmTrain2,PullingWeight_Hybrid2, 'gx', 'LineWidth', LineWidth)
xlabel('Movement'); ylabel('Hybrid')
title(strcat(['FCR ', date]))
xlim([0 0.05]); ylim([0 0.05])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure


HvI_FCR = figure;
plot(PullingWeight_IsoTrain2, PullingWeight_Hybrid2, 'gx', 'LineWidth', LineWidth)
xlabel('Iso'); ylabel('Hybrid')
title(strcat(['FCR ', date]))
xlim([0 0.05]); ylim([0 0.05])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure


IvM_FCR = figure;
plot(PullingWeight_WmTrain2,PullingWeight_IsoTrain2, 'gx', 'LineWidth', LineWidth)
xlabel('Movement'); ylabel('Iso')
title(strcat(['FCR ', date]))
xlim([0 0.05]); ylim([0 0.05])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure


if saveFigs ==1
    saveas(HvM_FCR, strcat(['HvM_FCR',  date,'.fig']))
    saveas(HvI_FCR, strcat(['HvI_FCR',  date,'.fig']))
    saveas(IvM_FCR, strcat(['IvM_FCR',  date,'.fig']))
    saveas(HvM_FCR, strcat(['HvM_FCR',  date,'.pdf']))
    saveas(HvI_FCR, strcat(['HvI_FCR',  date,'.pdf']))
    saveas(IvM_FCR, strcat(['IvM_FCR',  date,'.pdf']))
    
end


%%

% ECR
LineWidth = 3;
HvI_ECR = figure;
plot(PullingWeight_IsoTrain11,PullingWeight_Hybrid11, 'mx', 'LineWidth', LineWidth)
xlabel('Iso'); ylabel('Hybrid')
title('ECR')
xlim([0 0.4]); ylim([0 0.4])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

HvM_ECR = figure;
plot(PullingWeight_WmTrain11,PullingWeight_Hybrid11, 'mx', 'LineWidth', LineWidth)
xlabel('Movement'); ylabel('Hybrid')
title('ECR')
xlim([0 0.4]); ylim([0 0.4])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

IvM_ECR = figure;
plot(PullingWeight_WmTrain11,PullingWeight_IsoTrain11, 'mx', 'LineWidth', LineWidth)
xlabel('Movement'); ylabel('Iso')
title('ECR')
xlim([0 0.4]); ylim([0 0.4])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

if saveFigs ==1
    saveas(HvM_ECR, strcat(['HvM_ECR',  date,'.fig']))
    saveas(HvI_ECR, strcat(['HvI_ECR',  date,'.fig']))
    saveas(IvM_ECR, strcat(['IvM_ECR',  date,'.fig']))
    saveas(HvM_ECR, strcat(['HvM_ECR',  date,'.pdf']))
    saveas(HvI_ECR, strcat(['HvI_ECR',  date,'.pdf']))
    saveas(IvM_ECR, strcat(['IvM_ECR',  date,'.pdf']))
    
end



%position ---------------------------------------------------------------
LineWidth = 3;
HvM_xpos = figure;
plot(PullingWeight_WmTrain_x,PullingWeight_Hybrid_x, 'x', 'LineWidth', LineWidth)
xlabel('Movement'); ylabel('Hybrid')
title(strcat(['Xposition ', date]))
xlim([0 0.4]); ylim([0 0.4])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

HvS_xpos = figure;
plot(PullingWeight_SprTrain_x,PullingWeight_Hybrid_x, 'x', 'LineWidth', LineWidth)
xlabel('Spring'); ylabel('Hybrid')
title(strcat(['Xposition ', date]))
xlim([0 0.4]); ylim([0 0.4])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

SvM_xpos = figure;
plot(PullingWeight_WmTrain_x,PullingWeight_SprTrain_x, 'x', 'LineWidth', LineWidth)
xlabel('Movement'); ylabel('Spring')
title(strcat(['Xposition ', date]))
xlim([0 0.4]); ylim([0 0.4])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

if saveFigs ==1
    saveas(HvM_xpos, strcat(['HvM_', 'Xposition_',  date,'.fig']))
    saveas(HvS_xpos, strcat(['HvS_', 'Xposition_',  date,'.fig']))
    saveas(SvM_xpos, strcat(['SvM_', 'Xposition_',  date,'.fig']))
    saveas(HvM_xpos, strcat(['HvM_', 'Xposition_',  date,'.pdf']))
    saveas(HvS_xpos, strcat(['HvS_', 'Xposition_',  date,'.pdf']))
    saveas(SvM_xpos, strcat(['SvM_', 'Xposition_',  date,'.pdf']))
end







% 
% figure
% plot(PullingWeight_SprTrain_x,PullingWeight_WmTrain_x, 'x', 'LineWidth', LineWidth)
% xlabel('Spring'); ylabel('Movement')
% title('Xposition')
% xlim([0 0.4]); ylim([0 0.4])


% plot(PullingWeight_IsoTrain11_Norm, PullingWeight_WmTrain11_Norm,'x', 'LineWidth', LineWidth)
% xlabel('Iso'); ylabel('Movement')
% title('ECR norm')
% xlim([0 0.4]); ylim([0 0.4])
% hold on;V=axis;plot(V(1:2),V(3:4),'k--');
% 
% figure
% plot(PullingWeight_IsoTrain2_Norm, PullingWeight_WmTrain2_Norm,'x', 'LineWidth', LineWidth)
% xlabel('Iso'); ylabel('Movement')
% title('FCR Norm')
% hold on;V=axis;plot(V(1:2),V(3:4),'k--');

