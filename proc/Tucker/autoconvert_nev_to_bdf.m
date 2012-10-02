% check a directory and run the bdf converter if unconverted files are
% there

%restoredefaultpath;matlabrc
%clear datapath
%cd C:\Userslimblab\Desktop\s1_analysis
%load_paths
%set the mount drive to scan and convert
folderpath='z:\Kramer_10I1\BumpDirection';

foldercontents=dir(folderpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
for i=1:length(foldercontents)
    if (length(fnames{i})>3)
        if strcmp(fnames{i}((length(fnames{i})-3):end),'.nev')
            if isempty(strmatch( strcat( fnames{i}(1:(length(fnames{i})-3)), 'mat'),fnames))
                %if we haven't found a .mat file to match the .nev then make
                %one

                disp(strcat('Working on: ',folderpath, fnames{i}))

                bdf=get_cerebus_data(strcat(folderpath, fnames{i}));
                save strcat(folderpath, fnames{i}(1:(length(fnames{i})-3)), 'mat') bdf
                clear bdf
            end
        end
    end
end
