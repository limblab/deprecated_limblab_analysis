function [all_stats] = EMG_cascade_get_stats(varargin)
 % varargin = {[FileNames]}
 %
 % FileNames = { HC_filename_day1   HC_filename_day2   HC_filename_day3... ;
 %               EC_filename_day1   EC_filename_day2   EC_filename_day3 ...;
 %               N2F_filename_day1  N2F_filename_day2  N2F_filename_day3...};
 %
 % all_stats = { HC_dataset_day1   HC_dataset_day2   HC_dataset_day3... ;
 %               EC_dataset_day1   EC_dataset_day2   EC_dataset_day3 ...;
 %               N2F_dataset_day1  N2F_dataset_day2  N2F_dataset_day3...};
 %
 % note: elements may be empty if a condition was not tested on corresponding day

if nargin > 0
    FileNames = varargin{1};
    [num_conditions,num_days] = size(FileNames);
else
    conditions = {'Hand Control','EMG Cascade','Neurons-to-Force'}; 
    num_conditions = size(conditions,2);
    dataPath = '\\citadel\data\';
    num_days = 0;

    for i = 1:num_conditions
        MoreFiles = 'Yes';
        num_days_tmp = 0;

        while strcmp(MoreFiles,'Yes')
            num_days_tmp = num_days_tmp+1;
            [FileNames_tmp, PathName] = uigetfile( [dataPath '*.mat'], sprintf('Select %s file for day #%d\n',conditions{i},num_days_tmp));


            if ~FileNames_tmp
                if num_days_tmp < num_days
                    continue;
                else
                    break;
                end
            else
                dir_sep = find(PathName=='\');
                dataPath = PathName(1:dir_sep(end-1));
                num_days = max(num_days,num_days_tmp);            
                FileNames(i,num_days_tmp) = {fullfile(PathName,FileNames_tmp)};%#okAGrow
            end    

            if num_days_tmp == num_days
                MoreFiles = questdlg('Do you want to add a file from another day?');
            end
        end
    end
end
%% Get Stats
all_stats = cell(num_conditions,num_days);

for cond = 1:num_conditions
    for day = 1:num_days
        if ischar(FileNames{cond,day})
            datafile = LoadDataStruct(FileNames{cond,day});
            all_stats{cond,day} = get_WF_stats(datafile);
        end
    end
end