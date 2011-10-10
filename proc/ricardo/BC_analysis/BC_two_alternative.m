function BC_two_alternative(filelist)

reward_code = 32;
abort_code = 33;
fail_code = 34;
incomplete_code = 35;

for file_no = 1:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pds = filelist(file_no).pd;
    codes = filelist(file_no).codes;
    currents = filelist(file_no).current; 
    electrodes = filelist(file_no).electrodes; 
    no_stim_code = codes(find(currents==0));
    stim_codes = codes(find(currents~=0));
       
    stimuli_table = [codes' electrodes' currents'];
    serverdatapath = filelist(file_no).serverdatapath;    
        
    load([filelist(file_no).datapath 'Processed\' filename],'trial_table','bdf','table_columns')
    
    trial_table(trial_table(:,table_columns.stim_id)==16,table_columns.stim_id) = -1;
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 &...
        trial_table(:,table_columns.stim_id)==0 &...
        trial_table(:,table_columns.bump_magnitude)>0,table_columns.stim_id) = -1;

    trial_table = trial_table(trial_table(:,table_columns.bump_time)~=0,:); % Remove aborts
    
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 & trial_table(:,table_columns.stim_id) ~= -1,...
        table_columns.bump_magnitude) = 0;
    trial_table(trial_table(:,table_columns.bump_and_stim)==0 & trial_table(:,table_columns.stim_id) ~= -1,...
        table_columns.bump_time) = 0;
    
    %remove training trials
    trial_table = trial_table(trial_table(:,table_columns.training)==0,:);
    
%     trial_table = trial_table(200:end,:);
    contingency = zeros(2,2,length(stim_codes));
    tpr = zeros(1,length(stim_codes));
    tnr = zeros(1,length(stim_codes));
    fpr = zeros(1,length(stim_codes));
    dprime = zeros(1,length(stim_codes));
    true_negative = size(trial_table(trial_table(:,table_columns.stim_id)==no_stim_code & trial_table(:,table_columns.result)==reward_code,:),1);
    false_positive = size(trial_table(trial_table(:,table_columns.stim_id)==no_stim_code & trial_table(:,table_columns.result)==fail_code,:),1);
        
    % Time course
    nbins = 5;
    hist_bins = linspace(0,trial_table(end,table_columns.start),nbins+1)+trial_table(end,table_columns.start)/(nbins-1)/2;
    hist_bins = hist_bins(1:end-1);
    figure;
    true_negatives = trial_table(trial_table(:,table_columns.stim_id)==no_stim_code &...
        trial_table(:,table_columns.result)==reward_code,table_columns.start);
    true_positives = trial_table(trial_table(:,table_columns.stim_id)~=no_stim_code &...
        trial_table(:,table_columns.result)==reward_code,table_columns.start);
    false_negatives = trial_table(trial_table(:,table_columns.stim_id)~=no_stim_code &...
        trial_table(:,table_columns.result)==fail_code,table_columns.start);
    false_positives = trial_table(trial_table(:,table_columns.stim_id)==no_stim_code &...
        trial_table(:,table_columns.result)==fail_code,table_columns.start);
    true_negatives_hist = hist(true_negatives,hist_bins);
    true_positives_hist = hist(true_positives,hist_bins);
    false_negatives_hist = hist(false_negatives,hist_bins);
    false_positives_hist = hist(false_positives,hist_bins);
    true_positive_rate = true_positives_hist./(true_positives_hist+false_negatives_hist);
    false_positive_rate = false_positives_hist./(false_positives_hist+true_negatives_hist);
    plot(hist_bins,[true_positive_rate; false_positive_rate],'-');
    xlabel('t (s)')
    ylabel('Rate')
    legend('True Positive','False Positive')
    title(filename,'Interpreter','none')
    
     % Time course by stim code
    nbins = 5;
    hist_bins = linspace(0,trial_table(end,table_columns.start),nbins+1)+trial_table(end,table_columns.start)/(nbins-1)/2;
    hist_bins = hist_bins(1:end-1);
    figure;
    rewards_fails_ratio_time = zeros(length(codes),nbins);
    for iStim = 1:length(codes)
        rewards_stim = trial_table(trial_table(:,table_columns.stim_id)==codes(iStim) &...
            trial_table(:,table_columns.result)==reward_code,table_columns.start);
        rewards_hist = hist(rewards_stim,hist_bins);
        fails_stim = trial_table(trial_table(:,table_columns.stim_id)==codes(iStim) &...
            trial_table(:,table_columns.result)==fail_code,table_columns.start);
        fails_hist = hist(fails_stim,hist_bins);
        rewards_fails_ratio_time(iStim,:) = rewards_hist./(rewards_hist+fails_hist);
    end
    plot(hist_bins,rewards_fails_ratio_time,'-')
    
    xlabel('t (s)')
    ylabel('R/(R+F)')
    title(filename,'Interpreter','none')
    legend(num2str(codes'))
    
    % ROC curves
    figure;
    hold on
    for iStimCode = 1:length(stim_codes)
        true_positive = size(trial_table(trial_table(:,table_columns.stim_id)==stim_codes(iStimCode) & trial_table(:,table_columns.result)==reward_code,:),1);
        false_negative = size(trial_table(trial_table(:,table_columns.stim_id)==stim_codes(iStimCode) & trial_table(:,table_columns.result)==fail_code,:),1);
        contingency(:,:,iStimCode) = [true_positive false_positive; false_negative true_negative];
        tpr(iStimCode) = true_positive/(true_positive+false_negative); % true positive rate
        tnr(iStimCode) = true_negative/(false_positive+true_negative); % true negative rate
        fpr(iStimCode) = false_positive/(false_positive+true_negative); % false positive rate
        dprime(iStimCode) = erfinv(tpr(iStimCode)*2-1)-erfinv(fpr(iStimCode)*2-1);
        plot(fpr(iStimCode),tpr(iStimCode),'b.');
%         text(fpr(iStimCode)+.05,tpr(iStimCode),num2str(dprime(iStimCode),2));
        text(fpr(iStimCode)+.05,tpr(iStimCode),[num2str(currents(codes(stim_codes(iStimCode)))) 'uA']);
    end
     
    plot([0 1],[0 1],'r--');
    title(filename,'Interpreter','none')
    ylabel('Hits (True positive rate)')
    xlabel('False alarms (False negative rate)')
    
    % Results by stim code
    figure;
    hold on
    phats = zeros(1,length(codes));
    pcis = zeros(2,length(codes));
    for iStim = 1:length(codes)
        temp_rewards = sum(trial_table(trial_table(:,table_columns.stim_id)==codes(iStim),table_columns.result)==reward_code);
        temp_fails = sum(trial_table(trial_table(:,table_columns.stim_id)==codes(iStim),table_columns.result)==fail_code);
        [phats(iStim),pcis(:,iStim)] = binofit(temp_rewards,(temp_rewards+temp_fails));
    end
    errorbar(codes,phats,phats-pcis(1,:),pcis(2,:)-phats,'.')
    xlabel('Code')
    ylabel('R/(R+F)')
    
    % Psychometric curves
    figure;
    hold on
    ylim([0 1])
    no_stim_details = stimuli_table(stimuli_table(:,2)==0,:);
    no_stim_results = trial_table(trial_table(:,table_columns.stim_id)==no_stim_details(1,1),table_columns.result);
    no_stim_rewards = sum(no_stim_results==reward_code);
    no_stim_fails = sum(no_stim_results==fail_code);
    stim_electrodes = unique(stimuli_table(stimuli_table(:,2)~=0,2));
    for iElectrode = 1:length(stim_electrodes)
        temp_table = stimuli_table(stimuli_table(:,2)==stim_electrodes(iElectrode),:);
        electrode_results{iElectrode} = zeros(size(temp_table,1)+1,6);
        [phat,pci] = binofit(no_stim_fails,(no_stim_rewards+no_stim_fails));
        electrode_results{iElectrode}(1,:) = [0 no_stim_rewards no_stim_fails phat pci];
        for iCurrent = 1:size(temp_table,1)
            temp_stim_id = temp_table(iCurrent,1);
            temp_results = trial_table(trial_table(:,table_columns.stim_id)==temp_stim_id,table_columns.result);
            temp_rewards = sum(temp_results==reward_code);
            temp_fails = sum(temp_results==fail_code);            
            [phat,pci] = binofit(temp_rewards,(temp_rewards+temp_fails));
            electrode_results{iElectrode}(iCurrent+1,:) = [temp_table(iCurrent,3) temp_rewards temp_fails phat pci];
        end
%         plot(-electrode_results{iElectrode}(:,1),electrode_results{iElectrode}(:,2)./...
%             (electrode_results{iElectrode}(:,2)+electrode_results{iElectrode}(:,3)),'.');  
        errorbar(-electrode_results{iElectrode}(:,1),electrode_results{iElectrode}(:,4),...
            electrode_results{iElectrode}(:,5)-electrode_results{iElectrode}(:,4),...
            electrode_results{iElectrode}(:,6)-electrode_results{iElectrode}(:,4),'.');            
    end        
end