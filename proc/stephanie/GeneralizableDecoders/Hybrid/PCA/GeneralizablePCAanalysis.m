function  [VAF_PC_struct MSE_PC_struct] = GeneralizablePCAanalysis(IsoBinned,WmBinned,IonIact,IonIpred,HonIpred,WonIpred,WonWact,WonWpred,HonWpred,IonWpred,foldername,save)

% [VAF_PC_struct_0606 MSE_PC_struct_0606] = GeneralizablePCAanalysis(IsoBinned,WmBinned,IonIact,IonIpred,HonIpred,WonIpred,WonWact,WonWpred,HonWpred,IonWpred,foldername,0)


% Get the PCs for the actual data
[iCoeff,iPCs,iLatent,iTsquared,iExplained,iMu] = pca(IonIact);

% testPCs = (IonIact-repmat(iMu,length(IonIact(:,1)),1))*iCoeff;

% Use the eigenvectors iLatent to get the PCs for the predictions
IonIPCs = (IonIpred-repmat(mean(IonIpred),length(IonIpred(:,1)),1))*iCoeff;

HonIPCs = (HonIpred-repmat(mean(HonIpred),length(HonIpred(:,1)),1))*iCoeff;
WonIPCs = (WonIpred-repmat(mean(WonIpred),length(WonIpred(:,1)),1))*iCoeff;


%Plot
for j =1
    figure;hold on;plot(iPCs(:,j),'k');plot(IonIPCs(:,j),'b'); plot(HonIPCs(:,j),'g'); plot(WonIPCs(:,j),'r')
    HonIPC_vaf(j) = calculateVAF(HonIPCs(:,j),iPCs(:,j));
    IonIPC_vaf(j) = calculateVAF(IonIPCs(:,j),iPCs(:,j));
    WonIPC_vaf(j) = calculateVAF(WonIPCs(:,j),iPCs(:,j));
    
    HonIPC_mse(j) = mse(HonIPCs(:,j),iPCs(:,j));
    IonIPC_mse(j) = mse(IonIPCs(:,j),iPCs(:,j));
    WonIPC_mse(j) = mse(WonIPCs(:,j),iPCs(:,j));
    
    
    legend('Actual',strcat('Within | vaf=',num2str(IonIPC_vaf(j))),strcat('Hybrid | vaf=',num2str(HonIPC_vaf(j))),strcat('Across | vaf=',num2str(WonIPC_vaf(j))));
    MillerFigure
    xlim([0 2000])
    title(strcat([IsoBinned.meta.datetime(1:9),' Isometric PC ', num2str(j)]));
    
    % Save figure
    if save == 1
        SaveFigure(foldername, 'Isometric_PC1')
    end
    
end



% Get the PCs for the actual data
[wmCoeff,wmPCs,wmLatent,wmTsquared,wmExplained,wmMu] = pca(WonWact);

% Use the eigenvectors iLatent to get the PCs for the predictions
IonWPCs = (IonWpred-repmat(mean(IonWpred),length(IonWpred(:,1)),1))*wmCoeff;

HonWPCs = (HonWpred-repmat(mean(HonWpred),length(HonWpred(:,1)),1))*wmCoeff;
WonWPCs = (WonWpred-repmat(mean(WonWpred),length(WonWpred(:,1)),1))*wmCoeff;

%Plot
for i=1
    figure;plot(wmPCs(:,i),'k');hold on; plot(WonWPCs(:,i),'b');plot(HonWPCs(:,i),'g'); plot(IonWPCs(:,i),'r')
    WonWPC_vaf(i) = calculateVAF(WonWPCs(:,i),wmPCs(:,i));
    IonWPC_vaf(i) = calculateVAF(IonWPCs(:,i),wmPCs(:,i));
    HonWPC_vaf(i) = calculateVAF(HonWPCs(:,i),wmPCs(:,i));
    
    WonWPC_mse(i) = mse(WonWPCs(:,i),wmPCs(:,i));
    IonWPC_mse(i) = mse(IonWPCs(:,i),wmPCs(:,i));
    HonWPC_mse(i) = mse(HonWPCs(:,i),wmPCs(:,i));
    
    legend('Actual',strcat('Within | vaf=',num2str(WonWPC_vaf(i))),strcat('Hybrid | vaf=',num2str(HonWPC_vaf(i))),strcat('Across | vaf=',num2str(IonWPC_vaf(i))));
    MillerFigure
    title(strcat([IsoBinned.meta.datetime(1:9),' Movement PC ', num2str(i)]));
    xlim([2000 2500])
    
    % Save figure
    if save == 1
        SaveFigure(foldername, 'Movement_PC1')
    end
    
    
end

VAF_PC_struct.HonIPC_vaf = HonIPC_vaf;
VAF_PC_struct.IonIPC_vaf = IonIPC_vaf;
VAF_PC_struct.WonIPC_vaf = WonIPC_vaf;
VAF_PC_struct.HonWPC_vaf = HonWPC_vaf;
VAF_PC_struct.WonWPC_vaf = WonWPC_vaf;
VAF_PC_struct.IonWPC_vaf = IonWPC_vaf;
%--
MSE_PC_struct.HonIPC_mse = HonIPC_mse;
MSE_PC_struct.IonIPC_mse = IonIPC_mse;
MSE_PC_struct.WonIPC_mse = WonIPC_mse;
MSE_PC_struct.HonWPC_mse = HonWPC_mse;
MSE_PC_struct.WonWPC_mse = WonWPC_mse;
MSE_PC_struct.IonWPC_mse = IonWPC_mse;

 
 

% newscore = (data-repmat(mu,18442,1))*coeff;