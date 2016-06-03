%process Han's data for PDs
%% process PDs using Raeed/Tucker functions
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;
input_data.task='RW';
input_data.offset=-.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=1;%default flag is 1
input_data.force_pd=0;%default flag is 0
input_data.prefix='Han';
%% 
folderpath='E:\local_processing\Han\stability\20141202';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% 
folderpath='E:\local_processing\Han\stability\20141203';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% 
folderpath='E:\local_processing\Han\stability\20141204';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% 
folderpath='E:\local_processing\Han\stability\20141205';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% 
folderpath='E:\local_processing\Han\stability\20141210';
data_struct = run_data_processing(function_name,folderpath,input_data);
