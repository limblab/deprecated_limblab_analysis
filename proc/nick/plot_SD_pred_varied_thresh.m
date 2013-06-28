for x = 0:2:20
% for x = 5:0.5:8
    
binnedData.states(:,1) = binnedData.velocbin(:,3) > x;
model = BuildSDModel(binnedData,'', 0.5, 1, 1, 0, 0, 0, 1, 1);
SDmodel.general_decoder = model{1};
SDmodel.posture_decoder = model{2};
SDmodel.movement_decoder= model{3};
PredData = predictSDSignals(SDmodel,binnedData,1);
figure;
plot(binnedData.velocbin(:,1),PredData.preddatabin(:,1),'.')
hold on
plot(binnedData.velocbin(binnedData.states(:,1)==0,1),PredData.preddatabin(binnedData.states(:,1)==0,1),'g.')
plot([-60 60],[-60 60],'r')
plot([0 0],[-60 60],'r')
plot([-60 60],[0 0],'r')
[r2 vaf mse] = getvaf(binnedData.velocbin(:,1),PredData.preddatabin(:,1));
if x > 0
    [r2_p vaf_p mse_p] = getvaf(binnedData.velocbin(binnedData.states(:,1)==0,1),PredData.preddatabin(binnedData.states(:,1)==0,1));
else
    r2_p = 0;
    vaf_p = 0;
    mse_p = 0;
end
[r2_m vaf_m mse_m] = getvaf(binnedData.velocbin(binnedData.states(:,1)==1,1),PredData.preddatabin(binnedData.states(:,1)==1,1));
title([num2str(x) 'cm/s, vaf = ' num2str(vaf) ',vaf_p = ' num2str(vaf_p) ',vaf_m = ' num2str(vaf_m)])
end