%%% General processing test scrit
%% Get bdf
bdf = get_nev_mat_data('Y:\Chips_12H1\RAW\Chips_20150206_RW_tucker_001',6);
% bdf = get_nev_mat_data('/Users/raeedchowdhury/Projects/s1_analysis/proc/raeed/Projects/General Tuning/Chips_20150206_RW_tucker_001',6);

%% parse for tuning
% [bdf.TT,bdf.TT_hdr] = rw_trial_table(bdf);
bdf.meta.task = 'RW';
bdf = make_tdf_function(bdf);

% for i = 1:length(bdf.units)
%     [s,t] = bin_spikes(bdf,50,bdf.units(i).id(1),bdf.units(i).id(2));
%     bdf.units(i).FR = [t' s'];
% end
% 
% clear i
% clear s
% clear t

behaviors = parse_for_tuning(bdf,'continuous');

%% compute tuning
tunings = compute_tuning(behaviors.FR,behaviors.armdata,[1 1 0 0 0 0],struct('num_rep',10000),'poisson');