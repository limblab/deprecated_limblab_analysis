function [S,F,t] = getStimForce(binnedData,chans,plotflag)

t_Stim = binnedData.stim(:,1);
Stim   = binnedData.stim(:,chans+1);
t_F    = binnedData.timeframe;
F      = binnedData.forcedatabin(:,1);

% 1 - Normalize
Stim = Stim/200;
NormFactor = prctile(binnedData.forcedatabin(:,1),98);
F = F/NormFactor;


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
F_times = t_F(F_idx);
F_ToUse = F(F_idx);
S_ToUse = zeros(length(F_idx),size(Stim,2));

for i = 1:length(F_idx)
    S_idx = t_Stim <= F_times(i)-0.04 & t_Stim >= F_times(i) -0.12;
    S_ToUse(i,:) = mean(Stim(S_idx,:),1);
end

if plotflag
    for i = 1:length(chans)
        figure;
        plot(S_ToUse(:,i),F_ToUse,'.');
        title('Stim chan %d',chans(i))
    end

    figure;
    plot(sum(S_ToUse,2),F_ToUse,'.');
end
    
% 
% subplot(3,1,1);
% plot(binned_stim_array(:,1),binned_stim_array(:,3));
% subplot(3,1,2);
% plot(binned_stim_array(:,1),binned_stim_array(:,5));
% subplot(3,1,3);
% plot(binnedData.timeframe,binnedData.forcedatabin(:,1));
