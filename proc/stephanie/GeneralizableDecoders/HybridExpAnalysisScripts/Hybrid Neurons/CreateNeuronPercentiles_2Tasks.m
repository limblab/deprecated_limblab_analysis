function CreateNeuronPercentiles_2Tasks(binned1,binned1name, binned2, binned2name, plotTitle)

% Make EMG decoder
options=[]; options.PredEMGs = 1;
EMGModel_1 = BuildModel(binned1, options);
EMGModel_2 = BuildModel(binned2, options);

[NeuronPercentile1]=HybridNeuronsThatCare(binned1,EMGModel_1.H,1);
[NeuronPercentile2]=HybridNeuronsThatCare(binned2,EMGModel_2.H,1);

% Make scatterplot
figure;
plot(NeuronPercentile1,NeuronPercentile2,'.k','MarkerSize',10)
hold on
x = 0:100;y=x;plot(x,y)
xlabel(binned1name);ylabel(binned2name)
title(plotTitle)
MillerFigure;

end