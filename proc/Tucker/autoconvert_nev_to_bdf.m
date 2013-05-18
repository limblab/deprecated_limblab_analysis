function file_list=autoconvert_nev_to_bdf(folderpath,matchstring)
% check a directory and run the bdf converter if unconverted files are
% there
disp(strcat('Converting files matching string: ',matchstring,' in folder: ',folderpath))
%
% %set the mount drive to scan and convert
% folderpath='C:\Users\limblab\Desktop\dail_data\10302012\';
% matchstring='10302012';
foldercontents=dir(folderpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
file_list=' ';
for i=1:length(foldercontents)
    if (length(fnames{i})>3)
        if (strcmp(fnames{i}((length(fnames{i})-3):end),'.nev') & ~isempty(strfind(fnames{i},matchstring)))
            
            disp(file_list)
            disp(fnames{i})
            file_list=strcat(file_list, ', ', fnames{i});
            if isempty(strmatch( strcat( fnames{i}(1:(length(fnames{i})-3)), 'mat'),fnames))
                %if we haven't found a .mat file to match the .nev then make
                %one

                disp(strcat('Working on: ',folderpath, fnames{i}))
                try
                    bdf=get_cerebus_data(strcat(folderpath, fnames{i}),3,'verbose','noeye');
                    disp(strcat('Saving: ',strcat(folderpath, fnames{i}(1:(length(fnames{i})-3)), 'mat')))
                    save( strcat(folderpath, fnames{i}(1:(length(fnames{i})-3)), 'mat'), 'bdf','-v7.3')
                    clear bdf
                catch temperr
                    disp(strcat('Failed to process: ', folderpath,fnames{i}))
                    disp(temperr.identifier)
                    disp(temperr.message)
                end
            end
        end
    end
end
