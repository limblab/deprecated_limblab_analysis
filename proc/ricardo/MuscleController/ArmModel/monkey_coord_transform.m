function [cursor_forward, cursor_up, cursor_right, vel_forward, vel_up, vel_right] = ...
            monkey_coord_transform(arm, center_pos, marker_pos, marker_vel)

% Converts the raw data from Optotrak marker coordinates to monkey trunk centered coordinates.
%
% Coordinate system for the Optotrak marker data is (assuming monkey sits
%   facing South for R arm and N for left arm)
%     X: North
%     Y: Down
%     Z: West
%
% Coordinate system for the monkey trunk centered data is 
%   Forward, Up and Right
%
% Variable names and sizes
% cursor_dir, vel_dir: num_tot_bins
% marker_pos, marker_vel: num_markers x num_dims x num_tot_bins
%
% Created by Sherwin Chan
% Date: 3/10/2004
% Last modified: 7/1/2005
%   -Changed coordinate system for optotrak so it wasn't in monkey
%   coordinates since that is really wrong.

if (arm == 'R')
    if size(size(marker_pos),2)==3   % circles
        cursor_forward = -((marker_pos(1,1,:) - center_pos(1)));
        cursor_up =      -((marker_pos(1,2,:) - center_pos(2)));
        cursor_right =    ((marker_pos(1,3,:) - center_pos(3)));
        vel_forward =    -marker_vel(1,1,:);
        vel_up =         -marker_vel(1,2,:);
        vel_right =       marker_vel(1,3,:);
    else % reaching data
        cursor_forward = -((marker_pos(1,:) - center_pos(1)));
        cursor_up =      -((marker_pos(2,:) - center_pos(2)));
        cursor_right =    ((marker_pos(3,:) - center_pos(3)));
        vel_forward =    -marker_vel(1,:);
        vel_up =         -marker_vel(2,:);
        vel_right =       marker_vel(3,:);
    end
elseif (arm == 'L')
    if size(size(marker_pos),2)==3
        cursor_forward =  ((marker_pos(1,1,:) - center_pos(1)));
        cursor_up =      -((marker_pos(1,2,:) - center_pos(2)));
        cursor_right =   -((marker_pos(1,3,:) - center_pos(3)));
        vel_forward =     marker_vel(1,1,:);
        vel_up =         -marker_vel(1,2,:);
        vel_right =      -marker_vel(1,3,:);
    else
        cursor_forward =  ((marker_pos(1,:) - center_pos(1)));
        cursor_up =      -((marker_pos(2,:) - center_pos(2)));
        cursor_right =   -((marker_pos(3,:) - center_pos(3)));
        vel_forward =     marker_vel(1,:);
        vel_up =         -marker_vel(2,:);
        vel_right =      -marker_vel(3,:);
    end
else
    disp(['ERROR: Letter ', arm, ' does not correspond to (R)ight or (L)eft arm.']);
    return;
end