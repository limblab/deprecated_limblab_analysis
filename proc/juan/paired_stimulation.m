%
% Function to deliver paired intracortical-muscular stimuli
%
%


function paired_stimulation( varargin )



% read parameters

if nargin > 1
    
    disp('ERROR: The function only takes one argument of type paired_stim_params');
    return;
elseif nargin == 1
   
    paired_stim_params      = varargin{1};
elseif nargin == 0
    
    paired_stim_params      = paired_stimulation_default();
end



%--------------------------------------------------------------------------
%% connect with Central 

% connect to central; if connection fails, return error message and quit
if ~cbmex('open', 1)
    
    echoudp('off');
%    close(handles.keep_running);
    error('ERROR: Connection to Central Failed');
end


% if want to save the data...
% Note: structure 'hw' will have all the cerebus and grapevine stuff
if paired_stim_params.save_data_yn
    
    % create file name
    hw.data_dir             = [paired_stim_params.data_dir filesep 'paired_stim_data_' datestr(now,'yyyy_mm_dd')];
    if ~isdir(hw.data_dir)
        mkdir(hw.data_dir)
    end
    hw.start_t              = datestr(now,'yyyymmdd_HHMMSS');
    hw.cb.full_file_name    = fullfile( hw.data_dir, [paired_stim_params.monkey '_' hw.start_t '_paired_stim' ]);
    
    % start 'file storage' app, or stop ongoing recordings
    cbmex('fileconfig', fullfile( hw.data_dir, hw.cb.full_file_name ), '', 0 );  
    drawnow;                        % wait till the app opens
    pause(1);                       % without this pause it doesn't work sometimes...
    drawnow;                        % wait some more to be sure. If app was closed, it did not always start recording otherwise

    % start cerebus file recording
    cbmex('fileconfig', hw.cb.full_file_name, '', 1);
    hw.cb.sys_time          = cbmex('time');     % ToDo: what for?
end




% flush central's buffer - ToDo: Why?????
cbmex('trialconfig', 1);
drawnow;

pause(1);                       % ToDo: see if it's necessary


% Figure out how many force channels there are, and preallocate matrices accordingly
if paired_stim_params.record_force_yn

    [ts_cell_array, ~, analog_data] = cbmex('trialdata',1);

    analog_data(:,1)        = ts_cell_array([analog_data{:,1}]',1); % replace channel numbers with names

    force.data              = analog_data( strncmp(analog_data(:,1), 'Force', 5), 3 );
    clear analog_data ts_cell_array;

    [force.nbr_forces, ~]   = size(force.data);
    disp(['Nbr Force sensors: ' num2str(force.nbr_forces)]), disp(' ');
    force.evoked_force      = zeros( ( abs(paired_stim_params.pre_stim_win) + paired_stim_params.post_stim_win ) * 2000/1000, paired_stim_params.nbr_stimuli, force.nbr_forces ); % ToDo: replace by read Force sampling freq    
end



%--------------------------------------------------------------------------
%% connect with Grapevine

% initialize xippmex
hw.gv.connection            = xippmex;

% if the connection fails, return error message and quite
if hw.gv.connection ~= 1
    error('ERROR: Xippmex did not initialize');
end

% find all Micro+Stim channels (stimulation electrodes)
hw.gv.stim_ch               = xippmex('elec','stim');

if isempty(hw.gv.stim_ch)
    error('ERROR: no stimulator found!');
end


%--------------------------------------------------------------------------
%% stimulate to get the curves!


% figure to plot the evoked force because of the paired stimulation
p_s_fig                     = struct(...
    'h',                        figure, ...
    't',                        paired_stim_params.pre_stim_win:1000/2000:paired_stim_params.post_stim_win);
%     'colors_plot',              colormap(autumn(length(hw.gv.stim_amps))),...
%     'colors_plot_2',            colormap(winter(length(hw.gv.stim_amps))));

set(p_s_fig.h, 'Name', 'Evoked Force - Close this figure to stop');


drawnow;



for i = 1:paired_stim_params.nbr_stimuli
        
    %------------------------------------------------------------------
    % Define the stimulation string for the pair of channes. Note that the
    % sign of 'paired_stim_params.ISI' defines which stimulus has to be
    % applied first
    
    
end

