%MvmtForPosVersusIsoForForce
date = '07252014';
LineWidth=3;
numOfLags=10;
options=[];options.PredCursPos = 1;
IsoModelAllx = BuildModel(IsoTrain, options);
WmModelAllx = BuildModel(WmTrain, options);
IsoModelAllx.H(1,:) = [];
WmModelAllx.H(1,:) = [];
[SortedNeuronsThatCare_IsoTrain_x PullingWeight_IsoTrain_x] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAllx.H(:,1), numOfLags, 1);
[SortedNeuronsThatCare_WmTrain_x PullingWeight_WmTrain_x] = neuronsThatCare1SetofWeights(WmTrain, WmModelAllx.H(:,1), numOfLags, 1);

plot(PullingWeight_IsoTrain_x, PullingWeight_WmTrain_x,'x','LineWidth',LineWidth)
xlabel('Isometric predicting force'); ylabel('Movement predicting position')
title(strcat(['Different Decoders ', date]))
xlim([0 0.2]); ylim([0 0.2])
hold on;V=axis;plot(V(1:2),V(3:4),'k--');
MillerFigure

saveas(gca, strcat(['MvmtForPosVersusIsoForForce ',  date,'.fig']))
saveas(gca, strcat(['MvmtForPosVersusIsoForForce ',  date,'.pdf']))

