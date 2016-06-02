% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or 
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

% Merge files
file_path = 'Z:\Jango_12a1\CerebusData\Generalizability\WithHandle\11-06-14\';
file_prefix = 'Jango';

% Run processSpikesForSorting for the first time to combine spike data from
% all files with a name starting with file_prefix.
mergingStatus = processSpikesForSorting_sn(file_path,file_prefix,1);

%-------------------------------------------------------------------------------------

%-------------------------------------------------------------------------
file_path = 'Z:\Jango_12a1\CerebusData\Generalizability\WithHandle\09-24-14\';
file_prefix = 'Jango';

mergingStatus = 'merged spikes';
mergingStatus = processSpikesForSorting_sn(file_path,file_prefix,0);
 
     
file_prefix1 = 'Jango_20140924_IsoHandleHoriz_UtahEMGs_SN_001';
file_prefix2 = 'Jango_20140924_WmHandleHoriz_UtahEMGs_SN_002';
file_prefix3 = 'Jango_20140924_SprHandleHoriz_UtahEMGs_SN_003';
file_prefix4 = 'Jango_20140924_IsoBoxCenterOut_UtahEMGs_SN_004';
%file_prefix5 = 'Jango_20140511_WMCenterOut_Utah12ImpEMGs_SN_004-s';
 
 if strcmp(mergingStatus,'processed')
     % If everything went well, create bdfs for your files (you might
     % want to split them up by task.)
     
     bdf1 = get_nev_mat_data([file_path file_prefix1],1);
     bdf2 = get_nev_mat_data([file_path file_prefix2],1);
     bdf3 = get_nev_mat_data([file_path file_prefix3],1);
     bdf4 = get_nev_mat_data([file_path file_prefix4],1);
 end

%------------------------------------------------------------------------

    
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

save(strcat(file_prefix1,'-s'), 'bdf1')
save(strcat(file_prefix2,'-s'), 'bdf2')
save(strcat(file_prefix3,'-s'), 'bdf3')
save(strcat(file_prefix4,'-s'), 'bdf4')
%save(strcat(file_prefix5,'-s'), 'bdf5')
