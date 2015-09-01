
function neural_activity = split_and_analyze_data( file_names, folder_name, win_duration, chosen_neurons )


if iscell(file_names)
    nbr_files           = numel(file_names);
else
    nbr_files           = 1;
end

if isempty(chosen_neurons)
    chosen_neurons      = 1:96;
end


epoch_ctr               = 1;

for i = 1:nbr_files

    % ---------------------------------------------------------------------
    % load the binned data, or bin the data
    if nbr_files == 1
       
        nev_file_name   = file_names;
    else
        nev_file_name   = file_names{i};
    end
    
    % check if there is a file with the binned data, otherwise bin it
    cur_dir_files       = dir;
    bin_file_name       = [nev_file_name(1:end-8) '_bin.mat'];
        
    if ~isempty( find( arrayfun( @(x) strncmp( x.name, bin_file_name, length(file_names) ), cur_dir_files ) , 1) )
        load( bin_file_name );
        binned_data = binnedData; clear binnedData;
    else
        
        binned_data = convert2BDF2Binned( [folder_name filesep file_names] );
    end
    
    % 'chop' the neural data to the chosen neurons
    binned_data.neuronIDs   = binned_data.neuronIDs(chosen_neurons,:);
    binned_data.spikeratedata   = binned_data.spikeratedata(:,chosen_neurons);
    
    
    % ---------------------------------------------------------------------
    % The calculations themselves
    
    
    % Calculate the bin length (in s)
    bin_length          = mean(diff(binned_data.timeframe));
    nbr_bins_per_win    = win_duration/bin_length;
    
    
    % 1. Split the trial in windows of specified win_duration
    
    nbr_win_this_trial  = floor( binned_data.meta.duration / win_duration );
    
    
    % 2. Calculate the mean firing rate for the specified neurons each window,
    
    for ii = 1:nbr_win_this_trial
        first_sample    = (ii-1)*nbr_bins_per_win + 1;
        last_sample     = ii*nbr_bins_per_win;

        neural_activity.mean_firing_rate(epoch_ctr,:) = mean( binned_data.spikeratedata(first_sample:last_sample,:) );
        neural_activity.std_firing_rate(epoch_ctr,:)  = std( binned_data.spikeratedata(first_sample:last_sample,:) );
        
        epoch_ctr       = epoch_ctr + 1;
    end
end


end