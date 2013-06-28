function plotCatchTrialSequence(filename)
% Plots, over time, whether each trial was a catch trial or not)

if ~iscell(filename)
    filename = {filename};
end

trialTable = poolCatchTrialData(filename);

hcInds = find(trialTable(:,11)==0);
ctInds = find(trialTable(:,11)==1);

% figure;
% hold all;
% plot([hcInds hcInds]',[zeros(size(hcInds)) ones(size(hcInds))]','g','LineWidth',2);
% plot([ctInds ctInds]',[zeros(size(ctInds)) ones(size(ctInds))]','r','LineWidth',2);
% axis('tight');
% set(gca,'YTick',0)
% xlabel('Trials');

figure;
colormap hot;
imagesc(trialTable(:,11)' + 3 - 3.*trialTable(:,11)',[0 3]);
xlabel('Trial');
set(gca,'YTick',0);