file_name_folder_location = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\User_folders\Stephanie\Data Analysis\FESgrantrenewal\JangoThresholdCrossings\';
folder_location = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\data\Jango_12a1\CerebusData\Generalizability\WithHandle';
behavior_names = {'SprBinned','WmBinned','IsoBinned'};

bin_opts.NormData = true;
%%

folders_to_use = dir(file_name_folder_location);
folders_to_use = {folders_to_use(:).name};
folders_to_use = folders_to_use(~cellfun(@isempty,regexp(folders_to_use,'[0-9][0-9]-[0-9]*')));

for iFolder = 1:length(folders_to_use)
    current_folder = [folder_location filesep folders_to_use{iFolder}];
    files_in_folder = dir([current_folder filesep '*.nev']);
    ignore_files = ~cellfun(@isempty,cellfun(@strfind,{files_in_folder.name},...
        repmat({'spikes'},size(files_in_folder))','UniformOutput',false));
    files_in_folder(ignore_files) = [];
    for iFile = 1:length(files_in_folder)
        disp(['Folder: ' num2str(iFolder) ' File: ' num2str(iFile)])
        [~,current_file,~] = fileparts(files_in_folder(iFile).name);
        disp('Making bdf')
        bdf = get_nev_mat_data([current_folder filesep current_file '.nev'],'ignore_jumps',1,'ignore_filecat',1,1);
        disp('Binning')
        binned_data = convertBDF2binned(bdf,bin_opts);
        disp('Saving')
        save([current_folder filesep current_file '-binned'],'binned_data')
    end
end


