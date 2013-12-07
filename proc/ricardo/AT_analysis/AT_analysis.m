

file_details.datapath = 'D:\Data\Kevin_12A2\Data\';
file_details.AT_file_prefix = 'Kevin_2013-12-06_AT_';
file_details.RW_file_prefix = [];
file_details.RW_file_prefix = '';
cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';
file_details.rot_handle = 1; 

% file_details.datapath = 'D:\Data\Mini_7H1\';
% file_details.AT_file_prefix = 'Mini_2013-10-23_AT_';
% file_details.RW_file_prefix = '';
% file_details.RW_file_prefix = '';
% cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Mini 7H1\Blackrock array info\1025-0592.cmp';
% file_details.rot_handle = 1; 

% file_details.datapath = 'D:\Data\TestData\';
% file_details.AT_file_prefix = 'Test_2013-08-28_AT_001';
% file_details.RW_file_prefix = '';

file_details.elec_map = read_cmp(cmp_file);

% All files before June 19, 2013 use non-rotated handle
filedate = datenum(cell2mat(regexp(file_details.AT_file_prefix,'\d\d\d\d-\d\d-\d\d','match')));
if filedate < datenum('2013-06-19')
    file_details.rot_handle = 0;
end

reload_data = 1;
plot_behavior = 1;
plot_emg = 1;
plot_units = 1;
plot_STAEMG = 0;
plot_SSEP = 0;
save_figs = 0;

wrong_file_loaded = 0;
if exist('AT_struct','var')
    if ~strcmp(file_details.AT_file_prefix,AT_struct.AT_file_prefix)
        wrong_file_loaded = 1;
    end
end
     
if ~reload_data || wrong_file_loaded
    if ~exist([file_details.datapath file_details.AT_file_prefix '-bdf.mat'],'file') && (...
            ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('AT_struct','var'))
        reload_data = 1;
    elseif ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('AT_struct','var') || wrong_file_loaded
        if exist([file_details.datapath file_details.AT_file_prefix '-bdf.mat'],'file')
            load([file_details.datapath file_details.AT_file_prefix '-bdf.mat'])    
        else
            reload_data = 1;
        end
    end
end

if reload_data
    clear bdf rw_bdf AT_struct
end
    
if ~(exist('bdf','var') && exist('rw_bdf','var') && exist('AT_struct','var') && ~reload_data)
    [bdf,rw_bdf,AT_struct] = AT_load_data(file_details,reload_data);
else
    disp('Data already in memory, not reloading');
end

filepath = 'D:\Data\Kevin_12A2\Data';
filelist = dir([filepath '\Kevin_2013-04-02_AT*.nev']);


cerebus2ElectrodesFile = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';

if plot_behavior
    AT_plot_behavior(AT_struct,bdf,file_details,save_figs)
end

if plot_emg
    AT_plot_EMG(AT_struct,save_figs)
end

if plot_units
    AT_plot_units(AT_struct,bdf,rw_bdf,save_figs)
end