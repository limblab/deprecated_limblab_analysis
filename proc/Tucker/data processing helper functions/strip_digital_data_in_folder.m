function strip_digital_data_in_folder(folderpath,matchstring)%script that loads nev into matlab, strips the digital data, and re-saves

%takes a path to an nev or nsx file and loads the data for that file
%into an NEVNSX object
% folderpath='E:\processing\PDs\10242013\';
% matchstring='Kramer_';

foldercontents=dir(folderpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
for i=1:length(foldercontents)
    if (length(fnames{i})>3)
        if (strcmp(fnames{i}((length(fnames{i})-3):end),'.nev') & ~isempty(strfind(fnames{i},matchstring)))
            resave_name=strcat( fnames{i}(1:(length(fnames{i})-4)),'_NODIGITAL', '.nev');
            if isempty(strmatch( resave_name,fnames))
                %if we haven't found a _NODIGITAL.nev file to match the .nev then make
                %one
                try
                    disp(strcat('Working on: ',folderpath, fnames{i}))
                    NEV=openNEV('read', [folderpath, fnames{i}],'nosave','nomat','report');
                    disp(strcat('Saving: ',resave_name))
                    saveNEVOnlySpikes2(NEV,[folderpath,resave_name])
                    clear NEV
                catch temperr
                    disp(strcat('Failed to process: ', folderpath,fnames{i}))
                    disp(temperr.identifier)
                    disp(temperr.message)
                end
            end
        end
    end
end
    
    
    