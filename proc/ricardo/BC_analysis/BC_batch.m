% function BC_batch

user = 'Ricardo';

% bump_raster_files(1).filenames = {'Tiki_2011-05-17_BC_001-s_thres',''};
% bump_raster_files(1).filenames = {'Tiki_2011-05-04_BC_001-s_multiunit'};
% bump_raster_files(2).filenames = {'Tiki_2011-03-22_BC_002-s_clear_units_only','Tiki_2011-03-22_BC_003-s_clear_units_only'};
bump_raster_files = [];

% psychophysics_files = {'Tiki_2011-05-19_BC_001-s_multiunit','Tiki_2011-04-28_BC_002-s_multiunit','Tiki_2011-04-28_BC_003-s_multiunit'};
% psychophysics_files = {'Tiki_2011-04-11_BC_001','Tiki_2011-04-13_BC_001','Tiki_2011-04-14_BC_001'};
psychophysics_files = {'Tiki_2011-08-15_BC_001'};
% psychophysics_files = [];
newsome_files = [];
clear newsome_results
% newsome_files(end+1).filenames = {'Tiki_2011-05-06_BC_001','Tiki_2011-05-06_BC_002','Tiki_2011-05-06_BC_003'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-07_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-18_BC_001','Tiki_2011-05-18_BC_002','Tiki_2011-05-18_BC_003','Tiki_2011-05-18_BC_004',...
%     'Tiki_2011-05-18_BC_005'};
% % newsome_files(end+1).filenames = {'Tiki_2011-05-19_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-20_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-23_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-24_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-25_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-26_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-05-27_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-01_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-02_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-03_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-07_BC_001','Tiki_2011-06-07_BC_002',...
%     'Tiki_2011-06-07_BC_003','Tiki_2011-06-07_BC_004'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-08_BC_001','Tiki_2011-06-08_BC_002','Tiki_2011-06-08_BC_003',...
%     'Tiki_2011-06-08_BC_004','Tiki_2011-06-08_BC_005','Tiki_2011-06-08_BC_006'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-09_BC_001','Tiki_2011-06-09_BC_002'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-10_BC_001'};
% newsome_files(end+1).filenames = {'Tiki_2011-06-13_BC_001'};

filelist = BC_experiment_list(user);
[BC_sorted_filelist BC_non_sorted_filelist] = BC_sorted_files(filelist);

filelist = [BC_sorted_filelist BC_non_sorted_filelist];
for iFile=1:length(filelist)  
% for iFile = 32
    iFile %#ok<NOPRT>
    if ~exist([filelist(iFile).datapath 'Processed\' filelist(iFile).name '.mat'],'file')    
        server2bdf(filelist(iFile));
        [trial_table table_columns]= BC_trial_table([filelist(iFile).datapath 'Processed\' filelist(iFile).name '.mat']);    
        save([filelist(iFile).datapath 'Processed\' filelist(iFile).name '.mat'],'trial_table','table_columns','-append')
    end
end

%% Bump raster/heatmap plots
for iFileGroup = 1:length(bump_raster_files)
    bump_raster_idx = zeros(size(filelist));
    for iFile=1:length(bump_raster_files(iFileGroup).filenames)
        bump_raster_idx = bump_raster_idx + strcmp({filelist.name},bump_raster_files(iFileGroup).filenames(iFile));
    end
    BC_bump_raster(filelist(find(bump_raster_idx)))
end

%% Psychophysics plots
psychophysics_idx = zeros(size(filelist));
for iFile=1:length(psychophysics_files)
    psychophysics_idx = psychophysics_idx + strcmp({filelist.name},psychophysics_files{iFile});
end
BC_psychophysics(filelist(find(psychophysics_idx)))

%% Newsome analysis
for iFileGroup = 1:length(newsome_files)
    newsome_files_idx = zeros(size(filelist));
    for iFile=1:length(newsome_files(iFileGroup).filenames)
        newsome_files_idx = newsome_files_idx + strcmp({filelist.name},newsome_files(iFileGroup).filenames(iFile));
    end
    newsome_results(iFileGroup) = BC_newsome(filelist(find(newsome_files_idx)));
end
if ~isempty(newsome_files)
    count = 0;
    count2 = 0;
    count3 = 0;
    diff_xthr_10 = [];
    diff_xthr_20 = [];
    diff_xthr_30 = [];
    for i=1:length(newsome_results)
        if newsome_results(i).electrodes == 14
            for j = 1:length(newsome_results(i).currents)
                if newsome_results(i).currents(j) == 10
                    count = count+1;
                    xthr_no_stim_10 = newsome_results(i).xthr(1);
                    xthr_stim_10 = newsome_results(i).xthr(j);
                    diff_xthr_10(count) = xthr_stim_10 - xthr_no_stim_10;
                end
                if newsome_results(i).currents(j) == 20
                    count2 = count2+1;
                    xthr_no_stim_20 = newsome_results(i).xthr(1);
                    xthr_stim_20 = newsome_results(i).xthr(j);
                    diff_xthr_20(count2) = xthr_stim_20 - xthr_no_stim_20;
                end
                if newsome_results(i).currents(j) == 20
                    count3 = count3+1;
                    xthr_no_stim_30 = newsome_results(i).xthr(1);
                    xthr_stim_30 = newsome_results(i).xthr(j);
                    diff_xthr_30(count3) = xthr_stim_30 - xthr_no_stim_30;
                end
            end
        end
    end
    %%
    figure;
    hist(diff_xthr_10,linspace(-0.01,0.01,20));
    % xlim([0 360])
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','b','FaceAlpha',0.5)
    hold on
    hist(diff_xthr_20,linspace(-0.01,0.01,20));
    h2 = findobj(gca,'Type','patch');
    set(h2(1),'FaceColor','r','FaceAlpha',0.5)
    hist(diff_xthr_30,linspace(-0.01,0.01,20));
    h3 = findobj(gca,'Type','patch');
    set(h3(1),'FaceColor','g','FaceAlpha',0.5)
    legend('10 uA','20 uA','30uA')
    xlabel('Stimulus effect (N)')
    ylabel('Count')
    title('Newsome effect summary at 10 and 20 uA, electrode 14')
end