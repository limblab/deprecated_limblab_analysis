function [missing_spikes,missing_pct] = compare_with_fake_monkeys(spikes,binsize)

n_neurons                = size(spikes,2);
n_spike_per_cycles_total = 108; % total number of spikes in each chan over one fake monkey cycle
cycle_duration           = 10;  % fake monkey cycle lasts 10 seconds
num_cycle_bins           = cycle_duration/binsize;

% start anywhere where all the channels are silent, but not right at
% beginning (say after at least 2 seconds)

skip_2sec_idx = round(2/binsize);
max_xcol = max(spikes,[],2); 
cycle_start_idx = find(max_xcol(skip_2sec_idx:end,:)==0,1,'first')+(skip_2sec_idx-1);

if ~isempty(cycle_start_idx)
    
    tot_spikes     = n_spike_per_cycles_total*n_neurons;
    num_spikes     = sum(sum(spikes(cycle_start_idx:cycle_start_idx+num_cycle_bins-1,:)));
    
    missing_spikes = max(0,tot_spikes - num_spikes);
    missing_pct    = missing_spikes/tot_spikes;
    
else
    missing_spikes = -1;
    missing_pct    = -1;
end