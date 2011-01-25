%This script will generate a pairwise triangular matrix containing the 
%number of sorting mismatches between each pair of sorted plexon files. 

path = '/Users/limblab/Documents/Joe Lancaster/MATLAB/s1_analysis/proc/joe/';
name{1} = 'Pedro_S1_040-s_multiunit';
name{2} = 'Pedro_S1_041-s_multiunit';
name{3} = 'Pedro_S1_042-s_multiunit';
name{4} = 'Pedro_S1_043-s_multiunit';
name{5} = 'Pedro_S1_044-s_multiunit';
files = size(name);
matrix = zeros(files(2));

for i = 1:files(2)
    for j = i:files(2)
        temp = compare_sorted(path, name{i}, name{j});
        matrix(i, j) = sum(temp);
    end;
end;

clearvars path name files i j temp;
clc