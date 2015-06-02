% 
% Function to do Stimulus Triggered Averaging, à la Cheney & Fetz
%
%       varargout = stim_trig_avg( varargin )
%
%       Input parameters: 
%           'sta_params'        : stimulation settings. If not passed, read
%                                   from sta_params_default 
%       Outputs: 
%           'emg'               : EMG evoked by eacg simulus, and some
%                                   related information
%           'sta_params'        : stimulation parameters
%
%


% %%%%%%%%%%%%
%   Some known issues:
%       - The resistor used in the analog input is hard-coded (100 Ohm)


function varargout = stim_trig_avg( varargin )


close all;

% read parameters

if nargin > 1
    
    error('ERROR: The function only takes one argument of type StTA_params');
elseif nargin == 1
   
    sta_params                  = varargin{1};
elseif nargin == 0
    
    sta_params                  = stim_trig_avg_default();
end

if nargout > 2
    
    disp('ERROR: The function only returns two variables of type StTA_params and EMG');
end



%--------------------------------------------------------------------------
%% connect with Central 

% connect to central; if connection fails, return error message and quit
if ~cbmex('open', 1)
    
    echoudp('off');
%    close(handles.keep_running);
    error('ERROR: Connection to Central Failed');
end



% If want to save the data ...

% Note structure 'hw' will have all the cerebus and grapevine stuff
if sta_params.save_data_yn
   
    % create file name
    hw.data_dir                 = [sta_params.data_dir filesep 'STA_data_' datestr(now,'yyyy_mm_dd')];
    if ~isdir(hw.data_dir)
        mkdir(hw.data_dir);
    end
    hw.start_t                  = datestr(now,'yyyymmdd_HHMMSS');
    hw.cb.full_file_name        = fullfile( hw.data_dir, [sta_params.monkey '_' sta_params.bank '_' num2str(sta_params.stim_elecs(1)) '_' hw.start_t '_' sta_params.task '_STA' ]);

    % start 'file storage' app, or stop ongoing recordings
    cbmex('fileconfig', fullfile( hw.data_dir, hw.cb.full_file_name ), '', 0 );  
    drawnow;                        % wait till the app opens
    pause(1);
    drawnow;                        % wait some more to be sure. If app was closed, it did not always start recording otherwise

    % start cerebus file recording
    cbmex('fileconfig', hw.cb.full_file_name, '', 1);
end


% configure acquisition
cbmex('trialconfig', 1);            % start data collection
drawnow;

pause(1);                           % ToDo: see if it's necessary



% figure out how many EMG channels there are, and preallocate matrices
% accordingly. Check that there is a 'sync out' signal from the stimulator 

[ts_cell_array, ~, analog_data] = cbmex('trialdata',1);

% look for the 'sync out' signal ('Stim_trig')
hw.cb.stim_trig_ch_nbr  =  find(strncmp(ts_cell_array(:,1),'Stim',4));
if isempty(hw.cb.stim_trig_ch_nbr)
    error('ERROR: Sync signal not found in Cerebus. The channel has to be named Stim_trig');
else
    disp('Sync signal found');
    
    % define resistor to record sync pulse
    hw.cb.sync_out_resistor = 100;
end



% EMG data will be stored in the 'emg' data structure
% 'emg.evoked_emg' has dimensions EMG signal -by- EMG channel- by- stimulus
% nbr -by- cortical electrode nbr 

analog_data(:,1)            = ts_cell_array([analog_data{:,1}]',1); % ToDo: replace channel numbers with names
emg.labels                  = analog_data( strncmp(analog_data(:,1), 'EMG', 3), 1 );
emg.nbr_emgs                = numel(emg.labels); disp(['Nbr EMGs: ' num2str(emg.nbr_emgs)]), disp(' ');
emg.fs                      = cell2mat(analog_data(find(strncmp(analog_data(:,1), 'EMG', 3),1),2));
emg.length_evoked_emg       = ( sta_params.t_before + sta_params.t_after ) * emg.fs/1000 + 1;
emg.evoked_emg              = zeros( emg.length_evoked_emg, emg.nbr_emgs, sta_params.nbr_stims_ch, ...
                                numel(sta_params.stim_elecs) ); 
emg.STA                     = zeros( emg.length_evoked_emg, emg.nbr_emgs, numel(sta_params.stim_elecs) );
emg.STA_std                 = zeros( emg.length_evoked_emg, emg.nbr_emgs, numel(sta_params.stim_elecs) );

clear analog_data ts_cell_array;
cbmex('trialconfig', 0);        % stop data collection for until the stim starts



%--------------------------------------------------------------------------
%% connect with Grapevine

% initialize xippmex
hw.gv.connection            = xippmex;

if hw.gv.connection ~= 1
    cbmex('close');
    error('ERROR: Xippmex did not initialize');
end


% check if the sync out channel has been mistakenly chosen for stimulation
if ~isempty(find(sta_params.stim_elecs == sta_params.sync_out_elec,1))
    cbmex('close');
    error('ERROR: sync out channel chosen for ICMS!');
end


% find all Micro+Stim channels (stimulation electrodes). Quit if no
% stimulator is found 
hw.gv.stim_ch               = xippmex('elec','stim');

if isempty(hw.gv.stim_ch)
    cbmex('close');
    error('ERROR: no stimulator found!');
end


% quit if the specified channels (in 'sta_params.stim_elecs') do
% not exist, or if the sync_out channel does not exist 
nbr_ch_found                = 0;
for i = 1:length(sta_params.stim_elecs)
    nbr_ch_found            = nbr_ch_found + numel(find( hw.gv.stim_ch == sta_params.stim_elecs(i)));
end

if ( nbr_ch_found < length(sta_params.stim_elecs) ) % ToDo: double check syntaxis 
    cbmex('close');
    error('ERROR: specified stimulator channels not found!');
elseif isempty(find(hw.gv.stim_ch==sta_params.sync_out_elec,1))
    cbmex('close');
    error('ERROR: sync out channel not found!');
end

clear nbr_ch_found


% % SAFETY! check that the stimulation amplitude is not too large ( > 90 uA
% % or > 1 ms) 
% if sta_params.stim_ampl > 0.090
%     cbmex('close');
%     error('ERROR: stimulation amplitude is too large (> 90uA) !');    
% elseif sta_params.stim_pw > 1
%     cbmex('close');
%     error('ERROR: stimulation pulse width is too large (> 1ms) !');    
% end
   


%--------------------------------------------------------------------------
%% some preliminary stuff
% 
% % figure to plot the STAs
% sta_fig                     = struct(...
%     'h',                        figure, ...
%     't',                        -sta_params.t_before:1000/emg.fs:sta_params.t_after, ...
%     'length_t',                 (sta_params.t_after + sta_params.t_before)*emg.fs/1000 + 1, ...
%     'colors_plot',              colormap(autumn(length(sta_params.nbr_stims_ch))));
% 
% set(sta_fig.h, 'Name', 'STAed EMG');

% 
% % calculate online (high-pass) EMG filter 
% if sta_params.fc_hp_filt ~= 0     % No filter if f_c == 0
%     [emg.online_filt.b, emg.online_filt.a]  = butter(5,sta_params.fc_hp_filt/(emg.fs/2),'high');
% end


% number of 30-s epochs + duration of the last epoch (in s)
hw.cb.epoch_duration        = 10;   % epoch duration (in s)
hw.cb.nbr_epochs            = ceil(sta_params.nbr_stims_ch/sta_params.stim_freq/hw.cb.epoch_duration);
hw.cb.nbr_stims_this_epoch  = sta_params.stim_freq*hw.cb.epoch_duration;
hw.cb.ind_ev_emg            = 0;    % ptr to know where to store the evoked EMG


drawnow;


%--------------------------------------------------------------------------
%% stimulate to get STAs


for i = 1:length(sta_params.stim_elecs)
        
    %------------------------------------------------------------------
    % Define the stimulation string and start data collection

    stim_string             = [ 'Elect = ' num2str(sta_params.stim_elecs(i)) ',' num2str(sta_params.sync_out_elec) ',;' ...
                                'TL = ' num2str(sta_params.train_duration) ',' num2str(sta_params.train_duration) ',; ' ...
                                'Freq = ' num2str(sta_params.stim_freq) ',' num2str(1000/sta_params.train_duration) ',; ' ...
                                'Dur = ' num2str(sta_params.stim_pw) ',' num2str(sta_params.stim_pw) ',; ' ...
                                'Amp = ' num2str(sta_params.stim_ampl/sta_params.stimulator_resolut) ',' num2str(ceil(3/hw.cb.sync_out_resistor/sta_params.stimulator_resolut*1000)) ',; ' ...
                                'TD = ' num2str(sta_params.pre_stim_win/1000) ',' num2str(sta_params.pre_stim_win/1000) ',; ' ...
                                'FS = 0,0,; ' ...
                                'PL = 1,1,;'];

    
    for ii = 1:hw.cb.nbr_epochs

        % start data collection
        cbmex('trialconfig', 1);
        drawnow;
        drawnow;
        drawnow;
        
        %------------------------------------------------------------------
        % Stimulate the channel as many times as specified
        
        if ii == hw.cb.nbr_epochs 
            hw.cb.nbr_stims_this_epoch  = rem(sta_params.nbr_stims_ch,sta_params.stim_freq*30);
        end
        
        for iii = 1:hw.cb.nbr_stims_this_epoch

            t_start             = tic;
            drawnow;

            % send stimulation command
            xippmex('stim',stim_string);
            drawnow;
            drawnow;
            drawnow;


            % wait for the inter-stimulus interfal (defined by stim freq)
            t_stop              = toc(t_start);
            while t_stop < sta_params.ITI/1000
                t_stop          = toc(t_start);
            end
 
%             if ~ishandle(sta_fig.h)
%                 cbmex('close');
%                 disp('Execution stopped by the user');
%             end
        end


        %------------------------------------------------------------------
        % read EMG data and sync pulses

        % read the data from central (flush the data cache)
        [ts_cell_array, ~, analog_data] = cbmex('trialdata',1);
        cbmex('trialconfig', 0);
        drawnow;

        % display if some of the stim pulses were lost
        if numel(cell2mat(ts_cell_array(hw.cb.stim_trig_ch_nbr,2))) ~= hw.cb.nbr_stims_this_epoch
            disp(' ');
            disp(['Warning: ' num2str(hw.cb.nbr_stims_this_epoch - numel(cell2mat(ts_cell_array(hw.cb.stim_trig_ch_nbr,2)))) ' sync pulses lost!']);
        else
            disp(' ');
            disp(['all sync pulses succesfully detected when stimulating ch. #' num2str(sta_params.stim_elecs(i))]);
        end

        % retrieve EMG data and stimulation time stamps
        analog_data(:,1)        = ts_cell_array([analog_data{:,1}]',1);
        aux                     = analog_data( strncmp(analog_data(:,1), 'EMG', 3), 3 );

        for iii= 1:emg.nbr_emgs
            emg.data(:,iii,i)   = double(aux{iii,1}); 
        end


        % ToDo: DELETE, ONLY TO CHECK
        % check if the trigger signal and the EMG are synchronized
        ts_sync_pulses          = double(cell2mat(ts_cell_array(hw.cb.stim_trig_ch_nbr,2)));
        
        ts_sync_pulses_its_freq             = ts_sync_pulses/30000*emg.fs;
        ts_first_sync_pulse_emg_freq        = ts_sync_pulses_its_freq(find(ts_sync_pulses_its_freq<5000,1));
        analog_sync_signal                  = double(analog_data{10,3});
        
        ts_first_sync_pulse_analog_signal   = find(analog_sync_signal<-2000,1);
        
                
        if abs( ts_first_sync_pulse_analog_signal - ts_sync_pulses_its_freq(1) ) > 10
            disp('the delay between the time stamps and the analog signal is > 1 ms!!!');
            disp(['it is: ' num2str( (ts_first_sync_pulse_analog_signal - ts_sync_pulses_its_freq(1))/10 )])
        else
            disp('the delay between the time stamps and the analog signal is < 1 ms!!!');
        end
        
%         figure,plot(analog_sync_signal), hold on, xlim([0 1500]), 
%         stem(ts_sync_pulses_its_freq,ones(length(ts_sync_pulses),1)*-5000,'marker','none','color','r')
        % ToDo: DELETE UNTIL HERE
        
        
        % this is a temporal fix to ignore the data when the analog and ts are not cynhronized
        if abs( ts_first_sync_pulse_analog_signal - ts_sync_pulses_its_freq(1) ) < 10
        
            % remove the first and/or the last sync pulse if they fall outside the data
            if floor(ts_sync_pulses(1)/30000) < sta_params.t_before/1000
                ts_sync_pulses(1)   = [];
%             elseif (length(emg.data)/emg.fs - sta_params.t_after/1000) < floor(ts_sync_pulses(end)/30000) % ToDo: improve; the -10 is because sometimes it crashed because the code is different to line 324
%                 ts_sync_pulses(end) = [];
            elseif (length(emg.data) - sta_params.t_after) < floor(ts_sync_pulses(end)/30000*emg.fs)
                ts_sync_pulses(end) = [];
            end

            % This is just to check the communication, it can probably be
            % deleted
            if hw.cb.nbr_stims_this_epoch < length(ts_sync_pulses)
                disp('length(emg.evoked_emg) < length(ts_sync_pulses)');
                pause;
            end
            
            % store the evoked EMG (interval around the stimulus defined by
            % pre-stim and post-stim parameters)
            emg_win_length_in_samples = (sta_params.t_after + sta_params.t_before)*emg.fs/1000;
            
            for iii = 1:min(length(ts_sync_pulses),length(emg.evoked_emg))
                trig_time_in_emg_sample_nbr     = floor(double(ts_sync_pulses(iii))/30000*emg.fs - sta_params.t_before/1000*emg.fs);
                if (trig_time_in_emg_sample_nbr + (sta_params.t_after + sta_params.t_before)*emg.fs/1000 ) > length(emg.data)
                    disp('the last sync pulse is far too late!');
                    break;
                    drawnow;
                else
                    emg.evoked_emg(:,:,iii+hw.cb.ind_ev_emg,i)    = emg.data( trig_time_in_emg_sample_nbr : ...
                        (trig_time_in_emg_sample_nbr + emg_win_length_in_samples), :, i );
                end
            end

            hw.cb.ind_ev_emg        = length(ts_sync_pulses) + hw.cb.ind_ev_emg;  % update ptr to index

        end
        

        % delete these vars % ToDo: update
        clear analog_data ts_cell_array; 
        emg                     = rmfield(emg,'data');

    end
end



%--------------------------------------------------------------------------
% Save data and stop cerebus recordings



% Return variables
if nargout == 1
    varargout{1}            = emg;
elseif nargout == 2
    varargout{1}            = emg;
    varargout{2}            = sta_params;
end


% Save the data, if specified in sta_params
if sta_params.save_data_yn
    
    % stop cerebus recordings
    cbmex('fileconfig', hw.cb.full_file_name, '', 0);
    cbmex('close');
    drawnow;
    drawnow;
    disp('Communication with Central closed');
    
%    xippmex('close');

    % save matlab data. Note: the time in the faile name will be the same as in the cb file
    hw.matlab_full_file_name    = fullfile( hw.data_dir, [sta_params.monkey '_' sta_params.bank '_' num2str(sta_params.stim_elecs(1)) '_' hw.start_t '_' sta_params.task '_STA' ]);
    
        
    disp(' ');
    save(hw.matlab_full_file_name,'emg','sta_params');
    disp(['EMG data and Stim Params saved in ' hw.matlab_full_file_name]);
end

cbmex('close')


% Calculate the STA metrics and plot, if specified in sta_params
if sta_params.plot_yn
   
    sta_metrics             = calculate_sta_metrics( emg, sta_params );
    plot_sta( emg, sta_params, sta_metrics )
end
