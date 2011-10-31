function ID = get_tgt_id(corners)
% This function returns an ID based on the location of a target
% 
% Corners is a 1x4 array of the target Upper Left and Lower Right
% corners locations [ULx ULy LRx LRy]
%
% ID 1 : on the positive x axis ( x>0, y=0 )
% ID 2 : in the first quadrant  ( x>0, y>0 )
% ID 3 : on the positive y axis ( x=0, y>0 )
% ID 4 : in the second quadrant ( x<0, y>0 )
% ID 5 : on the negative x axis ( x<0, y=0 )
% ID 6 : in the third quadrant  ( x<0, y<0 )
% ID 7 : on the negative y axis ( x=0, y<0 )
% ID 8 : in the fourth quadrant ( x>0, y<0 )
% 
% i.e.    3
%      4  |  2
%  --5----|----1->
%      6  |  8
%         7

x = corners(1)+(corners(3)-corners(1))/2;
y = corners(4)+(corners(2)-corners(4))/2;

if x > 0
	if y > 0
        ID = 2;
    elseif y < 0
        ID = 8;
    else
        ID = 1;
    end
elseif x < 0
    if y > 0
        ID = 4;
    elseif y < 0 
        ID = 6;
    else
        ID = 5;
    end
else
    if y > 0
        ID = 3;
    elseif y < 0
        ID = 7;
    else
        ID = 0;
    end
end
        