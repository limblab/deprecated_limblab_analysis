
% wrapper to find_output_null_potent_dims

function call_find_output_null_potent_dims_wf( data_struct, neural_chs, chosen_emgs, labels, varargin )


% read inputs

% params
neural_dims             = 1:12;
muscle_dims             = 1:3;
w_i                     = 'ot_on';
w_f                     = 'R';


% see if user has passed a BDF or a binned_data struct
if isfield( data_struct, 'timeframe' )
    binned_data         = data_struct;
else
    bdf                 = data_struct;
end

% see if user has passed the smoothed_firing_rates
if nargin == 5
    smoothed_FR         = varargin{1};
end


nbr_bdfs                = length(data_struct);


% if the user has not passed the binned_data and the smoothed_firing rates
if ~exist('smoothed_FR','var')
    smoothed_FR             = cell(4,1);
    for i = 1:nbr_bdfs
        [smoothed_FR{i},aux_bd] = gaussian_smoothing2( bdf(i) ); 
        binned_data(i)      = aux_bd; 
        clear aux_bd; 
    end
end


% crop the binned_data
cropped_binned_data     = call_crop_binned_data_wf( binned_data, w_i, w_f );


% ------------------------------------------------------------------------
% do PCA of the cropped smoothed firing rates
discard_chs             = setdiff(1:size(binned_data(1).neuronIDs,1),neural_chs);
for i = 1:nbr_bdfs
    dim_red_FR{i}       = dim_reduction( cropped_binned_data(i), 'pca', ...
                            discard_chs );
end

% do PCA of the EMGs
dim_red_emg             = dim_reduction_muscles( cropped_binned_data, ...
                            'pca', chosen_emgs, labels );

% ------------------------------------------------------------------------

% % if you want to compute the angle between hyperplanes for these "cropped"
% % tasks
% [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim_finding_closest( bdf, ...
%     neural_chs, 30, labels, 'pca', smoothed_FR, dim_red_FR );


% compute mean responses
for i = 1:nbr_bdfs
    single_trial_data{i} = single_trial_analysis_dim_red( cropped_binned_data(i), dim_red_FR{i}, ...
        dim_red_emg{i}, labels{i}, true );
end


% now do the multilinear regression to find output null and output potent
% dimensions
neural_to_EMG_lag       = 0.05*(-4:1:4);
onp_dim                 = cell(nbr_bdfs,length(neural_to_EMG_lag));
for i = 1:nbr_bdfs
    for l = 1:length(neural_to_EMG_lag)
        onp_dim{i,l}.neural_emg_lag = neural_to_EMG_lag(i);
        onp_dim{i,l}.data   = find_output_null_potent_dims( single_trial_data{i}, neural_dims, muscle_dims, ...
            neural_to_EMG_lag(l), dim_red_emg{i}, false );
    end
end


% get some summary stats
mean_R2_fcn_delay       = zeros(nbr_bdfs,length(neural_to_EMG_lag));
std_R2_fcn_delay        = zeros(nbr_bdfs,length(neural_to_EMG_lag));
weighed_R2_fcn_delay    = zeros(nbr_bdfs,length(neural_to_EMG_lag));
for i = 1:nbr_bdfs
    % do for the fit that comprises all targets
    tgt                 = length(single_trial_data{i})+1;
    for l = 1:length(neural_to_EMG_lag)
        mean_R2_fcn_delay(i,l)  = mean(onp_dim{i,l}.data{tgt}.R2);
        std_R2_fcn_delay(i,l)   = std(onp_dim{i,l}.data{tgt}.R2);
        weighed_R2_fcn_delay(i,l) = onp_dim{i,l}.data{tgt}.weighed_R2;
    end
end

% ------------------------------------------------------------------------
% FIGURES

% color per target
colors_delays        	= parula(nbr_bdfs);

% plot fit per task as function of the delay

% mean +/- SD R2
figure,hold on
for l = 1:length(neural_to_EMG_lag)
    for i = 1:nbr_bdfs

        errorbar(neural_to_EMG_lag(l),mean_R2_fcn_delay(i,l),std_R2_fcn_delay(i,l),...
            'color',colors_delays(i,:),'marker','o','markersize',14,'linewidth',4)
    end
    if l == 1, legend(labels); end
end
ylim([0 1.1]),xlim([neural_to_EMG_lag(1)-mean(diff(neural_to_EMG_lag)),neural_to_EMG_lag(end)+mean(diff(neural_to_EMG_lag))])
set(gca,'XTick',neural_to_EMG_lag),set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlabel('neural to EMG delay (ms)'),ylabel('R^2 of model fit')

% weighed R2
figure,hold on
for i = 1:nbr_bdfs
    plot(neural_to_EMG_lag,weighed_R2_fcn_delay(i,:),'color',colors_delays(i,:),'linewidth',2)
end    
ylim([0 1.1]),xlim([neural_to_EMG_lag(1)-mean(diff(neural_to_EMG_lag)),neural_to_EMG_lag(end)+mean(diff(neural_to_EMG_lag))])
set(gca,'XTick',neural_to_EMG_lag),set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlabel('neural to EMG delay (ms)'),ylabel('weighed R^2 of model fit')
legend(labels)
% 
% 
% % ---------------------
% % OUTPUT POTENT / NULL PLOTS
% 
% % Plot matrix V for each task
% tgt                     = 7;
% bdf_nbr                 = 2;
% lag_nbr                 = 5;
% 
% % title --add colors
% if tgt <= length(single_trial_data{bdf_nbr})
%     ttl                 = ['output-potent model ' labels{i} ' target ' num2str(tgt)];
% else
%     ttl                 = ['output-potent model ' labels{i} ' all targets'];
% end
% figure,
% subplot(121),imagesc(abs(onp_dim{bdf_nbr}.data{tgt}.svdec.V(:,1:3)))
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% set(gca,'XTick',1:length(muscle_dims)),set(gca,'XTick',1:length(neural_dims))
% xlabel('muscle comp.'),ylabel('neural comp.')
% title(['output-potent model ' labels{bdf_nbr} ' target ' num2str(tgt)])
% subplot(122),imagesc(sum(abs(onp_dim{bdf_nbr}.data{tgt}.svdec.V(:,1:3)),2)),colorbar
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% set(gca,'XTick',1),set(gca,'XTick',1:length(neural_dims)),set(gca,'XTickLabel',[])
% title('sum for all muscle comp')
% 
% % Plot output potent null dimensions
% 
% % normalize (to peak2peak value) the data
% norm_emg_data           = zeros(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2),size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,1));
% norm_potent             = zeros(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2),size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,1));
% norm_null               = zeros(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2),size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,1));
% for i = 1:size(onp_dim{1,5}.data{7}.emg_data,1)
%     norm_emg_data(:,i)  = onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data(i,:)/...
%         peak2peak(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data(i,:));
%     norm_potent(:,i)    = onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.task_relev(:,i)/...
%         peak2peak(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.task_relev(:,i));
%     norm_null(:,i)      = onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.null_space(:,i)/...
%         peak2peak(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.null_space(:,i));    
% end
% t_plot                  = single_trial_data{1}{1}.bin_size*(0:(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2)-1));
% 
% figure,
% subplot(311),plot(t_plot,norm_emg_data,'linewidth',3)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% subplot(312),plot(t_plot,norm_potent,'linewidth',3)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% subplot(313),plot(t_plot,norm_null,'linewidth',3)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
