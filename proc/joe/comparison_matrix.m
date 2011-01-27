%This script will generate a pairwise triangular matrix containing the 
%number of sorting mismatches between each pair of sorted plexon files. 

path = 'C:\Users\limblab\Documents\Joe Lancaster\S1 data files\';
name{1} = 'Pedro_S1_008-s.plx';
name{2} = 'Real Files\Pedro_S1_008-s.plx';
% name{3} = 'Pedro_S1_042-s_multiunit';
% name{4} = 'Pedro_S1_043-s_multiunit';
% name{5} = 'Pedro_S1_044-s_multiunit';
files = max(size(name));
matrix = cell(files);

for i = 1:files
    bdf = get_plexon_data([path name{i}]);
    nameLength = size(name{i});
    name{i} = [name{i}(1:(nameLength(2)-4)) num2str(i)]; 
    save([path name{i}], 'bdf');
end;

for i = 1:files
    for j = i:files
        matrix{i,j} = compare_sorted(path, name{i}, name{j});
    end;
end;

clearvars path name files i j temp bdf nameLength;
clc

