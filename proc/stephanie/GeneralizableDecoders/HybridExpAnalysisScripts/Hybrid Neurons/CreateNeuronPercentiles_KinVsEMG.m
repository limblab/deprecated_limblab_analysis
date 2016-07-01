function CreateNeuronPercentiles_KinVsEMG(binnedData,plotTitle)

% Make EMG decoder
options=[]; options.PredEMGs = 1;
EMGModel = BuildModel(binnedData, options);


% Make X force/pos decoder
options=[]; options.PredCursPos = 1;
KinModel = BuildModel(binnedData, options);

[EMG_NeuronPercentile]=HybridNeuronsThatCare(binnedData,EMGModel.H,1);
[Kin_NeuronPercentile]=HybridNeuronsThatCare(binnedData,KinModel.H,0);

% Make scatterplot
figure;
plot(EMG_NeuronPercentile,Kin_NeuronPercentile,'.k','MarkerSize',10)
hold on
x = 0:100;y=x;plot(x,y)
xlabel('EMG neurons');ylabel('Position neurons')
title(plotTitle)
MillerFigure;

end