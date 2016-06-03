function [ModelData, ActualData] = Get_Rate_Template_pairs(binnedData,S,Center_ts,Reward_ts,timeWindow)


numBins = timeWindow/0.05;
BaselineFR = Calc_BaselineFR(binnedData,Center_ts,numBins);

numTargets = size(Reward_ts,2);
for tmpTarget=1:numTargets


    numRewards = size(Reward_ts{1,tmpTarget},1);
    for tmpReward = 1:numRewards


        tmp_ts = Reward_ts{1,tmpTarget}(tmpReward,1);
        
        tmpDataBlock = find((binnedData.timeframe<=tmp_ts)&(binnedData.timeframe>tmp_ts-timeWindow) );
        tmpNumBins = size(tmpDataBlock,1);
        
        tmpData.timeframe = binnedData.timeframe( tmpDataBlock ,1);
        tmpData.spikeratedata = binnedData.spikeratedata(tmpDataBlock ,:);
        ActualData.emgdatabin = binnedData.emgdatabin(tmpDataBlock, [3 4 5 9]);
        ActualData.timeframe = tmpData.timeframe;
        tmpData.emgdatabin = zeros(tmpNumBins,size(S,2));

        
        %Generate a emg template
        for tmpBin = length(tmpDataBlock):-1:1
            tmpData.spikeratedata(tmpBin,:) = tmpData.spikeratedata(tmpBin,:)./BaselineFR;
            tmpData.emgdatabin(tmpBin,:) = S(tmpTarget,:)*mean(tmpData.spikeratedata(tmpBin,:));
        end
        clear BaselineFR;

        ModelData.spikeguide = binnedData.spikeguide;
        ModelData.emgguide = binnedData.emgguide;
        ModelData.timeframe = zeros(size(tmpData.spikeratedata,1)*1000,1,'single');
        ModelData.spikeratedata = zeros(size(tmpData.spikeratedata).*[1000 1],'single');
        ModelData.emgdatabin = zeros(size(tmpData.emgdatabin).*[1000 1],'single');
        for i=0:99
            ModelData.spikeratedata(1+i*tmpNumBins:(1+i)*tmpNumBins,:) = tmpData.spikeratedata;
            ModelData.emgdatabin(1+i*tmpNumBins:(1+i)*tmpNumBins,:) = tmpData.emgdatabin;
            ModelData.timeframe(1+i*tmpNumBins:(1+i)*tmpNumBins) = tmpData.timeframe;
        end
    end
end
        
        clear tmp*
end