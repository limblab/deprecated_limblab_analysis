function adiff = angleDiff(angle1,angle2)
% finds absolute value of difference in angle

adiff = abs(angle2 - angle1);

for i = 1:length(adiff)
    if adiff(i) > 180
        adiff(i) = abs(360-adiff(i));
    end
end