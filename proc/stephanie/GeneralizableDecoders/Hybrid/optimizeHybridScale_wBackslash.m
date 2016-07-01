%optimizeHybridScale

%Initialize variables
numlags = 10; plotFlag = 0;

%Load files


% Make test and training sets
[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);
HybridFinal.scale = [];


stdScale = std(IsoBinned.emgdatabin(:,:))./(std(WmBinned.emgdatabin(:,:)));
varScale = var(IsoBinned.emgdatabin(:,:))./(var(WmBinned.emgdatabin(:,:)));
sqrtStdScale = sqrt(std(IsoBinned.emgdatabin(:,:)))./sqrt((std(WmBinned.emgdatabin(:,:))));

newScales = [stdScale; varScale; sqrtStdScale];
H = [];
foldername = '11072014';

for i = 1:length(newScales(:,1))
    HybridFinal.scale = newScales(i,:)';
    dummyH = [];
    for Hind = 1%:12
        emgInd = Hind;
         [dummyH(:,Hind)] = backslash(HybridFinal,numlags,emgInd);
         [ dummyHstats.HonI_vaf(Hind)  dummyHstats.IonI_vaf(Hind)  dummyHstats.WonI_vaf(Hind)  dummyHstats.HonW_vaf(Hind)  dummyHstats.WonW_vaf(Hind) dummyHstats.IonW_vaf(Hind) ] = newGeneralizabilityStats(foldername,numlags,emgInd,dummyH(:,Hind), plotFlag, IsoTest, IsoTrain, WmTest, WmTrain,HybridFinal);
    end
    
    H{i} = dummyH;
    Hstats{i} = dummyHstats;
    
end

 %Save variables for this iteration
 %save('11062014decoders.mat')
    