function [angles_list,handle_pos] = calc_angles_from_imgs(path,beg_num,end_num,filetype)

% calc_angles_from_imgs.m takes as input the
% path of the image sequence, the image file numbers of the first and last
% image, and the filetype ('jpg','png',etc). 
% The path should be given as a string, including the entire file path up 
% until the image sequence number. 
%
% The function returns an array of angles corresponding to the wrist
% flexion angle, as well as a matrix containing handle coordinates.  The
% handle coordinates are in image format (origin is upper left) and are
% included for possible synchronization with recorded data. 
%
% To edit the image processing performance, see fiducial_track.m

table = zeros(end_num-beg_num+1,6);
%preallocate the table containing fiducial coordinates

h = waitbar(0,'Starting...');
for i = beg_num:end_num
    img = imread([path int2str(i)],filetype); %read image
    [hand,dist,med] = fiducial_track(img); 
        %use fiducial_track.m to find fiducial coordinates and then fill table
    table(i-beg_num+1,1:2) = hand;              
    table(i-beg_num+1,3:4) = dist; 
    table(i-beg_num+1,5:6) = med;
    waitbar(((i-beg_num+1)/length(table)),h,sprintf('Progress: %u / %u',...
        (i-beg_num+1),(length(table))));
end

waitbar(1,h,'Finishing...');
[~,pos_table] = adj_dist_fiduc(table); 
        %input the coordinate table into adj_dist_fiduc.m and return new
        %coordinate table.  'pos_table' is equivalent to 'table' except that
        %the distal arm fiducial coordinates have been replaced with
        %approximations of the points of rotation of the wrist.
        
angles_list = angles(pos_table);
        %runs angles.m to determine angles of flexion. 
handle_pos = pos_table(:,1:2);
        %handle position coordinates.
close(h);
