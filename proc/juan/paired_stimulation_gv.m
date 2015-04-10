%
% Function to deliver paired intracortical-muscular stimuli using Ripple's
% microstimulator for both 
%
%   function paired_stimulation_gv( varargin )
%
%   The input 

% -------------------------------------------------------------------------
% ToDo's:
%   - Force fs is hardcoded, as 2000 Hz



function paired_stimulation_gv( varargin )




% read parameters

if nargin > 1
    
    error('ERROR: The function only takes one argument of type p_s_params');
elseif nargin == 1
   
    p_s_params              = varargin{1};
elseif nargin == 0
    
    p_s_params              = paired_stimulation_default();
end



%--------------------------------------------------------------------------
%% connect with Central 


% Note: structure 'hw' will have all the cerebus and grapevine stuff


% connect to central; if connection fails, return error message and quit
if ~cbmex('open', 1)
    
    echoudp('off');
%    close(handles.keep_running);
    error('ERROR: Connection to Central Failed');
end


% if want to save the data...
if p_s_params.save_data_yn
    
    % create file name
    hw.data_dir             = [p_s_params.data_dir filesep 'paired_stim_data_' datestr(now,'yyyy_mm_dd')];
    if ~isdir(hw.data_dir)
        mkdir(hw.data_dir)
    end
    hw.start_t              = datestr(now,'yyyymmdd_HHMMSS');
    hw.cb.full_file_name    = fullfile( hw.data_dir, [p_s_params.monkey '_' hw.start_t '_paired_stim' ]);
    
    % start 'file storage' app, or stop ongoing recordings
    cbmex('fileconfig', fullfile( hw.data_dir, hw.cb.full_file_name ), '', 0 );  
    drawnow;                % wait till the app opens
    pause(1);               % without this pause it doesn't work some times
    drawnow;                % wait some more to be sure. If app was closed, it did not always start recording otherwise

    % start cerebus file recording
    cbmex('fileconfig', hw.cb.full_file_name, '', 1);
    hw.cb.sys_time          = cbmex('time');     % ToDo: what for?
end



% flush central's buffer        % ToDo: see if it's necessary
cbmex('trialconfig', 1);
drawnow;

pause(1);                       % ToDo: see if it's necessary



% check if there's a sync out signal ('Stim_trig') in Central 
[ts_cell_array, ~, analog_data] = cbmex('trialdata',1);

hw.cb.stim_trig_ch_nbr  =  find(strncmp(ts_cell_array(:,1),'Stim',4));
if isempty(hw.cb.stim_trig_ch_nbr)
    error('ERROR: Sync signal not found in Cerebus. The channel has to be named Stim_trig');
else
    disp('Sync signal found');
    
    % define resistor to record sync pulse
    hw.cb.sync_out_resistor    	= 1000;
end



% Preallocate matrices for recording the foce data in structure 'force'
if p_s_params.record_force_yn

    analog_data(:,1)        = ts_cell_array([analog_data{:,1}]',1); % replace channel numbers with names

    force.labels            = analog_data( strncmp(analog_data(:,1), 'Force', 5), 1 );
    force.nbr_forces        = numel(force.labels); disp(['Nbr Forces: ' num2str(force.nbr_forces)]), disp(' ');
    force.fs                = cell2mat(analog_data(find(strncmp(analog_data(:,1), 'Force', 5),1),2));
    
%    force.data              = analog_data( strncmp(analog_data(:,1), 'Force', 5), 3 );
    clear analog_data ts_cell_array;

%   force.evoked_force      = zeros( ( abs(p_s_params.pre_stim_win) + p_s_params.post_stim_win ) * 2000/1000, p_s_params.nbr_stimuli, force.nbr_forces ); % ToDo: replace by read Force sampling freq    
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
    't',                        p_s_params.pre_stim_win:1000/2000:p_s_params.post_stim_win);
%     'colors_plot',              colormap(autumn(length(hw.gv.stim_amps))),...
%     'colors_plot_2',            colormap(winter(length(hw.gv.stim_amps))));

set(p_s_fig.h, 'Name', 'Evoked Force - Close this figure to stop');
drawnow;


%------------------------------------------------------------------
% Define the stimulation string for the pair of channes. 


% Define the delay for the Cx/muscle stimulation. Remember the sign of
% 'p_s_params.ISI' defines which stimulus has to be applied first 

if p_s_params.ISI < 0
    hw.gv.td_cx             = abs(p_s_params.ISI);
    hw.gv.td_muscle         = 0;
else
    hw.gv.td_cx             = 0;
    hw.gv.td_muscle         = p_s_params.ISI;
end


% If the stim amplitude is greater than what the stimulator can supply,
% return error and quit

if p_s_params.stim_ampl_muscle > 127*p_s_params.stimulator_resolut
   
    error(['the maximum amplitude (in mA) the stimulator can deliver is ' num2str(127*p_s_params.stimulator_resolut)]);
    cbmex('close');
end


% The actual stimulation string. Some notes: * the polarity of the ICMS is
% always cathodic first; * the sync pulse has maximum amplitude; the other
% parameters (except for the number of stimuli) are the same as for ICMS; *
% the sync pulse is delivered at the same time as the first stimulus (Cx or
% muscle)

hw.gv.stim_string           = [ 'Elect = ' num2str(p_s_params.cortical_elec) ',' num2str(p_s_params.sync_out_elec) ','];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(p_s_params.muscle_elec(i)) ',' ];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];

hw.gv.stim_string           = [ hw.gv.stim_string 'TL = ' num2str(p_s_params.train_duration_cx) ',' num2str(p_s_params.train_duration_cx) ',']; 
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(p_s_params.train_durration_muscle(i)) ','];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];

hw.gv.stim_string           = [ hw.gv.stim_string 'Freq = ' num2str(p_s_params.stim_freq_cx) ',' num2str(1000/p_s_params.train_duration_cx) ','];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(p_s_params.stim_freq_muscle(i)) ','];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];

hw.gv.stim_string           = [ hw.gv.stim_string 'Dur = ' num2str(p_s_params.stim_pw_cx) ',' num2str(p_s_params.stim_pw_cx) ','];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(p_s_params.stim_pw_muscle(i)) ','];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];

hw.gv.stim_string           = [ hw.gv.stim_string 'Amp = ' num2str(floor(p_s_params.stim_ampl_cx/p_s_params.stimulator_resolut)) ',' num2str(127) ','];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(floor(p_s_params.stim_ampl_muscle(i)/p_s_params.stimulator_resolut)) ','];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];

hw.gv.stim_string           = [ hw.gv.stim_string 'TD = ' num2str(hw.gv.td_cx) ',' num2str(min(hw.gv.td_muscle, hw.gv.td_cx)) ','];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(hw.gv.td_muscle) ','];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];

hw.gv.stim_string           = [ hw.gv.stim_string 'FS = 0,0,' ];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string '0,'];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];
   
hw.gv.stim_string           = [ hw.gv.stim_string 'PL = 1,1,' ];
for i = 1:length(p_s_params.muscle_elec)
    hw.gv.stim_string       = [ hw.gv.stim_string num2str(p_s_params.stim_polar_muscle(i)) ','];
end
hw.gv.stim_string           = [ hw.gv.stim_string '; '];



%------------------------------------------------------------------
% This loop executes the paired stimulation

for i = 1:p_s_params.nbr_stimuli
        
    
    xippmex('stim',hw.gv.stim_string);
                            
    pause(p_s_params.t_btw_pairs/1000);
    
    if ~ishandle(p_s_fig.h)
       cbmex('close');
       error('EXITING. Execution stopped by the user')
    end
end


cbmex('close')

