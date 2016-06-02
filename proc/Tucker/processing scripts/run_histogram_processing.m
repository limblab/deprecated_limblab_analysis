input_data.matchstring='MrT';
input_data.binsize=.050;
input_data.window=[1 2];
input_data.labnum=6;

main_function_name='Perievent_histograms_target_appearance';
target_directory='Z:\MrT_9I4\Processed\experiment_20140707_RW_perievent_histograms_target';

run_data_processing(main_function_name,target_directory,input_data)