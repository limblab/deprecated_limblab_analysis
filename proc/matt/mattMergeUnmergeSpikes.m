% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)
file_path = 'Z:\Chewie_8I2\Matt\M1\CerebusData\2013-12-19\';
out_path = 'Z:\Chewie_8I2\Matt\M1\BDFStructs\2013-12-19\';
umonk = 'Chewie';
uarray = 'M1';
utask = 'CO';
upert = 'VR';
udate = '12192013';

file_prefix = [umonk '_' uarray '_' utask '_' upert '_'];

doCombine = 1;
doSplit = 0;
doBDF = 0;

if doCombine
    mergingStatus = processSpikesForSorting(file_path,file_prefix);
end


% 
% if doSplit
%     % Run processSpiesForSorting again to separate sorted spikes into their
%     % original files.
%     disp('Splitting sorted file into NEVs...');
%     mergingStatus = processSpikesForSorting(file_path,file_prefix);
% end
% 
% % this section will make each file into its own BDF
% if doBDF
%     
%     if ~exist(out_path, 'dir')
%         disp('Creating BDF directory...');
%         mkdir(out_path);
%     end
%     
%     disp('Creating BL BDF...');
%     out_struct = get_nev_mat_data([file_path file_prefix 'BL_'],3);
%     save([out_path file_prefix 'BL_' udate '.mat'],'out_struct');
%     
%     disp('Creating AD BDF...');
%     out_struct = get_nev_mat_data([file_path file_prefix 'AD_'],3);
%     save([out_path file_prefix 'AD_' udate '.mat'],'out_struct');
%     
%     disp('Creating WO BDF...');
%     out_struct = get_nev_mat_data([file_path file_prefix 'WO_'],3);
%     save([out_path file_prefix 'WO_' udate '.mat'],'out_struct');
% end
