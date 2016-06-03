% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or 
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

file_path = 'Z:\Jango_12a1\CerebusData\PICexperiment\06-11-14\';
file_prefix = 'Jango';


% Run processSpikesForSorting for the first time to combine spike data from
% all files with a name starting with file_prefix.
mergingStatus = processSpikesForSorting(file_path,file_prefix);
   % Now go to OfflineSorter and sort your spikes!
    %disp(['Sort ''' file_prefix_all '-spikes.nev'' in OfflineSorter and save sorted file as '''...
    %    file_prefix_all '-spikes-s.nev'' then press any key to continue.'])


%Sort file then run the rest of this--------------------------------------

file_path = 'Z:\Jango_12a1\CerebusData\PICexperiment\06-11-14\';
file_prefix = 'Jango';
file_prefix1 = 'Jango_IsoBoxBaseline_Utah12EMGs_06112014_SN_KG_001';
file_prefix2 = 'Jango_IsoBoxBaseline_Utah12EMGs_06112014_SN_KG_002';
file_prefix3 = 'Jango_IsoBoxPostCypro_Utah12EMGs_06112014_SN_KG_001';
file_prefix4 = 'Jango_IsoBoxPostCypro_Utah12EMGs_06112014_SN_KG_002';
file_prefix5 = 'Jango_IsoBoxPostCypro_Utah12EMGs_06112014_SN_KG_003';


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
        bdf5 = get_nev_mat_data([file_path file_prefix5],3);
    end