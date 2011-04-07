function BC_batch
% bump_raster_files(1).filenames = {'Tiki_2011-03-22_BC_002-s_multiunit','Tiki_2011-03-22_BC_003-s_multiunit'};
% bump_raster_files(2).filenames = {'Tiki_2011-03-22_BC_002-s_clear_units_only','Tiki_2011-03-22_BC_003-s_clear_units_only'};

bump_raster_files = [];

% psychophysics_files = {'Tiki_2011-03-24_BC_001','Tiki_2011-03-24_BC_002',...
%     'Tiki_2011-03-24_BC_003','Tiki_2011-03-24_BC_004'};
psychophysics_files = {'Tiki_2011-04-07_BC_001'};
% psychophysics_files = {'Pedro_2011-04-06_BC_001'};
% psychophysics_files = [];

filelist = BC_experiment_list;
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
    BC_bump_raster({filelist(find(bump_raster_idx)).name})
end

%% Psychophysics plots
psychophysics_idx = zeros(size(filelist));
for iFile=1:length(psychophysics_files)
    psychophysics_idx = psychophysics_idx + strcmp({filelist.name},psychophysics_files{iFile});
end
BC_psychophysics(filelist(find(psychophysics_idx)))
