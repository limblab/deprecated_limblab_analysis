%%
clear;
clc;
close all;
t = zeros(100,2);

b = [-8 8 -8 8];
r = [0 2000];

rand_x = b(1) + (b(2)-b(1)).*rand(1);
rand_y = b(3) + (b(4)-b(3)).*rand(1);
t(1,:) = [rand_x, rand_y];

redraw_tally = 0;
tally = zeros(1,100000);
for i = 2:100000
    keep_going = true;
    while keep_going
        rand_x = b(1) + (b(2)-b(1)).*rand(1);
        rand_y = b(3) + (b(4)-b(3)).*rand(1);
        t(i,:) = [rand_x, rand_y];
        
        temp = hypot(t(i,1)-t(i-1,1),t(i,2)-t(i-1,2));
        if temp >= 5 && temp <= 15
            keep_going = false;
        else
            redraw_tally = redraw_tally + 1;
            tally(i) = tally(i)+1;
        end
    end
end

d = zeros(size(t,1)-1,1);
for i = 2:size(t,1)
    d(i-1) = atan2(t(i,2)-t(i-1,2),t(i,1)-t(i-1,1));
end

dd = zeros(length(d)-1,1);
for i = 2:length(d)
    dd(i-1) = angleDiff(d(i-1),d(i),true,true);
end


figure;
subplot(1,4,1);
rose(dd)
title('Truly (Pseudo)Random','FontSize',14);

%%
num_targets = 10000;

maximum_distance = 15;
minimum_distance = 5;

left_target_boundary = -8;
right_target_boundary = 8;
lower_target_boundary = -8;
upper_target_boundary = 8;

% first target position
target_list(1,1) = left_target_boundary + (right_target_boundary - left_target_boundary) * rand;
target_list(1,2) = lower_target_boundary + (upper_target_boundary - lower_target_boundary) * rand;

% semi-random positions with min and max distances */
for i=2:num_targets
    temp_distance = minimum_distance + rand * (maximum_distance - minimum_distance);
    temp_angle = 2 * pi * rand;
    for j=1:5
            target_list(i,1) = target_list(i-1,1) + temp_distance * cos(temp_angle); % /* x position of first target*/
            target_list(i,2) = target_list(i-1,2) + temp_distance * sin(temp_angle); %/* y position of first target*/
        
        if (target_list(i,1) > left_target_boundary && target_list(i,1) < right_target_boundary && ...
                target_list(i,2) > lower_target_boundary && target_list(i,2) < upper_target_boundary)
            break;
        end
        
        if j==4
            target_list(i,1) = ( right_target_boundary + left_target_boundary )/2; %/* place target in center watchdog */
            target_list(i,2) = ( upper_target_boundary + lower_target_boundary )/2;
            break;
        end
        temp_angle = temp_angle + sign(-1+2*rand)*pi/2;
        temp_distance = minimum_distance;
    end
end

d = zeros(size(target_list,1)-1,1);
for i = 2:size(target_list,1)
    d(i-1) = atan2(target_list(i,2)-target_list(i-1,2),target_list(i,1)-target_list(i-1,1));
end

dd = zeros(length(d)-1,1);
for i = 2:length(d)
    dd(i-1) = angleDiff(d(i-1),d(i),true,true);
end

subplot(1,4,2);
rose(dd)
title('Actual Code Logic','FontSize',14);

%%
num_targets = 10000;

maximum_distance = 15;
minimum_distance = 5;

left_target_boundary = -8;
right_target_boundary = 8;
lower_target_boundary = -8;
upper_target_boundary = 8;

% first target position
target_list(1,1) = left_target_boundary + (right_target_boundary - left_target_boundary) * rand;
target_list(1,2) = lower_target_boundary + (upper_target_boundary - lower_target_boundary) * rand;

% semi-random positions with min and max distances */
for i=2:num_targets
    temp_distance = minimum_distance + rand * (maximum_distance - minimum_distance);
    temp_angle = 2 * pi * rand;
    for j=1:5
            target_list(i,1) = target_list(i-1,1) + temp_distance * cos(temp_angle); % /* x position of first target*/
            target_list(i,2) = target_list(i-1,2) + temp_distance * sin(temp_angle); %/* y position of first target*/
        
        if (target_list(i,1) > left_target_boundary && target_list(i,1) < right_target_boundary && ...
                target_list(i,2) > lower_target_boundary && target_list(i,2) < upper_target_boundary)
            break;
        end
        
        if j==4
            target_list(i,1) = ( right_target_boundary + left_target_boundary )/2; %/* place target in center watchdog */
            target_list(i,2) = ( upper_target_boundary + lower_target_boundary )/2;
            break;
        end
        temp_angle = 2 * pi * rand; %temp_angle - pi/2;
        temp_distance = minimum_distance;
    end
end

d = zeros(size(target_list,1)-1,1);
for i = 2:size(target_list,1)
    d(i-1) = atan2(target_list(i,2)-target_list(i-1,2),target_list(i,1)-target_list(i-1,1));
end

dd = zeros(length(d)-1,1);
for i = 2:length(d)
    dd(i-1) = angleDiff(d(i-1),d(i),true,true);
end

subplot(1,4,3);
rose(dd)
title('New Angle Every Time','FontSize',14);


%%
clear d;
load('F:\Mihili\Processed\2014-01-14\RT_VR_BL_2014-01-14.mat','movement_table');
d = movement_table(:,1);
% load('F:\Mihili\Processed\2014-01-14\RT_VR_AD_2014-01-14.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Mihili\Processed\2014-01-14\RT_VR_WO_2014-01-14.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Mihili\Processed\2014-01-15\RT_VR_BL_2014-01-15.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Mihili\Processed\2014-01-15\RT_VR_AD_2014-01-15.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Mihili\Processed\2014-01-15\RT_VR_WO_2014-01-15.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Mihili\Processed\2014-01-16\RT_VR_BL_2014-01-16.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Mihili\Processed\2014-01-16\RT_VR_AD_2014-01-16.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Mihili\Processed\2014-01-16\RT_VR_WO_2014-01-16.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Mihili\Processed\2014-02-14\RT_FF_BL_2014-02-14.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Mihili\Processed\2014-02-14\RT_FF_AD_2014-02-14.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Mihili\Processed\2014-02-14\RT_FF_WO_2014-02-14.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Mihili\Processed\2014-02-21\RT_FF_BL_2014-02-21.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Mihili\Processed\2014-02-21\RT_FF_AD_2014-02-21.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Mihili\Processed\2014-02-21\RT_FF_WO_2014-02-21.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Mihili\Processed\2014-02-24\RT_FF_BL_2014-02-24.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Mihili\Processed\2014-02-24\RT_FF_AD_2014-02-24.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Mihili\Processed\2014-02-24\RT_FF_WO_2014-02-24.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Chewie\Processed\2013-10-09\RT_VR_BL_2013-10-09.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Chewie\Processed\2013-10-09\RT_VR_AD_2013-10-09.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Chewie\Processed\2013-10-09\RT_VR_WO_2013-10-09.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Chewie\Processed\2013-10-10\RT_VR_BL_2013-10-10.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Chewie\Processed\2013-10-10\RT_VR_AD_2013-10-10.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Chewie\Processed\2013-10-10\RT_VR_WO_2013-10-10.mat','movement_table');
d = [d;movement_table(:,1)];

load('F:\Chewie\Processed\2013-10-11\RT_VR_BL_2013-10-11.mat','movement_table');
d = [d;movement_table(:,1)];
% load('F:\Chewie\Processed\2013-10-11\RT_VR_AD_2013-10-11.mat','movement_table');
% d = [d;movement_table(:,1)];
load('F:\Chewie\Processed\2013-10-11\RT_VR_WO_2013-10-11.mat','movement_table');
d = [d;movement_table(:,1)];

dd = zeros(length(d)-1,1);
for i = 2:length(d)
    dd(i-1) = angleDiff(d(i-1),d(i),true,true);
end
subplot(1,4,4);
rose(dd);
title('Recorded Data','FontSize',14);