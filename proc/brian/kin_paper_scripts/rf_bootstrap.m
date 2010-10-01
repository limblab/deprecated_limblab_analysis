% rf_bootstrap.m

% Define dataset
clear all;
dataset = 't2';

% Other constants
num_reps = 1000; % number of random iterations to run
hnn = 6;       % half number of neurons to use per iteration (3 fo p, 6 for t2)
tic;

% Load data
load(['glm_rts_' dataset '.mat']);
load(['rts_bdf_' dataset '.mat']);
load(['rts_' dataset '_run.mat']);
load('mappings.mat');
eval(['mapping = mapping_' dataset ';']);

% Convert summary into structarray
s = [];
for i = 1:length(summary)
    s = [s summary{i}];
end

% Find the cells that meet our criterion
cutoff = find(means(2:end)<.1, 1, 'first');
good_cells = dropped_units(1:cutoff,:);
[c, ia, ib] = intersect(good_cells, mapping(:,[1 2]), 'rows');
mapping = mapping(ib,:);

% Build cell lists
tact_cells = mapping(mapping(:,3)==1, [1 2]);
prop_cells = mapping(mapping(:,3)==2, [1 2]);

vafs = zeros(num_reps, 3);

for n = 1:num_reps
    et = toc;
    disp(sprintf('Working on %d of %d | ET: %f', n, num_reps, et));
    
    % tactile
    r = randperm(length(tact_cells));
    tunits = tact_cells(r(1:2*hnn),:);
    p = predictions(bdf, 'vel', tunits, 10);
    vafs(n,1) = mean(mean(p));
    
    % deep
    r = randperm(length(prop_cells));
    punits = prop_cells(r(1:2*hnn),:);
    p = predictions(bdf, 'vel', punits, 10);
    vafs(n,2) = mean(mean(p));
    
    % both
    bunits = [tunits(1:hnn,:); punits(1:hnn,:)];
    p = predictions(bdf, 'vel', bunits, 10);
    vafs(n,3) = mean(mean(p));
end
