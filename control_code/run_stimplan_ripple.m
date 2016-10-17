function [data, sample_rate, active_channel_list] = run_stimplan(abort,avIN,EMG_labels,EMG_enable,handles,calMat,curr_action_text, ws_object)

%[data procdata_a]  = run_stimplan(recruit_bin, base_channel_amp, base_channel_pw, modulation_bins, stim_freq, stim_pulses, timewindow [, PA_bin, modulation_multipliers])
%   data            = raw data collected in each repetition set, from each
%   channel.
%   procdata_a      = data from each repetition within each repetition set 
%                     integrated across given time window to get measure of response.
%   recruit_bin     = whether or not it's being called to run a recruitment test.
%   base_channel_amp= 1x16 vector of stimulation current for each channel.
%   base_channel_pw = 1x16 vector of stimulation pulsewidth for each channel.
%   stim_freq       = frequency of stimulation.
%   stim_pulses     = how many pulses to run in each set (basically number of
%                     repetitions to run for each stimulus parameter set).
%   rec_duration    = duration of the recording(s) (ms)
%   is_channel_modulated = whether to vary pulse amplitude or current intensity in each stim channel
%   modulation_multipliers = range to cycle through for PA or PW, in mA or us
%                     respectively, according to prior binary selection.
%                     i.e. "0, [0.2:0.1:2]" would be 0.2*pulsewidth through 2*pulsewidth in
%                     increments of 0.1*pulsewidth
%   EMG_labels      = cell array of 8 strings containing EMG labels
%   EMG_enable:     = 1x8 boolean vector to identify which muscles to plot
%   nreps           = number of repetitions of stimulus
%   stim_tip        = interphase delay in stimulus (mSec)
%   freq_daq        = data acquisition frequency (Hz)
%   stim_delay      = delay between subsequent stimulations in seconds
%Basic components:
%UPDATE stimrec INFO
%   "stimrec" is the basic DAQ function; you give it the parameters of a
%   train, it runs the train and pulls EMG data from the card.
%
%[emg_average] = emgproc_fns(emg_data, stimpulses, timewindow)
%   "emgproc_fns" is a simple processing function that takes each chunk
%   collected post-trigger in "stimrec" and integrates an appropriate
%   segment of the data to pull peak EMGs. 
%
% Once "stimrec" has finished, emgproc_fns will be called to process the
% data and, potentially, provide pretty graphs.  
%
%Currently these are the only two subsidiary functions.
%
% Basic layout:
% get GUI input
% run selected GUI command/collect data (loop for alt settings)
% process data
%
%[data procdata_a] = run_stimplan(recruit_bin, base_channel_amp, base_channel_pw, is_channel_modulated, stim_freq, stim_pulses, timewindow [, PA_bin, modulation_multipliers])

%% Extract all variables from structure
    mode = avIN.mode;
    base_channel_amp = avIN.amps;
    base_channel_pw = avIN.pws;
    stim_freq = avIN.freq;
    stim_pulses = avIN.pulses;
    rec_duration = avIN.rec_duration;
    is_channel_modulated = avIN.is_mod;
    is_channel_active = avIN.is_active;
    modulation_multipliers = avIN.mults;
    nreps = avIN.num_reps;
    stim_tip = avIN.stim_tip;
    freq_daq = avIN.freq_daq;
    stim_delay = avIN.delay;
    optctrl = avIN.optctrl;
    stagger = avIN.optctrl_stagger;
    stagger_time = avIN.optctrl_stagger_time;
    mod_wind = avIN.mod_window;
    sample_rate = freq_daq;

%% Process and validate the arguments
    % Ensure the mode is valid
    mode_tmp = 'static_pulses';
    if (strcmp(mode,'mod_amp') && any(is_channel_modulated)); mode_tmp = 'mod_amp'; end;
    if (strcmp(mode,'mod_pw' ) && any(is_channel_modulated)); mode_tmp = 'mod_pw';  end;
    if (strcmp(mode,'static_train')); mode_tmp = 'static_train'; end;
    mode = mode_tmp;

%% Run the stimulation
    stim_pulses = stim_pulses*ones(1,length(is_channel_modulated));
    active_channel_count = sum(is_channel_active);
    active_channel_list = find(is_channel_active==1);

    % A static stimulation with a single pulse OR a static train stimulation; one train of pulses, one recording
    if (strcmp(mode,'static_pulses')) || (strcmp(mode,'static_train'))
        % If this is during optimal control and there is a stagger in stimulation to see individual muscle forces
        if optctrl && stagger
            % modify stim_pulses to create stagger
            % randomize active channel list
            z = randperm(numel(1:active_channel_count));
            active_channel_list_random = active_channel_list(z); % this will generate random arrangement of indices 
            stim_pulses_upd = stim_pulses(1);
            add_pulses = floor((stagger_time/1e3)*stim_freq);
            for ii = 1:active_channel_count
                stim_pulses(active_channel_list_random(ii)) = stim_pulses_upd;
                stim_pulses_upd = stim_pulses_upd + add_pulses;
            end
            active_channel_list_random = fliplr(active_channel_list_random);
            active_channel_list = active_channel_list_random;
        end

        % Run stimulation
        [data, sample_rate] = stimrec_ripple(abort, base_channel_amp, base_channel_pw, stim_freq, stim_pulses, rec_duration, mode, is_channel_active, EMG_labels, EMG_enable, nreps, stim_tip, freq_daq, stim_delay, handles, calMat, curr_action_text,stagger_time, ws_object);

    else
        % No stagger or optimal control!
        stagger_time = 0.00001;

        % Determine number of channels with desired modulation
        ind = find(is_channel_modulated == 1);
        data{length(modulation_multipliers),length(ind)} = 0;
        for i = 1:length(modulation_multipliers)
            % PULSE AMPLITUDE MODULATION
            if (strcmp(mode,'mod_amp'))
                pulseamps_temp = base_channel_amp + (base_channel_amp.*repmat(modulation_multipliers(i)-1,1,16).*is_channel_modulated);
                
                %TODO: get rid of this loop, it's an inefficient way to do
                %it with ripple.
                for j = 1:length(ind) 
                    pulseamps_IN = pulseamps_temp(ind(j)); %get amps from correct channel
                    base_channel_pw_IN = base_channel_pw(ind(j)); 
                    is_channel_active = zeros(1, length(pulseamps_temp)); 
                    is_channel_active(ind(j)) = 1; 
                    ws_object.set_Run(ws_object.run_stop, 1:16); %make sure it's not going to run until the params are set
%                     pulseamps_IN = zeros(1,length(pulseamps_temp));
%                     pulseamps_IN(ind(j)) = pulseamps_temp(ind(j));
%                     base_channel_pw_IN = zeros(1,length(base_channel_pw));
%                     base_channel_pw_IN(ind(j)) = base_channel_pw(ind(j));
                    if j<length(ind)
                        stim_delay_IN = 0;              % delay (sec) between stim to different muscles
                    else
                        stim_delay_IN = stim_delay;     % delay (sec) between stim when changing stim parameters
                    end
                    [data{i,j}, sample_rate] = stimrec_ripple(abort, pulseamps_IN, base_channel_pw_IN, stim_freq, stim_pulses, rec_duration, mode, is_channel_active, EMG_labels, EMG_enable, nreps, stim_tip, freq_daq, stim_delay_IN, handles, calMat, curr_action_text, stagger_time, ws_object);

                    % plot point(s) on recruitment curve
                    platON = avIN.platON; platOFF = avIN.platOFF; 
                    plot_trial_recruitment(data{i,j},pulseamps_IN,EMG_labels(ind),j,EMG_enable,calMat,freq_daq,platON,platOFF,stim_pulses,mode,avIN.baseline);
                    %plot_trial_recruitment(data{i,j},pulseamps_IN(ind(j)),EMG_labels(ind),j,EMG_enable,calMat,freq_daq,platON,platOFF,stim_pulses,mode,avIN.baseline);
                end
%             % PULSE-WIDTH MODULATION
%             elseif (strcmp(mode,'mod_pw'))
%                 pulsewidths_temp = base_channel_pw + (base_channel_pw.*repmat(modulation_multipliers(i)-1,1,16).*is_channel_modulated);
%                 for j = 1:length(ind)
%                     pulsewidths_IN = zeros(1,length(pulsewidths_temp));
%                     pulsewidths_IN(ind(j)) = pulsewidths_temp(ind(j));
%                     base_channel_amp_IN = zeros(1,length(base_channel_amp));
%                     base_channel_amp_IN(ind(j)) = base_channel_amp(ind(j));
%                     if j<length(ind)
%                         stim_delay_IN = 0;              % delay (sec) between stim to different muscles
%                     else
%                         stim_delay_IN = stim_delay;     % delay (sec) between stim when changing stim parameters
%                     end
%                     [data{i,j}, sample_rate] = stimrec(abort, base_channel_amp_IN, pulsewidths_IN, stim_freq, stim_pulses, rec_duration, mode, is_channel_active, EMG_labels, EMG_enable, nreps, stim_tip, freq_daq, stim_delay_IN, handles, calMat, curr_action_text);
% 
%                     % plot point(s) on recruitment curve
%                     platON = mod_wind(1); platOFF = mod_wind(2); 
%                     plot_trial_recruitment(data{i,j},pulsewidths_IN(ind(j)),length(ind),j,EMG_enable,calMat,freq_daq,platON,platOFF,stim_pulses,mode);
%                 end 
            end
        end
    end












