% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or 
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

file_path = 'Z:\Jaco_8I1\CerebusData\ContextDependence\03-18-14\';
file_prefix = 'Jaco';


file_prefix1 = 'Jaco_2ForceLevelsE_UtahandFMAsandEMGs_03182014_001';
file_prefix2 = 'Jaco_3ForceLevelsE_UtahEMGs_03182014_002';
file_prefix3 = 'Jaco_2ForceLevelsE_UtahEMGs_03182014_003';
file_prefix4 = 'Jaco_CenterOut_UtahEMGs_03182014_004';


% Run processSpikesForSorting for the first time to combine spike data from
% all files with a name starting with file_prefix.
mergingStatus = processSpikesForSorting(file_path,file_prefix);

% Check that the spike data has been successfully merged
while strcmp(mergingStatus,'merged spikes')
    % Now go to OfflineSorter and sort your spikes!
    disp(['Sort ''' file_prefix_all '-spikes.nev'' in OfflineSorter and save sorted file as '''...
        file_prefix_all '-spikes-s.nev'' then press any key to continue.'])
    pause
    % Run processSpiesForSorting again to separate sorted spikes into their
    % original files.
    mergingStatus = processSpikesForSorting(file_path,file_prefix);
    if strcmp(mergingStatus,'processed')
        % If everything went well, create bdfs for your files (you might
        % want to split them up by task.)

        bdf1 = get_nev_mat_data([file_path file_prefix1],3);
        bdf2 = get_nev_mat_data([file_path file_prefix2],3);
        bdf3 = get_nev_mat_data([file_path file_prefix3],3);
        bdf4 = get_nev_mat_data([file_path file_prefix4],3);
    end
end