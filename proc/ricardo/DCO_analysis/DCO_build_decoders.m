% function params = DCO_build_decoders(data_struct,params)

DCO = data_struct.DCO;
bdf = data_struct.bdf;
% 
units = reshape([bdf.units.id],2,[])';

BDF2BinArgs.binsize = 0.05;
BDF2BinArgs.starttime = 1;
BDF2BinArgs.stoptime = 0;
BDF2BinArgs.EMG_hp = 50;
BDF2BinArgs.EMG_lp = 10;
BDF2BinArgs.minFiringRate = 1;
BDF2BinArgs.NormData = 0;
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
DecoderOptions.fillen = 0.5000;
DecoderOptions.UseAllInputs = 1;
DecoderOptions.PolynomialOrder = 2;
DecoderOptions.numPCs = 0;
DecoderOptions.Use_Thresh = 0;
DecoderOptions.Use_EMGs = 0;
DecoderOptions.Use_Ridge = 0;
DecoderOptions.Use_SD = 0;
DecoderOptions.foldlength = 60;
% 
disp('Converting BDF structure to binned data...');
binnedData = convertBDF2binned(bdf,BDF2BinArgs);

%% Normalizing EMG
for iTarget = 1:length(DCO.target_locations)    
    trial_idx = DCO.target_locations_idx{iTarget};
    trial_t_ct_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ct_hold_on DCO.table_columns.t_go_cue]);
    
    trial_t_final_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ot_last_hold DCO.table_columns.t_trial_end]);
    t_idx_ct_hold = [];
    t_idx_final_hold = [];
    t_idx_all = [];
    for iTrial = 1:size(trial_t_final_hold,1)
        t_idx_ct_hold = [t_idx_ct_hold; find(binnedData.timeframe > trial_t_ct_hold(iTrial,1) & binnedData.timeframe < trial_t_ct_hold(iTrial,2))];
        t_idx_final_hold = [t_idx_final_hold; find(binnedData.timeframe > trial_t_final_hold(iTrial,1) & binnedData.timeframe < trial_t_final_hold(iTrial,2))];
        t_idx_all = [t_idx_all; find(binnedData.timeframe > trial_t_ct_hold(iTrial,1) & binnedData.timeframe < trial_t_final_hold(iTrial,2))];
    end
    min_emg_target(iTarget,:) = mean(binnedData.emgdatabin(t_idx_ct_hold,:));
    mean_emg_target(iTarget,:) = mean(binnedData.emgdatabin(t_idx_final_hold,:));  
%     max_force_target(iTarget) = sqrt(sum(mean(binnedData.forcedatabin(t_idx_final_hold,:)).^2));     
%     min_force_target(iTarget) = sqrt(sum(mean(binnedData.forcedatabin(t_idx_ct_hold,:)).^2));
    temp_force = mean(binnedData.forcedatabin(t_idx_final_hold,:)) - mean(binnedData.forcedatabin(t_idx_ct_hold,:));
    temp_force = sqrt(sum(temp_force.^2));
    max_force_target(iTarget) = temp_force;
%     max_force_target(iTarget) = mean(sqrt(sum(binnedData.forcedatabin(t_idx_final_hold,:).^2,2)));
    min_force_target(iTarget) = mean(sqrt(sum(binnedData.forcedatabin(t_idx_ct_hold,:).^2,2)));
    mean_rest_force(iTarget,:) = mean(binnedData.forcedatabin(t_idx_ct_hold,:));
    std_rest_force(iTarget,:) = std(binnedData.forcedatabin(t_idx_ct_hold,:));  
    mean_hold_force(iTarget,:) = mean(binnedData.forcedatabin(t_idx_final_hold,:));
    std_hold_force(iTarget,:) = std(binnedData.forcedatabin(t_idx_final_hold,:)); 
end
% Subtract baseline
min_emg_target = min(min_emg_target);
binnedData.emgdatabin = binnedData.emgdatabin - repmat(min_emg_target,size(binnedData.emgdatabin,1),1);

% Normalize
flexors = ~cellfun(@isempty,strfind(binnedData.emgguide,'BRD')) | ~cellfun(@isempty,strfind(binnedData.emgguide,'BI'));
extensor = ~cellfun(@isempty,strfind(binnedData.emgguide,'TRI'));
average_emg_target = ones(1,length(binnedData.emgguide));
average_emg_target(flexors) = max(mean_emg_target(:,flexors));
average_emg_target(extensor) = max(mean_emg_target(:,extensor));
% mean_emg_target = max(mean_emg_target,[],1);
binnedData.emgdatabin = binnedData.emgdatabin./repmat(average_emg_target,size(binnedData.emgdatabin,1),1);

% if any(min_force_target > max_force_target)
%     warning('Monkey probably wasn''t holding handle')
% else
    force_normalization_factor = ones(1,length(binnedData.emgguide));
    if strfind(bdf.meta.filename,'Jaco') % Right handed
        force_normalization_factor(flexors) = max_force_target(end);
        force_normalization_factor(extensor) = max_force_target(1);
    else
        force_normalization_factor(flexors) = max_force_target(1);
        force_normalization_factor(extensor) = max_force_target(end);
    end
%     binnedData.emgdatabin = binnedData.emgdatabin.*repmat(force_normalization_factor,size(binnedData.emgdatabin,1),1);
% end
binnedData.emgdatabin(binnedData.emgdatabin<0) = 0;
%%
binnedData_all = binnedData;
binnedData_all.timeframe = 0;
binnedData_all.emgdatabin = zeros(1,size(binnedData.emgdatabin,2));
binnedData_all.spikeratedata = zeros(1,size(binnedData.spikeratedata,2));
binnedData_all.forcedatabin = zeros(1,size(binnedData.forcedatabin,2));
binnedData_reciprocal = binnedData;
binnedData_reciprocal.timeframe = 0;
binnedData_reciprocal.emgdatabin = zeros(1,size(binnedData.emgdatabin,2));
binnedData_reciprocal.spikeratedata = zeros(1,size(binnedData.spikeratedata,2));
binnedData_reciprocal.forcedatabin = zeros(1,size(binnedData.forcedatabin,2));

for iTrial = 1:size(DCO.trial_table,1)
    
    index = cellfun(@(x) x==iTrial, DCO.target_locations_idx, 'UniformOutput', 0);
    iTarget = find(cellfun(@sum,index));
    
    trial_t = DCO.trial_table(iTrial,[DCO.table_columns.t_trial_start DCO.table_columns.t_trial_end]);
    t_idx = find(binnedData.timeframe > trial_t(1) & binnedData.timeframe < trial_t(2));
    
    if iTarget == 1 || iTarget == 3
        binnedData_reciprocal.timeframe = [binnedData_reciprocal.timeframe ;...
            (binnedData_reciprocal.timeframe(end) + BDF2BinArgs.binsize +...
            [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))])'];
        binnedData_reciprocal.emgdatabin = [binnedData_reciprocal.emgdatabin ; binnedData.emgdatabin(t_idx,:)];
        binnedData_reciprocal.spikeratedata = [binnedData_reciprocal.spikeratedata ; binnedData.spikeratedata(t_idx,:)];
        binnedData_reciprocal.forcedatabin = [binnedData_reciprocal.forcedatabin ; binnedData.forcedatabin(t_idx,:)];
        
        binnedData_all.timeframe = [binnedData_all.timeframe ;...
            (binnedData_all.timeframe(end) + BDF2BinArgs.binsize +...
            [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))])'];
        binnedData_all.emgdatabin = [binnedData_all.emgdatabin ; binnedData.emgdatabin(t_idx,:)];
        binnedData_all.spikeratedata = [binnedData_all.spikeratedata ; binnedData.spikeratedata(t_idx,:)];
        binnedData_all.forcedatabin = [binnedData_all.forcedatabin ; binnedData.forcedatabin(t_idx,:)];
    elseif iTarget == 2
        binnedData_all.timeframe = [binnedData_all.timeframe;...
            (binnedData_all.timeframe(end) + BDF2BinArgs.binsize +...
            [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))])'];       
        binnedData_all.emgdatabin = [binnedData_all.emgdatabin ; binnedData.emgdatabin(t_idx,:)];
        binnedData_all.spikeratedata = [binnedData_all.spikeratedata ; binnedData.spikeratedata(t_idx,:)];
        binnedData_all.forcedatabin = [binnedData_all.forcedatabin ; binnedData.forcedatabin(t_idx,:)];
    end
end
new_length = size(binnedData_reciprocal.timeframe,1);
binnedData_all.timeframe = binnedData_all.timeframe(1:new_length);
binnedData_all.emgdatabin = binnedData_all.emgdatabin(1:new_length,:);
binnedData_all.spikeratedata = binnedData_all.spikeratedata(1:new_length,:);
binnedData_all.forcedatabin = binnedData_all.forcedatabin(1:new_length,:);



[filter_reciprocal, ~] = BuildModel(binnedData_reciprocal, DecoderOptions);
[R2_rec, vaf_rec, mse_rec] = mfxval(binnedData_reciprocal, DecoderOptions);

[filter_all, ~] = BuildModel(binnedData_all, DecoderOptions);
[R2_all, vaf_all, mse_all] = mfxval(binnedData_all, DecoderOptions);

vaf_rec
vaf_all

if any(units(:,2))
    warning('Not saving decoders because this is a sorted file!')
else
    data_folder = params.target_folder(1:strfind(params.target_folder,'CerebusData')-1);
    mkdir([data_folder 'SavedFilters'])
    save([data_folder 'SavedFilters\' params.DCO_file_prefix '_filter_all'],'filter_all')
    save([data_folder 'SavedFilters\' params.DCO_file_prefix '_filter_reciprocal'],'filter_reciprocal')
end

%%    
if params.build_single_neuron_decoders
    % PredData = predictSignals(filter_reciprocal,binnedData_reciprocal);
    % interp_pred_data = interp1(PredData.timeframe,PredData.preddatabin(:,3),binnedData_reciprocal.timeframe);

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
    params.fig_handles(end+1) = figure;
    plot(vaf_single_decoder')
    title('VAF for different decoders')
    ylabel('VAF')
    set(gca,'XTick',1:length(binnedData_single_decoder.emgguide))
    set(gca,'XTicklabel',binnedData_single_decoder.emgguide)
    if any(units(:,2))
        set(params.fig_handles(end),'Name','VAF for different decoders - sorted')
    else
        set(params.fig_handles(end),'Name','VAF for different decoders - unsorted')
    end
    %
    spikeratedata = binnedData.spikeratedata;
    % spikeratedata = spikeratedata-repmat(mean(spikeratedata),size(spikeratedata,1),1);
    % normalized_spikeratedata = spikeratedata./repmat(prctile(spikeratedata,99),size(spikeratedata,1),1);
    normalized_spikeratedata = binnedData.spikeratedata;
    mean_spikeratedata_ot_hold = cell(1,3);
    mean_emg = cell(1,3);
    spikeratedata_whole_trial = cell(1,3);
    emg_whole_trial = cell(1,3);
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
        spikeratedata_whole_trial{iTarget} = [spikeratedata_whole_trial{iTarget} ; normalized_spikeratedata(t_whole_trial,:)]; 
        emg_whole_trial{iTarget} = [emg_whole_trial{iTarget} ; binnedData.emgdatabin(t_whole_trial,:)];
        mean_emg{iTarget}(end+1,:) = mean(binnedData.emgdatabin(t_ot_hold_idx,:));    
    end
    
    single_target_decoder = cell(1,3);    
    for iTarget = 1:length(mean_spikeratedata_ot_hold)
        mean_spikeratedata_ot_hold{iTarget} = mean_spikeratedata_ot_hold{iTarget}-repmat(mean(mean_spikeratedata_ct_hold),size(mean_spikeratedata_ot_hold{iTarget},1),1);
        single_target_decoder{iTarget} = spikeratedata_whole_trial{iTarget}\emg_whole_trial{iTarget};
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
        target_1_muscle_idx = find(~cellfun(@isempty,strfind(binnedData.emgguide,target_1_muscle)));
    %     target_2_muscle_idx = find(~cellfun(@isempty,strfind(binnedData.emgguide,target_2_muscle)));
        target_3_muscle_idx = find(~cellfun(@isempty,strfind(binnedData.emgguide,target_3_muscle)));
    end
    
    params.fig_handles(end+1) = figure;
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
    if any(units(:,2))
        set(params.fig_handles(end),'Name',['FR ' target_2_muscle ' vs ' target_1_muscle ' - sorted'])
    else
        set(params.fig_handles(end),'Name',['FR ' target_2_muscle ' vs ' target_1_muscle ' - unsorted'])
    end

    params.fig_handles(end+1) = figure;
    plot(mean(mean_spikeratedata_ot_hold{3}),mean(mean_spikeratedata_ot_hold{2}),'.'); 
    axis equal
    xlabel([target_3_muscle ' target'])
    ylabel([target_2_muscle ' target'])
    [temp,p] = corrcoef(mean(mean_spikeratedata_ot_hold{3}),mean(mean_spikeratedata_ot_hold{2}));
    temp = temp(2)^2;
    title(['Normalized firing rates. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])
    if any(units(:,2))
        set(params.fig_handles(end),'Name',['FR ' target_2_muscle ' vs ' target_3_muscle ' - sorted'])
    else
        set(params.fig_handles(end),'Name',['FR ' target_2_muscle ' vs ' target_3_muscle ' - unsorted'])
    end

    params.fig_handles(end+1) = figure;
    plot(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{3}),'.'); 
    axis equal
    title('Normalized firing rates')
    xlabel([target_1_muscle ' target'])
    ylabel([target_3_muscle ' target'])
    [temp,p] = corrcoef(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{3}));
    temp = temp(2)^2;
    title(['Normalized firing rates. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])
    if any(units(:,2))
        set(params.fig_handles(end),'Name',['FR ' target_3_muscle ' vs ' target_1_muscle ' - sorted'])
    else
        set(params.fig_handles(end),'Name',['FR ' target_3_muscle ' vs ' target_1_muscle ' - unsorted'])
    end
    
    [n_1,~,p_1] = affine_fit([mean(mean_spikeratedata_ot_hold{1});mean(mean_spikeratedata_ot_hold{3});mean(mean_spikeratedata_ot_hold{2})]');
    
    params.fig_handles(end+1) = figure;
    plot3(mean(mean_spikeratedata_ot_hold{1}),mean(mean_spikeratedata_ot_hold{3}),mean(mean_spikeratedata_ot_hold{2}),'.');
    hold on
    [X,Y] = meshgrid(linspace(min([mean(mean_spikeratedata_ot_hold{3}) mean(mean_spikeratedata_ot_hold{1})]),...
        max([mean(mean_spikeratedata_ot_hold{3}) mean(mean_spikeratedata_ot_hold{1})]),3));
    %first plane
    surf(X,Y, - (n_1(1)/n_1(3)*X+n_1(2)/n_1(3)*Y-dot(n_1,p_1)/n_1(3)),'facecolor','red','facealpha',0.3);
    axis equal
    xlabel([target_1_muscle ' target'])
    ylabel([target_3_muscle ' target'])
    zlabel([target_2_muscle ' target'])
    [b,bint,r,rint,stats] = regress(mean(mean_spikeratedata_ot_hold{2})',...
        [ones(size(mean(mean_spikeratedata_ot_hold{1})')) mean(mean_spikeratedata_ot_hold{1})' mean(mean_spikeratedata_ot_hold{3})']);
    title(['Normalized firing rates. p = ' num2str(stats(3),2)])
    if any(units(:,2))
        set(params.fig_handles(end),'Name','FR 3 targets - sorted')
    else
        set(params.fig_handles(end),'Name','FR 3 targets - unsorted')
    end
    
    
    params.fig_handles(end+1) = figure;
    plot(single_target_decoder{1}(:,target_1_muscle_idx),single_target_decoder{2}(:,target_1_muscle_idx),'.'); 
    axis equal
    xlabel([target_1_muscle ' target'])
    ylabel(['Co-contraction target'])
    [temp,p] = corrcoef(single_target_decoder{1}(:,target_1_muscle_idx),single_target_decoder{2}(:,target_1_muscle_idx));
    temp = temp(2)^2;
    title(['Decoder weights. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])
    if any(units(:,2))
        set(params.fig_handles(end),'Name',['Decoder weights co-contraction vs ' target_1_muscle ' - sorted'])
    else
        set(params.fig_handles(end),'Name',['Decoder weights co-contraction vs ' target_1_muscle ' - unsorted'])
    end
    
    params.fig_handles(end+1) = figure;
    plot(single_target_decoder{3}(:,target_3_muscle_idx),single_target_decoder{2}(:,target_3_muscle_idx),'.'); 
    axis equal
    xlabel([target_3_muscle ' target'])
    ylabel(['Co-contraction target'])
    [temp,p] = corrcoef(single_target_decoder{3}(:,target_3_muscle_idx),single_target_decoder{2}(:,target_3_muscle_idx));
    temp = temp(2)^2;
    title(['Decoder weights. R^2 = ' num2str(temp,2) '. p = ' num2str(p(2),2)])
    if any(units(:,2))
        set(params.fig_handles(end),'Name',['Decoder weights co-contraction vs ' target_3_muscle ' - sorted'])
    else
        set(params.fig_handles(end),'Name',['Decoder weights co-contraction vs ' target_3_muscle ' - unsorted'])
    end
    
    
%     % Neural channel correlations
%     % 
%     for iUnit = 1:size(spikeratedata,2)
%         for jUnit = iUnit:size(spikeratedata,2)
%             temp = corrcoef(spikeratedata(:,iUnit),spikeratedata(:,jUnit));        
%             neuron_correlations(iUnit,jUnit) = temp(2)^2;
%         end
%     end
           
end