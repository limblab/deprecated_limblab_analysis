function [s1_analysis_path, data_path] = set_paths(computer)

switch computer
    case 1
        s1_analysis_path = 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
        data_path = 'D:\Data';
    case 2 
        s1_analysis_path = 'C:\Documents and Settings\limblab\Desktop\s1_analysis\';
        data_path = 'E:\DataFiles\Tiki';
    case 3
        s1_analysis_path = 'D:\Ricardo\MATLAB\s1_analysis';
        data_path = 'D:\Ricardo\MATLAB\Data';
end

cd(s1_analysis_path)
load_paths
cd([s1_analysis_path '\proc\ricardo'])