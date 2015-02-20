%%% General processing test scrit
%% Get bdf
bdf = get_nev_mat_data('Y:\Chips_12H1\RAW\Chips_20150206_RW_tucker_001',6);

%% parse for tuning
[bdf.TT,bdf.TT_hdr] = rw_trial_table(bdf);
bdf.meta.task = 'RW';

for i = 1:length(bdf.units)
    [s,t] = bin_spikes(bdf,50,bdf.units(i).id(1),bdf.units(i).id(2));
    bdf.units(i).FR = [t' s'];
end

behaviors = parse_for_tuning(bdf,'continuous');

%% compute tuning
tunings = compute_tuning(