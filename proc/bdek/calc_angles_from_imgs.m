function angles_list = calc_angles_from_imgs(path,beg_num,end_num,filetype)

% calc_angles_from_imgs(path,beg_num,end_num,filetype) takes as input the
% path of the image sequence, the image file numbers of the first and last
% image, and the filetype ('jpg','png',etc). The path should be given as a
% string, including the entire file path up until the image sequence
% number. 

% To edit the image processing performance, see wrist_angle.m

table = zeros(end_num-beg_num+1,6);
%preallocate the table containing fiducial coordinates

for i = beg_num:end_num
    img = imread([path int2str(i)],filetype); %read image
    [hand,dist,med] = fiducial_track(img); 
        %use fiducial_track.m to find fiducial coordinates and then fill table
    table(i-beg_num+1,1:2) = hand;              
    table(i-beg_num+1,3:4) = dist; 
    table(i-beg_num+1,5:6) = med;
    clc;
    progress = sprintf('%u/%u',i-beg_num+1,length(table)) %#ok<NASGU,NOPRT>
        %display progress in Command Window
end
 
[~,pos_table] = adj_dist_fiduc(table); 
        %input the coordinate table into adj_dist_fiduc.m and return new
        %coordinate table.  'pos_table' is equivalent to 'table' except that
        %the distal arm fiducial coordinates have been replaced with
        %approximations of the points of rotation of the wrist.
        
angles_list = angles(pos_table);
        %runs angles.m to determine angles of flexion. 
