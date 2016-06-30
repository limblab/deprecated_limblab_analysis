function out_struct = run_optimal_control(varargin)

%% Load data from input
    source                = varargin{1};
    optctrl_active_chbx   = varargin{2};
    all_optctrl           = varargin{3};
    saveFilename_calmat   = varargin{4};
    stim_channel_active   = varargin{5};
    stim_channel_amp      = varargin{6};
    abort                 = varargin{7};
    EMG_labels            = varargin{8};
    EMG_enable            = varargin{9};
    handles               = varargin{10};
    calMat                = varargin{11};
    curr_action_text      = varargin{12};
    save_status_text      = varargin{13};
    avIN                  = varargin{14};
    
    is_opt = avIN.is_opt;
    optctrl_np = avIN.optctrl_np;
    optctrl_auto = avIN.optctrl_auto;
    time_window = [avIN.platONoptctrl avIN.platOFFoptctrl];
    level_act = avIN.level_act;
    optctrl_nr = avIN.optctrl_nr;
    is_active = avIN.is_active;
    delay = avIN.delay;
    mode = avIN.mode;
    pws = avIN.pws;
    freq = avIN.freq;
    pulses = avIN.pulses;    
    rec_duration = avIN.rec_duration;
    is_mod = avIN.is_mod;
    mults = avIN.mults;
    num_reps = avIN.num_reps;
    stim_tip = avIN.stim_tip;
    freq_daq = avIN.freq_daq;
    optctrl = avIN.optctrl;
    optctrl_stagger = avIN.optctrl_stagger;
    optctrl_stagger_time = avIN.optctrl_stagger_time;
    optctrl_mode = avIN.optctrl_mode;
    c = [avIN.cost_r avIN.cost_q];

%% Make sure recruitment curve data (amp modulation) exists - ask user
    % Construct a questdlg with three options
    choice = questdlg('Would you like to use previous recruitment curves?', ...
	'Old or new rcurves', ...
	'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            [file_name_optctrl{1},path_name_optctrl{1}] = uigetfile('','Select old recruitment curve');
            load(strcat(path_name_optctrl{1},file_name_optctrl{1}));
        case 'No'
            rcurve = [];
            % Allow for multiple files to be loaded
            load_another = 1; % true to load the first file
            num_amp_datasets = 1; % initial number of files
            while load_another
                % Select amplitude modulation data to build recruitment curves
                [file_name_optctrl{num_amp_datasets},path_name_optctrl{num_amp_datasets}] = uigetfile('','Select data to form recruitment curve');
                if (isequal(file_name_optctrl,0) || isequal(path_name_optctrl,0)); 
                    msgbox('Recruitment curve data does not exist OR not selected','Please try again!','warn');
                    set(source,'Value',get(source,'Min')); % pop the button back out
                    set(optctrl_active_chbx,'Value',0)
                    set(all_optctrl,'Enable','off');
                    return;
                else
                    fprintf('\nRecruitment data successfully identified!\n')
                    fprintf('\nBeginning optimal control....\n')
                end 
                % Ask user if he would like to load another file
                % Construct a questdlg with three options
                choice = questdlg('Select another file?', 'Additional amp modulation data', 'Yes','No','No');
                % Decide what to do next based on response
                switch choice
                    case 'Yes'
                        load_another = 1;
                        num_amp_datasets = num_amp_datasets + 1;
                    case 'No'
                        load_another = 0;
                end
            end
    end
%% Determine which muscles are used for optimal control - those that are active AND selected for optimal control
vecGood = find(is_opt>0 & is_active>0);

%% Determine desired forces and optimal commands
switch optctrl_mode
    case 'force_mag'
        [optctrl_struct,rcurve] = optctrl_prep(path_name_optctrl,file_name_optctrl,saveFilename_calmat,optctrl_np,optctrl_auto,time_window,level_act,vecGood,c,rcurve);
    case 'fx_fy'
        [optctrl_struct,rcurve] = optctrl_prep_fxfy(path_name_optctrl,file_name_optctrl,saveFilename_calmat,optctrl_np,optctrl_auto,time_window,level_act,vecGood,c,rcurve);
    case 'force_stats'
        [optctrl_struct,rcurve] = optctrl_prep_sampling(path_name_optctrl,file_name_optctrl,saveFilename_calmat,optctrl_np,optctrl_auto,time_window,level_act,vecGood,c,rcurve);
end
optctrl_struct.optctrl_mode = optctrl_mode;

%% Ask user to select file to save optimal control data
pathname4optctrl = uigetdir(path_name_optctrl{1},'Select folder to save optctrl files');
hfigoptctrl = figure('Name','Optimal control preliminary results','NumberTitle','off');

% Save general variables into same file
save(fullfile(pathname4optctrl, 'opt_ctrl_general'),'rcurve','optctrl_struct');

%% Run optimal control
for nr = 1:optctrl_nr
    % Randomize desired forces
    z = randperm(numel(1:optctrl_np)); % this will generate random arrangement of indices 
    optctrlParams = optctrl_struct.paramsOPTIMAL(:,z);
    optctrlFdes = optctrl_struct.ctrlPts(z,:);

    % Optimal control stimulation - loop through each point
    for oo = 1:optctrl_np
        % Automatically load amps to each channel 
        nmusc_optctrl = length(is_active);
        is_active = zeros(1,nmusc_optctrl);
        is_active(optctrl_struct.indorig) = 1;

        amps = zeros(1,nmusc_optctrl);
        amps(optctrl_struct.indorig) = optctrlParams(:,oo);

        % Display in GUI - active channels and current amps
        for pp=1:nmusc_optctrl
            set(stim_channel_active(pp),'Value',is_active(pp));
            set(stim_channel_amp(pp),'String',num2str(amps(pp)));
        end

        % Run stimulation for optimal control to force oo
        out_struct.time = clock;
%         [out_struct.data, out_struct.sample_rate, out_struct.act_ch_list] = ...
%             run_stimplan(abort, mode, amps, pws, freq, pulses, rec_duration,...
%             is_mod, is_active, mults, EMG_labels, EMG_enable,num_reps,...
%             stim_tip,freq_daq,delay,handles,calMat,curr_action_text,optctrl,...
%             optctrl_stagger,optctrl_stagger_time,[]);
        avIN.amps = amps;
        [out_struct.data, out_struct.sample_rate, out_struct.act_ch_list] = run_stimplan(abort,avIN,EMG_labels,EMG_enable,handles,calMat,curr_action_text);
        
        
        out_struct.mode = avIN.mode;
        out_struct.base_amp = avIN.amps;
        out_struct.base_pw = avIN.pws;
        out_struct.freq = avIN.freq;
        out_struct.pulses = avIN.pulses;
        out_struct.is_channel_modulated = avIN.is_mod;
        out_struct.modulation_channel_multipliers = avIN.mults;
        out_struct.emg_labels = EMG_labels(EMG_enable);
        out_struct.emg_enable = EMG_enable;
        out_struct.daq_freq = avIN.freq_daq;
        out_struct.num_reps = avIN.num_reps;
        out_struct.stim_tip = avIN.stim_tip;
        out_struct.is_active = avIN.is_active;
        out_struct.calmat = calMat;
        out_struct.mod_wind = avIN.mod_window;
        out_struct.baseline = avIN.baseline;
        out_struct.fdes = optctrlFdes(oo,:);
        
%         out_struct.mode = mode;
%         out_struct.base_amp = amps;
%         out_struct.base_pw = pws;
%         out_struct.freq = freq;
%         out_struct.pulses = pulses;
%         out_struct.is_channel_modulated = is_mod;
%         out_struct.modulation_channel_multipliers = mults;
%         out_struct.emg_labels = EMG_labels(EMG_enable);
%         out_struct.emg_enable = EMG_enable;
%         out_struct.daq_freq = freq_daq;
%         out_struct.num_reps = num_reps;
%         out_struct.stim_tip = stim_tip;
%         out_struct.is_active = is_active;
%         out_struct.calmat = calMat;
%         out_struct.fdes = optctrlFdes(oo,:);
%         out_struct.stagger = optctrl_stagger;
%         out_struct.stagger_time = optctrl_stagger_time;


        % Automatically save data from file
        filename4optctrl = strcat('opt_ctrl_rep_',num2str(nr),'_',num2str(oo));
        save(fullfile(pathname4optctrl, filename4optctrl), 'out_struct');
        set(save_status_text, 'String', sprintf('Saved to: %s', filename4optctrl));
        set(save_status_text, 'TooltipString', fullfile(pathname4optctrl, filename4optctrl));
        default_save_path = pathname4optctrl;
        data_has_been_saved = 1;

        % Plot preliminary result comparing actual force to
        % desired force
        compare_opt_forces(out_struct,time_window,hfigoptctrl);

        % Pause after every stim to prevent fatigue
        hWaitBar = waitbar(0,sprintf('Preventing fatigue, opt ctrl, rep:%g, fdes:%g',nr,oo));
        goAhead = 1;
        startTime = clock;          
        while goAhead == 1
            % Compute how much time has elapsed
            tempTime = etime(clock,startTime);
            % Determine whether to abort or update waitbar
            if tempTime > delay
                % End delay
                goAhead = 0;
                waitbar(1,hWaitBar);
            else
                % Update waitbar
                waitbar(tempTime/delay,hWaitBar);
            end
        end
        delete(hWaitBar);
    end           
end