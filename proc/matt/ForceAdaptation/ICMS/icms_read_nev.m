function icms_read_nev(filenames,params)

% will cycle along multiple files and group them together
% note: assumes that an electrode only appears in one file
% switch date
%     case '02112016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_11\';
%         filenames = {'Jaco_A_1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31_20160211_145943_CO_TTA','001'};
%         % filenames = {'Jaco_A_29_20160211_153203_CO_TTA', '002'};
%         tuning_filename = ['F:\Jaco\Processed\2016-02-15\M1_tuning\CO_CS_movement_regression_' which_tuning '_2016-02-15.mat'];
%         bank = 'A';
%     case '02152016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_15\';
%         filenames = {'Jaco_A_19  31  21  28  23  26  13  29  11   5   4_20160215_154921_CO_TTA', '002'};
%         % filenames = {'Jaco_A_19  31  28  23  11_20160215_161144_CO_TTA', '003'};
%         tuning_filename = ['F:\Jaco\Processed\2016-02-15\M1_tuning\CO_CS_movement_regression_' which_tuning '_2016-02-15.mat'];
%     case '02172016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_17\';
%         filenames = {'Jaco_A_24  31  28  29  26  27  25  20_20160217_132032_CO_TTA', '003'; ...
%             'Jaco_C_15  17  28  21   2  31  29   5  18  19_20160217_134136_CO_TTA', '004'; ...
%             'Jaco_B_28  25  24  29_20160217_141029_CO_TTA','005'};
%         tuning_filename = ['F:\Jaco\Processed\2016-02-17\M1_tuning\CO_CS_movement_regression_' which_tuning '_2016-02-17.mat'];
%     case '02182016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_18\';
%         filenames = {'Jaco_B_4   6   7   9  10  11  12  15  16  18  19  20  22  23_20160218_111411_CO_TTA', '002'; ...
%             'Jaco_C_4   6   7   9  13  27   5_20160218_115221_CO_TTA', '003'; ...
%             'Jaco_A_8  30_20160218_121432_CO_TTA','004'};
%         tuning_filename = ['F:\Jaco\Processed\2016-02-18\M1_tuning\CO_CS_movement_regression_' which_tuning '_2016-02-18.mat'];
%     case '02222016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_22\';
%         filenames = {'Jaco_A_19  20_20160222_154317_CO_TTA','001'; ...
% %             'Jaco_A_19  20_20160222_160919_CO_TTA','002'; ...
%             'Jaco_A_19  20_20160222_161548_CO_TTA','003'; ...
%             'Jaco_A_19  20_20160222_163204_CO_TTA','004'; ...
%             'Jaco_A_19  20_20160222_164532_CO_TTA','005'; ...
%             'Jaco_A_19  20_20160222_165814_CO_TTA','006'};
%         tuning_filename = [];
%     case '02232016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_23\';
%         filenames = {'Jaco_C_10  20_20160223_113126_CO_TTA','001'};
%         tuning_filename = [];
%     case '02242016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_24\';
%         filenames = {'Jaco_C_10  28_20160224_133438_CO_TTA','001'; ...
%             'Jaco_C_10_20160224_134917_CO_TTA','002'; ...
%             'Jaco_C_10_20160224_143328_CO_TTA','003'; ...
%             'Jaco_C_10_20160224_144205_CO_TTA','004'; ...
%             'Jaco_C_10_20160224_144638_CO_TTA','005'; ...
%             'Jaco_C_10_20160224_145858_CO_TTA','006'};
%         tuning_filename = [];
%     case '02252016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_25\';
%         filenames = {'Jaco_C_6   9  13_20160225_104957_CO_TTA','001'; ...
%             'Jaco_C_6  13_20160225_110219_CO_TTA','002'; ...
%             'Jaco_C_6  13_20160225_115422_CO_TTA','003'; ...
%             'Jaco_C_6  13_20160225_121040_CO_TTA','004'};
%         tuning_filename = [];
%     case '02262016'
%         file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_26\';
%         filenames = {'Jaco_C_1  14  15  16  17  18  19  20  21  22  24  26  27  28  29  30  31_20160226_132112_CO_TTA','001'; ...
%             'Jaco_A_1   2   4   6   9  10  11  12  13  14  16  18  19  22  23  24  27  30_20160226_135648_CO_TTA','002'; ...
%             'Jaco_B_25  26  27  28  31_20160226_143513_CO_TTA','003'};
%         tuning_filename = [];
% end

convert_bdf = false;
strip_bdf = false;
process_stim_data = false;

file_dir = params.file_dir;
pulse_thresh = params.pulse_thresh;
sync_samp_freq = params.sync_samp_freq;
kin_samp_freq = params.kin_samp_freq;
time_before = params.time_before; % time before sync pulse in sec
time_after  = params.time_after; % time after sync pulse in sec

error_flag = 0;

%% Make sure a BDF exists for each file
for iFile = 1:size(filenames,1)
    filename = filenames{iFile,1};
    cerebus_number = filenames{iFile,2};
    
    if convert_bdf || ~exist(fullfile(file_dir,[filename cerebus_number '_bdf.mat']),'file')
        % convert file to BDF
        bdf = get_cerebus_data(fullfile(file_dir,[filename cerebus_number '.nev']),'verbose',3);
        save(fullfile(file_dir,[filename cerebus_number '_bdf.mat']),'bdf','-v7.3');
    end
    
    if strip_bdf || ~exist(fullfile(file_dir,[filename cerebus_number '_bdf_stripped.mat']),'file')
        % downsample kinematics?
        bdf.pos = downsample(bdf.pos,round(sync_samp_freq/kin_samp_freq));
        bdf.vel = downsample(bdf.vel,round(sync_samp_freq/kin_samp_freq));
        bdf.acc = downsample(bdf.acc,round(sync_samp_freq/kin_samp_freq));
        bdf.force = downsample(bdf.force,round(sync_samp_freq/kin_samp_freq));
        
        bdf = rmfield(bdf,'good_kin_data');
        bdf = rmfield(bdf,'analog');
        bdf.raw = rmfield(bdf.raw,'enc');
        
        save(fullfile(file_dir,[filename cerebus_number '_bdf_stripped.mat']),'bdf','-v7.3');
    end
    
    % get timestamps of grapevine sync pulse
    if process_stim_data || ~exist(fullfile(file_dir,[filename cerebus_number '_stim_data.mat']),'file')
        if ~exist('bdf','var')
            if exist(fullfile(file_dir,[filename cerebus_number '_bdf_stripped.mat']),'file')
                load(fullfile(file_dir,[filename cerebus_number '_bdf_stripped.mat']));
            elseif ~exist('bdf','var')
                load(fullfile(file_dir,[filename cerebus_number '_bdf.mat']));
            end
        end
        
        % get continuous sync pulse data
        sync_data = bdf.raw.analog.data{strcmpi(bdf.raw.analog.channels,'Stim_trig')};
        
        % identify threshold crossings
        idx = sync_data > pulse_thresh;
        % find times and convert to seconds
        pulse_times = find(diff(idx) > 0)/sync_samp_freq;
        clear idx sync_data;
        
        % get electrode IDs of each pulse
        load(fullfile(file_dir,[filename '.mat']));
        
        % align pos, vel, force on sync pulse
        % loop along identified pulses
        
        if length(pulse_times) ~= size(force.stimulated_channels,1)
            disp(' '); disp(' ');
            warning('WARNING: the number of pulses in the analog signal does not match the attempted stimulations');
            disp(' ');
                        disp('Only using what stim pulses were found in the data.');
                        force.stimulated_channels = force.stimulated_channels(1:length(pulse_times),:);
%             disp('Using saved Matlab data.');
%             pulse_times = force.stimulated_channels(:,1);
%             error_flag = 1;
        end
        
        % if we are using the Matlab structure...
        if error_flag
            stim_counter = zeros(1,length(ttap.stim_elec));
        end
        
        num_samples = [floor(time_before*kin_samp_freq),floor(time_after*kin_samp_freq)];
        % if they match, just assume that the order of everything works out
        tic;
        stim_data = repmat(struct(),1,length(pulse_times)-1);
        for iPulse = 1:length(pulse_times)-1
            
            if error_flag % if we are loading from .mat struct
                
                stim_data(iPulse).channel = force.stimulated_channels(iPulse,2);
                stim_data(iPulse).pulsetime = pulse_times(iPulse);
                stim_data(iPulse).timestamp = force.stimulated_channels(iPulse,1);
                stim_data(iPulse).pos = [];
                stim_data(iPulse).vel = [];
                
                idx = find(ttap.stim_elec == force.stimulated_channels(iPulse,2));
                stim_counter(idx) = stim_counter(idx) + 1;
                
                temp_force = squeeze(force.evoked_force(:,:,stim_counter(idx),idx));
                
                % now, convert 6-D force into 2-D force, if necessary
                if size(temp_force,2) > 2 % lab 3
                    % now turn force into 2d signal
                    fhcal = [-0.0129 0.0254 -0.1018 -6.2876 -0.1127 6.2163;...
                        -0.2059 7.1801 -0.0804 -3.5910 0.0641 -3.6077]'./1000;
                    f = zeros(size(temp_force,1),2,size(temp_force,3));
                    for idx_stim = 1:size(temp_force,3)
                        f(:,:,idx_stim) = squeeze(temp_force(:,:,idx_stim)) * fhcal;
                    end
                end
                
                stim_data(iPulse).force = f;
                
            else % if we are reading from continuous data
                
                stim_idx = find(bdf.pos(:,1) >= pulse_times(iPulse),1,'first');
                
                idx = stim_idx-num_samples(1):stim_idx+num_samples(2);
                zero_pad = [];
                if idx(end) > size(bdf.pos,1)
                    zero_pad = zeros(1,idx(end)-size(bdf.pos,1));
                    idx = stim_idx-num_samples(1):size(bdf.pos,1);
                end
                
                p = [bdf.pos(idx,2:3); repmat(zero_pad',1,2)];
                v = [bdf.vel(idx,2:3); repmat(zero_pad',1,2)];
                f = [bdf.force(idx,2:3); repmat(zero_pad',1,2)];
                
                %idx = bdf.pos(:,1) >= (pulse_times(iPulse) - time_before) & bdf.pos(:,1) <= (pulse_times(iPulse) +time_after);
                stim_data(iPulse).channel = force.stimulated_channels(iPulse,2);
                stim_data(iPulse).pulsetime = pulse_times(iPulse);
                stim_data(iPulse).timestamp = force.stimulated_channels(iPulse,1);
                stim_data(iPulse).pos = p;
                stim_data(iPulse).vel = v;
                stim_data(iPulse).force = f;
            end
        end
        toc
        save(fullfile(file_dir,[filename cerebus_number '_stim_data.mat']),'stim_data');
    end
end
clear bdf iPulse stim_data num_samples filename cerebus_number idx stim_idx pulse_times iFile;