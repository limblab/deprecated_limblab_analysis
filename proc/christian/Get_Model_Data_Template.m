function [ModelData,ActualData] = Get_Model_Data_Template(binnedData,S,GR_ts,timeWindow) %, SigLag)
% S is an M templates x N signals of expected output
%  GR_ts = [ts tgt_id gdt_id]
%       where tgt_id and gdt_id = [1 to tgt/gdt max] for Rewards ts
%       and tgt_id and gdt_id = 0 for TouchPad (Go_Cue) ts
% timeWindow is the duration in seconds of the spike data and expected EMG blocks to
%       concatenate into the ModelData
% SigLag is the expected lag in seconds between M1 activity and EMG - for future use

% BaselineFR = Calc_BaselineFR(binnedData,Center_ts,numBins);
binsize  = binnedData.timeframe(2)-binnedData.timeframe(1);
bin100ms = int32(0.1/binsize);
bin300ms = int32(0.3/binsize);
bin500ms = int32(0.5/binsize);

tmpNumBins  = int32(timeWindow/binsize);

numBlocks   = size(GR_ts,1);
numDataBins = tmpNumBins*numBlocks;
numEMGs     = size(S,2);
numUnits    = size(binnedData.spikeratedata,2);

ActualData.emgguide      = binnedData.emgguide(:,:);
ActualData.spikeguide    = binnedData.spikeguide;
ActualData.timeframe     = zeros(numDataBins,1);
ActualData.spikeratedata = zeros(numDataBins,numUnits);
ActualData.emgdatabin    = zeros(numDataBins,numEMGs);

ModelData = ActualData;

for b = 0:numBlocks-1
    
    b_start = 1+b*tmpNumBins;
    b_end   = (1+b)*tmpNumBins;
    
    tmp_ts = GR_ts(b+1,1);
    
    if tmp_ts < timeWindow
        continue;
    end
    
    tmpDataBlock = find((binnedData.timeframe<=tmp_ts)&(binnedData.timeframe>tmp_ts-timeWindow) );
    
    ActualData.emgdatabin(b_start:b_end,:)    = binnedData.emgdatabin(    tmpDataBlock, :);
    ActualData.timeframe(b_start:b_end,:)     = binnedData.timeframe(     tmpDataBlock,  1);
    ActualData.spikeratedata(b_start:b_end,:) = binnedData.spikeratedata( tmpDataBlock,  :);

    %Generate an emg template
    for tmpBin = 0:length(tmpDataBlock)-1
        %get an average FR 100ms before
        aveFR = mean(mean(binnedData.spikeratedata(tmpDataBlock(tmpBin+1)-bin100ms:tmpDataBlock(tmpBin+1),:)));
        %and scale EMG template
        ModelData.emgdatabin(b_start+tmpBin,:) = S(GR_ts(b+1,2)+1,:)*aveFR;
%        ModelData.emgdatabin(b_start+tmpBin,:) = S(GR_ts(b+1,2)+1,:);
    end
end
% 
% %scale to 0-30 
% for i = 1:numEMGs
%     ModelData.emgdatabin(:,i) = 30*ModelData.emgdatabin(:,i)/max(ModelData.emgdatabin(:,i));
% end

ModelData.timeframe     = ActualData.timeframe;
ModelData.spikeratedata = ActualData.spikeratedata;

end