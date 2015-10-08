% Function that takes a series of neural data files, splits them in
% windows, and calculates a series of statistic of the firing rates.
% Behavior data (cursor position, EMG, or "words") can be used to discard
% bins of neural data. 
%
%   function [neural_activity, binned_data] = split_and_analyze_data( file_names, ...
%                                               folder_name, sad_params )
%
% Input parameters:
% 'file_names'      : struct with the name of the nev files to analyze
% 'folder_name'     : path to the files
% 'sad_params'      : struct with parameters and options for the analysis
%                       (see split_and_analyze_data_defaults.m)
% Outputs:
% 'neural_activity' : statistics of the firing rate
% 'binned_data'     : the binned data used for the computation of the
%                       statistics, processed according to sad_params

% ToDo: see what to do with the words


function [neural_activity, binned_data] = split_and_analyze_data( file_names, folder_name, sad_params )


if iscell(file_names)
    nbr_files           = numel(file_names);
else
    nbr_files           = 1;
end

% if isempty(chosen_neurons)
%     chosen_neurons      = 1:96;
% end


epoch_ctr               = 1;

for i = 1:nbr_files

    % ---------------------------------------------------------------------
    % load the binned data, or bin the data
    if nbr_files == 1
        if strcmp(file_names(end-2:end),'nev')
            my_file.name    = file_names;
            my_file.type    = 'nev';
        else
            my_file.name    = file_names;
            my_file.type    = 'mat';
        end
    else
        if strcmp(file_names{1}(end-2:end),'nev')
            my_file.name    = file_names{i};
            my_file.type    = 'nev';
        else
            my_file.name    = file_names{i};
            my_file.type    = 'mat';
        end
    end
    
    % Load the file. The way to do it, depends on the chosen file type
    switch my_file.type
        case 'mat'
            load(my_file.name);
            binned_data = binnedData; clear binnedData;
        case 'nev'
            % check if there is a file with the binned data, otherwise bin it
            cur_dir_files   = dir;
            bin_file_name   = [my_file.name(1:end-8) '_bin.mat'];

            if ~isempty( find( arrayfun( @(x) strncmp( x.name, bin_file_name, ...
                    length(my_file.name) ), cur_dir_files ) , 1) )
                load( bin_file_name );
                binned_data = binnedData; clear binnedData;
            else
                binned_data = convert2BDF2Binned( [folder_name filesep my_file.name] );
            end
    end
    
    % 'chop' the neural data to the chosen neurons
    binned_data.neuronIDs   = binned_data.neuronIDs(sad_params.chosen_neurons,:);
    binned_data.spikeratedata   = binned_data.spikeratedata(:,sad_params.chosen_neurons);
    
    % 'chop' the LFPs to the chosen channels
    if sad_params.lfp
        BDF.lfp.lfpnames    = BDF.lfp.lfpnames(sad_params.chosen_neurons);
        BDF.lfp.data        = BDF.lfp.data(:,[1 (sad_params.chosen_neurons+1)]);
    end
    
    % ---------------------------------------------------------------------
    % The calculations themselves
    
    
    % Calculate the bin length (in s)
    bin_length          = mean(diff(binned_data.timeframe));
    nbr_bins_per_win    = sad_params.win_duration/bin_length;
    
    
    % 1. If specified, get rid of the bins for which the chosen behavior
    % signal is above the specified threshold
    
    switch sad_params.behavior_data
        case 'none'
            % Include all the neural data in the analysis, disregarding the
            % behavior
        case 'emg'
            % Discard periods of neural data based on the EMG level
            
        case 'pos'
            % rectify the data, if specified in
            % 'sad_params.rectify_behavior'
            if sad_params.rectify_behavior
                binned_data.cursorposbin = abs(binned_data.cursorposbin);
            end
            
            % Discard periods of neural data based on the cursor position
            % (force)
            
            % create a vector with the threshold for each axis
            switch sad_params.thr_statistic
                case 'none'
                    threshold = sad_params.thr_behavior*ones(1,size(binned_data.cursorposbin,2));
                case 'std'
                    threshold = mean(binned_data.cursorposbin)+...
                        sad_params.thr_behavior*std(binned_data.cursorposbin);
            end
            
            % find bins where rectified cursor position is above the
            % threshold
            pos_above_thr = [];
            for ii = 1:size(binned_data.cursorposbin,2)
                pos_above_thr = [pos_above_thr; ...
                    find( abs(binned_data.cursorposbin(:,ii)) > threshold(ii) )]; %#ok<AGROW>
            end
            pos_above_thr = unique(pos_above_thr);
            
        case 'vel'
            % rectify the data, if specified in
            % 'sad_params.rectify_behavior'
            if sad_params.rectify_behavior
                binned_data.velocbin = abs(binned_data.velocbin);
            end
            
            % Discard periods of neural data based on the cursor velocity
            
            % create a vector with the threshold for each axis
            switch sad_params.thr_statistic
                case 'none'
                    threshold = sad_params.thr_behavior*ones(1,size(binned_data.cursorposbin,2));
                case 'std'
                    threshold = mean(binned_data.velocbin)+...
                        sad_params.thr_behavior*std(binned_data.velocbin);
            end
            
            % find bins where rectify cursor velocity is above the
            % threshold
            pos_above_thr = [];
            for ii = 1:size(binned_data.velocbin,2)
                pos_above_thr = [pos_above_thr; ...
                    find( abs(binned_data.velocbin(:,ii)) > threshold(ii) )]; %#ok<AGROW>
            end
            pos_above_thr = unique(pos_above_thr);
            
        case 'word'
            % find time at which the selected word occurs
            word_t = binned_data.words( binned_data.words(:,2) == hex2dec(num2str(sad_params.word_hex)), 1 );
            % and see to what bin it corresponds
            word_bin = round(word_t/bin_length);
            
            % convert the desired window from time to number of bins
            win_word_bins = round(sad_params.win_word/1000/bin_length);
            
            % take the window of data defined in 'sad_params.win_word'
            % ... but before check if some of the windows are outside
            % boundaries
            word_bin( (word_bin+win_word_bins(1) ) < 0 ) = [];
            word_bin( (word_bin+win_word_bins(2) ) > binned_data.timeframe(end)/bin_length ) = [];
            % Warn when two targets are too close (closer than the length
            % of the specified window)
            if ~isempty( word_bin(diff(word_bin)<0) )
                disp('warning: two targets are too close!')
            end
            
            nbr_words = length(word_bin);
            bins_per_word = abs(diff(win_word_bins))+1;
            analysis_windows = zeros(nbr_words,bins_per_word);
            for ii = 1:nbr_words
                analysis_windows(ii,:) = word_bin(ii) + (win_word_bins(1):win_word_bins(2));
            end
            
            % create matrix with pos_above_threshold, to comply with the
            % rest of the code. This matrix will have all the bins that are
            % not in bins_to_analyze
            pos_above_thr = 1:numel(binned_data.timeframe);
            pos_above_thr = pos_above_thr( find(~ismember(pos_above_thr,analysis_windows)) );
            
            
            % Store the firing rate of each neuron during each window...
            
            % retrieve number neural channels
            nbr_neural_ch   = size(binned_data.spikeratedata,2);
            
            % preallocate matrices for storing the data and results
            neural_activity.firing_rate_in_win = cell(nbr_neural_ch,1);
            for ii = 1:nbr_neural_ch
                neural_activity.firing_rate_in_win{ii} = zeros(nbr_words,bins_per_word);
            end
            for ii = 1:nbr_neural_ch
                for iii = 1:nbr_words
                    neural_activity.firing_rate_in_win{ii}(iii,:) = ...
                        binned_data.spikeratedata(analysis_windows(iii,:),ii);
                end
            end
            
            % If analysing LFPs, 'chop' them to the desired analysis
            % windows
            if sad_params.lfp
                
                % find the sample at which each word ends
                word_sample_lfp = arrayfun( @(x) find(BDF.lfp.data(:,1) > x,1), word_t);
                
                % convert the desired window from time to number of samples
                win_word_samples = sad_params.win_word/1000*BDF.lfp.lfpfreq;
                
                % take the window of data defined in 'sad_params.win_word'
                word_sample_lfp( (word_sample_lfp+win_word_samples(1) ) < 0 ) = [];
                word_sample_lfp( (word_sample_lfp+win_word_samples(2) ) > ...
                    BDF.lfp.data(end,1)*BDF.lfp.lfpfreq ) = []; %BDF.lfp.data(end,1)*1000 ) = [];
                
                % return an error if the number of words in the LFPs are
                % different to the spikes
                if nbr_words ~= length(word_sample_lfp)
                    error('inconsistency in LFP and spike windows');
                end
                
                samples_per_word = abs(diff(win_word_samples))+1;
                analysis_windows_lfp = zeros(nbr_words,samples_per_word);
                for ii = 1:nbr_words
                    analysis_windows_lfp(ii,:) = word_sample_lfp(ii) + (win_word_samples(1):win_word_samples(2));
                end
                
                % create matrix with pos_above_threshold_lfp, which will
                % contain all the LFP samples that are not in the windows
                % to analyze
                
                pos_above_thr_lfp = 1:size(BDF.lfp.data,1);
                pos_above_thr_lfp = pos_above_thr_lfp( find(~ismember(pos_above_thr_lfp,analysis_windows_lfp)) );
            end
            
            % store analysis windows
            neural_activity.analysis_windows        = analysis_windows;
    end
    
  
    
    % discard those bins in the relevant variables
    if exist('pos_above_thr','var')
    
        binned_data.timeframe(pos_above_thr)        = [];
        binned_data.cursorposbin(pos_above_thr,:)   = [];
        binned_data.velocbin(pos_above_thr,:)       = [];
        binned_data.accelbin(pos_above_thr,:)       = [];
        binned_data.spikeratedata(pos_above_thr,:)  = [];
        if ~isempty(binned_data.emgdatabin)
            binned_data.emgdatabin(pos_above_thr,:) = [];
        end
        if ~isempty(binned_data.forcedatabin)
            binned_data.forcedatabin(pos_above_thr,:)   = [];
        end
        
        if sad_params.lfp
           BDF.lfp.data(pos_above_thr_lfp,:)        = []; 
        end
    end
    
    % store bin length and the analysis windows
    binned_data.bin_length                          = bin_length;
    
        
    
    % 3. Calculate the mean firing rate for the specified neurons in each
    % window of duration 'sad_params.win_duration'
    
    if strcmp(sad_params.behavior_data,'word')
        % if we are using words we pool all the the trials in this file together
        nbr_win_this_trial  = 1;
    else
        nbr_win_this_trial  = floor( numel(binned_data.timeframe)*bin_length / sad_params.win_duration );
    end
    
    for ii = 1:nbr_win_this_trial
        first_sample    = (ii-1)*nbr_bins_per_win + 1;
        if ~strcmp(sad_params.behavior_data,'word')
            last_sample = ii*nbr_bins_per_win;
        else
            last_sample = size(binned_data.spikeratedata,1);
        end
        
        neural_activity.mean_firing_rate(epoch_ctr,:) = mean( binned_data.spikeratedata(first_sample:last_sample,:) );
        neural_activity.std_firing_rate(epoch_ctr,:)  = std( binned_data.spikeratedata(first_sample:last_sample,:) );
        
        epoch_ctr       = epoch_ctr + 1;
    end
    
    
    % 4. If looking at words, calculate the mean and SD firing rate for
    % each channel across all occurrences of the word
    if strcmp(sad_params.behavior_data,'word')
        
        neural_activity.mean_firing_rate_in_win = zeros(bins_per_word,nbr_neural_ch);
        neural_activity.std_firing_rate_in_win = zeros(bins_per_word,nbr_neural_ch);
        
        for ii = 1:nbr_neural_ch
            neural_activity.mean_firing_rate_in_win(:,ii) = mean(neural_activity.firing_rate_in_win{ii},1);
            neural_activity.std_firing_rate_in_win(:,ii) = std(neural_activity.firing_rate_in_win{ii},1);
        end
        
        % 4b. If want to look at the LFPs, calculate the power spectrum and
        % spectrogram, and the AMPLITUDE STUFFF ??
        if sad_params.lfp
            
            neural_activity.lfp = psd_lfp( BDF.lfp, sad_params.win_word, word_sample_lfp );
            
%            neural_activity.lfp = ampl_lfp( BDF.lfp, sad_params.win_word, word_sample_lfp );
        end
    end
    
    
    % Pool binned_data, to return it
    binned_data_pool(i) = binned_data; %#ok<NASGU>
end


% Rename binned_data variable, to return it
clear binned_data;
binned_data             = binned_data_pool;


% 
% % -------------------------------------------------------------------------
% % Auxiliary plots
% 
% % Find reward time stamps
% reward_ev               = find(binned_data.words(:,2)==32);
%     
% figure,hold on
% plot(binned_data.timeframe,binned_data.cursorposbin)
% yax(1)                  = min(min(binned_data.cursorposbin(10:end,:)));
% yax(2)                  = max(max(binned_data.cursorposbin(10:end,:)));
% ylim(yax), xlim([binned_data.timeframe(1) binned_data.timeframe(end)]);
% plot(binned_data.words(reward_ev,1),repmat(yax,numel(reward_ev),1)')
%     