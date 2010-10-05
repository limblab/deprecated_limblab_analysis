% calculate success rate
% filename = 'D:\Data\Ricardo_BC_no_spikes_001';
close all
clear all
boot_iter = 10000;
set(0,'DefaultTextInterpreter','none')
curr_dir = pwd;    
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd(curr_dir)

resultpath = 'D:\Ricardo\Miller Lab\Bump choice results\Newsome results\';
[datapath filelist] = BC_newsome_experiment_list();

for file_no = 1:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pd = filelist(file_no).pd;
    if ~exist([resultpath filename '.fig'],'file')
        if ~exist([datapath filename '.mat'],'file')    
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
            bdf = get_plexon_data([datapath filename '.plx'],2);
            save([datapath filename],'bdf');
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\';
            trial_table = BC_build_trial_table([datapath filename]);    
            save([datapath filename],'trial_table','-append')
        end

        cd(curr_dir)
        load([datapath filename],'trial_table','bdf')

        trial_table = trial_table(trial_table(:,5)==0,:); % remove training trials
        bump_table = trial_table(trial_table(:,4)==1,:);
        stim_table = trial_table(trial_table(:,4)==2,:);

        %%  Probability of moving to a certain target
        figure_h = BC_newsome_sigmoids_plot(bump_table,stim_table,boot_iter,filename,stim_pd); 

        % %% Success rate for 0N trials over time
        % bin_length = 25;
        % BC_newsome_zero_bump_plot(trial_table,bin_length)
        % 
        % %% Success rate by bump magnitude
        % BC_bump_success_plot(bump_table,filename);
        
        hgsave(figure_h,[resultpath filename]);
        I = getframe(figure_h);
        imwrite(I.cdata, [resultpath filename '.png']);
        close all
    end

end