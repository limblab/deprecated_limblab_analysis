function scaled_ave = clim_ave(avg_activity, CLim, avg_max)% avg_min, avg_max)
%find a way to modify the 'average' bar in 'array_movie' 

aclim  = round(CLim/2); %average color limit value
avg    = avg_activity;  %input value (avg activity for given frame)
amax   = avg_max;       %highest avg activity among all frames


if amax < aclim %we want less scaling if maximum average is below 'aclim'
    att = 1 - ( (aclim - amax)/100 ); % 'att' is an attenuation term to give a progressive scaling
else
    att = 1;
end

%if this is frame with highest avg value, scaled average will be CLim*att
avg = avg*(CLim/amax)*att;

scaled_ave = avg;



