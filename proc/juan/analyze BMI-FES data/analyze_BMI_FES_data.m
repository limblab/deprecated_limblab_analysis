%
% Function to analyze and plot BMI-FES data
%

function results = analyze_BMI_FES_data( analysis_params )


file_name           = fullfile( analysis_params.dir, analysis_params.file );


% -------------------------------------------------------------------------
% load data

% load spike data
temp_file           = [file_name 'spikes.txt'];
temp_data           = tdfread(temp_file); % read tab-delimited file
temp_fieldname      = fieldnames(temp_data); % read automatically-generated field name to store data
spike_data          = temp_data.(temp_fieldname{1});

% load EMG preds
temp_file           = [file_name 'emgpreds.txt'];
temp_data           = tdfread(temp_file); % read tab-delimited file
temp_fieldname      = fieldnames(temp_data); % read automatically-generated field name to store data
emgpred_data        = temp_data.(temp_fieldname{1});

% load stimulator output
temp_file           = [file_name 'stim_out.txt'];
temp_data           = tdfread(temp_file); % read tab-delimited file
temp_fieldname      = fieldnames(temp_data); % read automatically-generated field name to store data
stim_data           = temp_data.(temp_fieldname{1});

clear temp_*;

% load BMI-FES params
params_file         = [file_name 'params.mat'];
params              = load(params_file);


% load BDF and get trial table
if strncmp(analysis_params.task,'MG',2)
    % for the multigadget, there is no pos data
    bdf             = get_nev_mat_data(file_name,'nokin');
    % get trial table
    tt              = mg_trial_table(bdf);
else strncmp(analysis_params.task,'WF',2)
    bdf             = get_nev_mat_data(file_name);
    % get trial table
    tt              = wf_trial_table(bdf);
end



% PLOT
xl                  = [0 200];
emg_chs             = 1+(2:4);
neural_chs          = 1+[1:24 26:35 39:45 47:96];

% plot force and FES/catch for the whole trial
figure, hold on
% plot the targets
tgt_gain = 125*1.5;
for i = 1:size(tt,1)
    if tt(i,12) == 82
        rectangle('Position',[tt(i,1),tgt_gain*tt(i,10),(tt(i,11)-tt(i,1)),tgt_gain*abs(tt(i,8)-tt(i,10))/2],...
            'FaceColor','black','EdgeColor',[1 1 1])
    else
        rectangle('Position',[tt(i,1),tgt_gain*tt(i,10),(tt(i,11)-tt(i,1)),tgt_gain*abs(tt(i,8)-tt(i,10))/2],...
            'FaceColor',[.7 .7 .7],'EdgeColor',[1 1 1])
    end
end
plot(bdf.force.data(:,1),bdf.force.data(:,2),'linewidth',4)
plot(stim_data(:,1),stim_data(:,8).*peak2peak(bdf.force.data(:,2))/2,'color',[.7 .7 .7],'linewidth',2)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlabel('time (s)'); ylabel('force'); 
legend('force','fes/catch','FontSize',14); legend boxoff
xlim(xl)


% % plot force, EMG predictions, PW commands
% figure,
% subplot(311),hold on
% for i = 1:size(tt,1)
%     if tt(i,12) == 82
%         rectangle('Position',[tt(i,1),tgt_gain*tt(i,10),(tt(i,11)-tt(i,1)),tgt_gain*abs(tt(i,8)-tt(i,10))/2],...
%             'FaceColor','black','EdgeColor',[1 1 1])
%     else
%         rectangle('Position',[tt(i,1),tgt_gain*tt(i,10),(tt(i,11)-tt(i,1)),tgt_gain*abs(tt(i,8)-tt(i,10))/2],...
%             'FaceColor',[.7 .7 .7],'EdgeColor',[1 1 1])
%     end
% end
% plot(bdf.force.data(:,1),bdf.force.data(:,2),'linewidth',2)
% plot(stim_data(:,1),stim_data(:,8).*peak2peak(bdf.force.data(:,2))/2,'color',[.7 .7 .7],'linewidth',2)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% xlim(xl); ylabel('force'); 
% legend('force','fes/catch','FontSize',14); 
% subplot(312),hold on
% plot(emgpred_data(:,1),emgpred_data(:,emg_chs),'linewidth',2), ylim([-.1 1.1])
% set(gca,'TickDir','out'),set(gca,'FontSize',14),
% legend(params.neuron_decoder.outnames(emg_chs),'FontSize',14)
% xlim(xl); ylabel('EMG predictions')
% subplot(313),hold on
% plot(stim_data(:,1),stim_data(:,emg_chs),'linewidth',2), ylim([-.1 1.1])
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% legend(params.neuron_decoder.outnames(emg_chs),'FontSize',14)
% xlim(xl); ylabel('PW command'); xlabel('time (s)')

% and with spikes
figure,
subplot(411),
imagesc(spike_data(:,1),1:length(neural_chs),spike_data(:,neural_chs)')
set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlim(xl);ylabel('neural activity'); colorbar
subplot(412),hold on
plot(emgpred_data(:,1),emgpred_data(:,emg_chs),'linewidth',2), ylim([-.1 1.1])
set(gca,'TickDir','out'),set(gca,'FontSize',14),
legend(params.neuron_decoder.outnames(emg_chs),'FontSize',14)
xlim(xl); ylabel('EMG predictions')
subplot(413),hold on
plot(stim_data(:,1),stim_data(:,emg_chs),'linewidth',2), ylim([-.1 1.1])
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend(params.neuron_decoder.outnames(emg_chs),'FontSize',14)
xlim(xl); ylabel('PW command'); xlabel('time (s)')
subplot(414),hold on
for i = 1:size(tt,1)
    if tt(i,12) == 82
        rectangle('Position',[tt(i,1),tgt_gain*tt(i,10),(tt(i,11)-tt(i,1)),tgt_gain*abs(tt(i,8)-tt(i,10))/2],...
            'FaceColor','black','EdgeColor',[1 1 1])
    else
        rectangle('Position',[tt(i,1),tgt_gain*tt(i,10),(tt(i,11)-tt(i,1)),tgt_gain*abs(tt(i,8)-tt(i,10))/2],...
            'FaceColor',[.7 .7 .7],'EdgeColor',[1 1 1])
    end
end
plot(bdf.force.data(:,1),bdf.force.data(:,2),'linewidth',2)
plot(stim_data(:,1),stim_data(:,8).*peak2peak(bdf.force.data(:,2))/2,'color',[.7 .7 .7],'linewidth',2)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlim(xl); ylabel('force'); 
legend('force','fes/catch','FontSize',14); 