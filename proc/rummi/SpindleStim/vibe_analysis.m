%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_bicepsvibe_cuneate_004\';
clear options
options.prefix='Whitslepig_20151113_bicepsvibe_cuneate_004';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'bicepsvibe';

vibe_data = run_data_processing(function_name,folder,options);
% % 
%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_tricepsvibe_cuneate_006\';
clear options
options.prefix='Whitslepig_20151113_tricepsvibe_cuneate_006';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'tricepsvibe';

vibe_data = run_data_processing(function_name,folder,options);
% % 
%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_bicepssweep_cuneate_012\';
clear options
options.prefix='Whitslepig_20151113_bicepssweep_cuneate_012';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'bicepssweep';

vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_bicepsvibetendon_cuneate_005\';
% % clear options
% % options.prefix='Whitslepig_20151113_bicepsvibetendon_cuneate_005';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'bicepsvibetendon';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_deltvibe_cuneate_011\';
% % clear options
% % options.prefix='Whitslepig_20151113_deltvibe_cuneate_011';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'deltvibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_pectvibe_cuneate_010\';
% % clear options
% % options.prefix='Whitslepig_20151113_pectvibe_cuneate_010';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'pectvibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_tricepsvibetendon_cuneate_007\';
% % clear options
% % options.prefix='Whitslepig_20151113_tricepsvibetendon_cuneate_007';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'tricepsvibetendon';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_wristextvibe_cuneate_009\';
% % clear options
% % options.prefix='Whitslepig_20151113_wristextvibe_cuneate_009';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'wristextvibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_wristflexvibe_cuneate_008\';
% % clear options
% % options.prefix='Whitslepig_20151113_wristflexvibe_cuneate_008';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'wristflexvibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\Whitslepig_20151113_wristsweep_cuneate_013\';
% % clear options
% % options.prefix='Whitslepig_20151113_wristsweep_cuneate_013';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'wristsweep';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);

%%
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_BicepsSweep_008\';
% % clear options
% % options.prefix='Chips_20151123_BicepsSweep_008';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'BicepsSweep';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_BicepsVibe_002\';
% % clear options
% % options.prefix='Chips_20151123_BicepsVibe_002';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'BicepsVibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_DeltVibe_005\';
% % clear options
% % options.prefix='Chips_20151123_DeltVibe_005';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'DeltVibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_GTOStim_001\';
% % clear options
% % options.prefix='Chips_20151123_GTOStim_001';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'GTOStim';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_GTOStim_03mA_001\';
% % clear options
% % options.prefix='Chips_20151123_GTOStim_03mA_001';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6; 
% % options.figure_title = 'GTOStim_03mA';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_GTOStim_03mA_artefactrejection_002\';
% % clear options
% % options.prefix='Chips_20151123_GTOStim_03mA_artefactrejection_002';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'GTOStim_03mA_artefactrejection';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_GTOStim_03mA_noartefactrejection_003\';
% % clear options
% % options.prefix='Chips_20151123_GTOStim_03mA_noartefactrejection_003';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'GTOStim_03mA_noartefactrejection';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_GTOStim_025mA_noartefactrejection_001\';
% % clear options
% % options.prefix='Chips_20151123_GTOStim_025mA_noartefactrejection_001';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'GTOStim_025mA_noartefactrejection';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_PecVibe_004\';
% % clear options
% % options.prefix='Chips_20151123_PecVibe_004';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'PecVibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_TricepsSweep_009\';
clear options
options.prefix='Chips_20151123_TricepsSweep_009';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'TricepsSweep';

vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_TricepsVibe_003\';
% % clear options
% % options.prefix='Chips_20151123_TricepsVibe_003';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'TricepsVibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);

% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_WristExtVibe_007\';
% % clear options
% % options.prefix='Chips_20151123_WristExtVibe_007';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'WristExtVibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);
% % 
% % %% Load bdf
% % folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_WristFlexVibe_006\';
% % clear options
% % options.prefix='Chips_20151123_WristFlexVibe_006';
% % options.only_sorted=1;
% % function_name='find_vibe_sensitivity';
% % options.labnum = 6;
% % options.figure_title = 'WristFlexVibe';
% % 
% % vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\movement\Whitslepig_20151113_passive_cuneate_003\';
clear options
options.prefix='Whitslepig_20151113_passive_cuneate_003';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'passive_cuneate';

vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\movement\Whitslepig_20151113_reaching_cuneate_001\';
clear options
options.prefix='Whitslepig_20151113_reaching_cuneate_001';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'reaching_cuneate_001';

vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\cuneate_day1\movement\Whitslepig_20151113_reaching_cuneate_002\';
clear options
options.prefix='Whitslepig_20151113_reaching_cuneate_002';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'reaching_cuneate_002';

vibe_data = run_data_processing(function_name,folder,options);

%% Load bdf
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\RWdata_area2\';
clear options
options.prefix='Chips_20151124_RW_tucker_002';
options.only_sorted=1;
function_name='find_vibe_sensitivity';
options.labnum = 6;
options.figure_title = 'RW-reaching_area2';

vibe_data = run_data_processing(function_name,folder,options);

%% get_vibe response data
folder='C:\Users\limblab\Desktop\rummi_vibe_cuneate_analysis\area2_day1\Chips_20151123_TricepsSweep_009\';
clear options
options.prefix='Chips_20151123_TricepsSweep_009';

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


units_want = [2 8 17 33 36];
vibe_trace = [bdf.analog.ts' bdf.analog.data];

for i=1:length(which_units)
%     k=units_want(i);
    
    vibe_response = get_vibe_response(bdf.units,vibe_trace,which_units(i));
    b(:,i) = vibe_response.on_rate;
    c(:,i) = [vibe_response.on_avg vibe_response.off_avg];
    
     

        xlswrite('sections.xlsx',b);
        xlswrite('avgs.xlsx', c);
 
end




















