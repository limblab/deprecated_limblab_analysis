%% process Chips two workspace data
folder='F:\Box Sync\Research\Multiworkspace\Data\Chips_20151202\';
clear options
options.prefix='Chips_20151202_RW';
options.only_sorted=1;
function_name='compare_workspace_PDs';
options.labnum=6;
options.dual_array = 0;

dbstop if error
output_data_20151202 = run_data_processing(function_name,folder,options);
dbclear if error

%% rotate empirical tuning curves
folder='F:\Box Sync\Research\Multiworkspace\Data\Chips_20151202\';
clear options
options.prefix='Chips_20151202_RW';
options.only_sorted=1;
function_name='rotate_tuning_curves';
options.labnum=6;
options.dual_array = 0;
% [bdf_DL,bdf_PM] = split_workspaces(folder, options);
% options.bdf_DL = bdf_DL;
% options.bdf_PM = bdf_PM;

dbstop if error
output_data_rotate=run_data_processing(function_name,folder,options);
dbclear if error

%% process dual array single units
folder='Y:\Han_13B1\Processed\experiment_20141210_twoRW\';
clear options
options.prefix='Han_20141210_RW';
options.only_sorted=1;
function_name='compare_workspace_PDs';
options.labnum=6;
options.dual_array = 1;
options.array_break = 64;

output_data_20141210 = run_data_processing(function_name,folder,options);

%% Get raw tuning curves
% folder='Y:\Han_13B1\Processed\experiment_20141210_twoRW\';
% clear options
% options.prefix='Han_20141210_RW';
% options.only_sorted=1;
% function_name='get_tuning_curves';
% options.labnum=6;
% options.plot_curves=0;
% 
% options.bdf = bdf_PM;
% 
% % output_data = run_data_processing(function_name,folder,options);
% [~,tuning_curves] = get_tuning_curves(folder,options);

%% process dual array single units
folder='Y:\Han_13B1\Processed\experiment_20141205_twoRW';
clear options
options.prefix='Han_20141205';
options.only_sorted=1;
function_name='compare_workspace_PDs';
options.labnum=6;
options.dual_array = 1;
options.array_break = 64;
[bdf_DL,bdf_PM] = split_workspaces(folder, options);
options.bdf_DL = bdf_DL;
options.bdf_PM = bdf_PM;

output_data_20141205 = run_data_processing(function_name,folder,options);

%% rotate empirical tuning curves
folder='Y:\Han_13B1\Processed\experiment_20141211_twoRW';
clear options
options.prefix='Han_20141211';
options.only_sorted=1;
function_name='rotate_tuning_curves';
options.labnum=6;
options.dual_array = 1;
options.array_break = 64;
% [bdf_DL,bdf_PM] = split_workspaces(folder, options);
options.bdf_DL = bdf_DL;
options.bdf_PM = bdf_PM;

output_data_rotate=run_data_processing(function_name,folder,options);