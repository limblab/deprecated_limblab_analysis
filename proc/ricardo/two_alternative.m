% close all
clear all
clc
set(0,'DefaultTextInterpreter','none')
curr_dir = pwd;    
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd(curr_dir)
boot_iter = 1000;

resultpath = 'D:\Ricardo\Miller Lab\Bump choice results\Two-alternative results\';
[datapath filelist] = two_alternative_experiment_list();
reward_code = 32;
abort_code = 33;
fail_code = 34;
incomplete_code = 35;

for file_no = 4:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pds = filelist(file_no).pd;
    stim_duration = filelist(file_no).period.*filelist(file_no).pulses;
    bump_duration = filelist(file_no).bump_duration;
    serverdatapath = filelist(file_no).serverdatapath;
    if strcmp(filelist(file_no).system,'plexon')
        extension = '.plx';
    else
        extension = '.nev';
    end
        if ~exist([datapath filename '.mat'],'file')  
            if ~exist([datapath filename extension],'file')
                disp('Waiting for file to be copied to server')
                while ~exist([serverdatapath '\' filename extension],'file')              
                    pause(30) 
                    why
                end
                disp('Done')
                copied=0;
                while copied==0
                    try
                        copyfile([serverdatapath '\' filename extension],datapath);
                        copied=1;
                    end
                end
                all_files = dir([serverdatapath '\' filename '*']);
                for i=1:length(all_files)
                    copyfile([serverdatapath '\' all_files(i).name],datapath);
                end                    
            end
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
            if strcmp(extension,'.plx')
                bdf = get_plexon_data([datapath filename extension],2);
            else
                bdf = get_cerebus_data([datapath filename extension],3);
            end
            save([datapath filename],'bdf');
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\';
            [trial_table table_columns]= two_alternative_trial_table([datapath filename]);    
            save([datapath filename],'trial_table','table_columns','-append')
        end

        cd(curr_dir)
        load([datapath filename],'trial_table','bdf','table_columns')
        
        %remove aborts
        trial_table = trial_table(trial_table(:,table_columns.result,:)~=abort_code,:);
        
        %psychophysics
        bump_magnitudes = unique(trial_table(:,[table_columns.interval_1_bump_magnitude,...
            table_columns.interval_2_bump_magnitude]));
        stim_codes = unique(trial_table(:,[table_columns.interval_1_stim_code,...
            table_columns.interval_2_stim_code]));
        
        if length(stim_codes)>1
            
        end
        
        if length(bump_magnitudes)>1
            results = trial_table(:,[table_columns.first_target table_columns.result]);
            results(:,2) = results(:,2)==reward_code;
            results = [results trial_table(:,[table_columns.interval_1_bump_magnitude,...
                table_columns.interval_2_bump_magnitude])]; %#ok<AGROW>
%             results(results(:,1)==2,2) = ~results(results(:,1) == 2,2);
            results(results(:,1)==2,[3 4]) = results(results(:,1)==2,[4 3]);
            results(results(:,1)==2,1) = 1;
            response_average = zeros(size(bump_magnitudes));
            for i=1:length(bump_magnitudes)
                response_average(i) = mean(results(results(:,3)==bump_magnitudes(i),2));
            end
%             response_average = (response_average-.5)/(.5);
            figure
            plot(2*bump_magnitudes, response_average)
            xlabel('Bump magnitude [N]')
            ylabel('Percent correct')
            title('Two-alternative forced choice')
        end
end
