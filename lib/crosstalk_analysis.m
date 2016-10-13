function varargout = crosstalk_analysis(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assesses all channels/units of array for crosstalk with other channels/units.
%
% Pass in BDF to run crosstalk analysis. If you have a crosstalk matrix
% from a previous call to this function, pass that instead of a BDF as the
% first input to call the built-in plotting routines and skip analysis.
%
% Will do some plotting if you provide ...'do_plots',true... as input.
%    1) Histogram of all electrode-to-electrode comparisons
%    2) Heat map of all electrode-to-electrode pairs
%    3) Max crosstalk value for each electrode plotted on array map layout
%    4) Visualization of shunted electrode groups plotted on array layout
%           (3 and 4 require path to array map file as input. See below)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS:
%   1) If using for analysis
%           bdf          : (struct) lab standard BDF
%      If using for plotting only:
%           crosstalk    : (array) crosstalk output for a metric from a
%                               previous call to this function. Can be the
%                               standard or alternate format.
%   2) which_method : (string or cell array) which method to use, cell has multiple
%           'spike'     : looks at spike coincidence (default)
%           'coherence' : looks at high frequency coherence in LFP
%   3+) varargin : any parameter with format ...'parameter',value...)
%           See default parameters section below to see parameters and
%     descriptions for what can be modified.
%
% OUTPUTS:
%   1) crosstalk      : (array) NxN, where N is number of electrodes
%                         Each entry has crosstalk value for the row/col pair
%   2) crstlk_alt     : (array) Alternate format of data
%                         Each row is [ unit1, unit2, crosstalk value ]
%   3) shunted_groups : (cell array) each element contains IDs for channels
%                         that are shunted together
%   4) params         : (struct) Nice packaged struct with analysis parameters
%                         in case anyone wants to save the results
%
%   If doing multiple, crosstalk will be a cell array, with an entry for each
%       metric's individual results. However, crstlk_alt will simply add
%       columns corresponding to each metric.
%       So: if which_method = {'spike','coherence'}, [ unit1, unit2, spike value, coherence value]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXAMPLES:
%   1) Look at spike coincidence to determine crosstalk among all units in BDF
%           crosstalk = crosstalk_analysis(bdf);
%   2) Run coherence analysis instead of spike coincidence, and get alternate data representation
%           [crosstalk, crstlk_alt] = crosstalk_analysis(bdf, 'coherence');
%   3) Run both types with parallel computing to decrease time, and plot results
%           crosstalk = crosstalk_analysis(bdf,'all','do_parallel',true,'do_plots',true);
%   4) Make plots for data from a previous call to this function
%           crosstalk_analysis(crosstalk,'spike','cmp_file',cmp_file_path);
%   5) Convert existing standard results from each metric into alt list representation of both
%           [~, crstlk_alt] = crosstalk_analysis( {crosstalk_spike,crosstalk_coh},'all','do_plots',false);
%   6) Look at groups of shunted electrodes, and return parameters
%           [crosstalk, ~, shunted_groups, params] = crosstalk_analysis(bdf);
%
% NOTES:
%   - These analyses can sometimes be very slow. For coherence, I chose coarse parameters
%       and only look at the first minute of the datafile, which decreased computation
%       time by several orders of magnitude. For this purpose, there is no real benefit
%       to looking at more data, or using smaller window sizes or more overlap.
%   - Coherence here refers to magnitude, so it's symmetric. Thus, the lower
%       half of the crosstalk matrix output is zero for this metric.
%
% TO DO:
%   - Have a basic interpretation function that labels suspected shunted
%   channels or groups of channels. e.g. will say "these 3 channels all
%   have high crosstalk values with each other"
%   - Allow for selection of unsorted/sorted spikes, or to collapse all
%   sorted units on a channel into a single unsorted group
%   - Allow for coherence analysis on LFP data, instead of just binned
%   spike trains
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Written by Matt Perich, February 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_metrics = {'spike','coherence'}; % list of currently implemented metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function and analysis parameters
do_parallel      = false;    % (bool) whether or not to distribute across cores
use_sort         = false;    % (bool) if true, keeps sorted units. If false, makes all unsorted
do_plots         = false;    % (bool) whether to make plots (later defaults to false)
cmp_file         = [];       % (string) full file path to .cmp file for array layout plot.
% NOTE: If cmp_file is empty, does not make the array plot
bin_size         = 0.001;    % size of time bins in sec
coh_time         = 60;       % how much of the datafile to use for coherence (in sec)
coh_win          = 4096;     % window size for coherence in number of samples
coh_overlap      = 0;        % amount of overlap in number of samples
coh_nfft         = coh_win;  % nfft sample size
coh_freq         = 30;       % look for mean coherence above this frequency (Hz)
spike_thresh     = 30;       % threshold for "shunting" for spike (% spikes)
coherence_thresh = 0.2;      % threshold for "shunting" for coherence (0 to 1)

% Plotting parameters. Can be overwritten, but are not returned in params
figure_position  = [100 100 800 600]; % figure positioning
font_size        = 14;                % font size for all text and labels
hist_bins        = 1000;              % number of bins for histogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do some basic checks and set up main inputs
clc;
if nargout > 4
    error('Too many outputs requested.');
end
if ~isstruct(varargin{1}) % plots only
    bdf = []; % a flag to skip the later analysis
    
    crosstalk = varargin{1};
    % check if it's the alternate format. If so, convert to standard
    %   alternate form should never be a cell, because it adds columns
    if ~iscell(crosstalk) && size(crosstalk,1) ~= size(crosstalk,2)
        new_crosstalk = cell(1,size(crosstalk,2)-2);
        for idx = 3:size(crosstalk,2)
            temp = zeros(max(crosstalk(:,1:2)));
            for i = 1:size(crosstalk,1)
                temp(crosstalk(i,1),crosstalk(i,2)) = crosstalk(i,idx);
            end
            new_crosstalk{idx-2} = temp;
        end
        crosstalk = new_crosstalk; clear new_crosstalk temp;
    end
    if ~iscell(crosstalk) % package as cell for use in loops later
        crosstalk = {crosstalk};
    end
    
    if nargin >= 2
        which_method = varargin{2};
    else
        which_method = {'noneprovided'};
    end
    if ~iscell(which_method)
        which_method = {which_method};
    end
    % check that it's a valid method
    if ~any(ismember(lower(which_method),all_metrics))
        error('Must provide proper metric name as second input (''spike'' and/or ''coherence'')...');
    end
    
    do_plots = true; % change default to true, but can override later.
else % do all analysis
    bdf = varargin{1};
    if ~isfield(bdf,'pos') % check that it's really a BDF
        if isfield(bdf,'emg')
            warning('BDF does not have a position field, will use EMG field instead');
        else
            error('BDF does not have a position or EMG field');
        end
    end
    which_method = [];
    if length(varargin) > 1 % if second input is provided
        which_method = varargin{2};
    end
    % set default if none provided
    if isempty(which_method)
        which_method = {'spike'};
    end
    if ~iscell(which_method)
        which_method = {which_method};
    end
    % check that it's a valid method
    if ~any(ismember(lower(which_method),all_metrics))
        error('Must provide proper metric name as second input (''spike'' and/or ''coherence'')...');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign varargin
for i = 3:2:length(varargin)
    if exist(varargin{i},'var')
        % assignin applies to workspace calling the current function, so
        % this hack creates a fake subfunction so we can modify this workspace
        feval(@()assignin('caller',varargin{i},varargin{i+1}));
    else
        warning(['WARNING: variable ' varargin{i} ' not recognized. Ignoring.']);
    end
end
clear varargin;

params.which_method = which_method;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check to see if it's plotting only
if ~isempty(bdf)
    tic;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get some info
    if use_sort
        N = length(bdf.units);  % number of neurons
    else
        elec_ids = unique(cellfun(@(x) x(1),{bdf.units.id}));
        N = length(elec_ids);
    end
    if isfield(bdf,'pos')
        t_start = bdf.pos(1,1);
        t_end = bdf.pos(end,1); % length of file
    elseif isfield(bdf,'emg') % if there's no pos field
        t_start = bdf.emg.data(1,1);
        t_end = bdf.emg.data(end,1); % length of file
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check to ensure the matlab pool is open if parallel is desired
    if do_parallel
        disp('Parallel mode: ENABLED!');
        parfor_arg = Inf;
    else
        parfor_arg = 0; % turns off multiple workers for parfor loop
    end
    if do_parallel && isempty(gcp('nocreate'))
        disp('Matlab pool not found. Opening pool...');
        parpool;
    end
    
    t_bins = t_start:bin_size:t_end;
    % check to ensure the requested time isn't longer than the file
    if t_bins(end) < coh_time
        % pos starts at 1 second, so subtract 1
        coh_time = t_bins(end)-1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % bin all data in bin_size bins
    disp(['Binning data in ' num2str(round(1000*bin_size)) ' msec bins...']);
    tic;
    bs = zeros(N,length(t_bins)-1);
    for u = 1:N
        if ~use_sort % pool all spikes from each electrode
            idx = find(cellfun(@(x) x(1) == elec_ids(u),{bdf.units.id}));
            ts = bdf.units(idx(1)).ts;
            for i = 2:length(idx)
                ts = [ts; bdf.units(idx(i)).ts];
            end
        else % just use each sorted unit's spikes
            ts = bdf.units(u).ts;
        end
        ts = ts(ts >= t_start & ts <= t_end);
        bs(u,:) = histcounts(ts,t_bins);
    end
    clear bdf ts;
    toc;
    
    crosstalk = cell(1,length(which_method));
    for idx = 1:length(which_method)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Calculate crosstalk based on the metric
        result = zeros(N);
        % to save memory, only copy what you need
        bs = bs(:,1:coh_time*round(1/bin_size));
        switch lower(which_method{idx})
            case 'spike'
                disp('Computing spike coincidence...');
                % loop along neuron comparisons
                for u1 = 1:N
                    parfor (u2 = 1:N, parfor_arg)
                        if u1 ~= u2
                            % find coincident spikes, allowing +/- 1 bin (msec by default)
                            num_coincident = sum( ((bs(u1,:)+bs(u2,:)) > 1));
                            % as a percentage
                            result(u1,u2) = 100 * num_coincident / sum(bs(u1,:));
                        end
                    end
                end
                
            case 'coherence'
                disp('Computing coherence...');
                % loop along neuron comparisons
                for u1 = 1:N
                    parfor (u2 = u1:N, parfor_arg)
                        if u1 ~= u2
                            [c,f]  = mscohere(bs(u1,1:coh_time*round(1/bin_size)),bs(u2,1:coh_time*round(1/bin_size)),hanning(coh_win),coh_overlap,coh_nfft,1/bin_size);
                            % as a percentage
                            result(u1,u2) = mean(c(f > coh_freq));
                        end
                    end
                end
                % coherence is symmetrical, so we skipped the bottom
                % half of the array to save computing time. Thus,
                % duplicate the values here.
                result = result + rot90(flip(result,1),-1);
            otherwise
                error('Error during analysis: method not recognized.');
        end
        crosstalk{idx} = result;
    end

    % package up some parameters just in case someone wants them
    params.use_sort = use_sort;
    params.bin_size = bin_size;
    if any(strcmpi('coherence',which_method))
        params.coh_time = coh_time;
        params.coh_win = coh_win;
        params.coh_overlap = coh_overlap;
        params.coh_nfft = coh_nfft;
        params.coh_freq = coh_freq;
    end
    toc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create alternate data representation
N = size(crosstalk{1},1);
crstlk_alt = zeros(numel(crosstalk{1})-N,2+length(crosstalk));
count = 0;
for u1 = 1:N
    for u2 = 1:N
        if u1 ~= u2
            count = count + 1;
            crstlk_alt(count,1) = u1;
            crstlk_alt(count,2) = u2;
            for idx = 1:length(crosstalk)
                crstlk_alt(count,idx+2) = crosstalk{idx}(u1,u2);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Look for groups of shunted channels
shunted_groups = cell(1,length(which_method));
for idx = 1:length(which_method)
    eval(['thresh = ' which_method{idx} '_thresh;']);
    above_thresh = crosstalk{idx} > thresh;
    shunted = above_thresh & rot90(flip(above_thresh,1),-1);
    
    % get list of all units that are bidirectionally shunted with this one
    shunt_list = cell(1,size(shunted,1));
    for u = 1:size(shunted,1)
        shunt_list{u} = find(shunted(u,:));
    end
    
    % Dynamically build a list of channels that are shunted with any others
    %   Bad coding practice? Sure. Effective? Definitely.
    ignore_chans = [];
    chans = cell(1,size(shunted,1));
    for u = 1:size(shunted,1)
        if ~any(ismember(u,ignore_chans))
            % find all channels that are shunted with the current channel and
            % make a master list
            matches = find(cellfun(@(x) any(x==u),shunt_list));
            if ~isempty(matches)
                temp = shunt_list{u};
                for i = 1:length(matches)
                    temp = [temp, shunt_list{matches(i)}];
                end
                
                chans{u} = unique(temp);
                ignore_chans = [ignore_chans, unique(temp)];
            end
        end
    end
    shunted_groups{idx} = chans(~cellfun(@isempty,chans));
    params.([which_method{idx} '_thresh']) = thresh;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a bunch of plots
if do_plots
    for idx = 1:length(which_method)
        switch lower(which_method{idx})
            case 'spike'
                plot_title = 'Spike Coincidence (Max % of Spikes)';
                plot_label = 'Percent of Coincident Spikes';
                clim = [0 100];
            case 'coherence'
                plot_title = 'High-Freq Coherence (Max ||Coherence||)';
                plot_label = 'High-Frequency Coherence';
                clim = [0 1];
            otherwise
                error('Error during plotting: method not recognized');
        end
        
        % Plot histogram of all electrode-to-electrode comparisons
        figure('Position',figure_position);
        hist(crstlk_alt(:,2+idx),clim(1):diff(clim)/hist_bins:clim(2));
        set(gca,'Box','off','TickDir','out','FontSize',font_size,'XLim',clim);
        xlabel(plot_label,'FontSize',font_size);
        ylabel('Count','FontSize',font_size);
        
        % Plot heatmap of unit-to-unit comparisons
        figure('Position',figure_position);
        imagesc(crosstalk{idx},clim);
        axis('square');
        colorbar;
        set(gca,'Box','off','TickDir','out','FontSize',font_size);
        title(plot_label,'FontSize',font_size);
        xlabel('Reference Unit ID','FontSize',font_size);
        ylabel('Test Unit ID','FontSize',font_size);
        
        % If desired, plot array view like Blackrock's
        %   Color represents maximum crosstalk of that electrode across all pairs
        if ~isempty(cmp_file) && ~use_sort % doesn't currently support sorted units
            cmp = read_cmp(cmp_file);
            [~,cmp_name,~] = fileparts(cmp_file);
            array_size = [length(unique([cmp{:,1}])), length(unique([cmp{:,2}]))];
            
            array_data = zeros(array_size(1),array_size(2));
            for i = 1:size(cmp,1)
                array_data(cmp{i,2}+1,cmp{i,1}+1) = max(crosstalk{idx}(cmp{i,3},:));
            end
            
            figure('Position',figure_position);
            imagesc(array_data,clim);
            axis square;
            colorbar;
            set(gca,'Box','off','TickDir','out','FontSize',font_size,'YDir','normal');
            title(plot_title,'FontSize',font_size);
            xlabel(cmp_name,'FontSize',font_size);
            
            % plot shunted groups
            chans = [cmp{:,3}];
            array_data = zeros(array_size(1),array_size(2));
            for i = 1:length(shunted_groups{idx})
                g = shunted_groups{idx}{i};
                for j = 1:length(g)
                    k = chans == g(j);
                    array_data(cmp{k,2}+1,cmp{k,1}+1) = i;
                end
            end
            
            figure('Position',figure_position);
            imagesc(array_data,[0,length(shunted_groups{idx})]);
            axis square;
            set(gca,'Box','off','TickDir','out','FontSize',font_size,'YDir','normal');
            title([which_method{idx} ': shunted groups; thresh = ' num2str(eval([which_method{idx} '_thresh']))],'FontSize',font_size);
            xlabel(cmp_name,'FontSize',font_size);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Package up outputs

% doesn't need to be cell if it's just one metric
if length(crosstalk) == 1
    crosstalk = crosstalk{1};
end
if length(shunted_groups) == 1
    shunted_groups = shunted_groups{1};
end

varargout{1} = crosstalk;
varargout{2} = crstlk_alt;
varargout{3} = shunted_groups;
varargout{4} = params;

