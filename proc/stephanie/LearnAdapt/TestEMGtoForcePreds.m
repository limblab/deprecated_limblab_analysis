% Test predictions of force from EMG

% Make predictions of force using the actual EMG that the monkey was
% executing during brain control. Use the EMG to force decoder that I
% gave the monkey during the experiment. Compare this to predictions of force from the
% neural activity that he was producing during brain control.


% Make binned Data file
FCUind = strmatch('FCU',binnedData.emgguide(1,:)); FCUind = FCUind(1);
FCRind = strmatch('FCR',binnedData.emgguide(1,:)); FCRind = FCRind(1);
ECUind = strmatch('ECU',binnedData.emgguide(1,:)); ECUind = ECUind(1);
ECRind = strmatch('ECR',binnedData.emgguide(1,:)); ECRind = ECRind(1);
emg_vector = [FCUind FCRind ECUind ECRind];
% Make new binnedData file where the EMGs are where the spikes are (a hack
% so you can make predictions using EMGs as your input)
binnedDataEMGinput = binnedData;
%binnedDataEMGinput.spikeratedata = binnedData.emgdatabin(:,emg_vector);
binnedDataEMGinput.emgguide = binnedData.emgguide(:,emg_vector);
%binnedDataEMGinput.neuronIDs = [1 0; 2 0; 3 0; 4 0];
binnedDataEMGinput.emgdatabin =  binnedData.emgdatabin(:,emg_vector);



[CursorPreds,EMGNew,ActualCursorNew]=predMIMO3(binnedDataEMGinput.emgdatabin,emg_decoder.H,1,1,binnedDataEMGinput.cursorposbin);
VAF = calculateVAF(CursorPreds,ActualCursorNew);

figure
hold on
plot(CursorPreds(:,1),'r')
plot(ActualCursorNew(:,1),'k')
title(strcat('X force | VAF = ', num2str(VAF(:,1))))

figure
hold on
plot(CursorPreds(:,2),'r')
plot(ActualCursorNew(:,2),'k')
title(strcat('Y force | VAF = ', num2str(VAF(:,2))))












options.plotflag =1;
options.foldlength = 300;
options.UseAllInputs = 1;
options.fillen = 0.25;
options.PredCursPos = 1; options.PredEMGs = 0; options.PredForce = 0; options.PredVeloc = 0;
options.EMGcascade=0; options.Use_Ridge=0; options.Use_EMGs=0; options.Use_Thresh=0;
options.numPCs = 0; options.Use_SD = 0;
[~, EMGtoForce_VAF] = mfxval(binnedDataEMGinput, options);

options.fillen=0.5;
options.EMGcascade=1; options.PredEMGs=1;
[~, NeuronstoForce_VAF] = mfxval(binnedData, options)
