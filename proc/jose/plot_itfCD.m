function [EstF_CD]=plot_itfCD()

% This function plots the impulse transfer Function of the Cascade Decoder
% given N different dataset

%% GUI

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\';

MoreFiles = questdlg('Do you want to add a file?');

numFiles = 0;

colors = ['r' 'k' 'b' 'c' 'g' 'm'];

Magx = [];
Magy = [];
Phasex = [];
Phasey = [];
Omegax = [];
Omegay = [];
EstFx = [];
EstFy = [];


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
    
    %% Actual Force

    Act_Fx = binnedData.forcedatabin(19:end,1); % double lag
    Act_Fy = binnedData.forcedatabin(19:end,2);

    %% Predicting Force from Cascade Decoder
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
    
    Magx = [Magx,Mag_CD(:,1)];
    Magy = [Magy,Mag_CD(:,2)];
    Phasex = [Phasex,Phase_CD(:,1)];
    Phasey = [Phasey,Phase_CD(:,2)];
    Omegax = [Omegax,Omega_CD(:,1)];
    Omegay = [Omegay,Omega_CD(:,2)];
    EstFx = [EstFx,EstF_CD(:,1)];
    EstFy = [EstFy,EstF_CD(:,2)];    

    MoreFiles = questdlg('Do you want to add another file?');
end

if strcmp(MoreFiles,'Cancel')
    return;
end

%% Plot

for i=1:numFiles
    %  Fx
    figure(1); 
    plot(EstFx(:,i), 20*log10(Magx(:,i)), [colors(i),'-']); hold on;
    xlabel('Frequency, Hz')
    ylabel('|H|, dB')
    title('CD Impulse response transfer function: Fx')
    % Fy
    figure(2); 
    plot(EstFy(:,i), 20*log10(Magy(:,i)), [colors(i),'-']); hold on;
    xlabel('Frequency, Hz')
    ylabel('\angle H, rad')
    title('CD Impulse response transfer function: Fy')
end





