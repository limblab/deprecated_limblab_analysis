function [ filt_struct ] = VMR_define_filters()
% Defines how to filter the covariates for the VMR
% analysis projects
% NOTE: All original covariates will be removed. In order to keep an
% original covariate "as is", explicitly filter it with a 1

% No inputs needed. Just modify the filters in-function here. The output of
% the function is a struct which you will feed to another function. That
% function is "filter_and_insert", and you'll also give it the covariate
% matrix you want filtered. I.e., filter_and_insert(filt_struct, cov_mat)

% Components of the filt_struct
% 1) .filt_name - whatever you want to call that particular filter.
% 2) .cov_num_in - the columns of the cov_mat that you want filtered with
% the filter in question
% 3) .filt_func - the actual filter 
% 4) .filt_shift - if you want an additional shift. this is sometimes
% easier than buildilng the shift into the filt_func.

% The function I've included below - rcosbasis - is a script we have laying
% around that generates decent temporal basis functions. Good place to
% start. Credit to Ian Stevenson and Pavan Ramkumar.

% All of the filters that I've included below are ones I've used for anothe
% project and are just examples. 

%% User inputs

bin_size = 10; % in ms

%% Initialization

idx = 1;

%% Assign movement filters

% Make temporal basis functions
[~,rcos_basis] = rcosbasis(1:80,[20 20 20],[5 7.5 10]); % 1 = 200ms total width, 2 = 300, 3 = 400ms;

% Movement filter 1
filt_struct(idx).filt_name = 'Early narrow';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,1);
filt_struct(idx).filt_shift = -40;
idx = idx + 1;

% Movement filter 2
filt_struct(idx).filt_name = 'Mid narrow';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,1);
filt_struct(idx).filt_shift = -30;
idx = idx + 1;

% Movement filter 3
filt_struct(idx).filt_name = 'Early wide';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,3);
filt_struct(idx).filt_shift = -40;
idx = idx + 1;

% Movement filter 4
filt_struct(idx).filt_name = 'Late narrow';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,1);
filt_struct(idx).filt_shift = 0;
idx = idx + 1;

% Movement filter 5
filt_struct(idx).filt_name = 'Early medium';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,2);
filt_struct(idx).filt_shift = -40;
idx = idx + 1;

% Movement filter 6
filt_struct(idx).filt_name = 'Mid medium';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,2);
filt_struct(idx).filt_shift = -20;
idx = idx + 1;

% Movement filter 7
filt_struct(idx).filt_name = 'Mid wide';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,3);
filt_struct(idx).filt_shift = -20;
idx = idx + 1;

% Movement filter 8
filt_struct(idx).filt_name = 'Late medium';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,2);
filt_struct(idx).filt_shift = 0;
idx = idx + 1;

% Movement filter 9
filt_struct(idx).filt_name = 'Late wide';
filt_struct(idx).cov_num_in = [1 2 3];
filt_struct(idx).filt_func = rcos_basis(:,3);
filt_struct(idx).filt_shift = 0;
idx = idx + 1;



end

