numPreds = size(AllPredData,2);

MeanVelTgt = cell(1,numPreds);
 
% MeanVelTgt = NaN(1,6);
% STDVelTgt  = NaN(1,6);

InTgt = binnedData.targetHold;

for pred = 1:numPreds
    disp(sprintf('averaging velocity prediction %d of %d',pred,numPreds));
    
%     find matching timeframes
    idx = false(size(binnedData.timeframe));
    disp('finding matching timeframes');
    tic;
    for i = 1:length(AllPredData{pred}.timeframe)
        idx = idx | binnedData.timeframe == AllPredData{pred}.timeframe(i);
    end
    toc;
% 
%     MeanVelTgt(1,pred)= mean(abs(OLPredData{pred}.preddatabin(InTgt(idx),3)));
%     STDVelTgt(1,pred) = std(abs(OLPredData{pred}.preddatabin(InTgt(idx),3)));
    
    MeanTgt = StateMean(AllPredData{pred}.preddatabin(:,3),InTgt(idx));
    MeanVelTgt{1,pred}= MeanTgt{2};

end

clear InTgt idx i pred MeanTgt;

for i = 1:numPreds
    MeanVelTgt{1,i} = abs(MeanVelTgt{1,i});
end