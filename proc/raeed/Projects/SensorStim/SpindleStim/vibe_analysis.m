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