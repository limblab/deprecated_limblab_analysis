

data=binnedData.spikeratedata;  
[W, pc, eigV] = princomp(data);
c_var = (cumsum(eigV) ./ sum(eigV));

PCA_BinnedData = binnedData;
PCA_BinnedData.spikeratedata = pc(:,1:14);
PCA_BinnedData.spikeguide = binnedData.spikeguide(1:14,:);


plot(pc(1,:),pc(2,:),'.'); 
title('{\bf PCA} by princomp'); xlabel('PC 1'); ylabel('PC 2')

Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = binnedData.forcedatabin(10:end,2);
Pred_Fx3 = OLPredData_N2F_PCA.preddatabin(:,1);
Pred_Fy3 = OLPredData_N2F_PCA.preddatabin(:,2);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_PCA = [Pred_Fx3,Pred_Fy3];

R2_N2F_PCA = CalculateR2(Act_N2F,Pred_N2F_PCA);