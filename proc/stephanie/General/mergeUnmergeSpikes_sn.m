% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or 
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

file_path = 'Z:\Jango_12a1\CerebusData\Generalizability\WithHandle\07-24-14\';
file_prefix = 'Jango';

% Run processSpikesForSorting for the first time to combine spike data from
% all files with a name starting with file_prefix.
mergingStatus = processSpikesForSorting(file_path,file_prefix);

%-------------------------------------------------------------------------------------

file_prefix1 = 'Jango_20140724_IsoHandleHoriz_Utah10ImpEMGs_SN_001';
file_prefix2 = 'Jango_20140724_WmHandleHoriz_Utah10ImpEMGs_SN_002';
file_prefix3 = 'Jango_20140724_SprHandleHoriz_Utah10ImpEMGs_SN_003';
file_prefix4 = 'Jango_20140724_IsoBoxCO_Utah10ImpEMGs_SN_004';
%file_prefix5 = 'Jango_20140511_WMCenterOut_Utah12ImpEMGs_SN_004-s';





 mergingStatus = 'merged spikes';
 mergingStatus = processSpikesForSorting(file_path,file_prefix);
    if strcmp(mergingStatus,'processed')
        % If everything went well, create bdfs for your files (you might
        % want to split them up by task.)

        bdf1 = get_nev_mat_data([file_path file_prefix1],1);
        bdf2 = get_nev_mat_data([file_path file_prefix2],1);
        bdf3 = get_nev_mat_data([file_path file_prefix3],1);
        bdf4 = get_nev_mat_data([file_path file_prefix4],1);
        bdf5 = get_nev_mat_data([file_path file_prefix5],1);
    end

% Check that the spike data has been successfully merged
while strcmp(mergingStatus,'merged spikes')
    % Now go to OfflineSorter and sort your spikes!
    disp(['Sort ''' file_prefix_all '-spikes.nev'' in OfflineSorter and save sorted file as '''...
        file_prefix_all '-spikes-s.nev'' then press any key to continue.'])
    pause
   
    file_path = 'Z:\Jango_12a1\CerebusData\PICexperiment\06-15-14\';
    file_prefix = 'Jango';
    
file_prefix1 = 'Jango_IsoBoxBaseline_Utah12EMGs_06152014_SN_KG_001-s';
file_prefix2 = 'Jango_IsoBoxBaseline_Utah12EMGs_06152014_SN_KG_002-s';
file_prefix3 = 'Jango_IsoBoxCypro_Utah12EMGs_06152014_SN_KG_003-s';
file_prefix4 = 'Jango_IsoBoxCypro_Utah12EMGs_06152014_SN_KG_004-s';
%file_prefix5 = 'Jango_20140511_WMCenterOut_Utah12ImpEMGs_SN_004-s';
    
    % Run processSpiesForSorting again to separate sorted spikes into their
    % original files.
    mergingStatus = processSpikesForSorting(file_path,file_prefix);
    if strcmp(mergingStatus,'processed')
        % If everything went well, create bdfs for your files (you might
        % want to split them up by task.)

        bdf1 = get_nev_mat_data([file_path file_prefix1],1);
        bdf2 = get_nev_mat_data([file_path file_prefix2],1);
        bdf3 = get_nev_mat_data([file_path file_prefix3],1);
        bdf4 = get_nev_mat_data([file_path file_prefix4],1);
    end
%end

save(file_prefix1, 'bdf1')
save(file_prefix2, 'bdf2')
save(file_prefix3, 'bdf3')
save(file_prefix4, 'bdf4')
%save(file_prefix5, 'bdf5')
