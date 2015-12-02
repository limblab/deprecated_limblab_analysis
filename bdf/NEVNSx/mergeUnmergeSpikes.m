% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or 
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

file_prefix_all = 'Jaco_2015-09-16_DCO_emg_emg_cartesian_';
file_path = ['D:\Jaco_8I1\' params.DCO_file_prefix '\CerebusData\'];
% file_path = 'D:\Chewie_8I2\Chewie_2015-05-05_DCO_emg_emg_cartesian\CerebusData\';
% file_prefix_all = 'Chewie_2015-05-05_DCO_emg_emg_cartesian_';
% file_path = 'D:\Data\Mini_7H1\';
% file_prefix_all = 'Mini_2013-11-22_UF_';
% file_prefix_some = 'Kevin_2013-10-07_UF_001';

% Run processSpikesForSorting for the first time to combine spike data from
% all files with a name starting with file_prefix.
mergingStatus = processSpikesForSorting(file_path,file_prefix_all);

% Check that the spike data has been successfully merged
while strcmp(mergingStatus,'merged spikes')
    % Now go to OfflineSorter and sort your spikes!
    disp(['Sort ''' file_prefix_all '-spikes.nev'' in OfflineSorter and save sorted file as '''...
        file_prefix_all '-spikes-s.nev'' then press any key to continue.'])
    pause
    % Run processSpiesForSorting again to separate sorted spikes into their
    % original files.
    mergingStatus = processSpikesForSorting(file_path,file_prefix_all);
    if strcmp(mergingStatus,'processed')
        % If everything went well, create bdfs for your files (you might
        % want to split them up by task.)
%         bdf_some = get_nev_mat_data([file_path file_prefix_some],3);
%         bdf_all = get_nev_mat_data([file_path file_prefix_all],3);
    end
end