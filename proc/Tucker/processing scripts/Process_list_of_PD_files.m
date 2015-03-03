
%% process PDs using Raeed/Tucker functions
close all
clear
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;

folderpath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150220_RW_PD';
input_data.prefix='Chips_20150220_RW_tucker_001-01';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% process PDs using Raeed/Tucker functions
close all
clear
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;

folderpath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150223_PD';
input_data.prefix='Chips_20150223_RW_tucker_001-01';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% process PDs using Raeed/Tucker functions
clear
close all
clear
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;

folderpath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150224_RW_PD';
input_data.prefix='Chips_20150224_RW_tucker_001-s';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% process PDs using Raeed/Tucker functions
close all
clear
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;

folderpath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150226_RW_PD';
input_data.prefix='Chips_20150226_RW_tucker_001-s';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% process PDs using Raeed/Tucker functions
close all
clear
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;

folderpath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150227_RW_PD';
input_data.prefix='Chips_20150227_RW_tucker_001-s';
data_struct = run_data_processing(function_name,folderpath,input_data);