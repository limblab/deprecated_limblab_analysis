function unit_structure = artifact_removal(varargin)
%ARTIFACT_REMOVAL Remove artifacts from neural data
%   BDF = artifact_removal(BDF) returns a bdf structure with no spikes
%   occurring within 0.001 s in at least 3 channels.
%   
%   NEV = artifact_removal(NEV) returns an NEV structure with no spikes
%   occurring within 0.001 s in at least 3 channels.
%   
%   BDF = artifact_removal(BDF,NUM_CHANNELS,INTERVAL,DELETE_ARTIFACTS) returns a bdf structure
%   with no spikes occurring within INTERVAL seconds in at least NUM_CHANNELS 
%   channels. If DELETE_ARTIFACTS is 0, artifacts will be stored as unit
%   number 99.
%
%   NEV = artifact_removal(NEV,NUM_CHANNELS,INTERVAL,DELETE_ARTIFACTS) returns an NEV structure
%   with no spikes occurring within INTERVAL seconds in at least NUM_CHANNELS 
%   channels. If DELETE_ARTIFACTS is 0, artifacts will be stored as unit
%   number 99.
    
if nargin == 1
    unit_structure = varargin{1};
    rejection_num_chans = 3;
    rejection_window = 0.001;
    delete_artifacts = 1;
elseif nargin == 3
    unit_structure = varargin{1};
    rejection_num_chans = varargin{2};
    rejection_window = varargin{3};  % in seconds
    delete_artifacts = varargin{4};
end
    
if isfield(unit_structure,'MetaTags')  %% If coming from an NEVNSx structure
    timestamps = double(unit_structure.Data.Spikes.TimeStamp);
    num_electrodes = length(unique(unit_structure.Data.Spikes.Electrode));
elseif isfield(unit_structure,'units')  %% If coming from a bdf structure
    [timestamps,sort_order] = sort([unit_structure.units.ts]);
    timestamps = round(timestamps*30000);
    unit_index = [];
    units = [];
    for iUnit = 1:size(unit_structure.units,2)
        unit_index = [unit_index repmat(iUnit,1,length(unit_structure.units(iUnit).ts))];
    end
    unit_index = unit_index(sort_order);
    num_electrodes = length(unit_structure.units);
else
    warning('No units found in structure')
    return
end

rejection_samples = rejection_window*30000;

artifacts = [];
actual_spikes = [];
tic
if ~isempty(timestamps)
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
    disp(['Removed ' num2str(length(artifacts)) ' artifacts, found ' num2str(length(actual_spikes))...
        ' actual spikes in ' num2str(toc) ' seconds.'])

    if isfield(unit_structure,'MetaTags')  %% If coming from an unit_structureNSx structure    
        if delete_artifacts
            unit_structure.Data.Spikes.TimeStamp = unit_structure.Data.Spikes.TimeStamp(actual_spikes);
            unit_structure.Data.Spikes.Electrode = unit_structure.Data.Spikes.Electrode(actual_spikes);
            unit_structure.Data.Spikes.Unit = unit_structure.Data.Spikes.Unit(actual_spikes);
            unit_structure.Data.Spikes.Waveform = unit_structure.Data.Spikes.Waveform(:,actual_spikes);
        else
            unit_structure.Data.Spikes.Unit(artifacts) = 99;
        end
    else                                    %% If coming from a unit_structure structure
        for iUnit = 1:size(unit_structure.units,2)
            unit_structure.units(iUnit).ts = timestamps(intersect(actual_spikes,find(unit_index == iUnit)))/30000;            
        end
        if ~delete_artifacts
            for iUnit = 1:size(unit_structure.units,2)
                if ~isempty(intersect(artifacts,find(unit_index == iUnit)))
                    unit_structure.units(end+1).id = [unit_structure.units(iUnit).id(1) 99];
                    unit_structure.units(end).ts = timestamps(intersect(artifacts,find(unit_index == iUnit)))/30000;
                end
            end
        end
    end
end