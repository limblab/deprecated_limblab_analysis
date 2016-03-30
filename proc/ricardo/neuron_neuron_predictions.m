%%
recalculate_all_data = 1;
% folder_location = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
folder_location = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\User_folders\Stephanie\Data Analysis\FESgrantrenewal\JangoThresholdCrossings\';
behavior_names = {'SprBinned','WmBinned','IsoBinned'};

%%
if recalculate_all_data
    folders = dir(folder_location);
    folders = {folders(:).name};
    folders = folders(~cellfun(@isempty,regexp(folders,'[0-9][0-9]-[0-9]*')));

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
    DecoderOptions.foldlength = 90;

    R2 = {};
    electrodes = {};
    for iFile = 1:length(folders)
        filename = dir([folder_location filesep folders{iFile} filesep 'Gen*.mat']);
        all_data = load([folder_location filesep folders{iFile} filesep filename(1).name]);
        for iBehavior = 1:length(behavior_names)
            if isfield(all_data,behavior_names{iBehavior})
                binnedData_all = all_data.(behavior_names{iBehavior});
                R2{iFile,iBehavior} = [];            
                for iSpike = 1:size(binnedData_all.spikeratedata,2)
                    binnedData_new = binnedData_all;
                    binnedData_new.emgdatabin = binnedData_all.spikeratedata(:,iSpike);
                    binnedData_new.emgguide = {['Elec' num2str(binnedData_all.neuronIDs(iSpike,1))]};
                    binnedData_new.spikeratedata(:,iSpike) = [];
                    binnedData_new.neuronIDs(iSpike,:) = [];

                    [R2_all, vaf_all, mse_all] = mfxval(binnedData_new, DecoderOptions);
                    R2{iFile,iBehavior}(iSpike) = mean(R2_all(~isnan(R2_all)));
    %                 [filter_all, pred_spike] = BuildModel(binnedData_new, DecoderOptions);
    %                 temp = corrcoef(binnedData_all.spikeratedata(10:end,iSpike),...
    %                     pred_spike.preddatabin);
    %                 R2{iFile,iBehavior}(iSpike) = temp(2)^2;
                    electrodes{iFile,iBehavior}(iSpike,:) = binnedData_all.neuronIDs(iSpike,:);
                    disp(['File: ' num2str(iFile) '. Behavior: ' num2str(iBehavior) ...
                        '. Chan: ' num2str(iSpike) '. R^2 = ' num2str(R2{iFile,iBehavior}(iSpike))])
                end

    %             figure; 
    %             histogram(vaf,0:.05:1)
    %             xlabel('VAF','Interpreter','tex')
    %             ylabel('Count')
    %             title('Firing rate predictions from other firing rates')
            end
        end
    end


    neuron_unique_id = {};
    for iFile = 1:length(folders)
        for iBehavior = 1:length(behavior_names)
            if ~isempty(electrodes{iFile,iBehavior})
                neuron_unique_id{iFile,iBehavior} = electrodes{iFile,iBehavior}(:,1).^2 +...
                    electrodes{iFile,iBehavior}(:,2);
            end
        end
    end

    % all_data = [datenum behavior electrode_id R2]
    all_data = [];
    for iFile = 1:length(folders)
        folder_date = datenum(folders{iFile}(1:8));
        for iBehavior = 1:length(behavior_names)
            if ~isempty(neuron_unique_id{iFile,iBehavior})
                for iElectrode = 1:length(neuron_unique_id{iFile,iBehavior})
                    all_data(end+1,:) = [datenum(folders{iFile}(1:8)) ...
                        iBehavior ...
                        neuron_unique_id{iFile,iBehavior}(iElectrode) ...
                        R2{iFile,iBehavior}(iElectrode)];
                end
            end
        end
    end

    all_data = all_data(~isnan(all_data(:,4)),:)
    new_dir = [folder_location 'NeuronToNeuronPredictions'];
    mkdir(new_dir)
    save([new_dir '\NeuronToNeuronPredictionData'],'all_data')
else
    new_dir = [folder_location 'NeuronToNeuronPredictions'];
    load([new_dir '\NeuronToNeuronPredictionData'])
end
%%
unique_dates = unique(all_data(:,1));
unique_ids = unique(all_data(:,2));

mean_r2_by_date = [];
std_r2_by_date = [];
for iDate = 1:length(unique_dates)
    mean_r2_by_date(iDate) = mean(all_data(all_data(:,1)==unique_dates(iDate),4));
    std_r2_by_date(iDate) = std(all_data(all_data(:,1)==unique_dates(iDate),4));
end
    
figure; 
errorbar(unique_dates-unique_dates(1)+1,mean_r2_by_date,std_r2_by_date)
xlabel('Day')
ylabel('R^2 (mean +/- std)')
title('R^2 over time')
ylim([0 1])

mean_r2_by_behavior = [];
std_r2_by_behavior = [];
for iBehavior = 1:length(behavior_names)
    mean_r2_by_behavior(iBehavior) = mean(all_data(all_data(:,2)==iBehavior,4));
    std_r2_by_behavior(iBehavior) = std(all_data(all_data(:,2)==iBehavior,4));
end
    
figure; 
errorbar(1:length(behavior_names),mean_r2_by_behavior,std_r2_by_behavior,'.')
set(gca,'XTick',1:length(behavior_names))
set(gca,'XTickLabel',behavior_names)
xlabel('Behavior')
ylabel('R^2 (mean +/- std)')
title('R^2 as a function of behavior')
ylim([0 0.5])

%%
mean_r2_by_date_behavior = [];
std_r2_by_date_behavior = [];
num_neurons_by_date_behavior = [];
for iDate = 1:length(unique_dates)
    for iBehavior = 1:length(behavior_names)
        mean_r2_by_date_behavior(iDate,iBehavior) = mean(all_data(all_data(:,1)==unique_dates(iDate) & all_data(:,2)==iBehavior,4));
        std_r2_by_date_behavior(iDate,iBehavior) = std(all_data(all_data(:,1)==unique_dates(iDate) & all_data(:,2)==iBehavior,4));
        num_neurons_by_date_behavior(iDate,iBehavior) = length(all_data(all_data(:,1)==unique_dates(iDate) & all_data(:,2)==iBehavior,:));
    end
end
num_neurons_by_date_behavior(num_neurons_by_date_behavior==0) = nan;

%%
x_data = [unique_dates-unique_dates(1)+1-.25 unique_dates-unique_dates(1)+1 unique_dates-unique_dates(1)+1+.25];
h_fig = figure;
h_axes1 = subplot(211);
h_errorbar = errorbar(x_data,mean_r2_by_date_behavior,std_r2_by_date_behavior,'.','MarkerSize',10);
hold on
for iBehavior = 1:length(behavior_names)
    fit_temp = fit(x_data(~isnan(mean_r2_by_date_behavior(:,iBehavior)),2),...
        mean_r2_by_date_behavior(~isnan(mean_r2_by_date_behavior(:,iBehavior)),iBehavior),...
        'linear');
    plot([x_data(1,2) x_data(end,2)],fit_temp([x_data(1,2) x_data(end,2)]),...
        'Color',get(h_errorbar(iBehavior),'Color'))
end

xlabel('Day')
ylabel('R^2 (mean +/- std)')
title('Neuron prediction from other neurons. R^2 over time')
legend(behavior_names)
ylim([0 0.5])
xlim([-10 x_data(end)+10])

h_axes2 = subplot(212);
hold on
h_bar = plot(x_data,num_neurons_by_date_behavior,'.','MarkerSize',10);
set(h_bar,'LineStyle','none')
for iH = 1:length(behavior_names)
    set(h_bar(iH),'Color',get(h_errorbar(iH),'Color'))
end
y_data = num_neurons_by_date_behavior(:);
x_data = repmat(unique_dates-unique_dates(1)+1,length(behavior_names),1);
x_data = x_data(~isnan(y_data));
x_data = x_data + rand(size(x_data))*.05;
y_data = y_data(~isnan(y_data));
fit_temp = fit(x_data,y_data,'linear');
plot([x_data(1) x_data(end)],fit_temp([x_data(1) x_data(end)]),...
    '-k')
title('Number of sorted neurons over time')
ylabel('Number of sorted neurons')
xlabel('Day')
set(h_axes2,'Xlim',get(h_axes1,'Xlim'))
ylim([0 100])
legend([behavior_names,'All behavior fit'])



