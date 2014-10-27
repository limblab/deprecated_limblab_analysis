function [EMGpatterns, EMGLabels] = ave_emgs_wf(binnedData, timeBefore, timeAfter,EMGvector, plotflag)

%   wf_trialtable:
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: OT on time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)

%assumes EMGpatterns for center hold + 8 targets
numTgts = 8;

% rewards = find( binnedData.tt(:,9)==double('R') );
% numRew = length(rewards);
numEMGs = length(EMGvector);
numTrials=size(binnedData.trialtable,1);
EMGpatterns = zeros(numTgts+1,numEMGs);
tgt_count = zeros(numTgts,1);
EMGLabels = binnedData.emgguide(EMGvector,:);

for i = 1:numTrials
    if(binnedData.trialtable(i,7)>=0)
        %average EMGs after touch pad hold (go tone)
        %place results in EMGpatterns(1,:,:)
        Go_ts = binnedData.trialtable(i,7);
        start = find(binnedData.timeframe > Go_ts-timeBefore, 1, 'first');
        stop  = find(binnedData.timeframe > Go_ts+timeAfter,  1, 'first');

        if isempty(start) || isempty(stop)
            warning('Trying to access out of range data, trialtable may not match binnedData');
            numTrials = numTrials-1;
            continue;
        else
            %average EMGs at Go_Cue: (in first row of EMGpatterns)
            mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
            EMGpatterns(1,:) = EMGpatterns(1,:) + mEMG;
        end
    end
 
    %average EMGs after Rewards. Make sure target ID is not -1
    if binnedData.trialtable(i,9)==double('R') && binnedData.trialtable(i,10) >=0
       
        tgt_id    = binnedData.trialtable(i,10);
        reward_ts = binnedData.trialtable(i,8 );

        start = find(binnedData.timeframe > reward_ts-timeBefore, 1, 'first');
        stop  = find(binnedData.timeframe > reward_ts+timeAfter,  1, 'first');
        
        if isempty(start) || isempty(stop)
            warning('Trying to access out of range data, trialtable may not match binnedData');
            
        else
            %average EMGs at Reward: (in 2nd to numTgt+1 rows of EMGpatterns)
            % and place results in EMGpatterns(2:end,:)
            mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
            EMGpatterns(tgt_id+1,:) = EMGpatterns(tgt_id+1,:) + mEMG;

            tgt_count(tgt_id) = tgt_count(tgt_id) + 1;
        end
    end
end

%Now divide to get the mean
%first, for Go_Cues:
EMGpatterns(1,:) = EMGpatterns(1,:)/numTrials;
%then for each target at reward:
for t=1:numTgts
    if tgt_count(t)
        EMGpatterns(t+1,:) = EMGpatterns(t+1,:)/tgt_count(t);
    end
end

%polar plot of EMGs
if plotflag
    plot_emg_patterns(EMGpatterns)
end