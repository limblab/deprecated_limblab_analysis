
[bestc bestf] = CalcCh_Feat_fromFeatInd(featindBEST_Chewie)

[bestcSpike] = LFPtoSpikeChTransform(bestc);

bestcLMP = [bestcSpike(bestf==1)];
FeatNum = length(bestcLMP);
bestcLMP = [bestcSpike(bestf==1) repmat(1,FeatNum,1)];

bestcDelta = [bestcSpike(bestf==2)];
FeatNum = length(bestcDelta);
bestcDelta = [bestcSpike(bestf==2) repmat(2,FeatNum,1)];

bestcMu = [bestcSpike(bestf==3)];
FeatNum = length(bestcMu);
bestcMu = [bestcSpike(bestf==3) repmat(3,FeatNum,1)];

bestcGam1 = [bestcSpike(bestf==4)];
FeatNum = length(bestcGam1);
bestcGam1 = [bestcSpike(bestf==4) repmat(4,FeatNum,1)];

bestcGam2 = [bestcSpike(bestf==5)];
FeatNum = length(bestcGam2);
bestcGam2 = [bestcSpike(bestf==5) repmat(5,FeatNum,1)];

bestcGam3 = [bestcSpike(bestf==6)];
FeatNum = length(bestcGam3);
bestcGam3 = [bestcSpike(bestf==6) repmat(6,FeatNum,1)];

bestcAllFeat = [bestcLMP; bestcDelta; bestcMu; bestcGam1; bestcGam2; bestcGam3];


for i = 1:length(bestcAllFeat)
    
    
    if  isempty(find(ul1(:,1) == bestcAllFeat(i,1)))== 0 ;
        
        bestcAllFeat(i,3) = find(ul1(:,1) == bestcAllFeat(i,1));
        
    end
    
end

bestcAllFeat_Spikes = bestcAllFeat(bestcAllFeat(:,3)~=0,:);
bestcAllFeat_NoSpikes = bestcAllFeat(bestcAllFeat(:,3)==0,:);

SPDdir_ByBand = SPD(bestcAllFeat_Spikes(:,3),:);