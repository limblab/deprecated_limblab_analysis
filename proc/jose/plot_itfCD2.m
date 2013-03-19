function [N2F_Magx,CD_Magx,N2F_Magy,CD_Magy,EstFreq] = plot_itfCD2()

% This function plots the average impulse transfer Function of the Cascade Decoder
% given N different dataset
% Standard Deviation of the ITF is plotted as a shadow

%% GUI

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\';

MoreFiles = questdlg('Do you want to add a file?');

numFiles = 0;

N2F_Magx = [];
N2F_Magy = [];
N2F_EstFx = [];
N2F_EstFy = [];
PCA_Magx = [];
PCA_Magy = [];
PCA_EstFx = [];
PCA_EstFy = [];
CD_Magx = [];
CD_Magy = [];
CD_EstFx = [];
CD_EstFy = [];

while strcmp(MoreFiles,'Yes')
    
    [FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
    if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        load(datafile,'binnedData'); % datafile automatically loaded as binnedData
        numFiles = numFiles + 1;
    else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
    end
    %% N2F
    Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag
    Act_Fy = binnedData.forcedatabin(10:end,2);
    
    % Calculating PredF
    pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
    input_type = 0; % use neurons as inputs
    PolynomialOrder = 3; % N2F
    [filt_aux, PredF_N2F] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder); 
    Pred_Fx1 = PredF_N2F.preddatabin(:,1);
    Pred_Fy1 = PredF_N2F.preddatabin(:,2);
    
    %% Calculate tf N2F Decoder

    Act_N2F = [Act_Fx,Act_Fy];
    Pred_N2F = [Pred_Fx1,Pred_Fy1];
    [Mag_N2F,Phase_N2F,Omega_N2F,EstF_N2F] = impulse_txy_decoder(Act_N2F,Pred_N2F);
    
    N2F_Magx = [N2F_Magx,Mag_N2F(:,1)];
    N2F_Magy = [N2F_Magy,Mag_N2F(:,2)];
    N2F_EstFx = [N2F_EstFx,EstF_N2F(:,1)];
    N2F_EstFy = [N2F_EstFy,EstF_N2F(:,2)]; 
    
    %% N2F + PCA
    
    data=binnedData.spikeratedata;  
    [W, pc, eigV] = princomp(data);
    PCA_BinnedData = binnedData;
    PCA_BinnedData.spikeratedata = pc(:,1:14);
    PCA_BinnedData.spikeguide = binnedData.spikeguide(1:14,:);

    Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag = 10
    Act_Fy = binnedData.forcedatabin(10:end,2);
    
     % Calculating PredEMGs
    pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
    input_type = 0; % use neurons as inputs
    PolynomialOrder = 3; % N2F
    [filt_aux, PredF_PCA] = BuildFilter(PCA_BinnedData,pred_out,input_type,PolynomialOrder); 
    Pred_Fx3 = PredF_PCA.preddatabin(:,1);
    Pred_Fy3 = PredF_PCA.preddatabin(:,2);

    %% Calculate tf N2F + PCA Decoder

    Act_PCA = [Act_Fx,Act_Fy];
    Pred_PCA = [Pred_Fx3,Pred_Fy3];
    [Mag_PCA,Phase_PCA,Omega_PCA,EstF_PCA] = impulse_txy_decoder(Act_PCA,Pred_PCA);
    
    PCA_Magx = [PCA_Magx,Mag_PCA(:,1)];
    PCA_Magy = [PCA_Magy,Mag_PCA(:,2)];
    PCA_EstFx = [PCA_EstFx,EstF_PCA(:,1)];
    PCA_EstFy = [PCA_EstFy,EstF_PCA(:,2)];    
    
    %% Predicting Force from Cascade Decoder

    Act_Fx = binnedData.forcedatabin(19:end,1); % double lag
    Act_Fy = binnedData.forcedatabin(19:end,2);

    % Calculating PredEMGs
    pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
    input_type = 0; % use neurons as inputs
    PolynomialOrder = 2; % N2E
    [filt_aux, OLPredData_N2E] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
    OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder

    % Calculating E2F Decoder
    pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
    input_type = 1; % use EMGs as inputs
    PolynomialOrder = 3; % E2F
    [filt_E2F, OLauxData] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
    PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
    Pred_Fx2 = PredF_CD.preddatabin(:,1);
    Pred_Fy2 = PredF_CD.preddatabin(:,2);

    %% Calculate tf Cascade Decoder

    Act_CD = [Act_Fx,Act_Fy];
    Pred_CD = [Pred_Fx2,Pred_Fy2];
    [Mag_CD,Phase_CD,Omega_CD,EstF_CD] = impulse_txy_decoder(Act_CD,Pred_CD);
    
    CD_Magx = [CD_Magx,Mag_CD(:,1)];
    CD_Magy = [CD_Magy,Mag_CD(:,2)];
    CD_EstFx = [CD_EstFx,EstF_CD(:,1)];
    CD_EstFy = [CD_EstFy,EstF_CD(:,2)];    
    

    MoreFiles = questdlg('Do you want to add another file?');
end

if strcmp(MoreFiles,'Cancel')
    return;
end

%% Plot

% N2F
mMagx_N2F = mean(N2F_Magx,2);
stdMagx_N2F = std(N2F_Magx,1,2);
mMagy_N2F = mean(N2F_Magy,2);
stdMagy_N2F = std(N2F_Magy,1,2);

nMagx_N2F = mMagx_N2F - stdMagx_N2F;
pMagx_N2F = mMagx_N2F + stdMagx_N2F;

nMagy_N2F = mMagy_N2F - stdMagy_N2F;
pMagy_N2F = mMagy_N2F + stdMagy_N2F;

% PCA
mMagx_PCA = mean(PCA_Magx,2);
stdMagx_PCA = std(PCA_Magx,1,2);
mMagy_PCA = mean(PCA_Magy,2);
stdMagy_PCA = std(PCA_Magy,1,2);

nMagx_PCA = mMagx_PCA - stdMagx_PCA;
pMagx_PCA = mMagx_PCA + stdMagx_PCA;

nMagy_PCA = mMagy_PCA - stdMagy_PCA;
pMagy_PCA = mMagy_PCA + stdMagy_PCA;

% CD
mMagx_CD = mean(CD_Magx,2);
stdMagx_CD = std(CD_Magx,1,2);
mMagy_CD = mean(CD_Magy,2);
stdMagy_CD = std(CD_Magy,1,2);

nMagx_CD = mMagx_CD - stdMagx_CD;
pMagx_CD = mMagx_CD + stdMagx_CD;

nMagy_CD = mMagy_CD - stdMagy_CD;
pMagy_CD = mMagy_CD + stdMagy_CD;

EstFreq = N2F_EstFx(:,1); 

figure(1); 
    
area([N2F_EstFx(:,1);flipdim(N2F_EstFx(:,1),1)],[20*log10(nMagx_N2F);flipdim(20*log10(pMagx_N2F),1)],...
    'FaceColor',[0.85 0.85 1],'EdgeColor',[0.9 0.9 1]);  hold on
    
area([CD_EstFx(:,1);flipdim(CD_EstFx(:,1),1)],[20*log10(nMagx_CD);flipdim(20*log10(pMagx_CD),1)],...
    'FaceColor',[1 0.85 0.85],'EdgeColor',[1 0.9 0.9]);  hold on

area([PCA_EstFx(:,1);flipdim(PCA_EstFx(:,1),1)],[20*log10(nMagx_PCA);flipdim(20*log10(pMagx_PCA),1)],...
    'FaceColor',[0.85 1 0.85],'EdgeColor',[0.9 1 0.9]);  hold on

plot(N2F_EstFx(:,1),20*log10(mMagx_N2F),'b','LineWidth',2,'MarkerSize',1);
plot(CD_EstFx(:,1),20*log10(mMagx_CD),'r','LineWidth',2,'MarkerSize',1);
plot(PCA_EstFx(:,1),20*log10(mMagx_PCA),'g','LineWidth',2,'MarkerSize',1);
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('CD Impulse response transfer function: Fx')
legend('N2F Decoder','Cascade Decoder','N2F + 8 PC')

figure(2); 
    
area([N2F_EstFy(:,1);flipdim(N2F_EstFy(:,1),1)],[20*log10(nMagy_N2F);flipdim(20*log10(pMagy_N2F),1)],...
    'FaceColor',[0.85 0.85 1],'EdgeColor',[0.9 0.9 1]);  hold on
    
area([CD_EstFy(:,1);flipdim(CD_EstFy(:,1),1)],[20*log10(nMagy_CD);flipdim(20*log10(pMagy_CD),1)],...
    'FaceColor',[1 0.85 0.85],'EdgeColor',[1 0.9 0.9]);  hold on

area([PCA_EstFy(:,1);flipdim(PCA_EstFy(:,1),1)],[20*log10(nMagy_PCA);flipdim(20*log10(pMagy_PCA),1)],...
    'FaceColor',[0.85 1 0.85],'EdgeColor',[0.9 1 0.9]);  hold on

plot(N2F_EstFy(:,1),20*log10(mMagy_N2F),'b','LineWidth',2,'MarkerSize',1);
plot(CD_EstFy(:,1),20*log10(mMagy_CD),'r','LineWidth',2,'MarkerSize',1);
plot(PCA_EstFy(:,1),20*log10(mMagy_PCA),'g','LineWidth',2,'MarkerSize',1);
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('CD Impulse response transfer function: Fx')
legend('N2F Decoder','Cascade Decoder','N2F + 8 PC')

