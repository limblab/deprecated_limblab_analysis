NeuronsThatCareScraps


% Make EMG decoder 
options=[]; options.PredEMGs = 1;
EMGModel = BuildModel(WmBinned, options);


% Make X force/pos decoder
options=[]; options.PredCursPos = 1;
KinModel = BuildModel(WmBinned, options);

%[SortedNeuronsThatCare_EMG SortedNeuronsThatCare_EMG_Names]=HybridNeuronsThatCare(WmBinned,EMGModel.H,1);
%EMGstring=num2str(SortedNeuronsThatCare_EMG_Names); EMGcell=cellstr(EMGstring);
[EMG_NeuronPercentile]=HybridNeuronsThatCare(WmBinned,EMGModel.H,1);
[Kin_NeuronPercentile]=HybridNeuronsThatCare(WmBinned,KinModel.H,0);
% [SortedNeuronsThatCare_Kin SortedNeuronsThatCare_Names]=HybridNeuronsThatCare(WmBinned,KinModel.H,0);
% Kinstring=num2str(SortedNeuronsThatCare_Kin); Kincell=cellstr(Kinstring);

% Make scatterplot
figure;
plot(EMG_NeuronPercentile,Kin_NeuronPercentile,'.k','MarkerSize',10)
hold on
x = 0:100;y=x;plot(x,y)
xlabel('EMG neurons');ylabel('Position neurons')


UniqueEMGneurons_I = length(setdiff(EMGcell,Kincell));
UniqueKinneurons_I = length(setdiff(Kincell,EMGcell));
SharedNeurons_I=intersect(EMGcell,Kincell);

% figure;plot(SortedNeuronsThatCare_EMG(:,1),SortedNeuronsThatCare_EMG(:,2),'bo','MarkerSize',15,'LineWidth',1.5)
% hold on
% plot(SortedNeuronsThatCare_Kin(:,1),SortedNeuronsThatCare_Kin(:,2),'ro','MarkerSize',20,'LineWidth',1.5)

%------------------------------------------------------------
% Make EMG decoder 
options=[]; options.PredEMGs = 1;
EMGModel = BuildModel(WmBinned, options);


% Make X force/pos decoder
options=[]; options.PredCursPos = 1;
KinModel = BuildModel(WmBinned, options);

[SortedNeuronsThatCare_EMG]=HybridNeuronsThatCare(WmBinned,EMGModel.H);
SortedNeuronsThatCare_EMG = SortedNeuronsThatCare_EMG(1:15,:);
EMGstring=num2str(SortedNeuronsThatCare_EMG); EMGcell=cellstr(EMGstring);

[SortedNeuronsThatCare_Kin]=HybridNeuronsThatCare(WmBinned,KinModel.H);
SortedNeuronsThatCare_Kin = SortedNeuronsThatCare_Kin(1:15,:);
Kinstring=num2str(SortedNeuronsThatCare_Kin); Kincell=cellstr(Kinstring);

UniqueEMGneurons_W = length(setdiff(EMGcell,Kincell));
UniqueKinneurons_W = length(setdiff(Kincell,EMGcell));
SharedNeurons_W=intersect(EMGcell,Kincell);




%---------------------------------------------------
% Make EMG decoder 
options=[]; options.PredEMGs = 1;
IsoEMGModel = BuildModel(IsoBinned, options);
WmEMGModel = BuildModel(WmBinned, options);

[SortedNeuronsThatCare_IsoEMG]=HybridNeuronsThatCare(IsoBinned,IsoEMGModel.H);
[SortedNeuronsThatCare_WmEMG]=HybridNeuronsThatCare(WmBinned,WmEMGModel.H);

% Plot
% figure;plot(SortedNeuronsThatCare_IsoEMG(:,1),SortedNeuronsThatCare_IsoEMG(:,2),'bo','MarkerSize',15,'LineWidth',1.5)
% hold on
% plot(SortedNeuronsThatCare_WmEMG(:,1),SortedNeuronsThatCare_WmEMG(:,2),'ro','MarkerSize',20,'LineWidth',1.5)
