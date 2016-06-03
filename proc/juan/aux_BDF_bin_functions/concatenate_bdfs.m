%
% Concatenate an array of BDFs into a single BDF. This version assumes 1)
% no sorted neurons, 2) that all the fields are the same, 3) will not store
% the raw data, and 4) will not store the waveforms of the threshold
% crossings
%
%   function conc_bdf = concatenate_bdfs( bdf_array )
%
% Input:
%   bdf_array               : array of BDFs
%
% Output:
%   conc_bdf                : concatenated BDF. It has an additional field
%                               with file_start_t
%
% Note: the function assumes EMGs were recorded. Also, it only merges the
% filename, duration and FileSepTimes of meta
%
% ----------
% NOTE: THE FUNCTION MAY NEED SOME IMPROVEMENTS IN HOW THE EMG, FORCE AND
% POSITION TIME VECTORS ARE CONSTRUCTED
%

function conc_bdf = concatenate_bdfs( bdf_array ) 

nbr_bdfs                = length(bdf_array);
% tmeporary fix because there are useless channels that appear in units in
% some of Steph's generalizbility datasets
max_nbr_units           = 96;
% sampling frequency threshold crossings
fs_units                = 30000;

% ------------------------------------------------------------------------
% 1. retrieve the end times of each bdf

% since it may be different between data streams (because of the different
% sampling frequencies), take the minimum ...
bdf_end_times           = zeros(1,nbr_bdfs);
for i = 1:nbr_bdfs
    bdf_end_times(i)    = min([bdf_array(i).pos(end,1), bdf_array(i).emg.data(end,1), ...
                            bdf_array(i).force.data(end,1)]);
end

% ... and round it to the minimum common duration that is multiple of the
% slowest sampling rate between force and EMG

% --> NOTE: This version ignores position since oftentimes they are missed
% points in our datafiles

min_fs                  = min([bdf_array(1).emg.emgfreq, bdf_array(1).force.forcefreq]);
% but before that crop the extra microseconds that make bdf_end_times and
% exact multiple of the slowest fs
extra_bdf_time          = arrayfun(@(x) rem(x,1/min_fs), bdf_end_times );
bdf_end_times           = bdf_end_times - extra_bdf_time;
% now make all the bdf_end_times equal to the duration of the shortest file
bdf_end_times           = min(bdf_end_times)*ones(1,nbr_bdfs);

% ------------------------------------------------------------------------
% 2. check that the number of neurons, forces, emgs and pos is the same
% across BDFs 

% check that all the BDFs have the same number of "good" neural channels
nbr_units               = arrayfun(@(x)size(x.units,2),bdf_array);

if length(unique(nbr_units)) > 1
    % some of the BDFs from Steph's generalizbility experiment have more
    % neural channels than they should (with the extra ones being weird
    % artefacts). If that happens, get rid of them
    bdfs_extra_neurons = find(nbr_units>96);
    if ~isempty(bdfs_extra_neurons)
        warning('there are more neural channels than there should');
        % get rid of the additional useless neural channels
        for i = 1:length(bdfs_extra_neurons)
            bdf_array(bdfs_extra_neurons(i)).units(max_nbr_units+1:end) = [];
        end
    else
        error('the numnber of neural channels is different across BDFs');
    end
end

% check that all the BDFs have the same number of EMGs
nbr_emgs                = arrayfun(@(x)length(x.emg.emgnames),bdf_array);
if length(unique(nbr_emgs)) > 1
    error('the numnber of EMGs is different across BDFs');
end
% check that all the EMGs have the same labels
for i = 1:nbr_bdfs-1
    if ~isempty( find(strncmp(bdf_array(i).emg.emgnames,bdf_array(i+1).emg.emgnames,7)==0,1) )
        error(['EMG labels are not the same across BDFs ' num2str(i) ' and ' num2str(i+1)])
    end
end

% check that all the BDFs have the same number of forces
nbr_forces              = arrayfun(@(x)length(x.force.labels),bdf_array);
if length(unique(nbr_forces)) > 1
    error('the numnber of forces is different across BDFs');
end
% check that all the forces have the same labels
for i = 1:nbr_bdfs-1
    if ~isempty( find(strncmp(bdf_array(i).force.labels,bdf_array(i+1).force.labels,7)==0,1) )
        error(['EMG labels are not the same across BDFs ' num2str(i) ' and ' num2str(i+1)])
    end
end

% check that all the BDFs have the same number of positions
nbr_poss                = arrayfun(@(x)size(x.pos,2)-1,bdf_array);
if length(unique(nbr_poss)) > 1
    error('the numnber of position variables is different across BDFs');
end

% clear some variables that won't be used anymore
clear nbr_poss nbr_forces nbr_emgs bdfs_extra_neurons
% update nbr of units after chopping, if necessary
nbr_units               = unique(arrayfun(@(x)size(x.units,2),bdf_array));


% ------------------------------------------------------------------------
% 3. concatenate

% define the fields that are not repeated
for i = 1:nbr_units
    conc_bdf.units(i).id = bdf_array(1).units(i).id;
end

conc_bdf.emg.emgnames   = bdf_array(1).emg.emgnames;
conc_bdf.emg.emgfreq    = bdf_array(1).emg.emgfreq;

conc_bdf.force.labels   = bdf_array(1).force.labels;
conc_bdf.force.forcefreq = bdf_array(1).force.forcefreq;

% preallocate some matrices
conc_bdf.words          = [];
conc_bdf.databursts     = {};
conc_bdf.emg.data       = [];
conc_bdf.force.data     = [];
conc_bdf.pos            = [];
conc_bdf.targets.corners = [];
conc_bdf.targets.rotation = [];
conc_bdf.good_kin_data  = [];
for i = 1:nbr_units
    conc_bdf.units(i).ts = [];
    conc_bdf.units(i).waveforms = [];
end


% "trim" the force, emgs, pos matrices if necessary
for i = 1:nbr_bdfs
    % emgs
    emg_to_chop_indx    = find(bdf_array(i).emg.data(:,1) > bdf_end_times(i),1);
    if ~isempty( emg_to_chop_indx )
        bdf_array(i).emg.data(emg_to_chop_indx:end,:) = [];
        warning(['chopping end of EMG data in BDF(' num2str(i) ')'])
    end
    % forces
    forces_to_chop_indx  = find(bdf_array(i).force.data(:,1) > bdf_end_times(i),1);
    if ~isempty( forces_to_chop_indx )
        bdf_array(i).force.data(forces_to_chop_indx:end,:) = [];
        warning(['chopping end of force data in BDF(' num2str(i) ')'])
    end
    % pos
    poss_to_chop_indx    = find(bdf_array(i).pos(:,1) > bdf_end_times(i),1);
    if ~isempty( poss_to_chop_indx )
        bdf_array(i).pos(poss_to_chop_indx:end,:) = [];
        warning(['chopping end of pos data in BDF(' num2str(i) ')'])
    end
    % units
    for ii = 1:length(bdf_array(i).units)
        units_to_chop_indx = find(bdf_array(i).units(ii).ts > bdf_end_times(i),1);
        if ~isempty(units_to_chop_indx)
            bdf_array(i).units(ii).ts(units_to_chop_indx:end) = [];
            bdf_array(i).units(ii).waveforms(units_to_chop_indx:end,:) = [];
            warning(['chopping end of threshold crossings in in neuron ' num2str(ii) ...
                ' of BDF(' num2str(i) ')'])
        end
    end
    clear emg_to_chop_indx forces_to_chop_indx poss_to_chop_indx units_to_chop_indx;
end


% add the end time of the previous BDF to the time vector of the next
for i = 2:nbr_bdfs
   
    bdf_array(i).emg.data(:,1) = bdf_array(i).emg.data(:,1) + sum(bdf_end_times(1:i-1)) + ...
                                    1/conc_bdf.emg.emgfreq;
    bdf_array(i).force.data(:,1) = bdf_array(i).force.data(:,1) + sum(bdf_end_times(1:i-1)) + ...
                                    1/conc_bdf.force.forcefreq;
    bdf_array(i).pos(:,1) = bdf_array(i).pos(:,1) + sum(bdf_end_times(1:i-1)) + ...
                                    mean(diff(bdf_array(1).pos(:,1)));
	for ii = 1:nbr_units
        bdf_array(i).units(ii).ts = bdf_array(i).units(ii).ts + sum(bdf_end_times(1:i-1)) + ...
                                    1/fs_units;
    end
end


% append fields
for i = 1:nbr_bdfs
    
    % the meta fields will just be merged into a single struct
    if i == 1
        conc_bdf.meta           = bdf_array(1).meta;
        conc_bdf.meta.filename  = bdf_array(i).meta.filename;
        conc_bdf.meta.duration  = sum(bdf_end_times);
        conc_bdf.meta.bdf_info  = ['merged with concatenate_bdfs on ' datestr(now,1)];
        conc_bdf.meta.FileSepTime = []; % to get rid of whatever was there
        conc_bdf.meta.FileSepTime(1) = 0;
    else
        conc_bdf.meta.filename  = [conc_bdf.meta.filename ' ' bdf_array(i).meta.filename];
        conc_bdf.meta.FileSepTime(i) = sum(arrayfun(@(x)x.meta.duration,bdf_array(1:i-1))) + 1/fs_units;
    end
    
    % concatenate units
    for ii = 1:nbr_units
        conc_bdf.units(ii).ts = [conc_bdf.units(ii).ts; bdf_array(i).units(ii).ts];
        conc_bdf.units(ii).waveforms = [conc_bdf.units(ii).waveforms; bdf_array(i).units(ii).waveforms];
    end
    
    % EMG
    conc_bdf.emg.data   = [conc_bdf.emg.data; bdf_array(i).emg.data];
    
    % concatenate forces
    conc_bdf.force.data = [conc_bdf.force.data; bdf_array(i).force.data];
    
    % concatenate positions
    conc_bdf.pos        = [conc_bdf.pos; bdf_array(i).pos];
    
    % concatenate words
    conc_bdf.words      = [conc_bdf.words; bdf_array(i).words];
    
    % concatenate databursts
    conc_bdf.databursts = [conc_bdf.databursts; bdf_array(i).databursts];
    
    % concatenate targets
    conc_bdf.targets.corners    = [conc_bdf.targets.corners; bdf_array(i).targets.corners];
    conc_bdf.targets.rotation   = [conc_bdf.targets.rotation; bdf_array(i).targets.rotation];
    
    % concatenate good_kin_data
    conc_bdf.good_kin_data = [conc_bdf.good_kin_data; bdf_array(i).good_kin_data];
    
end

% add raw field
raw_field_names         = fieldnames(bdf_array(1).raw);
for i = 1:length(raw_field_names)
    conc_bdf.raw.(raw_field_names{i}) = [];
end

% reorder the fields as in an original BDFs
conc_bdf                = orderfields(conc_bdf,[9 1 10 2 3 4 5 6 7 8]);
