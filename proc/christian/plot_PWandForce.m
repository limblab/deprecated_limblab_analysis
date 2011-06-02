% stim = get_stim_commands(out_struct);
% [binned_stim_array, stimT] = binPW_atStimFreq(stim);
% binnedData.stim = binned_stim_array;

PW = binnedData.stim(:,3)+binnedData.stim(:,5);

%1-Normalize
PW = PW./200;
t_stim = binned_stim_array(:,1);

F = binnedData.forcedatabin(:,1)./prctile(binnedData.forcedatabin(:,1),98);
t_F = binnedData.timeframe;

% 2 - plot
figure
plot(t_stim,PW,t_F,F);


figure;
subplot(3,1,1);
plot(binned_stim_array(:,1),binned_stim_array(:,3));
subplot(3,1,2);
plot(binned_stim_array(:,1),binned_stim_array(:,5));
subplot(3,1,3);
plot(binnedData.timeframe,binnedData.forcedatabin(:,1));
