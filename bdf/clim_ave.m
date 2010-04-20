function scaled_ave = clim_ave(avg_activity, CLim, avg_max)
% Modifies the 'average' bar (value stored in 'all_activity' array) of each
% 'array_movie' image. This is done by taking the 'avg_activity' value of
% that particular frame, the number of rows in the colormap ('CLim'), and
% the maximum average activity value from among all the image frames
% ('avg_max') and scaling 'avg_activity' based on the difference between
% 'CLim' and 'avg_max'

aclim  = round(CLim/2); %average color limit value
avg    = avg_activity;  %input value (avg activity for given frame)
amax   = avg_max;       %highest avg activity among all frames


if amax < aclim %we want less scaling if maximum average is below 'aclim' (attenuation term will always shrink the scaled number, never grow it)
    att = 1 - ( (aclim - amax)/100 ); % 'att' is an attenuation term to give progressive scaling
else
    att = 1;
end

%if this is frame with highest avg value, scaled average will be CLim*att
avg = avg*(CLim/amax)*att;

scaled_ave = avg;



