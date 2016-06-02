function [S,F,t] = getStimForce(binnedData,chans,plotflag)

t_Stim = binnedData.stim(:,1);
Stim   = binnedData.stim(:,chans+1);
t_F    = binnedData.timeframe;
F      = binnedData.forcedatabin(:,1);

% 1 - Normalize - No, prctile depends on how much the monkey worked, this would change results
% Stim = Stim/200;
% NormFactor = prctile(binnedData.forcedatabin(:,1),98);
% F = F/NormFactor;


% 2 - plot force and stim over time
if plotflag
    figure
    plot(t_Stim,Stim);hold on; plot(t_F,F,'r--');
end

% C=xcorr(F,Stim(:,2));
% figure;
% plot([sort(-t_Stim(2:end));t_Stim],C);
%peak is found at -80ms -> use average values from stim found between 40ms and 120ms before Force

F_idx   = find(F);
t = t_F(F_idx);
F = F(F_idx);
S = zeros(length(F_idx),size(Stim,2));

for i = 1:length(F_idx)
    S_idx = t_Stim <= t(i)-0.04 & t_Stim >= t(i) -0.12;
    if ~any(S_idx)
        %Very beginning of file, no prior stim info, put 0 in both F and S...
        S(i,:) = 0;
        F(i,:) = 0;
    else
        S(i,:) = mean(Stim(S_idx,:),1);
    end
end

if plotflag
    for i = 1:length(chans)
        figure;
        plot(S(:,i),F,'.');
        title(sprintf('Stim chan %d',chans(i)));
    end

    figure;
    plot(sum(S,2),F,'.');
    title('Sum of all Stim chans');
end


% subplot(3,1,1);
% plot(binned_stim_array(:,1),binned_stim_array(:,3));
% subplot(3,1,2);
% plot(binned_stim_array(:,1),binned_stim_array(:,5));
% subplot(3,1,3);
% plot(binnedData.timeframe,binnedData.forcedatabin(:,1));
