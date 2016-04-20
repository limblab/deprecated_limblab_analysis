function dif1 = angleDiff(angle1, angle2)
%ANGLEDIFF Difference between two angles


dif = mod((angle2 - angle1), 2*pi);
if dif > pi
    dif1 = 2*pi - dif;
else
    dif1 = dif;
end