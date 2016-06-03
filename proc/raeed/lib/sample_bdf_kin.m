function [pos, vel, acc] = sample_bdf_kin(bdf_cell,ts)
% SAMPLE_BDF_KIN Samples kinematics from a set of bdf data structures
%   Provided a sampling time, ts, typically 50 ms, SAMPLE_BDF_KIN returns
%   interpolated kinematics, concatenated from a set of BDF data
%   structures in a cell array. ts is in milliseconds.

% Author: Raeed Chowdhury
% Date Revised: 2014/07/02

% check if bdf_cell is cell array or just bdf
if ~iscell(bdf_cell)
    if isstruct(bdf_cell)
        bdf_cell = {bdf_cell};
    else
        error('sample_bdf_kin:invalid_input','First input must be a BDF or cell array of BDFs')
    end
end

% loop over all BDFs in cell array
pos = [];
vel = [];
acc = [];
for i = 1:length(bdf_cell)
    temp_bdf = bdf_cell{i};
    
    vt = temp_bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);
    
    pos = [pos; interp1(temp_bdf.pos(:,1),temp_bdf.pos(:,2:3),t)];
    vel = [vel; interp1(temp_bdf.vel(:,1),temp_bdf.vel(:,2:3),t)];
    acc = [acc; interp1(temp_bdf.acc(:,1),temp_bdf.acc(:,2:3),t)];
end