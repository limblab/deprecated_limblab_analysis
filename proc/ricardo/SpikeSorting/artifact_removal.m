function NEV = artifact_removal(varargin)
    
if nargin == 1
    NEV = varargin{1};
    rejection_num_chans = 3;
    rejection_window = 0.001;
elseif nargin == 3
    NEV = varargin{1};
    rejection_num_chans = varargin{2};
    rejection_window = varargin{3};  % in seconds
end
    
rejection_samples = rejection_window*30000;
timestamps = double(NEV.Data.Spikes.TimeStamp);

num_electrodes = length(unique(NEV.Data.Spikes.Electrode));

artifacts = [];
actual_spikes = [];
tic
for i = 1:rejection_samples
    last_timestamp = timestamps(end);
    bins = i + (0:rejection_samples:last_timestamp+rejection_samples);
    [count,in_bin] = histc(timestamps,bins);
    [~,spike_count_in_bin] = histc(count,0.5:1:num_electrodes+.5);
    bins_to_keep = find(spike_count_in_bin<rejection_num_chans);
    bins_to_reject = find(spike_count_in_bin>=rejection_num_chans);

    actual_spikes = find(ismember(in_bin,bins_to_keep));
    artifacts = unique([artifacts find(ismember(in_bin,bins_to_reject))]);

    actual_spikes = unique([actual_spikes intersect(actual_spikes,1:length(timestamps))]);
    actual_spikes = actual_spikes(~ismember(actual_spikes,artifacts));
end
disp(['Removed ' num2str(length(artifacts)) ' artifacts, found ' num2str(length(actual_spikes)) ' actual spikes in '...
    num2str(toc) ' seconds.'])

NEV.Data.Spikes.TimeStamp = NEV.Data.Spikes.TimeStamp(actual_spikes);
NEV.Data.Spikes.Electrode = NEV.Data.Spikes.Electrode(actual_spikes);
NEV.Data.Spikes.Unit= NEV.Data.Spikes.Unit(actual_spikes);
NEV.Data.Spikes.Waveform = NEV.Data.Spikes.Waveform(:,actual_spikes);