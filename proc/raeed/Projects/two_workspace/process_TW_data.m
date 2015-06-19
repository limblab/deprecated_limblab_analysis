%% process dual array single units
folder='Y:\Han_13B1\Processed\experiment_20141210_twoRW\';
clear options
options.prefix='Han_20141210_RW';
options.only_sorted=1;
function_name='compare_workspace_PDs';
options.labnum=6;
options.do_unit_pds=1;
options.do_electrode_pds=0;
options.dual_array = 1;
options.array_break = 64;

options.bdf_DL = bdf_DL;
options.bdf_PM = bdf_PM;

output_data = run_data_processing(function_name,folder,options);

%% Get raw tuning curves
folder='Y:\Han_13B1\Processed\experiment_20141210_twoRW\';
clear options
options.prefix='Han_20141210_RW';
options.only_sorted=1;
function_name='get_tuning_curves';
options.labnum=6;
options.plot_curves=0;

options.bdf = bdf_PM;

% output_data = run_data_processing(function_name,folder,options);
[~,tuning_curves] = get_tuning_curves(folder,options);

%% process single array single units
folder='Y:\Han_13B1\Processed\experiment_20151210_twoRW';
options.prefix='Han_20141210_RW';
options.only_sorted=1;
function_name='compare_workspace_PDs';
options.labnum=6;
options.do_unit_pds=1;
options.do_electrode_pds=0;
options.dual_array = 1;
options.array_break = 64;
output_data = run_data_processing(function_name,folder,options);