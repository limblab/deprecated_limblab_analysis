%optimizeHybridScale


% Make test and training sets
[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);
HybridFinal.scale = [];


stdScale = std(IsoBinned.emgdatabin(:,:))./(std(WmBinned.emgdatabin(:,:)));
varScale = var(IsoBinned.emgdatabin(:,:))./(var(WmBinned.emgdatabin(:,:)));
sqrtStdScale = sqrt(std(IsoBinned.emgdatabin(:,:)))./sqrt((std(WmBinned.emgdatabin(:,:))));

newScales = [stdScale; varScale; sqrtStdScale];
H = [];

for i = 1:length(newScales(:,1))
    HybridFinal.scale = newScales(i,:)';
    dummyH = [];
[dummyH dummyHstats.HonI_vaf  dummyHstats.IonI_vaf  dummyHstats.WonI_vaf  dummyHstats.HonW_vaf  dummyHstats.WonW_vaf dummyHstats.IonW_vaf] = newGeneralizabilityStats_Jan2015(IsoTest, IsoTrain, WmTest, WmTrain,HybridFinal);


    H{i} = dummyH;
    Hstats{i} = dummyHstats;
    
end

 %Save variables for this iteration
 save('07232014decoders_fastHybrid.mat')
    