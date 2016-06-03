function [file_list,bdf_list]=autoconvert_nev_to_bdf_listreturn(folderpath,matchstring,varargin)
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
file_list={};
bdf_list={};
for i=1:length(foldercontents)
    if (length(fnames{i})>3)
        
        if exist(strcat(folderpath,fnames{i}),'file')~=2
            continue
        end
        
        temppath=follow_links(strcat(folderpath,fnames{i}));
        [tempfolder,tempname,tempext]=fileparts(temppath);
        if (strcmp(tempext,'.nev') & ~isempty(strfind(tempname,matchstring)))
            
            file_list{end+1}=temppath;
            try
                if isempty(strmatch( strcat( tempfolder,tempname, '.mat'),fnames))
                    %if we haven't found a .mat file to match the .nev then make
                    %one

                    disp(strcat('Working on: ',temppath, tempname,tempext))
                    NEVNSx=cerebus2NEVNSx( temppath,labnum,'verbose','noeye');
                    bdf_list{end+1}=get_nev_mat_data(NEVNSx,'noeye',
                else
                    load(temppath);
                    bdf_list{end+1}=bdf;
                end
            catch temperr
                disp(strcat('Failed to process: ', folderpath,tempname))
                disp(temperr.identifier)
                disp(temperr.message)
            end
        end
    end
end
