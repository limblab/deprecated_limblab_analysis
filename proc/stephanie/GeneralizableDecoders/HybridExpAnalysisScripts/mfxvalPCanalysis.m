mfxvalPCanalysis

[Coeff,PCs,Latent,Tsquared,Explained,Mu] = pca(Act);

% Use the eigenvectors iLatent to get the PCs for the predictions
predPCs = (PredData-repmat(mean(PredData),length(PredData(:,1)),1))*Coeff;

 PC_vaf(1) = calculateVAF(predPCs(:,1),PCs(:,1));