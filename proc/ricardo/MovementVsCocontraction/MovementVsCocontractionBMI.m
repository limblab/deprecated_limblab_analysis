clear all

emg_idx = 2:3;

% analysis_name = 'day vs day';
% alldata(1).filename = 'Chewie_2015-01-29_DCO_emg_hu_001';
% alldata(1).filetype = 'Movement day 1';
% alldata(2).filename = 'Chewie_2015-01-30_DCO_emg_hu_001';
% alldata(2).filetype = 'Movement day 2';

% analysis_name = 'day vs day';
% alldata(1).filename = 'Chewie_2015-01-29_RP_emg_hu_001';
% alldata(1).filetype = 'Co-contraction day 1';
% alldata(2).filename = 'Chewie_2015-01-30_RP_emg_hu_001';
% alldata(2).filetype = 'Co-contraction day 2';

analysis_name = 'mov vs cocon';
alldata(1).filename = 'Chewie_2015-02-04_RP_n2e_hu_001';
alldata(1).filetype = 'Co-contraction';
alldata(2).filename = 'Chewie_2015-02-04_DCO_n2e_hu_001';
alldata(2).filetype = 'Movement';

% analysis_name = 'cocon1 vs cocon2';
% alldata(1).filename = 'Chewie_2015-02-04_RP_n2e_hu_001';
% alldata(1).filetype = 'Co-contraction 1';
% alldata(2).filename = 'Chewie_2015-02-04_RP_n2e_hu_002';
% alldata(2).filetype = 'Co-contraction 2';

datapath = 'D:\Chewie_8I2\';
mkdir([datapath alldata(1).filename(1:end-4) filesep 'Results']);

load([datapath alldata(1).filename(1:end-4) filesep 'BinnedData' filesep alldata(1).filename]);
alldata(1).binnedData = binnedData;

bmi_emg_idx = find(~cellfun(@isempty,strfind(alldata(1).binnedData.bmi_headers,'EMG')));

alldata(1).binnedData.emgdatabin = alldata(1).binnedData.bmi(:,bmi_emg_idx(emg_idx));
alldata(1).binnedData.emgguide = alldata(1).binnedData.emgguide(emg_idx,:);
clear binnedData

load([datapath alldata(2).filename(1:end-4) filesep 'BinnedData' filesep alldata(2).filename]);
alldata(2).binnedData = binnedData;

bmi_emg_idx = find(~cellfun(@isempty,strfind(alldata(2).binnedData.bmi_headers,'EMG')));

alldata(2).binnedData.emgdatabin = alldata(2).binnedData.bmi(:,bmi_emg_idx(emg_idx));
alldata(2).binnedData.emgguide = alldata(2).binnedData.emgguide(emg_idx,:);
clear binnedData
   
for iSpike = 1:size(alldata(1).binnedData.spikeguide,1)
    spike_guide_cell_1{iSpike} = alldata(1).binnedData.spikeguide(iSpike,:);
end
for iSpike = 1:size(alldata(2).binnedData.spikeguide,1)
    spike_guide_cell_2{iSpike} = alldata(2).binnedData.spikeguide(iSpike,:);
end

[~,sg1,sg2] = intersect(spike_guide_cell_1,spike_guide_cell_2);
alldata(1).binnedData.spikeratedata = alldata(1).binnedData.spikeratedata(:,sg1);
alldata(1).binnedData.spikeguide = alldata(1).binnedData.spikeguide(sg1,:);
alldata(2).binnedData.spikeratedata = alldata(2).binnedData.spikeratedata(:,sg2);
alldata(2).binnedData.spikeguide = alldata(2).binnedData.spikeguide(sg2,:);

modulated_neurons = (std(alldata(1).binnedData.spikeratedata)>5) &...
    (std(alldata(2).binnedData.spikeratedata)>5);
alldata(1).binnedData.spikeratedata = alldata(1).binnedData.spikeratedata(:,modulated_neurons);
alldata(1).binnedData.spikeguide = alldata(1).binnedData.spikeguide(modulated_neurons,:);
alldata(2).binnedData.spikeratedata = alldata(2).binnedData.spikeratedata(:,modulated_neurons);
alldata(2).binnedData.spikeguide = alldata(2).binnedData.spikeguide(modulated_neurons,:);

%%
dt = mean(diff(alldata(1).binnedData.timeframe));
num_emgs = size(alldata(1).binnedData.emgdatabin,2);
num_neurons = size(alldata(1).binnedData.spikeratedata,2);
for iFile = 1:2
    alldata(iFile).cross_correlation_max = zeros(size(alldata(1).binnedData.emgdatabin,2),size(alldata(1).binnedData.spikeratedata,2));
    alldata(iFile).cross_correlation_max_lag = zeros(size(alldata(1).binnedData.emgdatabin,2),size(alldata(1).binnedData.spikeratedata,2));
    alldata(iFile).cross_correlation_min = zeros(size(alldata(1).binnedData.emgdatabin,2),size(alldata(1).binnedData.spikeratedata,2));
    alldata(iFile).cross_correlation_min_lag = zeros(size(alldata(1).binnedData.emgdatabin,2),size(alldata(1).binnedData.spikeratedata,2));
    for iEMG = 1:num_emgs
        for iNeuron = 1:num_neurons
            [XCF,lags,bounds] = crosscorr(alldata(iFile).binnedData.spikeratedata(:,iNeuron),alldata(iFile).binnedData.emgdatabin(:,iEMG),20,1.96);
            
%             [XCF,lags] = xcov(alldata(iFile).binnedData.spikeratedata(:,iNeuron),alldata(iFile).binnedData.emgdatabin(:,iEMG),20);
%             lags = -lags;
            
            [alldata(iFile).cross_correlation_max(iEMG,iNeuron),alldata(iFile).cross_correlation_max_lag(iEMG,iNeuron)] = max(XCF);
            alldata(iFile).cross_correlation_max_lag(iEMG,iNeuron) = dt*lags(alldata(iFile).cross_correlation_max_lag(iEMG,iNeuron));
            [alldata(iFile).cross_correlation_min(iEMG,iNeuron),alldata(iFile).cross_correlation_min_lag(iEMG,iNeuron)] = min(XCF);
            alldata(iFile).cross_correlation_min_lag(iEMG,iNeuron) = dt*lags(alldata(iFile).cross_correlation_min_lag(iEMG,iNeuron));
            alldata(iFile).cross_correlation_bound(iEMG,iNeuron) = max(bounds);
        end
    end
end

%%
figure;

for iEMG = 1:num_emgs    
    positive_lags_1 = find(alldata(1).cross_correlation_max_lag(iEMG,:)>=0 &...
        alldata(1).cross_correlation_max_lag(iEMG,:)<1);
    
    positive_lags_2 = find(alldata(2).cross_correlation_max_lag(iEMG,:)>=0 &...
        alldata(2).cross_correlation_max_lag(iEMG,:)<1);
    
    positive_lags = intersect(positive_lags_1,positive_lags_2);
    
    subplot(1,num_emgs,iEMG)
    hold on
    x = alldata(1).cross_correlation_max(iEMG,positive_lags)';
    y = alldata(2).cross_correlation_max(iEMG,positive_lags)';
%     [~,~,~,~,stats] = regress(x-mean(x),y-mean(y));
%     r_squared = stats(1);
    [f,stats] = polyfit(x,y,1);
    y_est = polyval(f,x);
    r_squared = 1-sum((y-y_est).^2)/sum((y-mean(y)).^2);
    
    plot(x,y,'.k','MarkerSize',10)
    text(0.5,0.9,{['R^2 = ' num2str(r_squared)];['n = ' num2str(length(positive_lags))]})
    plot([0 1],[0 1],'--')
    title({alldata(1).filename; alldata(2).filename;...
        'Crosscorrelations';...
        ['Neurons to predicted EMG ' deblank(alldata(1).binnedData.emgguide(iEMG,:))]},'Interpreter','none')
    ylabel([alldata(2).filetype ' crosscorrelation'])
    xlabel([alldata(1).filetype ' crosscorrelation'])    
    axis square
    xlim([0 1])
    ylim([0 1])    
end

print(gcf,'-dpdf',[datapath alldata(1).filename(1:end-4) filesep 'Results' filesep alldata(1).filename '-individual crosscorrelations-predicted_emg-' analysis_name])
%% 
[max_correlations_1,b] = max(alldata(1).cross_correlation_max(:,:));
max_correlations_1_lag(b==1) = alldata(1).cross_correlation_max_lag(1,b==1);
max_correlations_1_lag(b==2) = alldata(1).cross_correlation_max_lag(2,b==2);

positive_lags_1 = (max_correlations_1_lag>=0 & max_correlations_1_lag<1);

[max_correlations_2,b] = max(alldata(2).cross_correlation_max(:,:));
max_correlations_2_lag(b==1) = alldata(2).cross_correlation_max_lag(1,b==1);
max_correlations_2_lag(b==2) = alldata(2).cross_correlation_max_lag(2,b==2);

positive_lags_2 = (max_correlations_2_lag>=0 & max_correlations_2_lag<1);

positive_lags = positive_lags_1 & positive_lags_2;

figure; 
hold on    
x = max_correlations_1(positive_lags)';
y = max_correlations_2(positive_lags)';
% y = max(alldata(2).cross_correlation_max(:,positive_lags))';
% [~,~,~,~,stats] = regress(x-mean(x),y-mean(y));
% r_squared = stats(1);
[f,stats] = polyfit(x,y,1);
y_est = polyval(f,x);
r_squared = 1-sum((y-y_est).^2)/sum((y-mean(y)).^2);
plot(x,y,'.k','MarkerSize',10);            

plot([0 1],[0 1],'--')
text(0.5,0.9,{['R^2 = ' num2str(r_squared)];['n = ' num2str(sum(positive_lags))]})
ylabel([alldata(2).filetype ' crosscorrelation'])
xlabel([alldata(1).filetype ' crosscorrelation']) 
axis square
xlim([0 1])
ylim([0 1])    
title({[alldata(1).filename ' - ' alldata(2).filename];...
    'Crosscorrelations';...
    ['Neurons to predicted EMG ']},'Interpreter','none')

print(gcf,'-dpdf',[datapath alldata(1).filename(1:end-4) filesep 'Results' filesep alldata(1).filename '-max crosscorrelations-predicted_emg-' analysis_name])

    