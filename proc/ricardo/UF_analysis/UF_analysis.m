% clear all

% file_details.datapath = 'D:\Data\Kevin_12A2\Data\';
% file_details.UF_file_prefix = 'Kevin_2013-10-18_UF_';
% file_details.RW_file_prefix = [];
% file_details.RW_file_prefix = '';
% cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';
% file_details.rot_handle = 1; 

file_details.datapath = 'D:\Data\Mini_7H1\';
file_details.UF_file_prefix = 'Mini_2013-11-22_UF_';
file_details.RW_file_prefix = '';
file_details.RW_file_prefix = '';
cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Mini 7H1\Blackrock array info\1025-0592.cmp';
file_details.rot_handle = 1; 

% file_details.datapath = 'D:\Data\Kramer_10I1\';
% file_details.UF_file_prefix = 'Kramer_2013-08-30_UF_';
% file_details.RW_file_prefix = 'Kramer_2013-08-30_RW_';
% cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kramer 10I1\Kramer sept 2012 implant array mapping\6251-0922.cmp';
% file_details.rot_handle = 0; 

% file_details.datapath = 'D:\Data\TestData\';
% file_details.UF_file_prefix = 'Test_2013-08-28_UF_001';
% file_details.RW_file_prefix = '';

file_details.elec_map = read_cmp(cmp_file);

% All files before June 19, 2013 use non-rotated handle
filedate = datenum(cell2mat(regexp(file_details.UF_file_prefix,'\d\d\d\d-\d\d-\d\d','match')));
if filedate < datenum('2013-06-19')
    file_details.rot_handle = 0;
end

reload_data = 0;
plot_behavior = 0;
plot_emg = 0;
plot_units = 0;
plot_STAEMG = 0;
plot_SSEP = 0;
plot_decode = 0;
decode_input = {'kinematics','emg','units'};
save_figs = 1;

wrong_file_loaded = 0;
if exist('UF_struct','var')
    if ~strcmp(file_details.UF_file_prefix,UF_struct.UF_file_prefix)
        wrong_file_loaded = 1;
    end
end
     
if ~reload_data || wrong_file_loaded
    if ~exist([file_details.datapath file_details.UF_file_prefix '-bdf.mat'],'file') && (...
            ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('UF_struct','var'))
        reload_data = 1;
    elseif ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('UF_struct','var') || wrong_file_loaded
        if exist([file_details.datapath file_details.UF_file_prefix '-bdf.mat'],'file')
            load([file_details.datapath file_details.UF_file_prefix '-bdf.mat'])    
        else
            reload_data = 1;
        end
    end
end

if reload_data
    clear bdf rw_bdf UF_struct
end
    
if ~(exist('bdf','var') && exist('rw_bdf','var') && exist('UF_struct','var') && ~reload_data)
    [bdf,rw_bdf,UF_struct] = UF_load_data(file_details,reload_data);
else
    disp('Data already in memory, not reloading');
end

if plot_behavior
    UF_plot_behavior(UF_struct,bdf,file_details,save_figs)    
end

if plot_emg
    UF_plot_EMG(UF_struct,save_figs)
end

if plot_units
    UF_plot_units(UF_struct,bdf,rw_bdf,save_figs);
end

if plot_SSEP
    UF_plot_SSEP(UF_struct,bdf,save_figs);
end

if plot_STAEMG  % Spike triggered EMG
    UF_plot_STAEMG(UF_struct,bdf,save_figs);
end

if plot_decode
    for iInput = 1:length(decode_input)
        UF_decode(decode_input{iInput},UF_struct,bdf,save_figs);
    end
end


%% TODO

% poop