function filename = Mapfile_repo(monkey,implant)
% By: Brian Dekleva 2013-9-30 v0
% Repository of all monkey implants. Call with strings of Monkey name and
% implant location.
% 
%    For example: filename = Mapfile_repo('Mihili','PMd');
%
% Note: Can by combined with ArrayMap.m to obtain
% electrode mapping in (x,y) coordinates (as viewed on Cerebus)
%
%   For example: Map = ArrayMap(Mapfile_repo('Mihili','PMd'));

%% Monkey implant list
Kramer.M1       = '6251-0922';          %#ok<*STRNU>

Spike.M1        = '6250-0807';

Chewie.M1       = '1025-0394';

MrT.M1          = '6250-0896';
MrT.PMd         = '6251-0880';

Mihili.M1       = '6250-000989';
Mihili.PMd      = '6251-000987';

Chips.Cuneate   = '1024-000890';

%% Chose appropriate mapfile repository
% Checks to see if limblab directory exists on the computer. If not, use
% the local 'Maps' repository.
orig_place = cd;
local_repo = [cd '\Maps\'];
server_repo = '\\165.124.111.182\limblab\lab_folder\Lab-Wide Animal Info\Implants\Blackrock Array Info\Array Map Files';
if exist(server_repo,'dir')==7; repo_locale = server_repo; else repo_locale = local_repo; end
%% 
chosen_monkey_array = [monkey '.' implant];

if exist(monkey,'var') % If the monkey exists
    if isfield(eval(monkey),implant) % And the implant exists   
        correct_file = eval(chosen_monkey_array);
        % Go to limblab and compile list of directory files and folders
        cd(repo_locale);
        listing = dir;
        dir_list = vertcat(listing(:).isdir);
        
        % Find the subfolders (excluding '.' and '..')
        folder_places = find(dir_list == 1);
        folder_places(ismember({listing(folder_places).name},{'.','..'})) = [];
        
        % Find the files in the main folder and check for the desired
        % mapfile
        file_places = find(dir_list == 0);
        loc_of_map = file_places(~cellfun(@isempty,strfind({listing(dir_list == 0).name},[correct_file '.cmp'])));
        if ~isempty(loc_of_map)
            filename = [repo_locale '\' listing(loc_of_map).name];
        
        % If it isn't there, check the subfolders
        else
            for i = 1:length(folder_places) % Loop through subfolders
                newlist = dir(listing(folder_places(i)).name); % look at files in subfolder
                dir_list = vertcat(newlist(:).isdir);

                subfile_places = find(dir_list == 0);
                
                loc_of_map = subfile_places(~cellfun(@isempty,strfind({newlist(dir_list==0).name},[correct_file '.cmp'])));
                if ~isempty(loc_of_map) % If it's there, output name and break
                    filename = [repo_locale '\' listing(folder_places(i)).name '\' newlist(loc_of_map).name];
                    break
                end
            end
        end 
        if isempty(loc_of_map) 
            warning('Mapfile not Found: Check folder - ADD TO LIMBLAB');
            filename = [];
        end  
    else
        warning('Array not in repository - ADD INFO TO MAPFILE_REPO.M');
        filename = [];
    end
else
    warning('Monkey not in repository - ADD INFO TO MAPFILE_REPO.M');
    filename = [];
end
% Go back to original directory
cd(orig_place);
