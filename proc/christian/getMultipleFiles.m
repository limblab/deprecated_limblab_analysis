function [FileNames,PathNames] = getMultipleFiles()

    MoreFiles = 'Yes';
    FileNames = {};
    PathNames = {};
    dataPath = 'C:\Monkey\Keedoo\BinnedData\';

    while strcmp(MoreFiles,'Yes')

        [FileNames_tmp, PathName_tmp] = uigetfile( [dataPath '*.mat'], 'Choose File(s)','Multiselect','On');
        dataPath = PathName_tmp;

        if ischar(FileNames_tmp) %Num File = 1
            FileNames = [FileNames {FileNames_tmp}];
            PathNames = [PathNames {PathName_tmp}];
        elseif iscell(FileNames_tmp) %Num Files >1
            FileNames = [FileNames FileNames_tmp];
            PathNames = [PathNames repmat({PathName_tmp},1,size(FileNames_tmp,2))];
        else %user pressed cancel
            MoreFiles = 'Cancel';
            break;
        end
        MoreFiles = questdlg('Do you want to add another file?','Add More Files?');
    end

    if strcmp(MoreFiles,'Cancel') || isempty(FileNames)
        FileNames = {};
        PathNames = {};
    end
end