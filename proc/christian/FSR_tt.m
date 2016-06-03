

tt = binnedData.trialtable;
target = 0;

Rewards = find(tt(:,12)==double('R'));
% Rewards= find(tt(:,12)==double('R') & tt(:,6)==target);
numunits = size(binnedData.spikeratedata,2);


FSR   = zeros(length(Rewards),1); %Force to Stim Ratio
FRFR  = zeros(length(Rewards),numunits); % Firing Rate to Force Ratio
TSR   = zeros(length(Rewards),1); %Target height to Force Ratio
FRTR  = zeros(length(Rewards),numunits); % Firing Rate to Target height Ratio
meanS = zeros(length(Rewards),1); %average Stim PW (combined from all stim chans)
meanF = zeros(length(Rewards),1); %average force 
meanFR= zeros(length(Rewards),numunits); % mean Firing Rate
MFRFR = zeros(length(Rewards),1);
MFRTR = zeros(length(Rewards),1);
S = sum([binnedData.stim(:,3) binnedData.stim(:,5)],2);

for i = 1:length(Rewards)
    tgt_h = tt(Rewards(i),10);
    startt = tt(Rewards(i),3);
    endt = tt(Rewards(i),11);
    idxTimeRange = find(binnedData.timeframe > startt & binnedData.timeframe <= endt);
    init_offset = find(binnedData.forcedatabin(idxTimeRange)>0,1,'first')+4;%200ms after initial force signal
    late_offset = find(binnedData.forcedatabin(idxTimeRange)>0,1,'last'); %reward time or last force signal time
    idxTimeRange = idxTimeRange(init_offset:late_offset); 
    if isempty(idxTimeRange)
        disp(sprintf('Could not find force signal in specific time range for trial #%g',i));
        continue;
    end
    meanF(i) = mean(binnedData.forcedatabin(idxTimeRange));
    meanFR(i,:)= mean(binnedData.spikeratedata(idxTimeRange,:));
    idxSRange = find(binnedData.stim(:,1)>=binnedData.timeframe(idxTimeRange(1)) & ...
                     binnedData.stim(:,1)<=binnedData.timeframe(idxTimeRange(end)));
    meanS(i)  = mean(S(idxSRange));
    FSR(i)    = meanF(i)/meanS(i);
    TSR(i)    = tgt_h/meanS(i);
    FRFR(i,:) = meanF(i)./meanFR(i,:);
    FRTR(i,:) = tgt_h./meanFR(i,:);
    MFRFR(i)  = mean(FRFR(i,isfinite(FRFR(i,:))));
    MFRTR(i)  = mean(FRTR(i,isfinite(FRTR(i,:))));
end

figure;plot(meanF/max(binnedData.forcedatabin));hold on;plot(meanS/max(S),'g');legend('Force','Stim');
figure;plot(FSR/max(FSR));title('FSR');%hold on;plot(TSR,'g'); legend('Force/Stim','Target/Stim');
figure;plot(mean(meanFR,2));title('MMFR');
figure;imagesc(FRFR);title('FRFR'); %figure;imagesc(FRTR);title('FRTR');
figure;plot(MFRFR);title('MFRFR');%hold on;plot(MFRTR,'g');title('Mean FR accross units');legend('MFR/Force','MFR/Target');

Jaco_042111_012_FSR= struct('meanF',meanF,...
                            'meanFR',meanFR,...
                            'meanS',meanS,...
                            'FSR',FSR,...
                            'TSR',TSR,...
                            'FRFR',FRFR,...
                            'FRTR',FRTR,...
                            'MFRFR',MFRFR,...
                            'MFRTR',MFRTR);