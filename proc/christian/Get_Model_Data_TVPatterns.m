function [ModelData] = Get_Model_Data_TVPatterns(binnedData,S_TVP,R_ts )%, timeWindow) %, SigLag)
% S_TVP is MxN array of N-1 expected EMG signals over a period of time (M*binsize seconds)
%   the first column in S_TVP is time relative to reward ts

binsize  = binnedData.timeframe(2)-binnedData.timeframe(1);
binsizeTVP = S_TVP(2,1)-S_TVP(1,1);
timeWindow = binsizeTVP*size(S_TVP,1);
timebefore = S_TVP(1,1);

numBlocks   = size(R_ts,1);
numDataBins = size(binnedData.timeframe,1);
numEMGs     = size(S_TVP,2)-1;

ModelData.emgguide      = binnedData.emgguide(:,:);
ModelData.spikeguide    = binnedData.spikeguide;
ModelData.timeframe     = binnedData.timeframe;
ModelData.spikeratedata = binnedData.spikeratedata;
%%%
ModelData.emgdatabin    = zeros(numDataBins,numEMGs);
%%%

for b = 1:numBlocks
        
    b_start = R_ts(b)+timebefore;
    b_end   = b_start+timeWindow;
        
    if b_start < 0 || b_end > binnedData.timeframe(end,1)
        continue;
    end
    
    tmpDataBlock = find((binnedData.timeframe>=b_start) & binnedData.timeframe<b_end);

    %use template as emg data, scaled in amplitude with aveFR    
    %get an average FR over the block period 
    aveFR = mean(mean(binnedData.spikeratedata(tmpDataBlock,:)));
    %and scale EMG template with aveFR
    ModelData.emgdatabin(tmpDataBlock,:) = S_TVP(:,2:end)*aveFR;
end

% %scale to 0-30 
% for i = 1:numEMGs
%     ModelData.emgdatabin(:,i) = 30*ModelData.emgdatabin(:,i)/max(ModelData.emgdatabin(:,i));
% end

end