function [allx,ally,allz,allframes,blocked_data] = preprocess(raw_data,OPTS)
% function to find good blocks of continuously marked frames in the file,
% then rotate them so they're in the treadmill coordinates (XY is saggital
% plane). OPTS specifies the criteria for defining good blocks of data


% find continuous blocks of frames with no gaps in the file
[blocked_data, frames] = find_frameblocks(raw_data,OPTS);
    
% rotate the markers so xy plane is sagittal
% and allow the possibilitiy to go through and label the markers correctly
nblocks = length(blocked_data);
new_data = blocked_data;
for blockn = 1:nblocks
    [x,y,z] = separate_points(blocked_data{blockn});  % this is just manipulating the data structure
    [newx,newy,newz] = rotate_markers(x,y,z, OPTS.ALL_FRAME, OPTS.ALL_LEG);  % rotate the coordinates
    % [x2, y2,z2] = edit_markers(x,y,z);   % NB this is reversed for some of the animals - should be xyz or yzx
    new_data{blockn} = combine_points(newx,newy,newz,frames{blockn});  % put the data back together as blocks
end

%  pull all the blocks together into single variables
nblocks = length(new_data);
allx = zeros(1,OPTS.NMARKERS);
ally = allx; allz = allx;  allframes = 0;
for blockn = 1:nblocks
    [x,y,z] = separate_points(new_data{blockn}(:,3:end));
    %     [newx, newy, newz] = zero_2_point(x,y,z,2);
    allx = [allx; x];
    ally = [ally; y];
    allz = [allz; z];
    allframes = [allframes; frames{blockn}];
end
allx = allx(2:end,:);
ally = ally(2:end,:);
allz = allz(2:end,:);
allframes = allframes(2:end);
blocked_data = new_data;