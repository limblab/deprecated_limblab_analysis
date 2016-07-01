MainNeuronsThatCare
% options.PredCursPos = 1;

numOfLags = 10;

options=[]; options.PredEMGs = 1;
IsoModelAll = BuildModel(IsoTrain, options);
WmModelAll = BuildModel(WmTrain, options);
IsoModelAll.H(1,:) = [];
WmModelAll.H(1,:) = [];


SortedNeuronsThatCare_Hybrid1 = neuronsThatCare1SetofWeights(HybridFinal, H1, numOfLags, 1);
[SortedNeuronsThatCare_Hybrid2 PullingWeight_Hybrid2] = neuronsThatCare1SetofWeights(HybridFinal, H2, numOfLags, 2);
SortedNeuronsThatCare_Hybrid3 = neuronsThatCare1SetofWeights(HybridFinal, H3, numOfLags, 3);
SortedNeuronsThatCare_Hybrid4 = neuronsThatCare1SetofWeights(HybridFinal, H4, numOfLags, 4);
SortedNeuronsThatCare_Hybrid5 = neuronsThatCare1SetofWeights(HybridFinal, H5, numOfLags, 5);
SortedNeuronsThatCare_Hybrid6 = neuronsThatCare1SetofWeights(HybridFinal, H6, numOfLags, 6);
SortedNeuronsThatCare_Hybrid7 = neuronsThatCare1SetofWeights(HybridFinal, H7, numOfLags, 7);
SortedNeuronsThatCare_Hybrid8 = neuronsThatCare1SetofWeights(HybridFinal, H8, numOfLags, 8);
SortedNeuronsThatCare_Hybrid9 = neuronsThatCare1SetofWeights(HybridFinal, H9, numOfLags, 9);
SortedNeuronsThatCare_Hybrid10 = neuronsThatCare1SetofWeights(HybridFinal, H10, numOfLags, 10);
[SortedNeuronsThatCare_Hybrid11 PullingWeight_Hybrid11] = neuronsThatCare1SetofWeights(HybridFinal, H11, numOfLags, 11);
%SortedNeuronsThatCare_Hybrid12 = neuronsThatCare1SetofWeights(HybridFinal, H12, numOfLags, 12);



[SortedNeuronsThatCare_IsoTrain1 PullingWeight_IsoTrain1] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,1), numOfLags, 1);
[SortedNeuronsThatCare_IsoTrain2 PullingWeight_IsoTrain2] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,2), numOfLags, 2);
[SortedNeuronsThatCare_IsoTrain3 PullingWeight_IsoTrain3] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,3), numOfLags, 3);
[SortedNeuronsThatCare_IsoTrain4 PullingWeight_IsoTrain4] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,4), numOfLags, 4);
[SortedNeuronsThatCare_IsoTrain5 PullingWeight_IsoTrain5] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,5), numOfLags, 5);
[SortedNeuronsThatCare_IsoTrain6 PullingWeight_IsoTrain6] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,6), numOfLags, 6);
[SortedNeuronsThatCare_IsoTrain7 PullingWeight_IsoTrain7] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,7), numOfLags, 7);
[SortedNeuronsThatCare_IsoTrain8 PullingWeight_IsoTrain8] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,8), numOfLags, 8);
[SortedNeuronsThatCare_IsoTrain9 PullingWeight_IsoTrain9] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,9), numOfLags, 9);
[SortedNeuronsThatCare_IsoTrain10 PullingWeight_IsoTrain10] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,10), numOfLags, 10);
[SortedNeuronsThatCare_IsoTrain11 PullingWeight_IsoTrain11] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,11), numOfLags, 11);
%SortedNeuronsThatCare_IsoTrain12 = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,12), numOfLags, 12);

[SortedNeuronsThatCare_WmTrain1 PullingWeight_WmTrain1] = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,1), numOfLags, 1);
[SortedNeuronsThatCare_WmTrain2 PullingWeight_WmTrain2]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,2), numOfLags, 2);
[SortedNeuronsThatCare_WmTrain3 PullingWeight_WmTrain3]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,3), numOfLags, 3);
[SortedNeuronsThatCare_WmTrain4 PullingWeight_WmTrain4]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,4), numOfLags, 4);
[SortedNeuronsThatCare_WmTrain5 PullingWeight_WmTrain5]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,5), numOfLags, 5);
[SortedNeuronsThatCare_WmTrain6 PullingWeight_WmTrain6]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,6), numOfLags, 6);
[SortedNeuronsThatCare_WmTrain7 PullingWeight_WmTrain7]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,7), numOfLags, 7);
[SortedNeuronsThatCare_WmTrain8 PullingWeight_WmTrain8]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,8), numOfLags, 8);
[SortedNeuronsThatCare_WmTrain9 PullingWeight_WmTrain9]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,9), numOfLags, 9);
[SortedNeuronsThatCare_WmTrain10 PullingWeight_WmTrain10]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,10), numOfLags, 10);
[SortedNeuronsThatCare_WmTrain11 PullingWeight_WmTrain11]= neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,11), numOfLags, 11);
%SortedNeuronsThatCare_WmTrain12 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,12), numOfLags, 12);


% Kinematics
numOfLags = 10;
options=[];options.PredCursPos = 1;
SprModelAllx = BuildModel(SprTrain, options);
WmModelAllx = BuildModel(WmTrain, options);
HybridKinModel = BuildModel(HybridKinematics, options);
HybridKinModel.H(1,:) = [];
SprModelAllx.H(1,:) = [];
WmModelAllx.H(1,:) = [];
[SortedNeuronsThatCare_Hybrid_x PullingWeight_Hybrid_x] = neuronsThatCare1SetofWeights(HybridKinematics, HybridKinModel.H(:,1), numOfLags, 1);
[SortedNeuronsThatCare_SprTrain_x PullingWeight_SprTrain_x] = neuronsThatCare1SetofWeights(SprTrain, SprModelAllx.H(:,1), numOfLags, 1);
[SortedNeuronsThatCare_WmTrain_x PullingWeight_WmTrain_x] = neuronsThatCare1SetofWeights(WmTrain, WmModelAllx.H(:,1), numOfLags, 1);

% 
[SortedNeuronsThatCare_IsoTrain_x PullingWeight_IsoTrain_x] = neuronsThatCare1SetofWeights(IsoTrain, IsoModelAll.H(:,1), numOfLags, 1);


%%

numOfLags = 10;

% SortedNeuronsThatCare_Hybrid1_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H1_SandM, numOfLags, 1);
SortedNeuronsThatCare_Hybrid2_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H2_SM, numOfLags, 2);
% SortedNeuronsThatCare_Hybrid3_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H3_SandM, numOfLags, 3);
% SortedNeuronsThatCare_Hybrid4_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H4_SandM, numOfLags, 4);
% SortedNeuronsThatCare_Hybrid5_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H5_SandM, numOfLags, 5);
% SortedNeuronsThatCare_Hybrid6_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H6_SandM, numOfLags, 6);
% SortedNeuronsThatCare_Hybrid7_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H7_SandM, numOfLags, 7);
% SortedNeuronsThatCare_Hybrid8_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H8_SandM, numOfLags, 8);
% SortedNeuronsThatCare_Hybrid9_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H9_SandM, numOfLags, 9);
% SortedNeuronsThatCare_Hybrid10_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H10_SandM, numOfLags, 10);
SortedNeuronsThatCare_Hybrid11_SandM = neuronsThatCare1SetofWeights(HybridFinal_SandM, H11_SM, numOfLags, 11);

% SortedNeuronsThatCare_SprTrain1 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,1), numOfLags, 1);
SortedNeuronsThatCare_SprTrain2 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,2), numOfLags, 2);
% SortedNeuronsThatCare_SprTrain3 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,3), numOfLags, 3);
% SortedNeuronsThatCare_SprTrain4 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,4), numOfLags, 4);
% SortedNeuronsThatCare_SprTrain5 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,5), numOfLags, 5);
% SortedNeuronsThatCare_SprTrain6 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,6), numOfLags, 6);
% SortedNeuronsThatCare_SprTrain7 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,7), numOfLags, 7);
% SortedNeuronsThatCare_SprTrain8 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,8), numOfLags, 8);
% SortedNeuronsThatCare_SprTrain9 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,9), numOfLags, 9);
% SortedNeuronsThatCare_SprTrain10 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,10), numOfLags, 10);
SortedNeuronsThatCare_SprTrain11 = neuronsThatCare1SetofWeights(SprTrain, SprModelAll.H(:,11), numOfLags, 11);

% SortedNeuronsThatCare_WmTrain1 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,1), numOfLags, 1);
SortedNeuronsThatCare_WmTrain2 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,2), numOfLags, 2);
% SortedNeuronsThatCare_WmTrain3 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,3), numOfLags, 3);
% SortedNeuronsThatCare_WmTrain4 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,4), numOfLags, 4);
% SortedNeuronsThatCare_WmTrain5 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,5), numOfLags, 5);
% SortedNeuronsThatCare_WmTrain6 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,6), numOfLags, 6);
% SortedNeuronsThatCare_WmTrain7 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,7), numOfLags, 7);
% SortedNeuronsThatCare_WmTrain8 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,8), numOfLags, 8);
% SortedNeuronsThatCare_WmTrain9 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,9), numOfLags, 9);
% SortedNeuronsThatCare_WmTrain10 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,10), numOfLags, 10);
SortedNeuronsThatCare_WmTrain11 = neuronsThatCare1SetofWeights(WmTrain, WmModelAll.H(:,11), numOfLags, 11);


foldername = '081914_Hybrid_SandM_';
saveON = 1;
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid2_SandM, SortedNeuronsThatCare_SprTrain2,SortedNeuronsThatCare_WmTrain2,HybridFinal_SandM.emgguide(2,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid11_SandM, SortedNeuronsThatCare_SprTrain11,SortedNeuronsThatCare_WmTrain11,HybridFinal_SandM.emgguide(11,:),foldername,saveON)


%% Plots
foldername = '081914_';
saveON = 1;
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid1, SortedNeuronsThatCare_IsoTrain1,SortedNeuronsThatCare_WmTrain1,HybridFinal.emgguide(1,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid2, SortedNeuronsThatCare_IsoTrain2,SortedNeuronsThatCare_WmTrain2,HybridFinal.emgguide(2,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid3, SortedNeuronsThatCare_IsoTrain3,SortedNeuronsThatCare_WmTrain3,HybridFinal.emgguide(3,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid4, SortedNeuronsThatCare_IsoTrain4,SortedNeuronsThatCare_WmTrain4,HybridFinal.emgguide(4,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid5, SortedNeuronsThatCare_IsoTrain5,SortedNeuronsThatCare_WmTrain5,HybridFinal.emgguide(5,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid6, SortedNeuronsThatCare_IsoTrain6,SortedNeuronsThatCare_WmTrain6,HybridFinal.emgguide(6,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid7, SortedNeuronsThatCare_IsoTrain7,SortedNeuronsThatCare_WmTrain7,HybridFinal.emgguide(7,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid8, SortedNeuronsThatCare_IsoTrain8,SortedNeuronsThatCare_WmTrain8,HybridFinal.emgguide(8,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid9, SortedNeuronsThatCare_IsoTrain9,SortedNeuronsThatCare_WmTrain9,HybridFinal.emgguide(9,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid10, SortedNeuronsThatCare_IsoTrain10,SortedNeuronsThatCare_WmTrain10,HybridFinal.emgguide(10,:),foldername,saveON)
plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid11, SortedNeuronsThatCare_IsoTrain11,SortedNeuronsThatCare_WmTrain11,HybridFinal.emgguide(11,:),foldername,saveON)
%plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid12, SortedNeuronsThatCare_IsoTrain12,SortedNeuronsThatCare_WmTrain12,HybridFinal.emgguide(12,:),foldername,saveON)

plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid_x, SortedNeuronsThatCare_SprTrain_x,SortedNeuronsThatCare_WmTrain1_x,'X pos',foldername,saveON)






