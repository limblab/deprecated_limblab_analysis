% clear all
file_details.UF_file_prefix = 'Kevin_2013-05-31_UF_';
file_details.RW_file_prefix = 'Kevin_2013-05-31_RW_001';
file_details.datapath = 'D:\Data\Kevin_12A2\Data\';
cerebus2ElectrodesFile = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';
file_details.elec_map = cerebusToElectrodeMap(cerebus2ElectrodesFile);

reload_data = 1;
plot_behavior = 1;
plot_emg = 1;
plot_units = 0;
plot_STAEMG = 0;
plot_SSEP = 0;

if ~reload_data
    if ~exist([file_details.datapath file_details.UF_file_prefix '-bdf.mat'],'file') && (...
            ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('UF_struct','var'))
        reload_data = 1;
    elseif ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('UF_struct','var')
        load([file_details.datapath file_details.UF_file_prefix '-bdf.mat'])
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
    UF_plot_behavior(UF_struct,bdf)
end

if plot_emg
    UF_plot_EMG(UF_struct)
end

if plot_units
    UF_plot_units(UF_struct,bdf,rw_bdf);
end

if plot_SSEP
    UF_plot_SSEP(UF_struct,bdf);
end

if plot_STAEMG  % Spike triggered EMG
    UF_plot_STAEMG(UF_struct,bdf);
end
%% TODO

% poop