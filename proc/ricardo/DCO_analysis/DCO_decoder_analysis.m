% function params = DCO_build_decoders(data_struct,params)
DCO = data_struct.DCO;
bdf = data_struct.bdf;

BDF2BinArgs.binsize = 0.05;
BDF2BinArgs.starttime = 1;
BDF2BinArgs.stoptime = 0;
BDF2BinArgs.EMG_hp = 50;
BDF2BinArgs.EMG_lp = 10;
BDF2BinArgs.minFiringRate = 1;
BDF2BinArgs.NormData = 1;
BDF2BinArgs.FindStates = 0;
BDF2BinArgs.Unsorted = 1;
BDF2BinArgs.TriKernel = 0;
BDF2BinArgs.sig = 0.04;
BDF2BinArgs.ArtRemEnable = 1;
BDF2BinArgs.NumChan = 10;
BDF2BinArgs.TimeWind = .0005;

DecoderOptions.PredEMGs = 1;
DecoderOptions.PredForce = 0;
DecoderOptions.PredCursPos = 0;
DecoderOptions.PredVeloc = 0;
DecoderOptions.fillen = 0.05000;
DecoderOptions.UseAllInputs = 1;
DecoderOptions.PolynomialOrder = 2;
DecoderOptions.numPCs = 0;
DecoderOptions.Use_Thresh = 0;
DecoderOptions.Use_EMGs = 0;
DecoderOptions.Use_Ridge = 0;
DecoderOptions.Use_SD = 0;
DecoderOptions.foldlength = 30;

% % Add co-contraction "EMG"
% emg_idx = find(~cellfun(@isempty,strfind(bdf.emg.emgnames,'BRD')));
% emg_idx = [emg_idx find(~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI')))];
% 
% [b_lp,a_lp] = butter(4,10/(bdf.emg.emgfreq/2));
% [b_hp,a_hp] = butter(4,70/(bdf.emg.emgfreq/2),'high');
% 
% clear emg_processed
% for iEMG = 1:2
%     emg_processed(:,iEMG) = double(bdf.emg.data(:,emg_idx(iEMG)+1));
%     emg_processed(:,iEMG) = filtfilt(b_hp,a_hp,emg_processed(:,iEMG));
%     emg_processed(:,iEMG) = abs(emg_processed(:,iEMG));
%     emg_processed(:,iEMG) = filtfilt(b_lp,a_lp,emg_processed(:,iEMG));
%     emg_processed(emg_processed(:,iEMG)<0,iEMG) = 0;
%     emg_processed(:,iEMG) = emg_processed(:,iEMG)/max(emg_processed(:,iEMG));
% end
%     
% temp_1 = emg_processed(:,1)./emg_processed(:,2);        
% temp_2 = emg_processed(:,2)./emg_processed(:,1);
% temp_1(isnan(temp_1)) = 1;
% temp_2(isnan(temp_2)) = 1;
% temp = min(temp_1,temp_2);
% 
% emg_cocontraction_bi_tri = temp .* (emg_processed(:,1) + ...
%     emg_processed(:,2));
% 
% % emg_cocontraction_bi_tri = (emg_processed(:,1) + ...
% %     emg_processed(:,2));
% 
% bdf.emg.emgnames{end+1} = 'EMG_cocon';
% bdf.emg.data(:,end+1) = emg_cocontraction_bi_tri;

disp('Converting BDF structure to binned data...');
binnedData = convertBDF2binned(bdf,BDF2BinArgs);

% [end_idx,~] = find(binnedData.emgdatabin>20*max(std(binnedData.emgdatabin)),1,'first');
% % end_idx = 54000;
% if ~isempty(end_idx)
%     BDF2BinArgs.stoptime = floor(binnedData.timeframe(end_idx)-1);
%     disp(['Removing last ' num2str(binnedData.timeframe(end) - floor(binnedData.timeframe(end_idx)-1))...
%         ' seconds because of noise in the EMG recordings.'])    
%     binnedData = convertBDF2binned(bdf,BDF2BinArgs);
% end
disp('Done.');

% clear bdf
%%
% Duplicate and Shift neural data (so I can split it up into trials later)
% ONLY WORKS WITH UNSORTED DATA!
temp = reshape([bdf.units.id],2,[])';
temp = unique(temp(:,2));
temp(temp==255) = [];
if max(temp)==0
    sorted_file = 0;
    binnedData.neuronIDs = [reshape(repmat(binnedData.neuronIDs(:,1)',10,1),[],1) ...
        repmat((0:9)',size(binnedData.neuronIDs,1),1)];

    for iUnit=1:size(binnedData.neuronIDs,1)
        binnedData.spikeguide(iUnit,:) = ['ee' sprintf('%03d', binnedData.neuronIDs(iUnit,1)) 'u' sprintf('%1d',binnedData.neuronIDs(iUnit,2)) ];
    end
    binnedData.spikeratedata = DuplicateAndShift(binnedData.spikeratedata,10);
else
    sorted_file = 1;
    neuron_idx = find(binnedData.neuronIDs(:,2)>0 & binnedData.neuronIDs(:,2)<255);
    binnedData.spikeratedata = binnedData.spikeratedata(:,neuron_idx);
    binnedData.neuronIDs = binnedData.neuronIDs(neuron_idx,:);
end
%%
% Normalizing EMG
for iTarget = 1:length(DCO.target_locations)
    binnedData_temp{iTarget} = binnedData;
    binnedData_initial{iTarget} = binnedData;
    binnedData_final{iTarget} = binnedData;
    trial_idx = DCO.target_locations_idx{iTarget};
    trial_t_final_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ot_last_hold DCO.table_columns.t_trial_end]);
 
    t_idx_final_hold = [];
    for iTrial = 1:size(trial_t_final_hold,1)
        t_idx_final_hold = [t_idx_final_hold; find(binnedData.timeframe > trial_t_final_hold(iTrial,1) & binnedData.timeframe < trial_t_final_hold(iTrial,2))];
    end
    mean_emg_target(iTarget,:) = mean(binnedData.emgdatabin(t_idx_final_hold,:));   
%     [filter{iTarget}, OLPredData{iTarget}] = BuildModel(binnedData_sub{iTarget}, DecoderOptions);
end
mean_emg_target = max(mean_emg_target);
binnedData.emgdatabin = binnedData.emgdatabin./repmat(2*mean_emg_target,size(binnedData.emgdatabin,1),1);

%%
binnedData_all = binnedData;
binnedData_all.timeframe = [];
binnedData_all.emgdatabin = [];
binnedData_all.spikeratedata = [];

for iTarget = 1:length(DCO.target_locations)
    disp(['Filter ' num2str(iTarget) ' of ' num2str(length(DCO.target_locations))])
    binnedData_sub{iTarget} = binnedData;
    binnedData_initial{iTarget} = binnedData;
    binnedData_final{iTarget} = binnedData;
    trial_idx = DCO.target_locations_idx{iTarget};
    trial_t = DCO.trial_table(trial_idx,[DCO.table_columns.t_trial_start DCO.table_columns.t_trial_end]);
    trial_t_initial_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ct_hold_on DCO.table_columns.t_go_cue]);
    trial_t_final_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ot_last_hold DCO.table_columns.t_trial_end]);
    t_idx = [];
    t_idx_initial_hold = [];
    t_idx_final_hold = [];
    for iTrial = 1:size(trial_t,1)
        t_idx = [t_idx; find(binnedData_sub{iTarget}.timeframe > trial_t(iTrial,1) & binnedData_sub{iTarget}.timeframe < trial_t(iTrial,2))];
        l(iTrial) = length(find(binnedData_sub{iTarget}.timeframe > trial_t(iTrial,1) & binnedData_sub{iTarget}.timeframe < trial_t(iTrial,2)));
        t_idx_initial_hold = [t_idx_initial_hold; find(binnedData_sub{iTarget}.timeframe > trial_t_initial_hold(iTrial,1) & binnedData_sub{iTarget}.timeframe < (trial_t_initial_hold(iTrial,2)-.3))];
        t_idx_final_hold = [t_idx_final_hold; find(binnedData_sub{iTarget}.timeframe > trial_t_final_hold(iTrial,1) & binnedData_sub{iTarget}.timeframe < trial_t_final_hold(iTrial,2))];
    end
    binnedData_sub{iTarget}.timeframe = [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))]';
    binnedData_sub{iTarget}.emgdatabin = binnedData_sub{iTarget}.emgdatabin(t_idx,:);
    binnedData_sub{iTarget}.spikeratedata = binnedData_sub{iTarget}.spikeratedata(t_idx,:);
    
    binnedData_initial{iTarget}.timeframe = [0:diff(binnedData.timeframe(1:2)):(length(t_idx_initial_hold)-1)*diff(binnedData.timeframe(1:2))]';
    binnedData_initial{iTarget}.emgdatabin = binnedData.emgdatabin(t_idx_initial_hold,:);
    binnedData_initial{iTarget}.spikeratedata = binnedData.spikeratedata(t_idx_initial_hold,:);
    
    binnedData_final{iTarget}.timeframe = [0:diff(binnedData.timeframe(1:2)):(length(t_idx_final_hold)-1)*diff(binnedData.timeframe(1:2))]';
    binnedData_final{iTarget}.emgdatabin = binnedData.emgdatabin(t_idx_final_hold,:);
    binnedData_final{iTarget}.spikeratedata = binnedData.spikeratedata(t_idx_final_hold,:);
    
    if iTarget == 1
        binnedData_all.timeframe = binnedData_sub{iTarget}.timeframe;
    else
        binnedData_all.timeframe = [binnedData_all.timeframe ;...
            binnedData_all.timeframe(end) + BDF2BinArgs.binsize + binnedData_sub{iTarget}.timeframe];
    end
    binnedData_all.emgdatabin = [binnedData_all.emgdatabin ; binnedData_sub{iTarget}.emgdatabin];
    binnedData_all.spikeratedata = [binnedData_all.spikeratedata ; binnedData_sub{iTarget}.spikeratedata];
    
    [filter{iTarget}, OLPredData{iTarget}] = BuildModel(binnedData_sub{iTarget}, DecoderOptions);
    [R2{iTarget}, vaf_target{iTarget}, mse_target{iTarget}] = mfxval(binnedData_sub{iTarget}, DecoderOptions);
end
[filter_all, ~] = BuildModel(binnedData_all, DecoderOptions);
[R2_all, vaf, mse] = mfxval(binnedData_all, DecoderOptions);

%%
trial_t = DCO.trial_table(:,[DCO.table_columns.t_ct_hold_on DCO.table_columns.t_trial_end]);
median_t = median(diff(trial_t'));
dt = round(1000*diff(binnedData.timeframe(1:2)))/1000;
num_bins = floor(median_t/dt);
t_idx = zeros(size(trial_t,1),num_bins);
for iTrial = 1:size(trial_t,1)
    t_idx(iTrial,:) = find(binnedData.timeframe >= trial_t(iTrial,1),1,'first')+[0:num_bins-1];    
end
% firing_rates = binnedData.spikeratedata(t_idx(:),binnedData.neuronIDs(:,2)>0 & binnedData.neuronIDs(:,2) < 255);
firing_rates = binnedData.spikeratedata(t_idx(:),:);
[coeff,score,latent,tsquared] = pca(firing_rates);
reshape(score,size(t_idx,1),[],size(binnedData.neuronIDs,1)/10);
temp = reshape(score,size(t_idx,1),[],size(binnedData.neuronIDs,1)/10);
pc1 = temp(:,:,1);
pc2 = temp(:,:,2);
pc3 = temp(:,:,3);

for iTarget = 1:length(DCO.target_locations)
    pc1_mean(iTarget,:) = mean(pc1(DCO.target_locations_idx{iTarget},:));
    pc2_mean(iTarget,:) = mean(pc2(DCO.target_locations_idx{iTarget},:));
    pc3_mean(iTarget,:) = mean(pc3(DCO.target_locations_idx{iTarget},:));
    pc_dist(iTarget,:) = sqrt((pc1_mean(iTarget,:)-pc1_mean(iTarget,1)).^2+...
        (pc2_mean(iTarget,:)-pc2_mean(iTarget,1)).^2+(pc3_mean(iTarget,:)-pc3_mean(iTarget,1)).^2);
end
%%
for iTarget = 1:length(DCO.target_locations)
    for iTestData = 1:length(DCO.target_locations)
        nfolds = floor(binnedData_sub{iTestData}.timeframe(end)/DecoderOptions.foldlength);
        for iFold = 1:nfolds        
            idx = (iFold-1)*DecoderOptions.foldlength/BDF2BinArgs.binsize+(1:DecoderOptions.foldlength/BDF2BinArgs.binsize);
            [PredictedData,spikeDataNew,ActualDataNew]=predMIMO4(binnedData_sub{iTestData}.spikeratedata(idx,:),...
                filter{iTarget}.H,1,1,binnedData_sub{iTestData}.emgdatabin(idx,:));
            for z=1:size(PredictedData,2)
                PredictedData(:,z) = polyval(filter{iTarget}.P(:,z),PredictedData(:,z));
            end
            PredData{iTarget,iTestData,iFold} = PredictedData;        
            for iEMG = 1:size(binnedData_sub{iTestData}.emgdatabin,2)
                temp = corrcoef(binnedData_sub{iTestData}.emgdatabin(idx,iEMG),PredictedData(:,iEMG));
                r_squared{iTarget,iTestData}(iFold,iEMG) = temp(2)^2;
            end
            
            [PredictedData,spikeDataNew,ActualDataNew]=predMIMO4(binnedData_sub{iTestData}.spikeratedata(idx,:),...
                filter_all.H,1,1,binnedData_sub{iTestData}.emgdatabin(idx,:));
            for z=1:size(PredictedData,2)
                PredictedData(:,z) = polyval(filter{iTarget}.P(:,z),PredictedData(:,z));
            end

            PredData_all{iTarget,iTestData,iFold} = PredictedData;        
            for iEMG = 1:size(binnedData_sub{iTestData}.emgdatabin,2)
                temp = corrcoef(binnedData_sub{iTestData}.emgdatabin(idx,iEMG),PredictedData(:,iEMG));
                r_squared_all{iTarget,iTestData}(iFold,iEMG) = temp(2)^2;
            end
        end
    end
end

%%
figure
subplot(151)
hold on
emg_idx = 2:3;
if length(DCO.target_locations) == 3
    idx_temp = [1 2 3];
else
    idx_temp = [1 3 5];
end
for iEMG = 1:length(emg_idx)    
    errorbar(emg_idx(iEMG)-.1,mean(R2{idx_temp(1)}(:,emg_idx(iEMG))),std(R2{idx_temp(1)}(:,emg_idx(iEMG))),'.b')
    errorbar(emg_idx(iEMG),mean(R2{idx_temp(2)}(:,emg_idx(iEMG))),std(R2{idx_temp(2)}(:,emg_idx(iEMG))),'.r')
    errorbar(emg_idx(iEMG)+.1,mean(R2{idx_temp(3)}(:,emg_idx(iEMG))),std(R2{idx_temp(3)}(:,emg_idx(iEMG))),'.k')
end
ylim([0 1])
xlim([1 4])
title('Within')
ylabel('R^2')
set(gca,'XTick',emg_idx)
set(gca,'XTickLabel',bdf.emg.emgnames(emg_idx))
legend('Flexion','Co-contraction','Extension')

subplot(152)
hold on
emg_idx = 2:3;
for iEMG = 1:length(emg_idx)    
    errorbar(emg_idx(iEMG)-.1,mean(r_squared_all{idx_temp(1),idx_temp(1)}(:,emg_idx(iEMG))),std(r_squared_all{idx_temp(1),idx_temp(1)}(:,emg_idx(iEMG))),'.b')
    errorbar(emg_idx(iEMG),mean(r_squared_all{idx_temp(2),idx_temp(2)}(:,emg_idx(iEMG))),std(r_squared_all{idx_temp(2),idx_temp(2)}(:,emg_idx(iEMG))),'.r')
    errorbar(emg_idx(iEMG)+.1,mean(r_squared_all{idx_temp(3),idx_temp(3)}(:,emg_idx(iEMG))),std(r_squared_all{idx_temp(3),idx_temp(3)}(:,emg_idx(iEMG))),'.k')
end
ylim([0 1])
xlim([1 4])
title('Full decoder')
ylabel('R^2')
set(gca,'XTick',emg_idx)
set(gca,'XTickLabel',bdf.emg.emgnames(emg_idx))

subplot(153)
% Decoder = flexion, test = co-contraction
hold on
emg_idx = 2:3;
for iEMG = 1:length(emg_idx)    
    errorbar(emg_idx(iEMG)-.1,mean(r_squared{1,idx_temp(1)}(:,emg_idx(iEMG))),std(r_squared{1,idx_temp(1)}(:,emg_idx(iEMG))),'.b')
    errorbar(emg_idx(iEMG),mean(r_squared{1,idx_temp(2)}(:,emg_idx(iEMG))),std(r_squared{1,idx_temp(2)}(:,emg_idx(iEMG))),'.r')
    errorbar(emg_idx(iEMG)+.1,mean(r_squared{1,idx_temp(3)}(:,emg_idx(iEMG))),std(r_squared{1,idx_temp(3)}(:,emg_idx(iEMG))),'.k')
end
ylim([0 1])
xlim([1 4])
title('Decoder: flexion')
ylabel('R^2')
set(gca,'XTick',emg_idx)
set(gca,'XTickLabel',bdf.emg.emgnames(emg_idx))

subplot(154)
% Decoder = flexion, test = co-contraction
hold on
emg_idx = 2:3;
for iEMG = 1:length(emg_idx)    
    errorbar(emg_idx(iEMG)-.1,mean(r_squared{idx_temp(2),idx_temp(1)}(:,emg_idx(iEMG))),std(r_squared{idx_temp(2),idx_temp(1)}(:,emg_idx(iEMG))),'.b')
    errorbar(emg_idx(iEMG),mean(r_squared{idx_temp(2),idx_temp(2)}(:,emg_idx(iEMG))),std(r_squared{idx_temp(2),idx_temp(2)}(:,emg_idx(iEMG))),'.r')
    errorbar(emg_idx(iEMG)+.1,mean(r_squared{idx_temp(2),idx_temp(3)}(:,emg_idx(iEMG))),std(r_squared{idx_temp(2),idx_temp(3)}(:,emg_idx(iEMG))),'.k')
end
ylim([0 1])
xlim([1 4])
title('Decoder: co-contraction')
ylabel('R^2')
set(gca,'XTick',emg_idx)
set(gca,'XTickLabel',bdf.emg.emgnames(emg_idx))

subplot(155)
% Decoder = flexion, test = co-contraction
hold on
emg_idx = 2:3;
for iEMG = 1:length(emg_idx)    
    errorbar(emg_idx(iEMG)-.1,mean(r_squared{idx_temp(3),idx_temp(1)}(:,emg_idx(iEMG))),std(r_squared{idx_temp(3),idx_temp(1)}(:,emg_idx(iEMG))),'.b')
    errorbar(emg_idx(iEMG),mean(r_squared{idx_temp(3),idx_temp(2)}(:,emg_idx(iEMG))),std(r_squared{idx_temp(3),idx_temp(2)}(:,emg_idx(iEMG))),'.r')
    errorbar(emg_idx(iEMG)+.1,mean(r_squared{idx_temp(3),idx_temp(3)}(:,emg_idx(iEMG))),std(r_squared{idx_temp(3),idx_temp(3)}(:,emg_idx(iEMG))),'.k')
end
ylim([0 1])
xlim([1 4])
title('Decoder: extension')
ylabel('R^2')
set(gca,'XTick',emg_idx)
set(gca,'XTickLabel',bdf.emg.emgnames(emg_idx))

%%
% figure
% for iEMG = 1:size(binnedData_sub{iTestData}.emgdatabin,2)
%     subplot(1,size(binnedData_sub{iTestData}.emgdatabin,2),iEMG)
%     imagesc(r_squared(:,:,iEMG),[-1 1])
%     axis square
%     title(deblank(binnedData_sub{iTestData}.emgguide(iEMG,:)))
%     ylabel('Filter')
%     xlabel('Data set')
% end

% filter_1 = filter{1}.H(2:end,2);
% filter_2 = filter{5}.H(2:end,3);
% filter_3 = filter{3}.H(2:end,2) + filter{3}.H(2:end,3);

% filter_1 = binnedData_sub{1}.spikeratedata\binnedData_sub{1}.emgdatabin(:,3);
% filter_2 = binnedData_sub{5}.spikeratedata\binnedData_sub{5}.emgdatabin(:,2);
% filter_3 = binnedData_sub{3}.spikeratedata\(binnedData_sub{3}.emgdatabin(:,2) +...
%    binnedData_sub{3}.emgdatabin(:,3));
% 
% mdl = LinearModel.fit([filter_1 filter_2],filter_3);
% 
% rand_idx = randperm(size(binnedData_sub{5}.spikeratedata,1));
% rand_idx_1 = rand_idx(1:end/2);
% rand_idx_2 = rand_idx(end/2+1:end);
% 
% filter_1 = binnedData_sub{5}.spikeratedata(rand_idx_1,:)\binnedData_sub{5}.emgdatabin(rand_idx_1,2);
% filter_2 = binnedData_sub{5}.spikeratedata(rand_idx_2,:)\binnedData_sub{5}.emgdatabin(rand_idx_2,2);
% % filter_1 = binnedData_sub{1}.spikeratedata\binnedData_sub{1}.emgdatabin(:,3);
% % filter_2 = binnedData_sub{3}.spikeratedata\binnedData_sub{3}.emgdatabin(:,3);
% 
% mdl = LinearModel.fit(filter_1,filter_2);
% 
% mdl_coefficients = mdl.Coefficients.Estimate;
% 
% figure; 
% plot([filter_1*mdl_coefficients(2) filter_2])

%%
clear correlations emgmodulation depthmodulation fr_initial stdfr_initial 
clear stdfr_initial fr_final stdfr_final
for iTarget = 1:size(binnedData_sub,2)
    num_samples_initial(iTarget) = size(binnedData_initial{iTarget}.spikeratedata,1);
    num_samples_final(iTarget) = size(binnedData_final{iTarget}.spikeratedata,1);
    for iSpike = 1:size(binnedData.spikeratedata,2)
        for iEMG = 1:size(binnedData.emgguide,2)      
        %         [B{iTarget,iEMG}, FitInfo{iTarget,iEMG}] = lasso(binnedData_sub{iTarget}.spikeratedata(:,:),binnedData_sub{iTarget}.emgdatabin(:,iEMG),'CV',5);
        
            temp = corrcoef(binnedData_sub{iTarget}.spikeratedata(:,iSpike),binnedData_sub{iTarget}.emgdatabin(:,iEMG));
            correlations(iTarget,iEMG,iSpike) = temp(2);
%             depthmodulation(iTarget,iEMG,iSpike) = diff(prctile(binnedData_sub{iTarget}.spikeratedata(:,iSpike),[5 95]));
%             depthmodulation(iTarget,iEMG,iSpike) = mean(binnedData_sub{iTarget}.spikeratedata(:,iSpike))/mean(binnedData.spikeratedata(:,iSpike));            
            emgmodulation(iTarget,iEMG) = mean(binnedData_final{iTarget}.emgdatabin(:,iEMG))-mean(binnedData_initial{iTarget}.emgdatabin(:,iEMG));
        end        
        depthmodulation(iTarget,iSpike) = mean(binnedData_final{iTarget}.spikeratedata(:,iSpike))-mean(binnedData_initial{iTarget}.spikeratedata(:,iSpike));
        fr_initial(iTarget,iSpike) = mean(binnedData_initial{iTarget}.spikeratedata(:,iSpike));
        stdfr_initial(iTarget,iSpike) = std(binnedData_initial{iTarget}.spikeratedata(:,iSpike));
        fr_final(iTarget,iSpike) = mean(binnedData_final{iTarget}.spikeratedata(:,iSpike));
        stdfr_final(iTarget,iSpike) = std(binnedData_final{iTarget}.spikeratedata(:,iSpike));        
    end
end

clear meandepth meanfr_final meanstdfr_final meansemfr_final meanfr_initial meanstdfr_initial
clear meansemfr_initial meancorrelations meanemg_final stdemg_final sememg_final meanemg_initial
clear stdemg_initial sememg_initial
for iTarget = 1:size(depthmodulation,1)
    if sorted_file        
        meandepth(iTarget,:) = depthmodulation(iTarget,:);
        meanfr_final(iTarget,:) = fr_final(iTarget,:);
        meanstdfr_final(iTarget,:) = stdfr_final(iTarget,:);
        meansemfr_final(iTarget,:) = meanstdfr_final(iTarget,:)/sqrt(num_samples_final(iTarget));
        meanfr_initial(iTarget,:) = fr_initial(iTarget,:);
        meanstdfr_initial(iTarget,:) = stdfr_initial(iTarget,:);
        meansemfr_initial(iTarget,:) = meanstdfr_initial(iTarget,:)/sqrt(num_samples_initial(iTarget));
        for iEMG = 1:size(binnedData.emgguide,2)
            meancorrelations(iTarget,iEMG,:) = squeeze(correlations(iTarget,iEMG,:));
            meanemg_final(iTarget,iEMG) = mean(binnedData_final{iTarget}.emgdatabin(:,iEMG));
            stdemg_final(iTarget,iEMG) = std(binnedData_final{iTarget}.emgdatabin(:,iEMG));
            sememg_final(iTarget,iEMG) = stdemg_final(iTarget)/sqrt(num_samples_final(iTarget));
            meanemg_initial(iTarget,iEMG) = mean(binnedData_initial{iTarget}.emgdatabin(:,iEMG));
            stdemg_initial(iTarget,iEMG) = std(binnedData_initial{iTarget}.emgdatabin(:,iEMG));
            sememg_initial(iTarget,iEMG) = stdemg_initial(iTarget)/sqrt(num_samples_initial(iTarget));
        end
    else
        meandepth(iTarget,:) = depthmodulation(iTarget,10:10:end);
        meanfr_final(iTarget,:) = fr_final(iTarget,10:10:end);
        meanstdfr_final(iTarget,:) = stdfr_final(iTarget,10:10:end);
        meansemfr_final(iTarget,:) = meanstdfr_final(iTarget,:)/sqrt(num_samples_final(iTarget));
        meanfr_initial(iTarget,:) = fr_initial(iTarget,10:10:end);
        meanstdfr_initial(iTarget,:) = stdfr_initial(iTarget,10:10:end);
        meansemfr_initial(iTarget,:) = meanstdfr_initial(iTarget,:)/sqrt(num_samples_initial(iTarget));
        for iEMG = 1:size(binnedData.emgguide,2)
            meancorrelations(iTarget,iEMG,:) = squeeze(correlations(iTarget,iEMG,10:10:end));
            meanemg_final(iTarget,iEMG) = mean(binnedData_final{iTarget}.emgdatabin(:,iEMG));
            stdemg_final(iTarget,iEMG) = std(binnedData_final{iTarget}.emgdatabin(:,iEMG));
            sememg_final(iTarget,iEMG) = stdemg_final(iTarget)/sqrt(num_samples_final(iTarget));
            meanemg_initial(iTarget,iEMG) = mean(binnedData_initial{iTarget}.emgdatabin(:,iEMG));
            stdemg_initial(iTarget,iEMG) = std(binnedData_initial{iTarget}.emgdatabin(:,iEMG));
            sememg_initial(iTarget,iEMG) = stdemg_initial(iTarget)/sqrt(num_samples_initial(iTarget));
        end
    end  
end

% figure; plot(squeeze(correlations(1,2,:)),squeeze(correlations(5,2,:)),'.')
% 
% figure; plot(reshape(correlations(1,2,:),10,[]),reshape(correlations(5,2,:),10,[]))


%% Triceps correlations
figure; 
plot(squeeze(meancorrelations(idx_temp(2),2,:))', squeeze(meancorrelations(idx_temp(3),2,:))','.')
axis square
title('Triceps')
xlabel('Correlations co-contraction')
ylabel('Correlations reciprocal')
temp = corrcoef(squeeze(meancorrelations(idx_temp(2),2,:))',squeeze(meancorrelations(idx_temp(3),2,:))');
temp_x = get(gca,'XLim');
temp_y = get(gca,'YLim');
text(temp_x(1)+diff(temp_x)*.1, temp_y(2)-diff(temp_y)*.1, ['R^2 = ' num2str(temp(2)^2)])

%% Brd correlations
figure; 
if sorted_file
    plot(squeeze(correlations(idx_temp(2),3,:)),squeeze(correlations(idx_temp(1),3,:)),'.')
    temp = corrcoef(correlations(idx_temp(2),3,:),correlations(idx_temp(1),3,:));
else    
    plot(mean(reshape(correlations(idx_temp(2),3,:),10,[])),mean(reshape(correlations(idx_temp(1),3,:),10,[])),'.')
    temp = corrcoef(mean(reshape(correlations(idx_temp(2),3,:),10,[])),mean(reshape(correlations(idx_temp(1),3,:),10,[])));
end
    
axis square
title('Brd')
xlabel('Correlations co-contraction')
ylabel('Correlations reciprocal')

temp_x = get(gca,'XLim');
temp_y = get(gca,'YLim');
text(temp_x(1)+diff(temp_x)*.1, temp_y(2)-diff(temp_y)*.1, ['R^2 = ' num2str(temp(2)^2)])

%% Extension depth of modulation
figure; 
if sorted_file
    plot(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(3),:)),'.')
    temp = corrcoef(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(3),:)));
else
    plot(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(3),:),10,[])),'.')
    temp = corrcoef(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(3),:),10,[])));
end
axis square
title('Triceps')
xlabel('Depth of modulation co-contraction')
ylabel('Depth of modulation reciprocal')

temp_x = get(gca,'XLim');
temp_y = get(gca,'YLim');
text(temp_x(1)+diff(temp_x)*.1, temp_y(2)-diff(temp_y)*.1, ['R^2 = ' num2str(temp(2)^2)])

%% Flexion depth of modulation
figure; 
if sorted_file
    plot(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(1),:)),'.')
    temp = corrcoef(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(1),:)));
else
    plot(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(1),:),10,[])),'.')
    temp = corrcoef(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(1),:),10,[])));
end
axis square
title('Brd')
xlabel('Depth of modulation co-contraction')
ylabel('Depth of modulation reciprocal')
temp_x = get(gca,'XLim');
temp_y = get(gca,'YLim');
text(temp_x(1)+diff(temp_x)*.1, temp_y(2)-diff(temp_y)*.1, ['R^2 = ' num2str(temp(2)^2)])

%% Depth of modulation
figure; 
hold on
if sorted_file
    plot(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(1),:)),'.b')
    plot(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(3),:)),'.r')
    temp = corrcoef(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(1),:)));
    temp2 = corrcoef(squeeze(depthmodulation(idx_temp(2),:)),squeeze(depthmodulation(idx_temp(3),:)));
else
    plot(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(1),:),10,[])),'.b')
    plot(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(3),:),10,[])),'.r')
    temp = corrcoef(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(1),:),10,[])));
    temp2 = corrcoef(mean(reshape(depthmodulation(idx_temp(2),:),10,[])),mean(reshape(depthmodulation(idx_temp(3),:),10,[])));
end

axis square
axis equal
title('Depth of modulation')
xlabel('Depth of modulation co-contraction')
ylabel('Depth of modulation reciprocal')
temp_x = get(gca,'XLim');
temp_y = get(gca,'YLim');
text(temp_x(1)+diff(temp_x)*.1, temp_y(2)-diff(temp_y)*.1, ['R^2 = ' num2str(temp(2)^2)],'Color','b')
text(temp_x(1)+diff(temp_x)*.1, temp_y(2)-diff(temp_y)*.2, ['R^2 = ' num2str(temp2(2)^2)],'Color','r')
legend('Flexion','Extension')


%% Depth of modulation

figure
for iPlot = 1:7
    subplot(1,7,iPlot)
    idx = ((iPlot-1)*floor(size(meandepth,2)/6))+(1:floor(size(meandepth,2)/6));
    idx(idx>size(meandepth,2)) = [];
    plot(meandepth(:,idx))
    xlim([1 length(DCO.target_locations)])
    set(gca,'Xtick',idx_temp)
    set(gca,'Xticklabel',{'Flex','Co','Ext'})
    if iPlot == 1
        ylabel('Modulation')
    end
end

%% 
if 0   
    difference = sum(meanfr_final([1 5],:)) - meanfr_final(3,:);
    errors = sum(meansemfr_final([1 3 5],:));

    difference_emg = sum(meanemg_final([1 5],:)) - meanemg_final(3,:);
    error_emg = sum(sememg_final([1 3 5],:));
elseif 0
    difference = sum(meanfr_final([1 5],:) - meanfr_initial([1 5],:)) - (meanfr_final(3,:) - meanfr_initial(3,:));
    errors = sum(meansemfr_final([1 3 5],:) + meansemfr_initial([1 3 5],:));

    difference_emg = sum(meanemg_final([1 5],:) - meanemg_initial([1 5],:)) - (meanemg_final(3,:) - meanemg_initial(3,:));
    error_emg = sum(sememg_final([1 3 5],:) + sememg_initial([1 3 5],:));
elseif 0
    difference = sum(meanfr_final([1 5],:));
    errors = sum(meansemfr_final([1 3 5],:));

    difference_emg = sum(meanemg_final([1 5],:));
    error_emg = sum(sememg_final([1 3 5],:));
elseif 1
%     sum_flex_ext = sqrt(sum(meanfr_final([1 5],:).^2));
    sum_flex_ext = sum(meanfr_final([1 idx_temp(3)],:));
    
    errors = sum(meansemfr_final([1 idx_temp(3)],:));
    cocon = meanfr_final(idx_temp(2),:);
    cocon_errors = meansemfr_final(idx_temp(2),:);

%     sum_flex_ext_emg = sum(meanemg_final([1 5],2:3) - meanemg_initial([1 5],2:3));
%     error_emg = sum(sememg_final([1 5],2:3) + sememg_initial([1 5],2:3));
%     cocon_emg = meanemg_final(3,2:3) - meanemg_initial(3,2:3);
%     cocon_emg_errors = sememg_final(3,2:3) - sememg_initial(3,2:3);

    sum_flex_ext_emg = sum(meanemg_final([idx_temp(1) idx_temp(3)],2:3)- meanemg_initial([idx_temp(1) idx_temp(3)],2:3));
    error_emg = sum(sememg_final([idx_temp(1) idx_temp(3)],2:3)+ sememg_initial([idx_temp(1) idx_temp(3)],2:3));
    cocon_emg = meanemg_final(idx_temp(2),2:3) - meanemg_initial(idx_temp(2),2:3);
    cocon_emg_errors = sememg_final(idx_temp(2),2:3) + sememg_initial(idx_temp(2),2:3);
end

figure;
subplot(121)
hold on
% plot(sum_flex_ext,cocon,'.')
plot([(sum_flex_ext-errors)',(sum_flex_ext+errors)']',[cocon',cocon']','-b')
plot([sum_flex_ext',sum_flex_ext']',[(cocon-cocon_errors)',(cocon+cocon_errors)']','-b')
plot([0 max([sum_flex_ext cocon])], [0 max([sum_flex_ext cocon])],'--k')
xlabel('Flexion + Extension (Hz)')
ylabel('Co-contraction (Hz)')
xlim(1.1*[min([sum_flex_ext cocon]) max([sum_flex_ext cocon])])
ylim(1.1*[min([sum_flex_ext cocon]) max([sum_flex_ext cocon])])
axis square
title('Neural channels')

subplot(122)
hold on
plot(sum_flex_ext_emg,cocon_emg,'.')
plot([(sum_flex_ext_emg-error_emg)',(sum_flex_ext_emg+error_emg)']',[cocon_emg',cocon_emg']','-b')
plot([sum_flex_ext_emg',sum_flex_ext_emg']',[(cocon_emg-cocon_emg_errors)',(cocon_emg+cocon_emg_errors)']','-b')

plot([0 max([sum_flex_ext_emg cocon_emg])],[0 max([sum_flex_ext_emg cocon_emg])],'--k')
xlabel('Flexion + Extension (au)')
ylabel('Co-contraction (au)')
xlim([0 1.1*max([sum_flex_ext_emg cocon_emg])])
ylim([0 1.1*max([sum_flex_ext_emg cocon_emg])])
axis square
title('EMG')

text(0.01, 0.01, bdf.meta.filename,'Interpreter','none','FontSize',6)

%%
figure; 
hold on
plot(binnedData_final{idx_temp(1)}.emgdatabin(:,3),binnedData_final{idx_temp(1)}.emgdatabin(:,2),'.b')
plot(binnedData_final{idx_temp(3)}.emgdatabin(:,3),binnedData_final{idx_temp(3)}.emgdatabin(:,2),'.r')
plot(binnedData_final{idx_temp(2)}.emgdatabin(:,3),binnedData_final{idx_temp(2)}.emgdatabin(:,2),'.k')
plot(binnedData_initial{idx_temp(1)}.emgdatabin(:,3),binnedData_initial{idx_temp(1)}.emgdatabin(:,2),'.b')
plot(binnedData_initial{idx_temp(3)}.emgdatabin(:,3),binnedData_initial{idx_temp(3)}.emgdatabin(:,2),'.r')
plot(binnedData_initial{idx_temp(2)}.emgdatabin(:,3),binnedData_initial{idx_temp(2)}.emgdatabin(:,2),'.k')
axis equal

%%
figure; 
subplot(121)
hold on
plot([meanfr_final(idx_temp(1),:); meanfr_initial(idx_temp(1),:)],[meanfr_final(idx_temp(3),:); meanfr_initial(idx_temp(3),:)],'-b')
plot(meanfr_final(idx_temp(1),:),meanfr_final(idx_temp(3),:),'ob')
xlabel('fr flexion (Hz)')
ylabel('fr extension (Hz)')
axis square
axis equal
subplot(122)
hold on
plot([meanfr_final(idx_temp(1),:); meanfr_initial(idx_temp(1),:)]./[meanfr_initial(idx_temp(1),:); meanfr_initial(idx_temp(1),:)],...
    [meanfr_final(idx_temp(3),:); meanfr_initial(idx_temp(3),:)]./[meanfr_initial(idx_temp(3),:); meanfr_initial(idx_temp(3),:)],'-b')
xlabel('normalized fr flexion (Hz)')
ylabel('normalized fr extension (Hz)')
axis square
axis equal

%%
figure;
subplot(121)
hold on
plot([meanfr_initial(idx_temp(1),:); meanfr_final(idx_temp(1),:)],...
    [meanfr_initial(idx_temp(2),:); meanfr_final(idx_temp(2),:)],'-b')
plot(meanfr_initial(idx_temp(2),:),meanfr_initial(idx_temp(2),:),'ob')
xlabel('fr flexion (Hz)')
ylabel('fr co-contraction (Hz)')
axis equal
subplot(122)
hold on
plot([meanfr_initial(idx_temp(1),:); meanfr_final(idx_temp(1),:)]./[meanfr_initial(idx_temp(1),:); meanfr_initial(idx_temp(1),:)],...
    [meanfr_initial(idx_temp(2),:); meanfr_final(idx_temp(2),:)]./[meanfr_initial(idx_temp(2),:);meanfr_initial(idx_temp(2),:)],'-b')
plot(meanfr_initial(idx_temp(1),:)./meanfr_initial(idx_temp(1),:),meanfr_initial(idx_temp(2),:)./meanfr_initial(idx_temp(2),:),'ob')
xlabel('normalized fr flexion (Hz)')
ylabel('normalized fr co-contraction (Hz)')
axis equal

%%
figure; 
hold on
plot([meanfr_initial(idx_temp(3),:); meanfr_final(idx_temp(3),:)],...
    [meanfr_initial(idx_temp(2),:); meanfr_final(idx_temp(2),:)],'-b')
plot(meanfr_initial(idx_temp(3),:),meanfr_initial(idx_temp(2),:),'ob')
xlabel('fr extension (Hz)')
ylabel('fr co-contraction (Hz)')
axis equal
%%
figure; 
plot([0*meanfr_final(idx_temp(1),:);meanfr_final(idx_temp(1),:)+meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(1),:)-meanfr_initial(idx_temp(3),:)],...
    [0*meanfr_final(idx_temp(2),:);meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:)],'-b')
axis equal
xlabel('Change in fr extension + flexion (Hz)')
ylabel('Change in fr co-contraction (Hz)')


%%
figure; 
subplot(121)
hold on
hist([meanfr_final(idx_temp(1),:)-meanfr_initial(idx_temp(1),:);meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:);meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(3),:)]',20)
plot([mean(meanfr_final(idx_temp(1),:)-meanfr_initial(idx_temp(1),:)) mean(meanfr_final(idx_temp(1),:)-meanfr_initial(idx_temp(1),:))],[0 35],'b')
plot([mean(meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:)) mean(meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:))],[0 35],'g')
plot([mean(meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(3),:)) mean(meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(3),:))],[0 35],'r')
xlabel('firing rate hold - baseline (Hz)')
legend('Flexion','Co-contraction','Extension')
subplot(122)
hold on
hist([(meanfr_final(idx_temp(1),:)-meanfr_initial(idx_temp(1),:))./meanfr_initial(idx_temp(1),:);...
    (meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:))./meanfr_initial(idx_temp(2),:);...
    (meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(3),:))./meanfr_initial(idx_temp(2),:)]',20)
plot([mean((meanfr_final(idx_temp(1),:)-meanfr_initial(idx_temp(1),:))./meanfr_initial(idx_temp(1),:)) mean((meanfr_final(idx_temp(1),:)-meanfr_initial(idx_temp(1),:))./meanfr_initial(idx_temp(1),:))],[0 35],'b')
plot([mean((meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:))./meanfr_initial(idx_temp(2),:)) mean((meanfr_final(idx_temp(2),:)-meanfr_initial(idx_temp(2),:))./meanfr_initial(idx_temp(2),:))],[0 35],'g')
plot([mean((meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(3),:))./meanfr_initial(idx_temp(3),:)) mean((meanfr_final(idx_temp(3),:)-meanfr_initial(idx_temp(3),:))./meanfr_initial(idx_temp(3),:))],[0 35],'r')
xlabel('Normalized firing rate hold - baseline (Hz)')
legend('Flexion','Co-contraction','Extension')
%%
% figure; plot(sum(meanfr_final([1 5],:)) - meanfr_final(idx_temp(2),:),'.')
% 
% figure;
% subplot(121)
% errorbar(sum_flex_ext,errors,'.')
% hold on
% plot(meanfr_final(1,:),'xk','MarkerSize',6)
% plot(meanfr_final(idx_temp(2),:),'xr','MarkerSize',6)
% plot(meanfr_final(idx_temp(3),:),'xg','MarkerSize',6)
% plot(mean(meanfr_initial),'xc','MarkerSize',6)
% plot([0 length(sum_flex_ext)+1],[0 0],'--k')
% xlabel('Channel')
% ylabel('Firing rate (Hz)')
% legend('Flex + Ext','Flexion','Cocontraction','Extension','Baseline')
% title('Neural channels')
% 
% subplot(122)
% errorbar(sum_flex_ext_emg(2:3),error_emg(2:3),'.')
% hold on
% plot(meanemg_final(1,2:3),'xk','MarkerSize',6)
% plot(meanemg_final(idx_temp(2),2:3),'xr','MarkerSize',6)
% plot(meanemg_final(idx_temp(3),2:3),'xg','MarkerSize',6)
% plot(mean(meanemg_initial(:,2:3)),'xc','MarkerSize',6)
% plot([0 length(sum_flex_ext_emg(2:3))+1],[0 0],'--k')
% xlabel('Channel')
% ylabel('EMG (au)')
% legend('Flex + Ext','Flexion','Cocontraction','Extension','Baseline')
% set(gca,'XTick',[1 2])
% set(gca,'XTickLabel',binnedData.emgguide(2:3))
% title('EMG')
% 
% %%
%%
%         corrcoef(reshape(depthmodulation(idx_temp(2),2,:),10,[]),reshape(depthmodulation(idx_temp(3),2,:),10,[]))



% corrcoef(reshape(depthmodulation(idx_temp(3),3,:),10,[]),reshape(depthmodulation(1,2,:),10,[]))

% [mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = mfxval(binnedData, DecoderOptions);
% disp('Done.');

% figure; 
% subplot(211)
% plot(binnedData.timeframe,binnedData.emgdatabin(:,2),OLPredData.timeframe,OLPredData.preddatabin(:,2))
% title(deblank(binnedData.emgguide(2,:)))
% subplot(212)
% plot(binnedData.timeframe,binnedData.emgdatabin(:,3),OLPredData.timeframe,OLPredData.preddatabin(:,3))
% title(deblank(binnedData.emgguide(idx_temp(2),:)))
% legend('Real data','Predicted')

% mean(mfxval_vaf)