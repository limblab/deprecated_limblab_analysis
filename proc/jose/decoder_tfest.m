function decoder_tfest()

%% GUI

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\'; 
% Call GUI
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Decoder');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    Decod = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    Decod = Decod.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end

%% Calculate tf function

Act_Fx = Decod.forcedatabin(10:end,1);
Act_Fy = binnedData.forcedatabin(10:end,1);
Pred_Fx = OLPredData.preddatabin(:,1);
Pred_Fy = OLPredData.preddatabin(:,2);

Txy_Fx = tfestimate(Act_Fx,Pred_Fx);

Txy_dB = 20*log10(abs(Txy_Fx));
plot(Txy_dB)

Fs = 20; % 0.05 ms bin = 20 Hz
[EstH, EstF] = tfestimate(Act_Fx, Pred_Fx, [], [], [], Fs);
EstMag   = abs(EstH);
EstPhase = angle(EstH);
EstOmega = EstF*2*pi;

%% Make plot
figure(1); clf
%  Magnitude plot on top
subplot(2, 1, 1)
semilogx(EstOmega, 20*log10(EstMag), 'b-')
xlabel('\omega, rad/s')
ylabel('|H|, dB')
%  Phase plot on bottom
subplot(2,1,2)
semilogx(EstOmega, EstPhase, 'b-')
xlabel('\omega, rad/s')
ylabel('\angle H, rad')