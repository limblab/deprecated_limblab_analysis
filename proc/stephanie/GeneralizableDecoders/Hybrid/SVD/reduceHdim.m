function [RedH u1 u2] = reduceHdim(binnedData, hybridflag)
if hybridflag==0
OriginalH=filMIMO4(binnedData.spikeratedata,binnedData.emgdatabin,10,1,1);
else
[OriginalH] = quickHybridDecoder(binnedData);
end 
[U,S,V] = svd(OriginalH');
ActualMuscles = binnedData.emgdatabin;
u1 = U(:,1); u2 = U(:,2);
MeasuredMode1 = ActualMuscles*u1;
MeasuredMode2 = ActualMuscles*u2;
NewBinned = binnedData;
NewBinned.emgdatabin = cat(2,MeasuredMode1,MeasuredMode2);
RedH=filMIMO4(NewBinned.spikeratedata,NewBinned.emgdatabin,10,1,1);
end