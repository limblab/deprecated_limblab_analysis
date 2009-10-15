ratios1 = slope1.*mean(binnedData.emgdatabin)./(mean(OLPredData.preddatabin)-offset1);
pblock1 = 1-ratios1;
pblockflex1 = mean(pblock1(flx));
pblockext1 = mean(pblock1(ext));

ratios2 = slope2.*mean(binnedData.emgdatabin)./(mean(OLPredData.preddatabin)-offset2);
pblock2 = 1-ratios2;
pblockflex2 = mean(pblock2(flx));
pblockext2 = mean(pblock2(ext));

block = [pblockflex1 pblockext1 pblockflex2 pblockext2]