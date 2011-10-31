function [EMGpatterns, EMGLabels] = ave_emgs_wf(binnedData, timeBefore, timeAfter,EMGvector, plotflag)

% original EMG order: [1-FDS1 2-FDS2 3-FDP1 4-ECR2 5-FCR1 6-FCR2 7-FCU2 8-ECR1 9-FDP2 10-ECU1 11-ECU2]
% new EMG order for polar plot:
%           [FCR2 ECR1 ECR2 ECU1 ECU2 FCU FDS1 FDS2 FDP1 FDP2 FCR1]
% EMGvector = [6 8 4 10 11 7 1 2 3 9 5];

numTgts = 8;
rewards = find( binnedData.tt(:,9)==double('R') );
numRew = length(rewards);
numEMGs = length(EMGvector);
EMGpatterns = zeros(numTgts,numEMGs);
tgt_count = zeros(numTgts,1);

for i = 1:numRew
    tgt_id    = binnedData.tt(rewards(i),10);
    reward_ts = binnedData.tt(rewards(i),8 );

    start = find(binnedData.timeframe > reward_ts-timeBefore, 1, 'first');
    stop  = find(binnedData.timeframe > reward_ts+timeAfter,  1, 'first');

    mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
    EMGpatterns(tgt_id,:) = EMGpatterns(tgt_id,:) + mEMG;

    tgt_count(tgt_id) = tgt_count(tgt_id) + 1;
end

%divide to get the mean
for t=1:8
    if tgt_count(t)
        EMGpatterns(t,:) = EMGpatterns(t,:)/tgt_count(t);
    end
end

EMGLabels = binnedData.emgguide(EMGvector,:);

%polar plot of EMGs
if plotflag
    for i=1:numTgts
        figure;
        theta = 0:2*pi()/(numEMGs):2*pi();
        rho = [EMGpatterns(i,:) EMGpatterns(i,1)];
        %     rho = [S(1,2:end,i) S(1,2,i)];
        polar(theta,rho);
        title(sprintf('Target %g',i));
    end
end