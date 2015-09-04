% Single unit decoders

DecoderOptions.PredEMGs = 1;
DecoderOptions.PredForce = 0;
DecoderOptions.PredCursPos = 0;
DecoderOptions.PredVeloc = 0;
DecoderOptions.fillen = 0.5000;
DecoderOptions.UseAllInputs = 1;
DecoderOptions.PolynomialOrder = 2;
DecoderOptions.numPCs = 0;
DecoderOptions.Use_Thresh = 0;
DecoderOptions.Use_EMGs = 0;
DecoderOptions.Use_Ridge = 0;
DecoderOptions.Use_SD = 0;
DecoderOptions.foldlength = 60;

binnedData_single_decoder = binnedData_all;
binnedData_single_decoder.emgguide = {'TRI','BRD','SUM','Co-con'};
temp_emg_1 = binnedData_all.emgdatabin(:,2);
temp_emg_1(temp_emg_1==0) = 1E-5;
temp_emg_2 = binnedData_all.emgdatabin(:,3);
temp_emg_2(temp_emg_2==0) = 1E-5;

temp = min([temp_emg_1./temp_emg_2 temp_emg_2./temp_emg_1],[],2);
cocon = temp.*(temp_emg_1+temp_emg_2);

binnedData_single_decoder.emgdatabin = [binnedData_all.emgdatabin(:,[2 3])...
    sum(binnedData_all.emgdatabin(:,[2 3])')'...
    cocon];
   
for iUnit = 1:size(binnedData_all.neuronIDs,1)   
    brd_idx = find(~cellfun(@isempty,strfind(binnedData_all.emgguide,'BRD')));
    tri_idx = find(~cellfun(@isempty,strfind(binnedData_all.emgguide,'TRI')));
    temp = corrcoef(binnedData_all.emgdatabin(:,brd_idx),binnedData_all.spikeratedata(:,iUnit));
    corrcoef_brd(iUnit) = temp(2);
    temp = corrcoef(binnedData_all.emgdatabin(:,tri_idx),binnedData_all.spikeratedata(:,iUnit));
    corrcoef_tri(iUnit) = temp(2);
    temp = corrcoef(sum(binnedData_all.emgdatabin(:,[brd_idx tri_idx])')',binnedData_all.spikeratedata(:,iUnit));
    corrcoef_sum(iUnit) = temp(2);
    
    binnedData_single_decoder.neuronIDs = binnedData_all.neuronIDs(iUnit,:);
    binnedData_single_decoder.spikeratedata = binnedData_all.spikeratedata(:,iUnit);
    [filter_single_decoder, ~] = BuildModel(binnedData_single_decoder, DecoderOptions);
    [R2_temp, vaf_temp, mse_temp] = mfxval(binnedData_single_decoder, DecoderOptions);
    R2_single_decoder(iUnit,:) = mean(R2_temp);
    vaf_single_decoder(iUnit,:) = mean(vaf_temp);
    mse_single_decoder(iUnit,:) = mean(mse_temp);
end
figure; plot(vaf_single_decoder')
legend(binnedData_single_decoder.emgguide)
    

%%
spikeratedata = binnedData.spikeratedata;
% spikeratedata = spikeratedata-repmat(mean(spikeratedata),size(spikeratedata,1),1);
% normalized_spikeratedata = spikeratedata./repmat(prctile(spikeratedata,99),size(spikeratedata,1),1);
normalized_spikeratedata = binnedData.spikeratedata;
mean_spikeratedata_ot_hold = cell(1,3);
mean_emg = cell(1,3);
mean_spikeratedata_ct_hold = [];
for iTrial = 1:size(DCO.trial_table,1)    
    index = cellfun(@(x) x==iTrial, DCO.target_locations_idx, 'UniformOutput', 0);
    iTarget = find(cellfun(@sum,index));
    
    trial_t = DCO.trial_table(iTrial,[DCO.table_columns.t_ot_first_hold DCO.table_columns.t_trial_end]);
    t_ot_hold_idx = find(binnedData.timeframe > trial_t(1) & binnedData.timeframe < trial_t(2));
    trial_t = DCO.trial_table(iTrial,[DCO.table_columns.t_ct_hold_on DCO.table_columns.t_go_cue]);
    t_ct_hold_idx = find(binnedData.timeframe > trial_t(1) & binnedData.timeframe < trial_t(2));
    trial_t = DCO.trial_table(iTrial,[DCO.table_columns.t_ct_hold_on DCO.table_columns.t_trial_end]);
    t_whole_trial = find(binnedData.timeframe > trial_t(1) & binnedData.timeframe < trial_t(2));
%     mean_spikeratedata_ot_hold{iTarget}(end+1,:) = mean(normalized_spikeratedata(t_ot_hold_idx,:))-mean(normalized_spikeratedata(t_ct_hold_idx,:));    
    mean_spikeratedata_ot_hold{iTarget}(end+1,:) = mean(normalized_spikeratedata(t_ot_hold_idx,:)); 
    mean_spikeratedata_ct_hold(end+1,:) = mean(normalized_spikeratedata(t_ct_hold_idx,:)); 
    mean_emg{iTarget}(end+1,:) = mean(binnedData.emgdatabin(t_ot_hold_idx,:));    
end
for iTarget = 1:length(mean_spikeratedata_ot_hold)
    mean_spikeratedata_ot_hold{iTarget} = mean_spikeratedata_ot_hold{iTarget}-repmat(mean(mean_spikeratedata_ct_hold),size(mean_spikeratedata_ot_hold{iTarget},1),1);
    
end
if strfind(bdf.meta.filename,'Jaco') 
    target_1_muscle = 'TRI';
    target_2_muscle = 'Co-contraction';
    target_3_muscle = 'BRD';
    target_1_muscle_idx = find(~cellfun(@isempty,strfind(binnedData.emgguide,target_1_muscle)));
%     target_2_muscle_idx = find(~cellfun(@isempty,strfind(binnedData.emgguide,target_2_muscle)));
    target_3_muscle_idx = find(~cellfun(@isempty,strfind(binnedData.emgguide,target_3_muscle)));
else
    target_1_muscle = 'BRD';
    target_2_muscle = 'Co-contraction';
    target_3_muscle = 'TRI';
end
figure; 
plot(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{2}),'.'); 
hold on
% plot(mean(mean_emg{1}),mean(mean_emg{2}),'.')
axis equal
title('Normalized firing rates')
xlabel([target_1_muscle ' target'])
ylabel([target_2_muscle ' target'])
[temp,p] = corrcoef(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{2}));
temp = temp(2)^2;
title(['Normalized firing rates. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])

figure; plot(mean(mean_spikeratedata_ot_hold{3}),mean(mean_spikeratedata_ot_hold{2}),'.'); 
axis equal
xlabel([target_3_muscle ' target'])
ylabel([target_2_muscle ' target'])
[temp,p] = corrcoef(mean(mean_spikeratedata_ot_hold{3}),mean(mean_spikeratedata_ot_hold{2}));
temp = temp(2)^2;
title(['Normalized firing rates. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])

figure; plot(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{3}),'.'); 
axis equal
title('Normalized firing rates')
xlabel([target_1_muscle ' target'])
ylabel([target_3_muscle ' target'])
[temp,p] = corrcoef(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{3}));
temp = temp(2)^2;
title(['Normalized firing rates. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])

[n_1,~,p_1] = affine_fit([mean(mean_spikeratedata_ot_hold{1});mean(mean_spikeratedata_ot_hold{3});mean(mean_spikeratedata_ot_hold{2})]');
figure; plot3(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{3}),mean(mean_spikeratedata_ot_hold{2}),'.');
hold on
[X,Y] = meshgrid(linspace(min([mean(mean_spikeratedata_ot_hold{3}) mean(mean_spikeratedata_ot_hold{1})]),...
    max([mean(mean_spikeratedata_ot_hold{3}) mean(mean_spikeratedata_ot_hold{1})]),3));
%first plane
surf(X,Y, - (n_1(1)/n_1(3)*X+n_1(2)/n_1(3)*Y-dot(n_1,p_1)/n_1(3)),'facecolor','red','facealpha',0.3);
axis equal
title('Normalized firing rates')
xlabel([target_1_muscle ' target'])
ylabel([target_3_muscle ' target'])
zlabel([target_2_muscle ' target'])


%% Neural channel correlations
% 
% for iUnit = 1:size(spikeratedata,2)
%     for jUnit = iUnit:size(spikeratedata,2)
%         temp = corrcoef(spikeratedata(:,iUnit),spikeratedata(:,jUnit));        
%         neuron_correlations(iUnit,jUnit) = temp(2)^2;
%     end
% end
%        