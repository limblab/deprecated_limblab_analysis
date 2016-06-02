addpath('\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Mini\VS-Long Hold\Hybrid','\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Mini\VS-Long Hold\Standard');

% hybrid decoder files (MVSLH2)
load('stats0814004.mat');
load('stats0814006.mat');
load('stats0815002.mat');
load('stats0815004.mat');
load('stats0816003.mat');
load('stats0821002.mat');
load('stats0821004.mat');
load('stats0822003.mat');
load('stats0822005.mat');
load('stats0824002.mat');
load('stats0824004.mat');

% standard decoder files (MVSLH1)
load('stats0814003.mat');
load('stats0814005.mat');
load('stats0815003.mat');
load('stats0815005.mat');
load('stats0816002.mat');
load('stats0821003.mat');
load('stats0821005.mat');
load('stats0822002.mat');
load('stats0822004.mat');
load('stats0824003.mat');
load('stats0824005.mat');

% hybrid decoder metrics
MVSLH2_num_entries = [stats0814004.num_entries stats0814006.num_entries stats0815002.num_entries ...
    stats0815004.num_entries stats0816003.num_entries stats0821002.num_entries stats0821004.num_entries ...
    stats0822003.num_entries stats0822005.num_entries stats0824002.num_entries stats0824004.num_entries];

MVSLH2_time2reward = [stats0814004.time2reward stats0814006.time2reward stats0815002.time2reward ...
    stats0815004.time2reward stats0816003.time2reward stats0821002.time2reward stats0821004.time2reward ...
    stats0822003.time2reward stats0822005.time2reward stats0824002.time2reward stats0824004.time2reward];

MVSLH2_time2targ = [stats0814004.time2target stats0814006.time2target stats0815002.time2target ...
    stats0815004.time2target stats0816003.time2target stats0821002.time2target stats0821004.time2target ...
    stats0822003.time2target stats0822005.time2target stats0824002.time2target stats0824004.time2target];

MVSLH2_dial_in = [stats0814004.dial_in stats0814006.dial_in stats0815002.dial_in ...
    stats0815004.dial_in stats0816003.dial_in stats0821002.dial_in stats0821004.dial_in ...
    stats0822003.dial_in stats0822005.dial_in stats0824002.dial_in stats0824004.dial_in];

% MVSLH2_movepatheff = [stats0814004.pathlength(5,:) stats0814006.pathlength(5,:) stats0815002.pathlength(5,:) ...
%     stats0815004.pathlength(5,:) stats0816003.pathlength(5,:) stats0821002.pathlength(5,:) stats0821004.pathlength(5,:) ...
%     stats0822003.pathlength(5,:) stats0822005.pathlength(5,:) stats0824002.pathlength(5,:) stats0824004.pathlength(5,:)];

MVSLH2_movepatheff = [stats0814004.pathlength(1,:) stats0814006.pathlength(1,:) stats0815002.pathlength(1,:) ...
    stats0815004.pathlength(1,:) stats0816003.pathlength(1,:) stats0821002.pathlength(1,:) stats0821004.pathlength(1,:) ...
    stats0822003.pathlength(1,:) stats0822005.pathlength(1,:) stats0824002.pathlength(1,:) stats0824004.pathlength(1,:)]/8;

% MVSLH2_totpatheff = [stats0814004.pathlength(6,:) stats0814006.pathlength(6,:) stats0815002.pathlength(6,:) ...
%     stats0815004.pathlength(6,:) stats0816003.pathlength(6,:) stats0821002.pathlength(6,:) stats0821004.pathlength(6,:) ...
%     stats0822003.pathlength(6,:) stats0822005.pathlength(6,:) stats0824002.pathlength(6,:) stats0824004.pathlength(6,:)];

MVSLH2_totpatheff = [stats0814004.pathlength(3,:) stats0814006.pathlength(3,:) stats0815002.pathlength(3,:) ...
    stats0815004.pathlength(3,:) stats0816003.pathlength(3,:) stats0821002.pathlength(3,:) stats0821004.pathlength(3,:) ...
    stats0822003.pathlength(3,:) stats0822005.pathlength(3,:) stats0824002.pathlength(3,:) stats0824004.pathlength(3,:)]/8;

MVSLH2_var = [stats0814004.vardata stats0814006.vardata stats0815002.vardata ...
    stats0815004.vardata stats0816003.vardata stats0821002.vardata stats0821004.vardata ...
    stats0822003.vardata stats0822005.vardata stats0824002.vardata stats0824004.vardata];

% standard decoder metrics
MVSLH1_num_entries = [stats0814003.num_entries stats0814005.num_entries stats0815003.num_entries ...
    stats0815005.num_entries stats0816002.num_entries stats0821003.num_entries stats0821005.num_entries ...
    stats0822002.num_entries stats0822004.num_entries stats0824003.num_entries stats0824005.num_entries];

MVSLH1_time2reward = [stats0814003.time2reward stats0814005.time2reward stats0815003.time2reward ...
    stats0815005.time2reward stats0816002.time2reward stats0821003.time2reward stats0821005.time2reward ...
    stats0822002.time2reward stats0822004.time2reward stats0824003.time2reward stats0824005.time2reward];

MVSLH1_time2targ = [stats0814003.time2target stats0814005.time2target stats0815003.time2target ...
    stats0815005.time2target stats0816002.time2target stats0821003.time2target stats0821005.time2target ...
    stats0822002.time2target stats0822004.time2target stats0824003.time2target stats0824005.time2target];

MVSLH1_dial_in = [stats0814003.dial_in stats0814005.dial_in stats0815003.dial_in ...
    stats0815005.dial_in stats0816002.dial_in stats0821003.dial_in stats0821005.dial_in ...
    stats0822002.dial_in stats0822004.dial_in stats0824003.dial_in stats0824005.dial_in];

% MVSLH1_movepatheff = [stats0814003.pathlength(5,:) stats0814005.pathlength(5,:) stats0815003.pathlength(5,:) ...
%     stats0815005.pathlength(5,:) stats0816002.pathlength(5,:) stats0821003.pathlength(5,:) stats0821005.pathlength(5,:) ...
%     stats0822002.pathlength(5,:) stats0822004.pathlength(5,:) stats0824003.pathlength(5,:) stats0824005.pathlength(5,:)];

MVSLH1_movepatheff = [stats0814003.pathlength(1,:) stats0814005.pathlength(1,:) stats0815003.pathlength(1,:) ...
    stats0815005.pathlength(1,:) stats0816002.pathlength(1,:) stats0821003.pathlength(1,:) stats0821005.pathlength(1,:) ...
    stats0822002.pathlength(1,:) stats0822004.pathlength(1,:) stats0824003.pathlength(1,:) stats0824005.pathlength(1,:)]/8;

% MVSLH1_totpatheff = [stats0814003.pathlength(6,:) stats0814005.pathlength(6,:) stats0815003.pathlength(6,:) ...
%     stats0815005.pathlength(6,:) stats0816002.pathlength(6,:) stats0821003.pathlength(6,:) stats0821005.pathlength(6,:) ...
%     stats0822002.pathlength(6,:) stats0822004.pathlength(6,:) stats0824003.pathlength(6,:) stats0824005.pathlength(6,:)];

MVSLH1_totpatheff = [stats0814003.pathlength(3,:) stats0814005.pathlength(3,:) stats0815003.pathlength(3,:) ...
    stats0815005.pathlength(3,:) stats0816002.pathlength(3,:) stats0821003.pathlength(3,:) stats0821005.pathlength(3,:) ...
    stats0822002.pathlength(3,:) stats0822004.pathlength(3,:) stats0824003.pathlength(3,:) stats0824005.pathlength(3,:)]/8;

MVSLH1_var = [stats0814003.vardata stats0814005.vardata stats0815003.vardata ...
    stats0815005.vardata stats0816002.vardata stats0821003.vardata stats0821005.vardata ...
    stats0822002.vardata stats0822004.vardata stats0824003.vardata stats0824005.vardata];
