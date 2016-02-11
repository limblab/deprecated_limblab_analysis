%
% Function to record data to compute stimulation to force models
%
%   function varargout = stim_to_force_daq( varargin )
%
%
%   The function takes 1 or 0 arguments of type 's_f_params'. When no
%   arguments are passed, it loads the parameters defined in
%   'stim_to_force_daq_default.m'
%
%   The function can return one variable of type 'force'. 'force' is a
%   structure that comprises: 1) the evoked Force in all the channels for
%   each stimulus, and 2) the amplitude of the stimuli delivered   
%


% %%%%%%%%%%%%
%   Changes wrt v1:
%       - the code reads a sync out from the stimulator to align the evoked
%       force


% %%%%%%%%%%%%
%   Some known issues:
%       - The force sampling freq is hardcoded, to 2 kHz
%       - Force sensor labels are hardcoded
%       - The buffer of the cerebus is read ~1 s after the stimulation
%       command is sent. To change this replace the pause(1) command around
%       line 197
%
%
%   Last edited by Juan Gallego, 01/27/15
%


function varargout = stim_to_force_daq( varargin )


% read parameters

% If the function is called without input paramters 

if nargin > 1
    
    disp('ERROR: The function only takes one argument of type s_f_params');
    return;
elseif nargin == 1
   
    s_f_params              = varargin{1};
elseif nargin == 0
    
    s_f_params              = stim_to_force_daq_default();
end



%--------------------------------------------------------------------------
% some preliminary calculations

% create vector with stimulation amplitudes, randomly ordered
% Note 'hw' will have all the cerebus and grapevine stuff
hw.gv.stim_amps             = repmat(linspace(s_f_params.min_stim_ampl,s_f_params.max_stim_ampl,s_f_params.nbr_steps),1,s_f_params.nbr_reps);
hw.gv.stim_amps             = datasample(hw.gv.stim_amps,length(hw.gv.stim_amps),'Replace',false);



%--------------------------------------------------------------------------
%% connect with Central 

% connect to central; if connection fails, return error message and quit
if ~cbmex('open', 1)
    
    echoudp('off');
%    close(handles.keep_running);
    error('ERROR: Connection to Central Failed');
end


% if want to save the data...
if s_f_params.save_data_yn
    
    % create file name
    hw.data_dir             = [s_f_params.data_dir filesep 'stim_to_force_data_' datestr(now,'yyyy_mm_dd')];
    if ~isdir(hw.data_dir)
        mkdir(hw.data_dir)
    end
    hw.start_t              = datestr(now,'yyyymmdd_HHMMSS');
    hw.cb.full_file_name    = fullfile( hw.data_dir, [s_f_params.monkey '_' hw.start_t '_' s_f_params.task '_stim_to_force' ]);
    
    % start 'file storage' app, or stop ongoing recordings
    cbmex('fileconfig', fullfile( hw.data_dir, hw.cb.full_file_name ), '', 0 );  
    drawnow;                        % wait till the app opens
    pause(1);
    drawnow;                        % wait some more to be sure. If app was closed, it did not always start recording otherwise

    % start cerebus file recording
    cbmex('fileconfig', hw.cb.full_file_name, '', 1);
end    


% configure acquisition
cbmex('trialconfig', 1);
drawnow;

pause(1);                       % ToDo: see if it's necessary


% Figure out how many EMG and force channels there are, and preallocate
% matrices accordingly

[ts_cell_array, ~, analog_data]     = cbmex('trialdata',1);

analog_data(:,1)        = ts_cell_array([analog_data{:,1}]',1); % ToDo: replace channel numbers with names
force.data              = analog_data( strncmp(analog_data(:,1), 'Force', 5), 3 );
[force.nbr_forces,~]    = size(force.data);
disp(['Nbr Force sensors: ' num2str(force.nbr_forces)]), disp(' ');
force.evoked_force      = zeros( ( s_f_params.pre_stim_win + s_f_params.post_stim_win ) * 2000/1000, s_f_params.nbr_reps * s_f_params.nbr_steps, force.nbr_forces ); % ToDo: replace by read Force sampling freq
force.length_evoked_force   = ( s_f_params.pre_stim_win + s_f_params.post_stim_win ) * 2000/1000;

clear analog_data ts_cell_array;



%--------------------------------------------------------------------------
%% connect with Grapevine

% initialize xippmex
hw.gv.connection            = xippmex;

% if the connection fails, return error message and quite
if hw.gv.connection ~= 1
        cbmex('close');
        error('ERROR: Xippmex did not initialize');
end

% find all Micro+Stim channels (stimulation electrodes)
hw.gv.stim_ch               = xippmex('elec','stim');

if isempty(hw.gv.stim_ch)
    cbmex('close');
    error('ERROR: no stimulator found!');
elseif ( numel(find( hw.gv.stim_ch == s_f_params.stim_elecs(1))) + numel(find( hw.gv.stim_ch == s_f_params.stim_elecs(2))) ) ~= 2 
    cbmex('close');
    error('ERROR: did not find the stim channels selected!');
end


%--------------------------------------------------------------------------
%% stimulate to get the curves!


% figure to plot the evoked forces and recruitment curves
force_fig                     = struct(...
    'h',                        figure, ...
    't',                        -s_f_params.pre_stim_win:1000/2000:(s_f_params.post_stim_win-1000/2000), ...     %ToDo> double check
    'colors_plot',              colormap(autumn(length(hw.gv.stim_amps))),...
    'colors_plot_2',            colormap(winter(length(hw.gv.stim_amps))));

set(force_fig.h, 'Name', 'Evoked Force - Close this figure to stop');


% preallocate some matrices to store stuff
force.peak_force            = zeros(force.nbr_forces,length(hw.gv.stim_amps));  % var to store peak force
force.background_force      = zeros(force.nbr_forces,length(hw.gv.stim_amps));  % var to store nackground force
force.stim_ts               = zeros(1,length(hw.gv.stim_amps));                 % stimulation time stamps

% % a high pass filter for the EMG (from Dideriksen et al., J Appl Physiol, 2014)
% [emg.online_filt.b, emg.online_filt.a]  = butter(5,120/(2000/2),'high');

drawnow;




for i = 1:length(hw.gv.stim_amps)
        
    
    %------------------------------------------------------------------
    % Define the stimulation string for the pair of channes. Note the
    % polarity (PL) is defined so as to one electrode is the anode and the
    % other the cathode
     
%     stim_string             = [ 'Elect = ' num2str(s_f_params.stim_elecs(1)) ',' num2str(s_f_params.stim_elecs(2)) ',; ' ...
%                                 'TL = ' num2str(s_f_params.train_duration) ',' num2str(s_f_params.train_duration) ',; ' ...    
%                                 'Freq = ' num2str(s_f_params.stim_freq) ',' num2str(s_f_params.stim_freq) ',; ' ...
%                                 'Dur = ' num2str(s_f_params.stim_pw) ',' num2str(s_f_params.stim_pw) ',; ' ...
%                                 'Amp = ' num2str(hw.gv.stim_amps(i)/s_f_params.stimulator_resolut) ',' num2str(hw.gv.stim_amps(i)/s_f_params.stimulator_resolut) ',; ' ...  % ToDo: define step as param
%                                 'TD = ' num2str(abs(s_f_params.beg_baseline_win)) ',' num2str(abs(s_f_params.beg_baseline_win)) ',; ' ...
%                                 'FS = 0,0,;' ...
%                                 'PL = 1,0,;'];
       
    stim_string             = [ 'Elect = ' num2str(s_f_params.stim_elecs(1)) ',' num2str(s_f_params.stim_elecs(2)) ',' num2str(s_f_params.sync_out_elec) ',; ' ...
                                'TL = ' num2str(s_f_params.train_duration) ',' num2str(s_f_params.train_duration) ',' num2str(ceil(1/s_f_params.stim_freq*1000)) ',; ' ... % ToDo: the train length may be too short, add an arbitrary short time, if necessary
                                'Freq = ' num2str(s_f_params.stim_freq) ',' num2str(s_f_params.stim_freq) ',' num2str(s_f_params.stim_freq) ',; ' ...
                                'Dur = ' num2str(s_f_params.stim_pw) ',' num2str(s_f_params.stim_pw) ',' num2str(s_f_params.stim_pw) ',; ' ...
                                'Amp = ' num2str(round(hw.gv.stim_amps(i)/s_f_params.stimulator_resolut)) ',' num2str(round(hw.gv.stim_amps(i)/s_f_params.stimulator_resolut)) ',' num2str(3/s_f_params.stimulator_resolut) ',; ' ...  % ToDo: the sync out pulse will be 3 V; check if ok
                                'TD = ' num2str(s_f_params.pre_stim_win)/1000 ',' num2str(s_f_params.pre_stim_win/1000) ',' num2str(s_f_params.pre_stim_win/1000) ',; ' ...
                                'FS = 0,0,0,; ' ...
                                'PL = 1,0,1,;'];
             
    % Display stim amplitude
    disp(['stim amplitude (mA): ' num2str(hw.gv.stim_amps(i))]);
                            
    % Start data collection
    cbmex('trialconfig',1);
    drawnow;

    % Store the current time. To control execution
    t_start                 = tic;
    
    % Send stimulation command
    xippmex('stim',stim_string);
    drawnow;

    
    %------------------------------------------------------------------ 
    % read and display EMG (and force) % ToDo: force
    % wait 1 s (for plotting and saving time) % ToDo: IMPROVE!!!
    pause(1);
    
    
    % read the data from central (flush the data cache)
    [ts_cell_array, ~, analog_data] = cbmex('trialdata',1);
    cbmex('trialconfig', 0);
    
    % retrieve Force data and sitmulation time stamp
    analog_data(:,1)                = ts_cell_array([analog_data{:,1}]',1); % ToDo: replace channel numbers with names
    force.data                      = analog_data( strncmp(analog_data(:,1), 'Force', 5), 3 );
%    force.stim_ts(i)                = ts_cell_array( 128 + s_f_params.ch_nbr_stim_trig_cb, : ); % stim time stamps, there should be only 1
    
    clear analog_data ts_cell_array;
    
    %------------------------------------------------------------------     
    % store force data in the data matrix, and calculate maximum force per channel
    for ii = 1:force.nbr_forces
        force.evoked_force( :, i, ii)   = double(force.data{ii}(1:(force.length_evoked_force)));    % ToDo: check size does not change!        
        force.background_force(ii,i)    = mean( force.evoked_force(1:s_f_params.pre_stim_win*2000/1000,i,ii) );
        force.evoked_force_nomean(:,i,ii)   = force.evoked_force(:,i,ii) - force.background_force(ii,i);
%         force.peak_force(ii,i)          = max( max(force.evoked_force_nomean(abs(s_f_params.pre_stim_win)*2000/1000:end,i,ii)),max(-force.evoked_force_nomean(:,i,ii)));
        [~, max_idx]                    = max(abs(force.evoked_force_nomean(:,i,ii)));
        force.peak_force(ii,i)          = force.evoked_force_nomean(max_idx,i,ii);
    end   
    
    
    % plot the data     % ToDo: read Force labels instead of having them hard-coded
    if ishandle(force_fig.h)
       
        subplot(221), hold on, plot( force_fig.t, force.evoked_force(1:length(force_fig.t),i,1), ...
            'linewidth', 2, 'color', force_fig.colors_plot(i,:))
        title('evoked Force'), ylabel('Force_x'), xlim([force_fig.t(1), force_fig.t(end)]);
        
        subplot(223), hold on, plot( force_fig.t, force.evoked_force(1:length(force_fig.t),i,2), ...
            'linewidth', 2, 'color', force_fig.colors_plot_2(i,:))
        xlabel('time (ms)'), ylabel('Force_y'), xlim([force_fig.t(1), force_fig.t(end)]);
        
        
        subplot(222), hold on, plot( hw.gv.stim_amps(i), force.peak_force(1,i), 'marker', 'o', ...
            'color', force_fig.colors_plot(i,:))
        title('recruitment curves'), ylabel('maximum force')
        
        subplot(224), hold on, plot( hw.gv.stim_amps(i), force.peak_force(2,i), 'marker', 'square', ...
            'color', force_fig.colors_plot_2(i,:))
        xlabel('stim amplitude (mA)'), ylabel('maximum force'), xlim([(s_f_params.min_stim_ampl-0.5), (s_f_params.max_stim_ampl+0.5)])
    else
        disp('Execution stopped by the user');
        cbmex('close');
        break;
    end
  
    
    
    %------------------------------------------------------------------
    % Wait until this cycle is over
        
    if s_f_params.manual_stim_ctrl_yn == 0
    
        % check if the random time between stimuli is over (-1 s that we
        % waited for above). The random time is defined considering the max
        % and min ISI set in s_f_params
        t_elapsed           = toc(t_start);
    
        while t_elapsed < ( s_f_params.min_inter_stim_int + rand(1)*(s_f_params.max_inter_stim_int - s_f_params.min_inter_stim_int) - 1)
            t_elapsed       = toc(t_start);
        end
    else
        % wait for the user to send another stim command
        pause;
        t_elapsed           = toc(t_start);
    end

    % ToDo - display a bunch of things before the next cycle
    disp(['t elapsed (s): ' num2str(t_elapsed)]);
    disp(['Stim nbr: ' num2str(i) ]);
end


%--------------------------------------------------------------------------
% Save data and stop cerebus recordings


% prepare variables for storage
force.stim_amps             = hw.gv.stim_amps;
force                       = rmfield(force,'data');
% force                       = rmfield(emg,'online_filt');
    

% Return variables
if nargout == 1
    
    varargout{1}            = force;
end



if s_f_params.save_data_yn
    
    % stop cerebus recordings
    cbmex('fileconfig', hw.cb.full_file_name, '', 0);
    cbmex('close');
    drawnow;
    disp('Communication with Central closed');

    % save matlab data. Note: the time in the faile name will be the same as in the cb file
    hw.matlab_full_file_name    = fullfile( hw.data_dir, [s_f_params.monkey '_' hw.start_t '_' s_f_params.task '_stim_to_force' ]);
    
        
    disp(' ');
    save(hw.matlab_full_file_name,'force');
    disp(['Force and stim_amps saved in ' hw.matlab_full_file_name]);
end