function file_list=autoconvert_nev_to_bdf(folderpath,matchstring,varargin)
% check a directory and run the bdf converter if unconverted files are
% there

if ~isempty(varargin)
    if isnumeric(varargin{1})
        labnum=varargin{1};
    else
        warning('AUTOCONVERT_NEV_TO_BDF:UnrecognizedInput', 'Expected a lab number, got a non-numeric input. Defaulting to Lab3')
        labnum=3;
    end
else
    labnum=3;
end
    

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
        
        if exist(strcat(folderpath,fnames{i}),'file')~=2
            continue
        end
        
        temppath=follow_links(strcat(folderpath,fnames{i}));
        [tempfolder,tempname,tempext]=fileparts(temppath);
        if (strcmp(tempext,'.nev') & ~isempty(strfind(tempname,matchstring)))
            
           file_list=strcat(file_list, ', ', temppath);
            if isempty(strmatch( strcat( folderpath,tempname, '.mat'),fnames))
                %if we haven't found a .mat file to match the .nev then make
                %one

                disp(strcat('Working on: ',temppath, tempname,tempext))
                try
                    bdf=get_cerebus_data( temppath,labnum,'verbose','noeye');
                    disp(strcat('Saving: ',strcat(folderpath, tempname, '.mat')))
                    save( strcat(folderpath, tempname, '.mat'), 'bdf','-v7.3')
                    clear bdf
                catch temperr
                    disp(strcat('Failed to process: ', folderpath,tempname))
                    disp(temperr.identifier)
                    disp(temperr.message)
                end
            end
        end
    end
end
