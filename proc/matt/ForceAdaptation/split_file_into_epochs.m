% this is a crappy convoluted way of breaking one reaaally long file into
% three different files for my adaptation experiments. I've used it for
% control data. First, turn the one file into BDF (should be "BL" epoch).
% Next, run my makeDataStruct code on this file alone. Then, run this
% script. It will make a backup copy of that original struct and make three
% unique ones, one for each fake epoch.

clear;
close all;
clc;

%%%%%%
% Code for Matt's data format
y = '2014';
m = '09';
d = '29';
arrays = {'M1'};
task = 'CO';
pert = 'VR';

fd = ['C:\Users\Matt Perich\Desktop\lab\data\Mihili\' y '-' m '-' d];
fn = ['\' task '_' pert '_BL_' y '-' m '-' d '.mat'];


% load data
data = load(fullfile(fd,fn));

% save original as backup
save(fullfile(fd,['\' task '_' pert '_BL_' y '-' m '-' d '_full.mat']),'-struct','data');

og_data = data;
clear data;

%%
% divide into 7 parts
t = og_data.cont.t;
tt = og_data.trial_table;
mt = og_data.movement_table;


% divvy trials into fake epochs
n = ceil(length(mt)/7);
bl_inds = 1:n;
ad_inds = n+1:n+3*n;
wo_inds = n+1+3*n:length(mt);

n = ceil(length(tt)/7);
bl_inds_tt = 1:n;
ad_inds_tt = n+1:n+3*n;
wo_inds_tt = n+1+3*n:length(tt);

% get time of end for each epoch
bl_end = mt(bl_inds(end),end);
ad_end = mt(ad_inds(end),end);
wo_end = mt(end,end);

%% assign baseline data struct
data.meta = og_data.meta;
data.params = og_data.params;
data.trial_table = og_data.trial_table(bl_inds_tt,:);
data.movement_table = og_data.movement_table(bl_inds,:);
data.movement_centers = og_data.movement_centers(bl_inds,:);

idx = t <= bl_end;
data.cont.t = og_data.cont.t(idx);
data.cont.pos = og_data.cont.pos(idx,:);
data.cont.vel = og_data.cont.vel(idx,:);
data.cont.acc = og_data.cont.acc(idx,:);
if ~isempty(og_data.cont.force)
    data.cont.force = og_data.cont.force(idx,:);
else
    data.cont.force = [];
end

for iArray = 1:length(arrays)
    data.(arrays{iArray}).sg = og_data.(arrays{iArray}).sg;
    for u = 1:length(og_data.(arrays{iArray}).units)
        idx = og_data.(arrays{iArray}).units(u).ts <= bl_end;
        data.(arrays{iArray}).units(u).id = og_data.(arrays{iArray}).units(u).id;
        data.(arrays{iArray}).units(u).wf = og_data.(arrays{iArray}).units(u).wf(:,idx);
        data.(arrays{iArray}).units(u).ts = og_data.(arrays{iArray}).units(u).ts(idx);
        data.(arrays{iArray}).units(u).ns = sum(idx);
        data.(arrays{iArray}).units(u).p2p = og_data.(arrays{iArray}).units(u).p2p;
        data.(arrays{iArray}).units(u).misi = og_data.(arrays{iArray}).units(u).misi;
        data.(arrays{iArray}).units(u).mfr = og_data.(arrays{iArray}).units(u).mfr;
        data.(arrays{iArray}).units(u).offline_sorter_channel = og_data.(arrays{iArray}).units(u).offline_sorter_channel;
    end
end

% now save baseline file
save(fullfile(fd,['\' task '_' pert '_BL_' y '-' m '-' d '.mat']),'-struct','data');
clear data;

%% assign adaptation data struct
data.meta = og_data.meta;
data.meta.epoch = 'AD';
data.params = og_data.params;
data.trial_table = og_data.trial_table(ad_inds_tt,:);
data.movement_table = og_data.movement_table(ad_inds,:);
data.movement_centers = og_data.movement_centers(ad_inds,:);

idx = find(t > bl_end & t <= ad_end);
t0 = t(idx(1));
data.cont.t = og_data.cont.t(idx); %-t0+1;
data.cont.pos = og_data.cont.pos(idx,:);
data.cont.vel = og_data.cont.vel(idx,:);
data.cont.acc = og_data.cont.acc(idx,:);
if ~isempty(og_data.cont.force)
    data.cont.force = og_data.cont.force(idx,:);
else
    data.cont.force = [];
end

for iArray = 1:length(arrays)
    data.(arrays{iArray}).sg = og_data.(arrays{iArray}).sg;
    for u = 1:length(og_data.(arrays{iArray}).units)
        idx = og_data.(arrays{iArray}).units(u).ts > bl_end & og_data.(arrays{iArray}).units(u).ts <= ad_end;
        data.(arrays{iArray}).units(u).id = og_data.(arrays{iArray}).units(u).id;
        data.(arrays{iArray}).units(u).wf = og_data.(arrays{iArray}).units(u).wf(:,idx);
        data.(arrays{iArray}).units(u).ts = og_data.(arrays{iArray}).units(u).ts(idx); %-t0+1;
        data.(arrays{iArray}).units(u).ns = sum(idx);
        data.(arrays{iArray}).units(u).p2p = og_data.(arrays{iArray}).units(u).p2p;
        data.(arrays{iArray}).units(u).misi = og_data.(arrays{iArray}).units(u).misi;
        data.(arrays{iArray}).units(u).mfr = og_data.(arrays{iArray}).units(u).mfr;
        data.(arrays{iArray}).units(u).offline_sorter_channel = og_data.(arrays{iArray}).units(u).offline_sorter_channel;
    end
end
% now save baseline file
save(fullfile(fd,['\' task '_' pert '_AD_' y '-' m '-' d '.mat']),'-struct','data');
clear data;

%% assign washout data struct
data.meta = og_data.meta;
data.meta.epoch = 'WO';
data.params = og_data.params;
data.trial_table = og_data.trial_table(wo_inds_tt,:);
data.movement_table = og_data.movement_table(wo_inds,:);
data.movement_centers = og_data.movement_centers(wo_inds,:);

idx = find(t > ad_end);
t0 = t(idx(1));
data.cont.t = og_data.cont.t(idx); %-t0+1;
data.cont.pos = og_data.cont.pos(idx,:);
data.cont.vel = og_data.cont.vel(idx,:);
data.cont.acc = og_data.cont.acc(idx,:);
if ~isempty(og_data.cont.force)
    data.cont.force = og_data.cont.force(idx,:);
else
    data.cont.force = [];
end

for iArray = 1:length(arrays)
    data.(arrays{iArray}).sg = og_data.(arrays{iArray}).sg;
    for u = 1:length(og_data.(arrays{iArray}).units)
        idx = og_data.(arrays{iArray}).units(u).ts > ad_end;
        data.(arrays{iArray}).units(u).id = og_data.(arrays{iArray}).units(u).id;
        data.(arrays{iArray}).units(u).wf = og_data.(arrays{iArray}).units(u).wf(:,idx);
        data.(arrays{iArray}).units(u).ts = og_data.(arrays{iArray}).units(u).ts(idx); %-t0+1;
        data.(arrays{iArray}).units(u).ns = sum(idx);
        data.(arrays{iArray}).units(u).p2p = og_data.(arrays{iArray}).units(u).p2p;
        data.(arrays{iArray}).units(u).misi = og_data.(arrays{iArray}).units(u).misi;
        data.(arrays{iArray}).units(u).mfr = og_data.(arrays{iArray}).units(u).mfr;
        data.(arrays{iArray}).units(u).offline_sorter_channel = og_data.(arrays{iArray}).units(u).offline_sorter_channel;
    end
end

% now save baseline file
save(fullfile(fd,['\' task '_' pert '_WO_' y '-' m '-' d '.mat']),'-struct','data');
clear data;

%%
% %%%%%%%
% % Code for BDFs
% %   NOTE: NEED TO ADD UNITS
% day = '09';
% fd = ['Z:\Chewie_8I2\Matt\M1\BDFStructs\2015-03-' day];
% fn = ['\Chewie_M1_CO_VR_BL_03' day '2015.mat'];
%
% % load data
% load(fullfile(fd,fn));
%
% %% save original as backup
% save(fullfile(fd,['\Chewie_M1_CO_VR_BL_03' day '2015_full.mat']),'out_struct');
%
% og_struct = out_struct;
% clear out_struct;
%
% %% find start words (17)
% k_t = og_struct.pos(:,1);
% w_t = og_struct.words(:,1);
% idx = find(og_struct.words(:,2)==17);
%
% % split it into 7 pieces, base is 1, adapt/wash are 3 each
% n = ceil(length(idx)/7);
%
% bl_starts = idx(1:n);
% ad_starts = idx(n+1:n+3*n);
% wo_starts = idx(n+1+3*n:end);
%
% % find the last time point for each file
% bl_end = og_struct.words(ad_starts(1)-1,1);
% ad_end = og_struct.words(wo_starts(1)-1,1);
%
% %%
% bl_bdf.meta = og_struct.meta;
% bl_bdf.raw = ['this was split from the original file ' fn];
% bl_bdf.words = og_struct.words(w_t <= bl_end,:);
% bl_bdf.databursts = ['this was split from the original file ' fn];
% bl_bdf.pos = og_struct.pos(k_t <= bl_end,:);
% bl_bdf.vel = og_struct.vel(k_t <= bl_end,:);
% bl_bdf.acc = og_struct.acc(k_t <= bl_end,:);
% bl_bdf.stim = og_struct.stim;
% bl_bdf.targets.corners = og_struct.targets.corners(1:n);
% bl_bdf.targets.rotation = og_struct.targets.rotation(1:n);
%
% out_struct = bl_bdf;
% save(fullfile(fd,['\Chewie_M1_CO_VR_BL_03' day '2015.mat']),'out_struct');
% clear out_struct;
%
% %%
% ad_bdf.meta = og_struct.meta;
% ad_bdf.raw = ['this was split from the original file ' fn];
% ad_bdf.words = og_struct.words(w_t > bl_end & w_t <= ad_end,:);
% ad_bdf.databursts = ['this was split from the original file ' fn];
% ad_bdf.pos = og_struct.pos(k_t > bl_end & k_t <= ad_end,:);
% ad_bdf.vel = og_struct.vel(k_t > bl_end & k_t <= ad_end,:);
% ad_bdf.acc = og_struct.acc(k_t > bl_end & k_t <= ad_end,:);
% ad_bdf.stim = og_struct.stim;
% ad_bdf.targets.corners = og_struct.targets.corners(n+1:n+3*n);
% ad_bdf.targets.rotation = og_struct.targets.rotation(n+1:n+3*n);
%
% out_struct = ad_bdf;
% save(fullfile(fd,['\Chewie_M1_CO_VR_AD_03' day '2015.mat']),'out_struct');
% clear out_struct;
%
% %%
% wo_bdf.meta = og_struct.meta;
% wo_bdf.raw = ['this was split from the original file ' fn];
% wo_bdf.words = og_struct.words(w_t > ad_end,:);
% wo_bdf.databursts = ['this was split from the original file ' fn];
% wo_bdf.pos = og_struct.pos(k_t > ad_end,:);
% wo_bdf.vel = og_struct.vel(k_t > ad_end,:);
% wo_bdf.acc = og_struct.acc(k_t > ad_end,:);
% wo_bdf.stim = og_struct.stim;
% wo_bdf.targets.corners = og_struct.targets.corners(n+1+3*n:end);
% wo_bdf.targets.rotation = og_struct.targets.rotation(n+1+3*n:end);
%
% out_struct = wo_bdf;
% save(fullfile(fd,['\Chewie_M1_CO_VR_WO_03' day '2015.mat']),'out_struct');
% clear out_struct;


