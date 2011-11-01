function [EMGpatterns, EMGLabels] = ave_emgs_mg(binnedData, timeBefore, timeAfter, EMGvector, plotflag)
%    mg_trialtable:
%    1: Start time
%    2: Hand on Touch Pad
%    3: Go cue (word = Go | Catch)
%    4: Trial Type (0:Go, 1:Catch)
%    5: Gadget ID (0:3)
%    6: Target ID (0:15)
%    12: Target UL X
%    8: Target UL Y
%    9: Target LR X
%    10:Target LR Y
%    11:Trial End time
%    12:Trial result        -- R, A, F, or I

targets = unique(binnedData.trialtable(:,6));
gadgets = unique(binnedData.trialtable(:,5));
numTgts = length(targets);
numGdts = length(gadgets);
numEMGs = length(EMGvector);
numTrials=size(binnedData.trialtable,1);
EMGpatterns = zeros(numTgts+1,numEMGs,numGdts);
tgt_gdt_count = zeros(numTgts,numGdts);

for i = 1:numTrials
    %average EMGs after touch pad hold (go tone)
    %place results in EMGpatterns(1,:,:)

    Go_ts = binnedData.trialtable(i,3);
    start = find(binnedData.timeframe > Go_ts-timeBefore, 1, 'first');
    stop  = find(binnedData.timeframe > Go_ts+timeAfter,  1, 'first');
    
    %average EMGs at Go_Cue: (in first row of EMGpatterns)
    mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
    EMGpatterns(1,:,:) = EMGpatterns(1,:,:) + repmat(mEMG,1,numGdts);

    %average EMGs after Rewards
    %place results in EMGpatterns(2:end,:,:)
    if binnedData.trialtable(i,12)==double('R')
        tgt_id    = find(targets==binnedData.trialtable(i,6));
        gdt_id    = find(gadgets==binnedData.trialtable(i,5));
        reward_ts = binnedData.trialtable(i,11 );

        start = find(binnedData.timeframe > reward_ts-timeBefore, 1, 'first');
        stop  = find(binnedData.timeframe > reward_ts+timeAfter,  1, 'first');

        %average EMGs at Reward: (in 2nd to numTgt+1 rows of EMGpatterns)
        mEMG = mean(binnedData.emgdatabin(start:stop,EMGvector));
        EMGpatterns(tgt_id+1,:,gdt_id) = EMGpatterns(tgt_id+1,:,gdt_id) + mEMG;

        tgt_gdt_count(tgt_id,gdt_id) = tgt_gdt_count(tgt_id,gdt_id) + 1;
    end
end

%Now divide to get the mean
%first, for Go_Cues:
EMGpatterns(1,:,:) = EMGpatterns(1,:,:)/numTrials;
%then for each target, gadget at reward:
for t=1:numTgts
    for g = 1:numGdts
        if tgt_gdt_count(t,g)
            EMGpatterns(t+1,:,g) = EMGpatterns(t+1,:,g)/tgt_gdt_count(t);
        end
    end
end
    
EMGLabels = binnedData.emgguide(EMGvector,:);

%polar plot of EMGs
if plotflag
    %EMG pattern for Go_Cues:
    figure;
    theta = 0:2*pi()/(numEMGs):2*pi();
    
    %This is just a way to plot radial axis from 0 to 1:
    P = polar(theta, ones(size(theta)));
    set(P, 'Visible', 'off'); hold on;
    
    %now plot EMG pattern:
    rho = [EMGpatterns(1,:,1) EMGpatterns(1,1,1)];
    P = polar(theta,rho);
    title('Touch Pad');
    
    %EMG patterns for tgts/gdts
    for t=1:numTgts
        for g = 1:numGdts
            figure;
            theta = 0:2*pi()/(numEMGs):2*pi();
            %same trick here:
            P = polar(theta, ones(size(theta)));
            set(P, 'Visible', 'off'); hold on;
            rho = [EMGpatterns(t+1,:,g) EMGpatterns(t+1,1,g)];
            polar(theta,rho);
            title(sprintf('Gadget %g, Target %g',gadgets(g),targets(t)));
        end
    end
end