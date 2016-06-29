%% Load bdf
folder='C:\Users\rhc307\Box Sync\Research\Cuneate\UChicago\Cuneate Data\Whitslepig_20151113_Millerlab\';
clear options
options.prefix='Whitslepig_20151113_bicepsvibe_cuneate';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;

vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\rhc307\Box Sync\Research\Cuneate\UChicago\Cuneate Data\Whitslepig_20151113_Millerlab\';
clear options
options.prefix='Whitslepig_20151113_bicepsvibetendon_cuneate';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;

vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\rhc307\Box Sync\Research\Cuneate\UChicago\Cuneate Data\Whitslepig_20151113_Millerlab\';
clear options
options.prefix='Whitslepig_20151113_tricepsvibe_cuneate';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;

vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\rhc307\Box Sync\Research\Cuneate\UChicago\Cuneate Data\Whitslepig_20151113_Millerlab\';
clear options
options.prefix='Whitslepig_20151113_tricepsvibetendon_cuneate';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;

vibe_data = run_data_processing(function_name,folder,options);

%% test out get_vibe_response ONLY A TEST, NOT REAL ANALYSIS
folder='C:\Users\rhc307\Box Sync\Research\Cuneate\UChicago\Cuneate Data\Whitslepig_20151113_Millerlab\';
clear options
options.prefix='Whitslepig_20151113_bicepsvibe_cuneate';

bdf = get_nev_mat_data([folder options.prefix],'nokin','noforce');
opts.binsize=0.05;
% opts.offset=-.015;
opts.do_trial_table=0;
opts.do_firing_rate=1;
bdf=postprocess_bdf(bdf,opts);
output_data.bdf=bdf;

for i=1:length(bdf.units)
    temp(i)=bdf.units(i).id(2)~=0 && bdf.units(i).id(2)~=255;
end
ulist=1:length(bdf.units);
which_units=ulist(temp);

vibe_trace = [bdf.analog.ts' bdf.analog.data];
vibe_response = get_vibe_response(bdf.units,vibe_trace,which_units);