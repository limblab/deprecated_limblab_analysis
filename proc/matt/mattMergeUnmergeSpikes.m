clear;
clc;
% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

% these are the sorted ones to be split and BDF'd
doFiles = {}
%     'Chewie','2015-11-20','VR','CO'};
%     'Chewie','2015-11-19','VR','CO'};
%     'Chewie','2015-11-18','VR','CO'};
%     'Chewie','2015-11-12','VR','CO'; ...
%     
uarray = 'M1';

whichPart = 2; % 1-merge,2-split,3-bdf

for i = 1:size(doFiles,1)
    
    fileRoot = ['F:\' doFiles{i,1} '\' uarray '\CerebusData\'];
    outRoot = ['F:\' doFiles{i,1} '\' uarray '\BDFStructs\'];
    
    useDate = doFiles{i,2};
    y = useDate(1:4);
    m = useDate(6:7);
    d = useDate(9:10);
    
    file_path = fullfile(fileRoot,useDate,filesep);
    out_path = fullfile(outRoot,useDate,filesep);
    umonk = doFiles{i,1};
    
    utask = doFiles{i,4};
    upert = doFiles{i,3};
    udate = [m d y];
    
%     file_prefix = [umonk '_' uarray '_'];
    file_prefix = [umonk '_' uarray '_' utask '_' upert '_'];
    
    switch whichPart
        case 1
            % merge them
            mergingStatus = processSpikesForSorting(file_path,file_prefix,false);
            
        case 2
            % Run processSpiesForSorting again to separate sorted spikes into their
            % original files.
            disp('Splitting sorted file into NEVs...');
            mergingStatus = mattProcessSpikesForSorting(file_path,file_prefix,true);
            
        case 3
            % this section will make each file into its own BDF
            if ~exist(out_path, 'dir')
                disp('Creating BDF directory...');
                mkdir(out_path);
            end
            
            disp('Creating BL BDF...');
            out_struct = get_nev_mat_data([file_path file_prefix 'BL_'],3);
            save([out_path file_prefix 'BL_' udate '.mat'],'out_struct','-v7.3');
            clear out_struct;
            
            disp('Creating AD BDF...');
            out_struct = get_nev_mat_data([file_path file_prefix 'AD_'],3);
            save([out_path file_prefix 'AD_' udate '.mat'],'out_struct','-v7.3');
            clear out_struct;
            
            disp('Creating WO BDF...');
            out_struct = get_nev_mat_data([file_path file_prefix 'WO_'],3);
            save([out_path file_prefix 'WO_' udate '.mat'],'out_struct','-v7.3');
            clear out_struct;
    end
    
end
disp('Done.');