function [Go_Rew_ts_wf_EMGs] = get_Real_EMGs_WF(binnedData, timeBefore, timeAfter,EMGvector)

%   wf_trialtable:
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: OT on time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)

tt=binnedData.trialtable;
%assumes EMGpatterns for center hold + 8 targets
numTgts = 8;

% rewards = find( binnedData.tt(:,9)==double('R') );
% numRew = length(rewards);
numEMGs = length(EMGvector);
numTrials=size(tt,1);

tgt_count = zeros(numTgts,1);

% Find Go and Reward rows in tt :
Go = find(tt(:,7) >= 0); %sometimes Go ts may be = -1 in tt if something was wrong
Rewards = find( tt(:,9)==double('R') );
numRew = length(Rewards);
numGo = length(Go);

Rew_ts_w_EMGs = zeros(numRew,numEMGs+1);
Go_ts_w_EMGs = zeros(numGo,numEMGs+1);

cont_go = 0;
cont_rw = 0;
for i = 1:numTrials
    if(tt(i,7)>=0)
        %average EMGs after touch pad hold (go tone)
        %place results in EMGpatterns(1,:,:)
        Go_ts = tt(i,7);
        start = find(binnedData.timeframe > Go_ts-timeBefore, 1, 'first');
        stop  = find(binnedData.timeframe > Go_ts+timeAfter,  1, 'first');

        if isempty(start) || isempty(stop)
            warning('Trying to access out of range data, trialtable may not match binnedData');
            numTrials = numTrials-1;
            continue;
        else
            %average EMGs at Go_Cue: (in first row of EMGpatterns)
            cont_go = cont_go + 1;            
            mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
            Go_ts_w_EMGs(cont_go,:) = [Go_ts , mEMG];
        end
    end
 
    %average EMGs after Rewards. Make sure target ID is not -1
    if binnedData.trialtable(i,9)==double('R') && binnedData.trialtable(i,10) >=0
        reward_ts = binnedData.trialtable(i,8 );
        start = find(binnedData.timeframe > reward_ts-timeBefore, 1, 'first');
        stop  = find(binnedData.timeframe > reward_ts+timeAfter,  1, 'first');
        
        if isempty(start) || isempty(stop)
            warning('Trying to access out of range data, trialtable may not match binnedData');           
        else
            cont_rw = cont_rw + 1;            
            mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
            Rew_ts_w_EMGs(cont_rw,:) = [reward_ts , mEMG];     
        end
    end
end

Go_Rew_ts_wf_EMGs = sortrows([Go_ts_w_EMGs; Rew_ts_w_EMGs],1);