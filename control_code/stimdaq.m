function stimdaq
%   STIMDAQ   The GUI to control the stimulation and triggered recordings
% 
%   STIMDAQ is set up with nested functions, as documented in the web page
%   http://xtargets.com/cms/Tutorials/Matlab-Programming/Using-Guide-With-Nested-Functions.html
%
%   While some of the figure is created with GUIDE, *all* callbacks are set
%   programmatically.
%   
%   Created by Matt Bauman on 2009-11-23.
%   Miller Limb Lab, Northwestern University.

%% Stimulator initialization
    % Send a 0 pulse on all channels to ensure that the trigger is properly
    % initialized
    clear; clc;
    
    % Delete any existing serial ports in MATLAB
    priorPorts = instrfind; % finds any existing Serial Ports in MATLAB
    delete(priorPorts); % and deletes them 
    
    if ~exist('ws_object', 'var')
        disp('Creating wireless stimulator object...');
        %ws = wireless_stim(com_port, 1); %the number has to do with verbosity of running feedback
        %ws.init(1, ws.comm_timeout_disable);
        
        ws_struct = struct(...
            'serial_string', 'COM5',...
            'dbg_lvl', 1, ...
            'comm_timeout_ms', 100, ... %-1 for no timeout
            'blocking', false, ...
            'zb_ch_page', 5 ...
            );
        
        ws_object = wireless_stim(ws_struct);
        ws_object.init();
    end
%     % Define serial port through proper COM port
%     s = serial('COM4','BaudRate',115200);
%     
%     % Define stimulation parameters
%     chList = 0:15;
%     stimSTR = fns_stim_prog('p',chList,'prog',0,1,30,0,0,0.5);
%     
%     % Send program to FNS-16 stimulator
%     fopen(s); fwrite(s,stimSTR); fclose(s);
%     
%     % Run program on FNS-16 stimulator
%     strOUT2 = fns_stim_prog('r',chList);
%     fopen(s); fwrite(s,strOUT2); fclose(s);
%     pause(2);
%     
%     % Halt all channels on FNS-16 stimulator
%     fopen(s); fwrite(s,'2'); fclose(s);

%% GUI Loading: Find all the pre-populated objects
    
    % Grab the GUIDE-programmed figure
    fig = open('stimdaq.fig');
    
    % Pull out the objects 
    stim_param_panel     = findobj(fig, 'tag', 'stim_param_panel');
    stim_freq            = findobj(fig, 'tag', 'stim_freq');
    stim_pulses          = findobj(fig, 'tag', 'stim_pulses');
    rec_duration_txbx    = findobj(fig, 'tag', 'rec_duration');
    modulation_mode_menu = findobj(fig, 'tag', 'modulation_mode_menu');
    channel_menu         = findobj(fig, 'tag', 'plot_raw_data_menu');
    multiplier_min       = findobj(fig, 'tag', 'multiplier_min');
    pulse_min_button     = findobj(fig, 'tag', 'pulse_min_button');
    pulse_max_button     = findobj(fig, 'tag', 'pulse_max_button');
    multiplier_max       = findobj(fig, 'tag', 'multiplier_max');
    multiplier_delta     = findobj(fig, 'tag', 'multiplier_delta');
    total_pulse_count    = findobj(fig, 'tag', 'total_pulse_count');
    start_button         = findobj(fig, 'tag', 'start_button');
    abort_button         = findobj(fig, 'tag', 'abort_button');
    fig_button           = findobj(fig, 'tag', 'figclose');
    save_button          = findobj(fig, 'tag', 'save_button');
    plot_recruitments_button = findobj(fig, 'tag', 'plot_recruitments_button');
    plot_raw_data_button = findobj(fig, 'tag', 'plot_raw_data_button');
    recording_time_text  = findobj(fig, 'tag', 'recording_time_text');
    mode_text            = findobj(fig, 'tag', 'mode_text');
    save_status_text     = findobj(fig, 'tag', 'save_status_text');
    EMG_button           = findobj(fig, 'tag', 'EMG_labels_button');
    daq_freq             = findobj(fig, 'tag', 'daq_freq');
    stim_reps            = findobj(fig, 'tag', 'stim_reps');
    stim_interphase      = findobj(fig, 'tag', 'stim_interphase');
    stim_delay           = findobj(fig, 'tag', 'stim_delay');
    curr_action_text     = findobj(fig, 'tag', 'curr_action_text');
    mle_fit_chbx         = findobj(fig, 'tag', 'mle_fit_chbx');
    optctrl_active_chbx  = findobj(fig, 'tag', 'optctrl_active');
    optctrl_numpts       = findobj(fig, 'tag', 'optctrl_numpts');
    optctrl_auto_chbx    = findobj(fig, 'tag', 'autoCtrl');
    optctrl_numreps      = findobj(fig, 'tag', 'optctrl_numreps');
    optctrl_level_act    = findobj(fig, 'tag', 'level_act_optctrl');
    optctrl_tw_low       = findobj(fig, 'tag', 'tw_optctrl_low');
    optctrl_tw_hi        = findobj(fig, 'tag', 'tw_optctrl_hi');
    stagger_stim         = findobj(fig, 'tag', 'stagger_stim');
    stagger_stim_time    = findobj(fig, 'tag', 'stagger_stim_time');
    mod_window_1         = findobj(fig, 'tag', 'mod_window_1');
    mod_window_2         = findobj(fig, 'tag', 'mod_window_2');
    optctrl_mode_menu    = findobj(fig, 'tag', 'optctrl_mode_menu');
    cost_r               = findobj(fig, 'tag', 'cost_r');
    cost_q               = findobj(fig, 'tag', 'cost_q');
    
    % Other data structures that need to be global
    abort = libpointer('bool', 0);
    % Compile figure handles
    handles = guihandles(fig);
    % Set current status as idle
    set(curr_action_text, 'String', 'idle');
    
%% Load Calibration Matrix for Force Transducer
    parentFolder = strcat(fileparts(mfilename('fullpath')),'\calibration matrices\');
    calMat = load(strcat(parentFolder, 'newCal'));
    calMat = calMat';
    % Make new folder to store calibration matrix (labeled with current date)
    folderName = strcat(date,' isometric data');
    if ~exist(strcat(parentFolder, folderName), 'dir')
        mkdir(parentFolder, folderName);
    end
    saveFilename_calmat = strcat(parentFolder,folderName,'\cal_mat_',date);
    % Save calibration matrix
    save(saveFilename_calmat,'calMat','-mat');
    
%% Define dummy variables for recruitment curves (for now). Reassigned after real recruitment curve formation
    saveFilename_sigmoid = strcat(cd,'\',folderName,'\recruit_sigmoid');
    recruit_exist = 0;
    rcurve = [];
    
%% Default EMG channel parameters
    EMG_labels = {'ch 0' 'ch 1' 'ch 2' 'ch 3' 'ch 4' 'ch 5' 'ch 6' 'ch 7' ...
        'ch 8' 'ch 9' 'ch 10' 'ch 11' 'ch 12' 'ch 13' 'ch 14' 'ch 15' 'Fx'...
        'Fy' 'Fz' 'Mx' 'My' 'Mz'};
    
    % Automatically assign the forces/moments and first five stimulation channels
    % to be recorded.
    EMG_enable = [true(1,5) false(1,11) true(1,6)];
    
    % Flags and initial variables for stimulation trials
    data_has_been_saved = 0;
    default_save_path = '';
    out_struct.data = [];
    
%% GUI Creation: Build the missing components programmatically
    % Setup the programmatically created stimulation parameter panel
    stim_channel_label = zeros(16,1);
    stim_channel_amp   = zeros(16,1);
    stim_channel_pw    = zeros(16,1);
    stim_channel_mod   = zeros(16,1);
    stim_channel_opt   = zeros(16,1);
    stim_channel_active = zeros(16,1);
    
    set(stim_param_panel, 'Units', 'Pixels')
    panel_position = get(stim_param_panel,'Position');
    
    % The labels at the top
    height = panel_position(4) - 90;
    
    uicontrol(stim_param_panel,'Style','text','String','Current',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [38 height 51 15]);
    uicontrol(stim_param_panel,'Style','text','String','Width',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [95 height 51 15]);
    uicontrol(stim_param_panel,'Style','text','String','A',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [150 height 15 15]);
    uicontrol(stim_param_panel,'Style','text','String','M',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [170 height 15 15]);
    uicontrol(stim_param_panel,'Style','text','String','O',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [190 height 15 15]);
    height = height - 20; % Padding between the labels and the table
    
    % The EMG channel labels
    set(channel_menu,'String',EMG_labels');
    
    % And now go through each channel, setting up all its widgets
    for chan=1:16
       stim_channel_label(chan) = uicontrol(stim_param_panel,...
           'Style', 'text',...
           'String', sprintf('%d',chan-1),...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [3 (height+2) 20 15],...
           'HorizontalAlignment', 'right');
       
       stim_channel_amp(chan) = uicontrol(stim_param_panel,...
           'Style', 'edit',...
           'String', '0',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [38 height 51 19],...
           'BackgroundColor', [1.0 1.0 1.0]);

       amp_menu = uicontextmenu('Parent',fig);
       uimenu(amp_menu, 'Label', 'Apply to all channels',...
           'Callback', {@context_menu_apply_to_all_amp_cb},...
           'UserData', stim_channel_amp(chan));
       set(stim_channel_amp(chan), 'UIContextMenu', amp_menu);

       stim_channel_pw(chan) = uicontrol(stim_param_panel,...
           'Style', 'edit',...
           'String', '0.1',...
           'Value', 0.1,...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [95 height 51 19],...
           'BackgroundColor', [1.0 1.0 1.0]);
       
       pw_menu = uicontextmenu('Parent',fig);
       uimenu(pw_menu, 'Label', 'Apply to all channels',...
           'Callback', {@context_menu_apply_to_all_pw_cb},...
           'UserData', stim_channel_pw(chan));
       set(stim_channel_pw(chan), 'UIContextMenu', pw_menu);

       stim_channel_mod(chan) = uicontrol(stim_param_panel,...
           'Style', 'checkbox',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [170 height 19 19],...
           'UserData', 0,...
           'Enable', 'off');
       
       stim_channel_active(chan) = uicontrol(stim_param_panel,...
           'Style', 'checkbox',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [150 height 19 19],...
           'UserData', 0,...
           'Enable', 'on');
       
       stim_channel_opt(chan) = uicontrol(stim_param_panel,...
           'Style', 'checkbox',...
           'Units', get(stim_param_panel, 'Units'),...
           'Position', [190 height 19 19],...
           'UserData', 0,...
           'Enable', 'off');
       
       height = height - 25;
    end
    

%% Collections of objects and aggregate changes to those collections...

    % All controls whose enabled is toggled by changing the modulation mode
    all_multiplier_controls  = findobj(fig, 'Parent',...
        findobj(fig, 'tag', 'multiplier_controls_panel'));
    set(all_multiplier_controls, 'Enable', 'off');
    
    % All controls whose enabled is toggled by clicking optimal control checkbox
    all_optctrl = findobj(fig,'Parent',...
        findobj(fig,'tag','optctrl_panel'));
    set(all_optctrl, 'Enable', 'off');

    % All the controls that rely on a valid dataset being loaded
    all_loaded_data_controls = findobj(findobj(fig, 'tag', 'loaded_data_panel'),...
        '-not','Type','uipanel');
    set(all_loaded_data_controls, 'Enable', 'off');
    
    % all edit boxes are floats... except one. Store the format
    % specifier in the UserData.
    all_edit_boxes = findobj(fig, 'Style', 'edit');
    set(all_edit_boxes,'UserData','%g');
    set(stim_pulses,'UserData','%d');
    
%% Callbacks

    % The EMG labels button - open gui to setup EMG labels
    set(EMG_button, 'Callback', {@EMG_button_cb})
    function EMG_button_cb(source, event)%#ok<INUSD>
        [EMG_labels, EMG_enable] = EMG_labels_gui(EMG_labels, EMG_enable);
        set(channel_menu,'Value',1);
        set(channel_menu,'String',EMG_labels(EMG_enable)');
        height = panel_position(4) - 90;
        height = height - 20;
        for chNum=1:16
%            stim_channel_label(chNum) = uicontrol(stim_param_panel,...
           uicontrol(stim_param_panel,...
               'Style', 'text',...
               'String', sprintf('%s',EMG_labels{chNum}),...
               'Units', get(stim_param_panel, 'Units'),...
               'Position', [3 (height+2) 28 15],...
               'HorizontalAlignment', 'right');
           height = height - 25;
        end
    end

    % The start button - dispatch the controller
    set(start_button, 'Callback', {@start_button_cb})
    function start_button_cb(source, event) %#ok<INUSD>
        
        % Clear the out_struct for new data (warning on unsaved overwrite)
        if (~clear_out_struct)
            % There was unsaved data, and the user chose to cancel
            set(source,'Value',get(source,'Min')); % pop the button back out
            return
        end
        
        % Push start button in        
        set(abort,'Value',0); set(source,'Enable','off');
        set(source,'Value',get(source,'Max')); % push the button in
        
        % Set the GUI as the current fig so stimrec plots to the live axes
        figure(fig); cla;
        
        % Pull out all the necessary values into standard arrays that are
        % part of running structure (allvars)
        allvars.mode = get(modulation_mode_menu,'UserData');
        amps_temp = get(stim_channel_amp, 'Value');
        pws_temp  = get(stim_channel_pw, 'Value');
        is_mod_temp = get(stim_channel_mod, 'Value');
        is_active_temp = get(stim_channel_active, 'Value');
        is_opt_temp = get(stim_channel_opt, 'Value');
        allvars.amps   = [amps_temp{:}];
        allvars.pws    = [pws_temp{:}];
        allvars.is_mod = [is_mod_temp{:}];
        allvars.is_active = [is_active_temp{:}];
        allvars.is_opt = [is_opt_temp{:}];
        allvars.freq = get(stim_freq, 'Value');
        allvars.pulses = get(stim_pulses, 'Value');
        allvars.rec_duration = get(rec_duration_txbx, 'Value');        
        allvars.mults = get(multiplier_min, 'Value'):get(multiplier_delta, 'Value'):get(multiplier_max, 'Value');
        allvars.num_reps = get(stim_reps, 'Value');
        allvars.stim_tip = get(stim_interphase,'Value');
        allvars.freq_daq = get(daq_freq,'Value');
        allvars.delay = get(stim_delay,'Value');
        allvars.optctrl = get(optctrl_active_chbx,'Value');
        allvars.optctrl_np = get(optctrl_numpts,'Value');
        allvars.optctrl_auto = get(optctrl_auto_chbx,'Value');
        allvars.optctrl_nr = get(optctrl_numreps,'Value');
        allvars.level_act = get(optctrl_level_act,'Value')/100;
        allvars.time_window = zeros(1,2);
        allvars.time_window(1) = get(optctrl_tw_low,'Value');
        allvars.time_window(2) = get(optctrl_tw_hi,'Value');
        allvars.platONoptctrl = floor(get(optctrl_tw_low,'Value')*(allvars.freq_daq/1000));
        allvars.platOFFoptctrl = floor(get(optctrl_tw_hi,'Value')*(allvars.freq_daq/1000));
        allvars.optctrl_stagger = get(stagger_stim,'Value');
        allvars.optctrl_stagger_time = get(stagger_stim_time,'Value');
        allvars.mod_window = zeros(1,2);
        allvars.mod_window(1) = get(mod_window_1,'Value');
        allvars.mod_window(2) = get(mod_window_2,'Value');
        allvars.platON = floor(get(mod_window_1,'Value')*(allvars.freq_daq/1000));
        allvars.platOFF = floor(get(mod_window_2,'Value')*(allvars.freq_daq/1000));
        allvars.optctrl_mode = get(optctrl_mode_menu,'UserData');
        allvars.baseline = 0.1;
        allvars.cost_r = get(cost_r,'Value');
        allvars.cost_q = get(cost_q,'Value');
        
        %Make sure the recording duration exceeds the train length + response latency (150ms) when in train mode
        if strcmp(allvars.mode,'static_train') && (allvars.pulses/allvars.freq+0.15) > allvars.rec_duration/1000
            set(source,'Value',get(source,'Min')); % pop the button back out
            set(source,'Enable','on');
            msgbox('Recording duration is too short for the pulse train','Check you parameters!','warn');
            return;
        end
        
%         try
            if ~allvars.optctrl   % Just regular trial - no optimal control
                
                % Run stimulation
                out_struct.time = clock;
                [out_struct.data, out_struct.sample_rate, out_struct.act_ch_list] = run_stimplan_ripple(abort,allvars,EMG_labels,EMG_enable,handles,calMat,curr_action_text, ws_object);
                
                % Store variables in output structure
                out_struct.mode = allvars.mode;
                out_struct.base_amp = allvars.amps;
                out_struct.base_pw = allvars.pws;
                out_struct.freq = allvars.freq;
                out_struct.pulses = allvars.pulses;
                out_struct.is_channel_modulated = allvars.is_mod;
                out_struct.modulation_channel_multipliers = allvars.mults;
                out_struct.emg_labels = EMG_labels(EMG_enable);
                out_struct.emg_enable = EMG_enable;
                out_struct.daq_freq = allvars.freq_daq;
                out_struct.num_reps = allvars.num_reps;
                out_struct.stim_tip = allvars.stim_tip;
                out_struct.is_active = allvars.is_active;
                out_struct.calmat = calMat;
                out_struct.mod_wind = allvars.mod_window;
                out_struct.baseline = allvars.baseline;
                
            else % optimal control
                out_struct = run_optimal_control(source,optctrl_active_chbx,all_optctrl,...
                                    saveFilename_calmat,stim_channel_active,stim_channel_amp,...
                                    abort,EMG_labels,EMG_enable,...
                                    handles,calMat,curr_action_text,...
                                    save_status_text,allvars);
                                
            end
%         catch exception
%             set(source,'Value',get(source,'Min')); % pop the button back out
%             out_struct.time = [];
%             throw(exception);
%         end
        
        if (size(out_struct.data))
            set(all_loaded_data_controls, 'Enable', 'on');
            data_has_been_saved = 0;
            pretty_time = sprintf('%02d:%02d:%02d',out_struct.time(4),out_struct.time(5),floor(out_struct.time(6)));
            set(recording_time_text, 'String', pretty_time);
            set(mode_text, 'String', out_struct.mode);
        end
        set(source,'Value',get(source,'Min'));
        set(source,'Enable','on');
              
    end

    % The abort button - abort the controller
    set(abort_button, 'Callback', {@abort_button_cb})
    function abort_button_cb(source, event) %#ok<INUSD>
        set(abort, 'Value', 1);
        set(start_button,'Enable','on');
        set(start_button,'Value', 0);
    end

    % The close windows button
    set(fig_button, 'Callback', {@figures_button_cb})
    function figures_button_cb(source, event) %#ok<INUSD>
        cab(fig);
        set(fig_button, 'Value', 1);
    end
    
    % The save button - save a data set
    set(save_button, 'Callback', {@save_button_cb})
    function save_button_cb(source, event) %#ok<INUSD>
        [file_name,file_path] = uiputfile(fullfile(default_save_path,'save.mat'), 'Save file');
        if (isequal(file_name,0) || isequal(file_path,0)); return; end; % The user cancelled
                
        save(fullfile(file_path, file_name), 'out_struct','rcurve');
        set(save_status_text, 'String', sprintf('Saved to: %s', file_name));
        set(save_status_text, 'TooltipString', fullfile(file_path, file_name));
        default_save_path = file_path;
        data_has_been_saved = 1;
    end

    % The modulation menu: enable/disable modulation sections of the GUI
    set(modulation_mode_menu, 'Callback', {@modulation_mode_menu_cb})
    function modulation_mode_menu_cb(source, event) %#ok<INUSD>
        % Update the UserData with the appropriate string
        switch get(source, 'Value')
            case 1
                set(source, 'UserData', 'static_pulses');
            case 2
                set(source, 'UserData', 'static_train');
            case 3
                set(source, 'UserData', 'mod_pw');
            case 4
                set(source, 'UserData', 'mod_amp');
        end
        
        % And update the GUI
        if get(source, 'Value') < 3
            % Static stimulation
            % Turn off the modulation bits
            set(stim_channel_mod,'Enable','off', 'Value',0);
            set(all_multiplier_controls,'Enable','off');
                        
            % Only turn optctrl  on if optctrl_chbx is selected
            set(optctrl_active_chbx,'Enable','on');
            set(all_optctrl,'Enable','off');
                
        else % Modulating stimulation
            % Turn on modulation bits; restore settings from UserData
            for i=1:length(stim_channel_mod)
                set(stim_channel_mod(i),'Value',get(stim_channel_mod(i),'UserData'));
            end
            set(stim_channel_mod,'Enable','on');            
            set(all_multiplier_controls,'Enable','on');
            set(all_optctrl,'Enable','off');
            set(stim_channel_opt,'Enable','off');
            set(optctrl_active_chbx,'Enable','off');
            set(optctrl_active_chbx,'Value',0);
        end
        update_total_pulse_count
    end

    % The optctrl modulation menu
    set(optctrl_mode_menu, 'Callback', {@optctrl_mode_menu_cb})
    function optctrl_mode_menu_cb(source, event) %#ok<INUSD>
        % Update the UserData with the appropriate string
        switch get(source, 'Value')
            case 1
                set(source, 'UserData', 'force_mag');
            case 2
                set(source, 'UserData', 'fx_fy');
            case 3
                set(source, 'UserData', 'force_stats');
        end
    end

    % The optctrl active checkbox
    set(optctrl_active_chbx, 'Callback', {@optctrl_active_chbx_cb});
    function optctrl_active_chbx_cb(source, event) %#ok<INUSD>
        if get(source,'Value')==1
            set(all_optctrl,'Enable','on');
            for i=1:length(stim_channel_opt)
                set(stim_channel_opt(i),'Value',get(stim_channel_opt(i),'UserData'));
            end
            set(stim_channel_opt,'Enable','on');            
        else
            set(all_optctrl,'Enable','off');
            set(stim_channel_opt,'Enable','off');
            set(stagger_stim,'Value',0);
        end
    end

    % The MLE active checkbox
    set(mle_fit_chbx, 'Callback', {@mle_fit_chbx_cb});
    function mle_fit_chbx_cb(source, event) %#ok<INUSD>
        if get(mode_text,'Value')==1
%             set(all_costim_levels,'Enable','on');set(mode_text, 'String'
        else
%             set(all_costim_levels,'Enable','off');
        end
    end

    % The one-pulse test buttons
    set(pulse_min_button, 'Callback', {@pulse_min_button_cb});
    function pulse_min_button_cb(source, event) %#ok<INUSD>
        set(abort,'Value',0);
        pulse_once('min');
    end
    
    set(pulse_max_button, 'Callback', {@pulse_max_button_cb});
    function pulse_max_button_cb(source, event) %#ok<INUSD>
        set(abort,'Value',0);
        pulse_once('max');
    end
    
    % The text entry boxes: convert strings to numerics and back.
    set(all_edit_boxes,'Callback',{@edit_box_cb});
    function edit_box_cb(source, event) %#ok<INUSD>
        % update the value
        fmt = get(source, 'UserData');
        new_value = sscanf(get(source, 'String'),fmt,1);
        if(size(new_value))
            % A valid entry: save it and write the parsed number back
            set(source, 'Value', new_value);
            set(source, 'String', sprintf(fmt,new_value));
        else
            % An invalid entry: write the previously saved value back
            set(source, 'String', sprintf(fmt,get(source, 'Value')));
        end

        update_total_pulse_count
    end

    set(stim_channel_mod, 'Callback', {@stim_channel_mod_cb});
    function stim_channel_mod_cb(source, event) %#ok<INUSD>
        % Save the setting to UserData
        for i=1:length(stim_channel_mod)
            set(stim_channel_mod(i),'UserData',get(stim_channel_mod(i),'Value'));
        end
        update_total_pulse_count
    end

    set(stim_channel_active, 'Callback', {@stim_channel_active_cb});
    function stim_channel_active_cb(source, event) %#ok<INUSD>
        % Save the setting to UserData
        for i=1:length(stim_channel_active)
            set(stim_channel_active(i),'UserData',get(stim_channel_active(i),'Value'));
        end
        update_total_pulse_count
    end

    set(stim_channel_opt, 'Callback', {@stim_channel_opt_cb});
    function stim_channel_opt_cb(source, event) %#ok<INUSD>
        % Save the setting to UserData
        for i=1:length(stim_channel_opt)
            set(stim_channel_opt(i),'UserData',get(stim_channel_opt(i),'Value'));
        end
        update_total_pulse_count
    end

    % The contextual menus
    function context_menu_apply_to_all_pw_cb(source, event) %#ok<INUSD>
        target = get(source, 'UserData');
        set(stim_channel_pw, 'Value', get(target, 'Value'));
        set(stim_channel_pw, 'String', get(target, 'String'));
    end

    function context_menu_apply_to_all_amp_cb(source, event) %#ok<INUSD>
        target = get(source, 'UserData');
        set(stim_channel_amp, 'Value', get(target, 'Value'));
        set(stim_channel_amp, 'String', get(target, 'String'));
    end

%% Plotting functions
    set(plot_raw_data_button, 'Callback', {@plot_raw_data_button_cb})
    function plot_raw_data_button_cb(source, event) %#ok<INUSD>
        enabled_chans_now = find(EMG_enable);

        %get desired analog input channel index (1 to 8)
        channel_index = enabled_chans_now(enabled_chans_now==get(channel_menu, 'Value'));
        
        %make sure out_struct contains data for this EMG
        enabled_chans_data = find(out_struct.emg_enable);
        if ~any(channel_index==enabled_chans_data)
            msgbox('No data is available for this channel','error');
        else
            plot_raw_StimDAQ(out_struct,channel_index);
        end
    end

    set(plot_recruitments_button, 'Callback', {@plot_recruitments_button_cb});
    function plot_recruitments_button_cb(source, event) %#ok<INUSD>
        % Get the window min and max
        window_min = findobj(fig,'tag','recruit_window_min');
        window_max = findobj(fig,'tag','recruit_window_max');
        time_window = [get(window_min,'Value') get(window_max,'Value')];
        
        % Verify the inputs
        if (time_window(1) > time_window(2))
            tmp = time_window(2);
            time_window(2) = time_window(1);
            time_window(1) = tmp;
        end
        if (time_window(1) <= 0)
            time_window(1) = 10; %millisec
        end
        
        % And report the value back
        set(window_min,'Value',time_window(1));
        set(window_max,'Value',time_window(2));
        set(window_min, 'String', sprintf(get(window_min, 'UserData'),get(window_min, 'Value')));
        set(window_max, 'String', sprintf(get(window_max, 'UserData'),get(window_max, 'Value')));
        
        %and plot the curves
        [mle_cond,rcurve] = plot_rec_curves_StimDAQ(out_struct,calMat,out_struct.emg_enable,...
            time_window,get(mle_fit_chbx,'Value'),saveFilename_sigmoid);
        set(mle_fit_chbx,'Value',mle_cond);
        recruit_exist = 1;
    end

%% Helper functions
    
    % Update the total number of pulses
    function update_total_pulse_count
%         num_pulses = get(stim_pulses, 'Value');
        modulation_enabled = get(stim_channel_mod, 'Value');
        if (any([modulation_enabled{:}]))
            num_iterations = 1 + ... % Add one to count both endpoints
                floor((get(multiplier_max,'Value') - get(multiplier_min,'Value')) /...
                get(multiplier_delta, 'Value'));
        else
            num_iterations = 1;
        end
        set(total_pulse_count, 'String', sprintf('%d',num_iterations));
    end

    function did_clear_data = clear_out_struct
        did_clear_data = 0;
        if (all(size(out_struct.data)) && ~data_has_been_saved)
            % Warn the user that they may be overwriting data
            response = modaldlg('Title','Confirm data overwrite',...
                'String','The data in memory has not been saved. Continuing will overwrite this data. Do you wish to proceed?');
            if (strcmp(response,'No')); return; end; % die if they chose 'No'
        end
        
        %Clear the data:
        out_struct.time = [];
        out_struct.data = [];
        out_struct.sample_rate = [];
        out_struct.mode = '';
        out_struct.base_amp=[];
        out_struct.base_pw=[];
        out_struct.freq = [];
        out_struct.pulses = [];
        out_struct.is_channel_modulated = [];
        out_struct.modulation_channel_multipliers = [];
        out_struct.emg_labels =[];
        out_struct.emg_enable=[];

        % And clear the display of the data
        set(all_loaded_data_controls, 'Enable', 'off');
        set(recording_time_text, 'String', '');
        set(mode_text, 'String', '');
        set(save_status_text, 'String', '');
        set(save_status_text, 'TooltipString', '');
        
        % Update the state flags
        data_has_been_saved = 0;
        did_clear_data = 1;
    end

    function pulse_once(extremum)
        % pull out the needed values into standard arrays
        mode = get(modulation_mode_menu,'UserData');
        amps_temp = get(stim_channel_amp, 'Value');
        pws_temp  = get(stim_channel_pw, 'Value');
        is_channel_modulated_temp = get(stim_channel_mod, 'Value');
        base_amps   = [amps_temp{:}];
        base_pws    = [pws_temp{:}];
        is_channel_modulated = [is_channel_modulated_temp{:}];
        freq = get(stim_freq, 'Value');
        rec_duration = get(rec_duration_txbx, 'Value');        
        %phony = get(phony_cbx, 'Value');
        
        % Set multiplier_box to the correct extremum
        if (strcmp(extremum,'min'))
            multiplier_box = multiplier_min;
        elseif (strcmp(extremum,'max'))
            multiplier_box = multiplier_max;
        else
            error 'Invalid extremum passed to pulse_once function';
        end
        
        if (strcmp(mode,'mod_amp'))
            amp_modulation = get(multiplier_box, 'Value');
            pw_modulation = 1;
        elseif (strcmp(mode,'mod_pw'))
            amp_modulation = 1;
            pw_modulation = get(multiplier_box, 'Value');
        else
            error 'Invalid modulation mode obtained from the modulation_mode_menu';
        end
        
        amps = base_amps + (base_amps.*repmat(amp_modulation-1,1,16).*is_channel_modulated);
        pws  = base_pws  + (base_pws .*repmat(pw_modulation -1,1,16).*is_channel_modulated);
        
        try
            %to use fns, switch this back to "stimrec" code
            isactivetemp = get(stim_channel_active, 'Value');
            is_active = [isactivetemp{:}];
            nreps = get(stim_reps, 'Value'); 
            stim_tip = get(stim_interphase,'Value');
            freq_daq = get(daq_freq,'Value'); 
            stagger_time = get(stagger_stim_time,'Value');
            disp('Calling stimrec')
            stimrec_ripple(abort, amps, pws, freq, 1, rec_duration, mode, is_active, EMG_labels, EMG_enable, ...
                nreps, stim_tip, freq_daq, stim_delay, handles, calMat, curr_action_text, stagger_time, ws_object);
           
        catch exception
%             err = lasterror;
%             errordlg(err.message,'Error');
            throw(exception);
        end
    end

%% Finalization: Ensure the GUI is in a consistent state.
    % Call the modulation mode callback to enable the appropriate controls
    modulation_mode_menu_cb(modulation_mode_menu, []);
    optctrl_mode_menu_cb(optctrl_mode_menu, []);
    optctrl_active_chbx_cb(optctrl_active_chbx, [])
end