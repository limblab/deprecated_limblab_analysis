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

doFiles = {'Mihili','2014-02-17','FF','CO'; ...
    'Mihili','2014-02-18','FF','CO'; ...
    'Mihili','2014-03-07','FF','CO'; ...
    'Mihili','2015-06-10','FF','CO'; ...
    'Mihili','2015-06-11','FF','CO'; ...
    'Mihili','2015-06-15','FF','CO'; ...
    'Mihili','2015-06-16','FF','CO'};

% READY TO SORT
%     'Chewie','2013-10-10','VR','RT'
%     'Chewie','2013-10-11','VR','RT'
%     'Chewie','2013-10-28','FF','RT'
%     'Chewie','2013-10-29','FF','RT'
% NEED TO BE MERGED MAYBE
%     'Chewie','2013-12-09','FF','RT'
%     'Chewie','2013-12-10','FF','RT'
%     'Chewie','2013-12-12','VR','RT'
%     'Chewie','2013-12-13','VR','RT'
%     'Chewie','2013-12-17','FF','RT'
%     'Chewie','2013-12-18','FF','RT'
%     'Chewie','2013-12-19','VR','CO'
%     'Chewie','2013-12-20','VR','CO'
%     'Chewie','2015-03-09','CS','CO'
%     'Chewie','2015-03-11','CS','CO'
%     'Chewie','2015-03-12','CS','CO'
%     'Chewie','2015-03-13','CS','CO'
%     'Chewie','2015-03-16','CS','RT'
%     'Chewie','2015-03-17','CS','RT'
%     'Chewie','2015-03-18','CS','RT'
%     'Chewie','2015-03-19','CS','CO'
%     'Chewie','2015-03-20','CS','RT'
%     'Chewie','2015-07-09','VR','CO'
%     'Chewie','2015-07-10','VR','CO'
%     'Chewie','2015-07-13','VR','CO'
%     'Chewie','2015-07-14','VR','CO'
%     'Chewie','2015-07-15','VR','CO'
%     'Chewie','2015-07-16','VR','CO'
%     'Mihili','2014-01-14','VR','RT'
%     'Mihili','2014-01-15','VR','RT'
%     'Mihili','2014-01-16','VR','RT'
%     'Mihili','2014-02-14','FF','RT' 
%     'Mihili','2014-02-21','FF','RT'
%     'Mihili','2014-02-24','FF','RT'
%     'Mihili','2014-03-03','VR','CO'
%     'Mihili','2014-03-04','VR','CO'
%     'Mihili','2014-03-06','VR','CO'
%     'Mihili','2014-06-26','CS','CO'
%     'Mihili','2014-06-27','CS','CO'
%     'Mihili','2014-09-29','CS','CO'
%     'Mihili','2014-12-03','CS','CO'
%     'Mihili','2015-05-11','CS','CO'
%     'Mihili','2015-05-12','CS','CO'
%     'Mihili','2015-06-23','VR','CO'
%     'Mihili','2015-06-25','VR','CO'
%     'Mihili','2015-06-26','VR','CO'

uarray = 'M1';

whichPart = [3]; % 1-merge,2-split,3-bdf

for j = 1:length(whichPart)
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
        
        switch whichPart(j)
            case 1
                % merge them
                if i == 1
                mergingStatus = processSpikesForSorting(file_path,file_prefix,false);
                end
                
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
                
                switch lower(uarray)
                    case 'm1'
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
                    case 'pmd'
                        disp('Creating BL BDF...');
                        out_struct = get_nev_mat_data([file_path file_prefix 'BL_'],3,'nokin');
                        save([out_path file_prefix 'BL_' udate '.mat'],'out_struct','-v7.3');
                        clear out_struct;
                        
                        disp('Creating AD BDF...');
                        out_struct = get_nev_mat_data([file_path file_prefix 'AD_'],3,'nokin');
                        save([out_path file_prefix 'AD_' udate '.mat'],'out_struct','-v7.3');
                        clear out_struct;
                        
                        disp('Creating WO BDF...');
                        out_struct = get_nev_mat_data([file_path file_prefix 'WO_'],3,'nokin');
                        save([out_path file_prefix 'WO_' udate '.mat'],'out_struct','-v7.3');
                        clear out_struct;
                end
        end
    end
end
disp('Done.');