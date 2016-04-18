%Script to track the color markers over time

%A file needs to be loaded which contains the color pixels of each frame

%In general, tracking works by finding points that are near the marker in
%the previous frame, along with using constraints based on distances to
%other markers. 

%The general flow of the script is as follows:
%1) Get the location of the arm markers
%The red arm markers are run a preliminary time, in order to get distance
%constraints from the blue arm marker
%Some manual correction is allowed for the elbow markers

%2) Get the location of the 

%For the main tracking portions of the script (e.g. blue arm, red hand,
%etc.), there are more detailed comments in the "Blue Arm" section which
%comes first. For the subsequent sections, only unique aspects are
%commented on in detail.




%% Input File to Load

%File to load
main_dir='/Users/jig289/Box Sync/Tracking_Data/';
monkey='Han';
date='03-22-16'; %mo-day-yr
exp='RW_DL';
num='001';

% Load ColorTracking File and Settings
fname_load=ls([main_dir monkey '/Color_Tracking/' date '/Tracking/color_tracking ' exp '_' num '*']);
load(deblank(fname_load))


%% User Options / Initializations

%If this is the first file from a date, set equal to 1 (there are more initializations)
first_time=0; 

%Load all of the settings if it's not the first file 
if ~first_time
    date2=['20' num2str(date(7:8)) num2str(date(1:2)) num2str(date(4:5))];
    fname_load_settings=[main_dir monkey '/Color_Tracking/' date '/Markers/settings_' monkey '_' date2];
    load(fname_load_settings);
end


%TIME INITIALIZATIONS
start=1; %Time point we're starting at
n=length(color1);
finish=n; %Time point we're finishing at
n_times=finish-start+1; %Number of time points (frames)

n_times_prelim=3000; %Number of time points to run in order to set distance limits (using all frames is not necessary and will take longer)
finish_prelim=start+n_times_prelim-1;

%Plot figure of schematic of marker locations?
plot_marker_locs=1;

%Manually type in initial marker locations? (Otherwise you get to click on
%them in the figure)
marker_init_manual=0;

%MARKER NUMBER INITIALIZATIONS
red_arm_marker_ids=[8,10];
blue_arm_marker_ids=[7];
green_shoulder_marker_ids=[9];
green_elbow_marker_ids=[6];
red_hand_marker_ids=[3];
yellow_hand_marker_ids=[4];
blue_hand_marker_ids=[2];
green_hand_marker_ids=[1,5];

%% Plotting Initializations

figure;
set(gca,'NextPlot','replacechildren');

xlims=[-.5 .5];
ylims=[-.5 .4];
zlims=[.9 1.4];

pause_time=.03;


%% Initializations of vectors/matrices

%Keeps track of all the cluster locations
all_medians=NaN(11,3,n_times); %Has NaNs when a marker is missing
all_medians2=NaN(11,3,n_times); %Estimates where markers are when they are missing

%Initialize some vectors that I use later for calculating the distance
%between points
dists=NaN(1,n_times_prelim);
dists1=NaN(1,n_times_prelim);
dists2=NaN(1,n_times_prelim);
dists3=NaN(1,n_times_prelim);
dists4=NaN(1,n_times_prelim);
dists5=NaN(1,n_times_prelim);


%% Marker location schematic figure

marker_demo_locs=[0 0; 1 1; 1 -1; 2 1; 2 -1;...
    10 -1; 10 3; 10 6; 10 9; 9 0;...
    2 -3];
r=[1 0 0];
g=[0 1 0];
b=[0 1 1];
y=[1 1 0];
marker_demo_colors=[g; b; r; y; g; g; b; r; g; r; b];

if plot_marker_locs
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(1,2,1);
    scatter(marker_demo_locs(:,1),marker_demo_locs(:,2),200,marker_demo_colors,'filled');
    str={'1','2','3','4','5','6','7','8','9','10','11'};
    text(marker_demo_locs(:,1),marker_demo_locs(:,2),str)
    xlim([-5 15]);
    ylim([-5 15]);
end


%% MARKER LOCATION INITIALIZATIONS (INTERACTIVE)

if ~marker_init_manual
    
    marker_colors={'g','b','r','y','g','g','b','r','g','r'}; %The colors of each of our markers
    
    num_markers=10;
    marker_coords_xy=NaN(num_markers,2);
    
    if plot_marker_locs
        subplot(1,2,2);
    else
        figure
    end
    %Get x,y,z coordinates for points in all colors
    temp=color1{start};
    x1=temp(1:end/3);
    y1=temp(end/3+1:2*end/3);
    z1=temp(2*end/3+1:end);
    hold on;
    temp=color2{start};
    x2=temp(1:end/3);
    y2=temp(end/3+1:2*end/3);
    z2=temp(2*end/3+1:end);
    temp=color3{start};
    x3=temp(1:end/3);
    y3=temp(end/3+1:2*end/3);
    z3=temp(2*end/3+1:end);
    temp=color4{start};
    x4=temp(1:end/3);
    y4=temp(end/3+1:2*end/3);
    z4=temp(2*end/3+1:end);
    
    %Plot all the points in the x/y plane (z, which is depth, doesn't change
    %much between the points)
    scatter(x1,y1,'b')
    hold on;
    scatter(x2,y2,'g')
    scatter(x3,y3,'r')
    scatter(x4,y4,'y')
    hold off
    xlabel('x')
    ylabel('y')
    xlim(xlims)
    ylim(ylims)
    
    %Have users select the markers
    for m=1:num_markers
        title(['Click marker ' num2str(m)])
        marker_coords_xy(m,:)=ginput(1);
    end
    
    
    marker_inits=NaN(11,3); %Made large enough for an 11th marker (which we used at one point)
    for m=1:num_markers
        if marker_colors{1}=='r'
            closest_point=knnsearch([x3' y3'],marker_coords_xy(m,:),'k',1);
            marker_inits(m,:)=[x3(closest_point) y3(closest_point) z3(closest_point)];
        end
        if marker_colors{1}=='g'
            closest_point=knnsearch([x2' y2'],marker_coords_xy(m,:),'k',1);
            marker_inits(m,:)=[x2(closest_point) y2(closest_point) z2(closest_point)];
        end
        if marker_colors{1}=='b'
            closest_point=knnsearch([x1' y1'],marker_coords_xy(m,:),'k',1);
            marker_inits(m,:)=[x1(closest_point) y1(closest_point) z1(closest_point)];
        end
        if marker_colors{1}=='y'
            closest_point=knnsearch([x4' y4'],marker_coords_xy(m,:),'k',1);
            marker_inits(m,:)=[x4(closest_point) y4(closest_point) z4(closest_point)];
        end
    end
    
    %What if there's another point w/ the same x,y, but a different z (very
    %rare, but possible)???
    
end

%% MARKER LOCATION INITIALIZATIONS (IF YOU'D PREFER TO TYPE IT IN)

if marker_init_manual
    marker_inits=NaN(11,3);
    marker_inits(1,:)=[1.12,.04,-.14];
    marker_inits(2,:)=[1.13,.06,-.13];
    marker_inits(3,:)=[1.12,.06,-.15];
    marker_inits(4,:)=[1.13,.09,-.13];
    marker_inits(5,:)=[1.13,.09,-.15];
    marker_inits(6,:)=[1.09,.26,-.06];
    marker_inits(7,:)=[1.09,.28,-.11];
    marker_inits(8,:)=[1.09,.31,-.02];
    marker_inits(9,:)=[1.12,.36,.04];
    marker_inits(10,:)=[1.10,.25,-.10];

    %I plot z,x,y (instead of x,y,z), so I input z,x,y above. Here, switch to x,y,z
    marker_inits_temp=marker_inits;
    marker_inits(:,1)=marker_inits_temp(:,2);
    marker_inits(:,2)=marker_inits_temp(:,3);
    marker_inits(:,3)=marker_inits_temp(:,1);
end

%% Blue Arm

%Initializations
plot_on=0; %Whether to plot while it's running
marker_ids=blue_arm_marker_ids; %Set the marker_ids specified in "Initializations"
color=color1; %Blue=1, Green=2, Red=3
prev_meds=marker_inits(marker_ids,:); %Set initial "previous marker locations" as the start locations input in "Initializations"
num_clust=length(marker_ids); %Number of clusters
within_clust_dist1=0.07; %How close points must be to the previous frame's marker to be considered
dist_min=0.07; %Minimum distance between markers (cluster medians aren't allowed w/ distance < min_dist)

medians=NaN(num_clust,3,n_times); %Has NaNs when a marker is missing
medians2=NaN(num_clust,3,n_times); %Has previous known positions when a marker is missing


% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)    
    %Get distances of all points to the marker in the previous frame
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;
    else
        D=pdist2(loc,medians2(:,:,t-1));
    end
    
    % Keep all the points close enough to the previous marker
    keep1=D(:,1)<within_clust_dist1;
    
    %Remove points (those we're not keeping)
    rmv=~(keep1);
    
    %Actually remove the points
    loc(rmv,:)=[];
        
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

%Put the markers found here in the matrix of all markers
all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;

%% Red Arm

if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Initializations
    plot_on=0;
    marker_ids=red_arm_marker_ids;
    color=color3;
    prev_meds=marker_inits(marker_ids,:);
    num_clust=length(marker_ids); 
    within_clust_dist1=.07; %How close points must be to the previous frame's first marker, # marker_ids(1), to be considered
    within_clust_dist2=.07; %How close points must be to the previous frame's second marker, # marker_ids(2), to be considered
    dist_min=0.07; 
    
    medians=NaN(num_clust,3,n_times);
    medians2=NaN(num_clust,3,n_times);
        
    % LOOP THROUGH TIME
    t=0;
    for i=start:finish
        
        t=t+1;
        
        %0. Get x,y,z positions
        temp=color{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        loc=[x; y; z]';
        
        %1. Filter some bad points (those that are really far away)
        %Get distances of all points to the marker in the previous frame
        if t==1
            D=pdist2(loc,prev_meds);
            prev_num_clust=num_clust;            
        else
            D=pdist2(loc,medians2(:,:,t-1));
        end
        
        % Keep all the points close enough to either of the previous markers
        keep1=D(:,1)<within_clust_dist1;
        keep2=D(:,2)<within_clust_dist2;       
        
        %Remove points (those we're not keeping)
        rmv=~(keep1 | keep2);
        
        %Actually remove the points
        loc(rmv,:)=[];
        
        
        %2. Cluster and assign
        %Note that this uses "cluster_func" instead of "cluster_func2"
        %which is slightly faster but less accurate. This is because we
        %will be redoing this later with cluster_func2. This current run is
        %only to determine the distances from the red arm to blue arm
        %markers (which will help in the next run)
        [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func(t, loc, num_clust, prev_num_clust, dist_min, .05, prev_meds, medians, medians2 );
        
        %3. Plot original image and cluster centers
        plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
        
    end
    
    %Put the markers found here in the matrix of all markers
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
    
end
%% SET LIMITS ON RED ARM TO BLUE ARM DISTANCES

%PLOT RED ARM TO BLUE ARM DISTANCES
if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Calculate distances for each time point
    for i=1:n_times_prelim
        dists(i)=pdist2(all_medians(10,:,i),all_medians(7,:,i)); %Distance between markers 7 and 10 (blue arm and red elbow)
        dists2(i)=pdist2(all_medians(8,:,i),all_medians(7,:,i)); %Distance between markers 7 and 8 (blue arm and red arm)
    end
    
    %Plot
    figure; plot(dists);
    hold on;
    plot(dists2)
    legend('7-10','7-8')
    
    % VISUALIZE FRAMES
    user_input=1; %A value so that it enters the while loop below
    while ~isempty(user_input)
        
        str1='Enter time point you want to visualize (or just press enter to continue) \n';
        user_input=input(str1);
        if ~isempty(user_input)
            plot_together_4colors_func(user_input, [7 8 10], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)
        end
    end
    
    % SET RED ARM TO BLUE ARM DISTANCES
    str1='1A. Input red_elbow_dist_from_blue \n';
    str2='The blue values in the above plot should be generally be below this value (the red elbow should be within this distance of the blue arm)\n';
    str3='The purpose of this is to keep all points w/in this distance of the blue as marker candidates (useful if the red elbow marker was gone the previous frame) \n';
    str4='Value is generally ~ .05-.1 \n';
    red_elbow_dist_from_blue=input([str1 str2 str3 str4]);
    
    str1='1B. Input red_blue_arm_dist_max \n';
    str2='All values in above plot should be below this value (Maximum distance from a red arm point to the blue)\n';
    str3='The purpose of this is to remove all points farther than this from the blue marker (to get rid of noise)';
    str4='Value is generally ~ .05-.1 \n';
    red_blue_arm_dist_max=input([str1 str2 str3 str4]);
    
end

%% Red Arm (Redo)
%Note that this is different from the previous version of "Red Arm" because
%now there are constraints involving distance from the blue arm marker

%Initializations
plot_on=0;
marker_ids=red_arm_marker_ids;
color=color3;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids); %Number of clusters
within_clust_dist1=.07; %How close points must be to the previous frame's first marker, # marker_ids(1), to be considered
within_clust_dist2=.07; %How close points must be to the previous frame's second marker, # marker_ids(2), to be considered   
dist_min=0.05; %Minimum distance between markers (cluster medians aren't allowed w/ distance < min_dist)

medians=NaN(num_clust,3,n_times); %Has NaNs when a marker is missing
medians2=NaN(num_clust,3,n_times); %Has previous known positions when a marker is missing


% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)
    %Get distances of all points to the marker in the previous frame
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;        
    else
        D=pdist2(loc,medians2(:,:,t-1));        
    end
    
    %Get distance to blue arm marker from the current frame
    D2=pdist2(loc,all_medians2(7,:,t)); 
    
    % Keep all the points close enough to either of the previous markers
    keep1=D(:,1)<within_clust_dist1;
    keep2=D(:,2)<within_clust_dist2;
    
    %Also keep if the it's near the blue arm marker (in case one of the
    %others disappears for a while)    
    keep3=D2<red_elbow_dist_from_blue;
    
    %Remove points that are too far from the blue marker
    rmv0=D2>red_blue_arm_dist_max;
    
    %Remove points (those we're not keeping, or those we're removing)
    rmv=~(keep1 | keep2 | keep3) | rmv0;
  
    %Actually remove the points
    loc(rmv,:)=[];
       
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;

%% REMOVE FAULTY RED ELBOW POINTS

%This calculates (and plots) the angle made by points 7,8,10
%Problems with the red elbow marker (point 10) will make this angle wrong
%We will remove those points

angle=NaN(1,n_times); %Initialize vector of angles for each frame

for i=1:n_times
    
    if all(~isnan(all_medians([7 8 10],1,i))) %Only find angle for frames when all markers 7/8/10 are present
        a=all_medians(10,:,i);
        b=all_medians(7,:,i);
        c=all_medians2(8,:,i);
        
        u=a-b; %Vector from 10 to 7
        v=c-b; %Vector from 8 to 7
        
        angle(i)=acos(dot(u,v)/norm(u)/norm(v)); %Angle made by 10,7,8
    end
end

%Plot
figure; plot(angle)   
red_elbow_angle_thresh=nanmean(angle)-4*nanstd(angle); %Frames with an angle below this will have marker 10 removed
title(['Red Elbow Angles: Default Threshold=' num2str(red_elbow_angle_thresh)]);


%VISUALIZE FRAMES
user_input=1; %A value so that it enters the while loop below
while ~isempty(user_input)
    
    str1='Enter time point you want to visualize (or just press enter to continue) \n';    
    user_input=input(str1);
    if ~isempty(user_input)
        plot_together_4colors_func(user_input, [7 8 10], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)
    end
end

%SET ANGLE THRESHOLD FOR RED ELBOW REMOVAL
str1='Enter angle threshold for red elbow removal. Press enter for default. \n'; 
temp=input(str1);
if ~isempty(temp)
    red_elbow_angle_thresh=temp;
end

%Remove red elbow points (based on angle)
rmv10=angle<red_elbow_angle_thresh;
all_medians(10,:,rmv10)=NaN;

%% Green Shoulder

if ~isempty(green_shoulder_marker_ids) %Only do this if it is a file with a green shoulder marker
    %Initializations
    plot_on=0;
    marker_ids=green_shoulder_marker_ids;
    color=color2;
    prev_meds=marker_inits(marker_ids,:);
    num_clust=length(marker_ids);
    within_clust_dist1=.07;
    dist_min=0.07; 
    
    medians=NaN(num_clust,3,n_times); 
    medians2=NaN(num_clust,3,n_times);
    
    
    % LOOP THROUGH TIME
    t=0;
    for i=start:finish
        
        t=t+1;
        
        %0. Get x,y,z positions
        temp=color{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        loc=[x; y; z]';
        
        %1. Filter some bad points (those that are really far away)
        
        if t==1
            D=pdist2(loc,prev_meds);
            prev_num_clust=num_clust;
        else
            D=pdist2(loc,medians2(:,:,t-1));
        end
        
        % Keep all the points close enough to the previous marker
        keep1=D(:,1)<within_clust_dist1;
        
        % Remove
        rmv=~(keep1);
        loc(rmv,:)=[];
        
        
        %2. Cluster and assign
        [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
        
        %3. Plot original image and cluster centers
        plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
        
    end
    
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
end


%% Green Elbow

%Initializations
plot_on=0;
marker_ids=green_elbow_marker_ids;
color=color2;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids);
within_clust_dist1=.07;
dist_min=0.07;

medians=NaN(num_clust,3,n_times);
medians2=NaN(num_clust,3,n_times);


% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)
    
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;
    else
        D=pdist2(loc,medians2(:,:,t-1));
    end
    
    % Keep all the points close enough to the previous marker
    keep1=D(:,1)<within_clust_dist1;
    
    %Also use distance from red elbow marker
    D2=pdist2(loc,all_medians(10,:,t));   
    keep2=D2<.03; %Keep points that are close to red elbow marker        
    rmv0=D2>.03; %Remove points that are too far from red elbow marker
   
    rmv=~(keep1|keep2) | rmv0; %Keep points that are either close enough to 
    %the previous marker or the red elbow marker. Additionally, remove 
    %points that are too far from the red elbow marker (even if they're 
    %close enough to the previous marker)

    %Remove
    loc(rmv,:)=[];
        
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;

%% REMOVE FAULTY GREEN ELBOW POINTS

%This calculates (and plots) the angle made by points 7,8,6
%Problems with the green elbow marker (point 6) will make this angle wrong
%We will remove those points

angle=NaN(1,n_times); %Initialize vector of angles for each frame

for i=1:n_times
    
    if all(~isnan(all_medians([7 8 6],1,i))) %Only find angle for frames when all markers 6/7/8 are present
        
        a=all_medians(6,:,i);
        b=all_medians(7,:,i);
        c=all_medians2(8,:,i);
        
        u=a-b; %Vector from 6 to 7
        v=c-b; %Vector from 8 to 7
        
        angle(i)=acos(dot(u,v)/norm(u)/norm(v)); %Angle made by 6,7,8
    end
end

%Plot
figure; plot(angle)
green_elbow_angle_thresh=nanmean(angle)-4*nanstd(angle); %Frames with an angle below this will have marker 6 removed
title(['Green Elbow Angles: Default Threshold=' num2str(green_elbow_angle_thresh)]);


% VISUALIZE FRAMES
user_input=1; %A value so that it enters the while loop below
while ~isempty(user_input)
    
    str1='Enter time point you want to visualize (or just press enter to continue) \n';    
    user_input=input(str1);
    if ~isempty(user_input)
        plot_together_4colors_func(user_input, [7 8 10], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)
    end
end

% SET ANGLE THRESHOLD FOR GREEN ELBOW REMOVAL
str1='Enter angle threshold for green elbow removal. Press enter for default. \n'; 
temp=input(str1);
if ~isempty(temp)
    green_elbow_angle_thresh=temp;
end

% Remove green elbow points (based on angle)
rmv6=angle<green_elbow_angle_thresh;
all_medians(6,:,rmv6)=NaN;



%% Red Hand (Preliminary)
if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Initializations
    plot_on=0;
    marker_ids=red_hand_marker_ids;
    color=color3;
    prev_meds=marker_inits(marker_ids,:);
    num_clust=length(marker_ids); 
    within_clust_dist1=.07;  %How close points must be to the previous frame's first marker, # marker_ids(1), to be considered
    dist_min=0.02;
    
    medians=NaN(num_clust,3,n_times); 
    medians2=NaN(num_clust,3,n_times); 
    
    
    % LOOP THROUGH TIME
    t=0;
    for i=start:finish_prelim
        
        t=t+1;
        
        %0. Get x,y,z positions
        temp=color{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        loc=[x; y; z]';
        
        %1. Filter some bad points (those that are really far away)
        %Get distances of all points to the marker in the previous frame
        if t==1
            D=pdist2(loc,prev_meds);
            prev_num_clust=num_clust;
        else
            D=pdist2(loc,medians2(:,:,t-1));
        end
        
        % Keep all the points close enough to either of the previous markers
        keep1=D(:,1)<within_clust_dist1;
        
        %Remove points (those we're not keeping)
        rmv=~keep1;
        
        %Actually remove the points
        loc(rmv,:)=[];
        
        
        %2. Cluster and assign
        %Note that this uses "cluster_func" instead of "cluster_func2"
        %which is slightly faster but less accurate. This is because we
        %will be redoing this later with cluster_func2. This current run is
        %only to determine the distances from the red hand markers to arm
        %markers (which will help in the next run)
        [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func(t, loc, num_clust, prev_num_clust, dist_min, .05, prev_meds, medians, medians2 );
               
        %3. Plot original image and cluster centers
        plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
        
    end
    
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
    
end

%% Yellow Hand (Preliminary)
if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Initializations
    plot_on=0;
    marker_ids=yellow_hand_marker_ids;
    color=color4;
    prev_meds=marker_inits(marker_ids,:);
    num_clust=length(marker_ids); 
    within_clust_dist1=.07;  %How close points must be to the previous frame's first marker, # marker_ids(1), to be considered
    dist_min=0.02;
    
    medians=NaN(num_clust,3,n_times); 
    medians2=NaN(num_clust,3,n_times); 
    
    
    % LOOP THROUGH TIME
    t=0;
    for i=start:finish_prelim
        
        t=t+1;
        
        %0. Get x,y,z positions
        temp=color{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        loc=[x; y; z]';
        
        %1. Filter some bad points (those that are really far away)
        %Get distances of all points to the marker in the previous frame
        if t==1
            D=pdist2(loc,prev_meds);
            prev_num_clust=num_clust;
        else
            D=pdist2(loc,medians2(:,:,t-1));
        end
        
        % Keep all the points close enough to either of the previous markers
        keep1=D(:,1)<within_clust_dist1;
        
        %Remove points (those we're not keeping)
        rmv=~keep1;
        
        %Actually remove the points
        loc(rmv,:)=[];
        
        
        %2. Cluster and assign
        %Note that this uses "cluster_func" instead of "cluster_func2"
        %which is slightly faster but less accurate. This is because we
        %will be redoing this later with cluster_func2. This current run is
        %only to determine the distances from the red hand markers to arm
        %markers (which will help in the next run)
        [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func(t, loc, num_clust, prev_num_clust, dist_min, .05, prev_meds, medians, medians2 );
               
        %3. Plot original image and cluster centers
        plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
        
    end
    
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
    
end

%% Green Hand (Preliminary)
if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Initializations
    plot_on=0;
    marker_ids=green_hand_marker_ids;
    color=color2;
    prev_meds=marker_inits(marker_ids,:);
    num_clust=length(marker_ids);
    within_clust_dist1=.07; %How close points must be to the previous frame's first marker, # marker_ids(1), to be considered
    within_clust_dist2=.07; %How close points must be to the previous frame's second marker, # marker_ids(2), to be considered
    dist_min=0.03; 
    
    medians=NaN(num_clust,3,n_times); 
    medians2=NaN(num_clust,3,n_times); 
    
    
    % LOOP THROUGH TIME
    t=0;
    for i=start:finish_prelim
        
        t=t+1;
        
        %0. Get x,y,z positions
        temp=color{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        loc=[x; y; z]';
        
        %1. Filter some bad points (those that are really far away)
        %Get distances of all points to the marker in the previous frame
        if t==1
            D=pdist2(loc,prev_meds);
            prev_num_clust=num_clust;
        else
            D=pdist2(loc,medians2(:,:,t-1));
        end
        % Keep all the points close enough to either of the previous markers
        keep1=D(:,1)<within_clust_dist1;
        keep2=D(:,2)<within_clust_dist2;
        
        %Remove points (those we're not keeping)
        rmv=~(keep1 | keep2);
        
        %Actually remove the points
        loc(rmv,:)=[];
        
        
        %2. Cluster and assign
        %Note that this uses "cluster_func" instead of "cluster_func2"
        %which is slightly faster but less accurate. This is because we
        %will be redoing this later with cluster_func2. This current run is
        %only to determine the distances from the green hand to arm
        %markers (which will help in the next run)
        [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func(t, loc, num_clust, prev_num_clust, dist_min, .05, prev_meds, medians, medians2 );
        
        %3. Plot original image and cluster centers
        plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
        
    end
    
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
    
end
%% Blue Hand (Preliminary)
if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Initializations
    plot_on=0;
    marker_ids=blue_hand_marker_ids;
    color=color1;
    prev_meds=marker_inits(marker_ids,:);
    num_clust=length(marker_ids);
    within_clust_dist1=.07;
    dist_min=0.07;
    
    medians=NaN(num_clust,3,n_times); 
    medians2=NaN(num_clust,3,n_times); 
    
    
    % LOOP THROUGH TIME
    t=0;
    for i=start:finish_prelim
        
        t=t+1;
        
        %0. Get x,y,z positions
        temp=color{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        loc=[x; y; z]';
        
        %1. Filter some bad points (those that are really far away)
        %Get distances of all points to the marker in the previous frame
        if t==1
            D=pdist2(loc,prev_meds);
            prev_num_clust=num_clust;
        else
            D=pdist2(loc,medians2(:,:,t-1));
        end
        
        %Keep points close enough to previous marker
        keep1=D(:,1)<within_clust_dist1;        
        rmv=~(keep1);
        
        %Actually remove
        loc(rmv,:)=[];
        
        
        %2. Cluster and assign
        %Note that this uses "cluster_func" instead of "cluster_func2"
        %which is slightly faster but less accurate. This is because we
        %will be redoing this later with cluster_func2. This current run is
        %only to determine the distances from the blue hand to arm
        %markers (which will help in the next run)
        [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func(t, loc, num_clust, prev_num_clust, dist_min, .05, prev_meds, medians, medians2 );
        
        %3. Plot original image and cluster centers
        plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
        
    end
    
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
end
%% Plot hand distances from red elbow
%Plots the distances of every hand marker to to red elbow marker in order
%to determine what distances are allowed (for rerunning the hand marker
%tracking)
if first_time
    
    %Calculate distances
    for i=1:n_times_prelim
        dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i)); %Distance from point 10 (red elbow to point 1)
        dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i)); %etc...
        dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));
    end
    
    %Plot
    figure; plot(dists1,'g'); hold on;
    plot(dists2,'b');
    plot(dists3,'r');
    plot(dists4,'y');
    plot(dists5,'g');
   
    
    %VISUALIZE FRAMES
    user_input=1; %A value so that it enters the while loop below
    while ~isempty(user_input)
        
        str1='Enter time point you want to visualize (or just press enter to continue) \n';
        user_input=input(str1);
        if ~isempty(user_input)
            plot_together_4colors_func(user_input, [7 8 10], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)
        end
    end
    
    
end
%% SET 5. hand distance limits from red elbow

if first_time
    
    str1='5A. Input green_hand_dists_elbow \n';
    str2='Lower and upper limits of distances of the green hand markers to the red elbow marker\n';
    str3='Value is generally ~ [.15,.26] \n';    
    green_hand_dists_elbow=input([str1 str2 str3]);
    
    str1='5B. Input red_hand_dists_elbow \n';
    str2='Lower and upper limits of distances of the red hand markers to the red elbow marker\n';
    str3='Value is generally ~ [.17,.23] \n';    
    red_hand_dists_elbow=input([str1 str2 str3]);
    
    str1='5C. Input blue_hand_dists_elbow \n';
    str2='Lower and upper limits of distances of the blue hand markers to the red elbow marker\n';
    str3='Value is generally ~ [.17,.23] \n';    
    blue_hand_dists_elbow=input([str1 str2 str3]);

    str1='5D. Input yellow_hand_dists_elbow \n';
    str2='Lower and upper limits of distances of the yellow hand markers to the red elbow marker\n';
    str3='Value is generally ~ [.15,.21] \n';    
    yellow_hand_dists_elbow=input([str1 str2 str3]);
    
    str1='5E. Input green_separator \n';
    str2='Distance that separates the green hand points\n';
    str3='Value is generally ~ .2 \n';    
    green_separator=input([str1 str2 str3]);
    
end
%% Plot hand distances from blue arm
%Plots the distances of every hand marker to to blue arm marker in order
%to determine what distances are allowed (for rerunning the hand marker
%tracking)

%Note that using the distance from the hand to the blue arm marker only is helpful for a task with holding the handle 

if first_time
    
    %Calculate distances
    for i=1:n_times_prelim
        dists1(i)=pdist2(all_medians(7,:,i),all_medians(1,:,i)); %Distance from point 7 (blue arm) to point 1
        dists2(i)=pdist2(all_medians(7,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(7,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(7,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(7,:,i),all_medians(5,:,i));
    end
    
    %Plot
    figure; %Yellow
    plot(dists4,'y-x');
    figure; %Blue
    plot(dists2,'b-x');
    figure; %Red
    plot(dists3,'r-x');
    figure; %Green
    plot(dists1,'g-x');
    hold on;
    plot(dists5,'c-x');
    
end
%% SET 6. hand distance limits from blue arm

if first_time
    
    str1='6A. Input green_hand_dists_bluearm \n';
    str2='Lower and upper limits of distances of the green hand markers (green and cyan above) to the blue arm marker\n';
    str3='Value is generally ~ [.15,.30] \n';    
    green_hand_dists_bluearm=input([str1 str2 str3]);
    
    str1='6B. Input red_hand_dists_bluearm \n';
    str2='Lower and upper limits of distances of the red hand markers (red above) to the blue arm marker\n';
    str3='Value is generally ~ [.16,.28] \n';    
    red_hand_dists_bluearm=input([str1 str2 str3]);

    str1='6C. Input blue_hand_dists_bluearm \n';
    str2='Lower and upper limits of distances of the blue hand markers (blue above) to the blue arm marker\n';
    str3='Value is generally ~ [.16,.28] \n';    
    blue_hand_dists_bluearm=input([str1 str2 str3]);
    
    str1='6D. Input yellow_hand_dists_bluearm \n';
    str2='Lower and upper limits of distances of the yellow hand markers (yellow above) to the blue arm marker\n';
    str3='Value is generally ~ [.14,.26] \n';    
    yellow_hand_dists_bluearm=input([str1 str2 str3]);
    
    
end
%% Plot hand distances from red arm
%Plots the distances of every hand marker to to red arm marker in order
%to determine what distances are allowed (for rerunning the hand marker
%tracking)

%Note that using the distance from the hand to the red arm marker only is helpful for a task with holding the handle 


if first_time
    %Calculate distances
    for i=1:n_times_prelim
        dists1(i)=pdist2(all_medians(8,:,i),all_medians(1,:,i)); %Distance from point 8 (red arm to point 1)
        dists2(i)=pdist2(all_medians(8,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(8,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(8,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(8,:,i),all_medians(5,:,i));
    end
    %Plot
    figure; %Yellow
    plot(dists4,'y-x');
    figure; %Blue
    plot(dists2,'b-x');
    figure; %Red
    plot(dists3,'r-x');
    figure; %Green
    plot(dists1,'g-x');
    hold on;
    plot(dists5,'c-x');
    
end
%% SET 7. hand distance limits from red arm

if first_time
    
    str1='7A. Input green_hand_dists_redarm \n';
    str2='Lower and upper limits of distances of the green hand markers (green and cyan above) to the red arm marker\n';
    str3='Value is generally ~ [.15,.35] \n';    
    green_hand_dists_redarm=input([str1 str2 str3]);
    
    str1='7B. Input red_hand_dists_redarm \n';
    str2='Lower and upper limits of distances of the red hand markers (red above) to the red arm marker\n';
    str3='Value is generally ~ [.15,.34] \n';    
    red_hand_dists_redarm=input([str1 str2 str3]);
    
    str1='7C. Input blue_hand_dists_redarm \n';
    str2='Lower and upper limits of distances of the blue hand markers (blue above) to the red arm marker\n';
    str3='Value is generally ~ [.18,.35] \n';    
    blue_hand_dists_redarm=input([str1 str2 str3]);
    
    str1='7D. Input yellow_hand_dists_redarm \n';
    str2='Lower and upper limits of distances of the yellow hand markers (yellow above) to the red arm marker\n';
    str3='Value is generally ~ [.15,.34] \n';    
    yellow_hand_dists_redarm=input([str1 str2 str3]);    
    
end
%% Plot hand distances from each other
%Plots the distances of the red hand markers to each other and the green
%hand markers to each other, in order to determine what distances are
%allowed (for rerunning the hand marker tracking)

if first_time
    %Calculate distances
    for i=1:n_times_prelim
        dists1(i)=pdist2(all_medians(5,:,i),all_medians(1,:,i)); %Distances between green hand markers
    end
    %Plot
    figure; plot(dists1,'g');
    title('Plot between green markers');
end
%% SET 8. minimum hand distances from each other

if first_time

    str1='8. Input green_dist_min \n';
    str2='Minimum distance allowed between green hand markers (green above)\n';
    str3='Value is generally ~ .03 \n';    
    green_dist_min=input([str1 str2 str3]);
    
end

%% Green Hand (Redo)

%Initializations
plot_on=0;
marker_ids=green_hand_marker_ids;
color=color2;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids); %Number of clusters
within_clust_dist1=.07;%How close points must be to the previous frame's first marker, # marker_ids(1), to be considered
within_clust_dist2=.07; %How close points must be to the previous frame's second marker, # marker_ids(2), to be considered
dist_min=green_dist_min; %Minimum distance between markers (cluster medians aren't allowed w/ distance < min_dist)

medians=NaN(num_clust,3,n_times); %Has NaNs when a marker is missing
medians2=NaN(num_clust,3,n_times); %Has previous known positions when a marker is missing

num_gone1=0;%The number of frames the first marker has been gone
num_gone2=0; %The number of frames the second marker has been gone

% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)
    %Get distances of all points to the marker in the previous frame
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;
    else
        D=pdist2(loc,medians2(:,:,t-1));
    end
    
    % Keep all the points close enough to either of the previous markers
    keep1=D(:,1)<within_clust_dist1;
    keep2=D(:,2)<within_clust_dist2;
    
    %Remove points that are too close or far from the red elbow marker
    D2=pdist2(loc,all_medians(10,:,t));
    rmv0=D2<green_hand_dists_elbow(1) | D2>green_hand_dists_elbow(2);
    
    %Remove points that are too close or far from the blue arm marker
    D3=pdist2(loc,all_medians(7,:,t));
    rmv1=D3<green_hand_dists_bluearm(1) | D3>green_hand_dists_bluearm(2);

    %Remove points that are too close or far from the red arm marker    
    D4=pdist2(loc,all_medians(8,:,t));
    rmv2=D4<green_hand_dists_redarm(1) | D4>green_hand_dists_redarm(2);
    
    %Use above criteria to set points for removal
    %We will always remove points that are too close or far from the arm markers (rmv0, rmv1, rmv2).
    %Depending on how many frames the markers have been missing, we additionally use different criteria for removing.
    
    %If both markers have been missing for <=4 frames, keep points close
    %enough to the marker's locations in the previous frame
    if num_gone1<=4 & num_gone2<=4
        rmv=~(keep1 | keep2) | rmv0 | rmv1 | rmv2;
    %If the second marker has been missing for >4 frames, only keep points close
    %enough to the first marker's location in the previous frame
    else if num_gone1<=4 & num_gone2>4
            rmv=~(keep1) | rmv0 | rmv1 | rmv2;
    %If the first marker has been missing for >4 frames, only keep points close
    %enough to the second marker's location in the previous frame
        else if num_gone1>4 & num_gone2<=4
                rmv=~(keep2) | rmv0 | rmv1 | rmv2;
    %If both markers have been missing for >4 frames, don't keep any points
    %based on distance to the markers' locations in the previous frame
            else
                rmv=rmv0 | rmv1 | rmv2;
            end
        end
    end
    
    
    %Actually remove
    loc(rmv,:)=[];
        
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    %Update how many frames markers have been missing
    %If marker1 is missing, add 1 to num_gone1. Otherwise set num_gone1=0
    %(since it's been missing 0 frames)
    if isnan(medians(1,1,t))
        num_gone1=num_gone1+1;
    else
        num_gone1=0;
    end
    %If marker2 is missing, add 1 to num_gone2. Otherwise set num_gone2=0
    %(since it's been missing 0 frames)
    if isnan(medians(2,1,t))
        num_gone2=num_gone2+1;
    else
        num_gone2=0;
    end
    
    %If the red elbow marker is not missing, make sure the the first marker
    %(marker # 1) is farther from the red elbow marker than the second
    %marker (marker #5). If not, switch their assignment.
    %If the red elbow marker is missing, but the blue arm marker is not
    %missing, then do the same as above w/ the blue arm marker.
    if t>1
        %     if isnan(medians(1,1,t-1)) || isnan(medians(2,1,t-1))
        if ~isnan(all_medians(10,1,t))
            if pdist2(medians(1,:,t),all_medians(10,:,t))<pdist2(medians(2,:,t),all_medians(10,:,t))
                temp=medians(1,:,t);
                temp2=medians2(1,:,t);
                medians(1,:,t)=medians(2,:,t);
                medians(2,:,t)=temp;
                medians2(1,:,t)=medians2(2,:,t);
                medians2(2,:,t)=temp2;
            end
        else if ~isnan(all_medians(7,1,t))
                if pdist2(medians(1,:,t),all_medians(7,:,t))<pdist2(medians(2,:,t),all_medians(7,:,t))
                    temp=medians(1,:,t);
                    temp2=medians2(1,:,t);
                    medians(1,:,t)=medians(2,:,t);
                    medians(2,:,t)=temp;
                    medians2(1,:,t)=medians2(2,:,t);
                    medians2(2,:,t)=temp2;
                end
            end
        end
        %     end
        
        %If both markers were gone previous frame, and now there's one, assume
        %it's not the first marker (marker #1  by the fingers)
        if isnan(medians(1,1,t-1)) && isnan(medians(2,1,t-1))
            if ~isnan(medians(1,1,t)) && isnan(medians(2,1,t)) %If only the first marker shows up, then flip the assignment
                temp=medians(1,:,t);
                medians(1,:,t)=medians(2,:,t);
                medians(2,:,t)=temp;
            end
        end
        
        %If the markers are too far away from the markers in the prevoius
        %frame, remove them.
        %For the first marker
        if abs(pdist2(medians(1,:,t),medians(1,:,t-1)))>within_clust_dist1
            medians(1,:,t)=NaN;
            medians2(1,:,t)=medians2(1,:,t-1);
        end
        %For the second marker
        if abs(pdist2(medians(2,:,t),medians(2,:,t-1)))>within_clust_dist2
            medians(2,:,t)=NaN;
            medians2(2,:,t)=medians2(2,:,t-1);
        end
        
        
        %If there's only a single marker (one is missing this frame), 
        %determine its label based on the distance from the red elbow 
        
        %The distance from the second marker (marker #5) to the red elbow
        %should be less than "green_separator." If it's more, then
        %change the label of this marker to the first marker (marker #1).
        if isnan(medians(1,1,t)) && ~isnan(medians(2,1,t))
            if pdist2(medians(2,:,t),all_medians(10,:,t))>green_separator
                medians(1,:,t)=medians(2,:,t);
                medians(2,:,t)=NaN;
            end
        end
        %The distance from the first marker (marker #1) to the red elbow
        %should be greater than "green_separator." If it's less, then
        %change the label of this marker to the second marker (marker #5).
        if ~isnan(medians(1,1,t)) && isnan(medians(2,1,t))
            if pdist2(medians(1,:,t),all_medians(10,:,t))<green_separator
                medians(2,:,t)=medians(1,:,t);
                medians(1,:,t)=NaN;
            end
        end
        
        
    end
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;

%% Blue Hand (Redo)

%Initializations
plot_on=0;
marker_ids=blue_hand_marker_ids;
color=color1;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids); 
within_clust_dist1=.07;
dist_min=0.07; 

medians=NaN(num_clust,3,n_times); 
medians2=NaN(num_clust,3,n_times); 

num_gone=0; %The number of frames the marker has been gone

% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)
    %Get distances of all points to the marker in the previous frame
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;
    else
        D=pdist2(loc,medians2(:,:,t-1));
    end
    
    % Keep all the points close enough to the previous marker
    keep1=D(:,1)<within_clust_dist1;
    
    %Remove points that are too close or far from the red elbow marker
    D2=pdist2(loc,all_medians(10,:,t));
    rmv0=D2<blue_hand_dists_elbow(1) | D2>blue_hand_dists_elbow(2);
    
    %Remove points that are too close or far from the blue arm marker
    D3=pdist2(loc,all_medians(7,:,t));
    rmv1=D3<blue_hand_dists_bluearm(1) | D3>blue_hand_dists_bluearm(2);
    
    %Remove points that are too close or far from the red arm marker
    D4=pdist2(loc,all_medians(8,:,t));
    rmv2=D4<blue_hand_dists_redarm(1) | D4>blue_hand_dists_redarm(2);
    
    %Use above criteria to set points for removal
    %We will always remove points that are too close or far from the arm markers (rmv0, rmv1, rmv2).    
    %If the marker has been missing for <=4 frames, keep points close
    %enough to the marker's location in the previous frame
    if num_gone<=4
        rmv=~(keep1)| rmv0 | rmv1 | rmv2;
    else
    %If the marker has been missing for >4 frames, don't keep any points
    %based on distance to the marker's location in the previous frame
        rmv=rmv0 | rmv1 | rmv2;
    end
    
    %Actually remove
    loc(rmv,:)=[];
    
    
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    
    %Update how many frames markers have been missing
    %If the marker is missing, add 1 to num_gone. Otherwise set num_gone=0
    %(since it's been missing 0 frames)
    if isnan(medians(1,1,t))
        num_gone=num_gone+1;
    else
        num_gone=0;
    end    
    
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;

%% Red Hand (Redo)

%Initializations
plot_on=0;
marker_ids=red_hand_marker_ids;
color=color3;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids); 
within_clust_dist1=.07;
dist_min=0.07; 

medians=NaN(num_clust,3,n_times); 
medians2=NaN(num_clust,3,n_times); 

num_gone=0; %The number of frames the marker has been gone

% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)
    %Get distances of all points to the marker in the previous frame
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;
    else
        D=pdist2(loc,medians2(:,:,t-1));
    end
    
    % Keep all the points close enough to the previous marker
    keep1=D(:,1)<within_clust_dist1;
    
    %Remove points that are too close or far from the red elbow marker
    D2=pdist2(loc,all_medians(10,:,t));
    rmv0=D2<red_hand_dists_elbow(1) | D2>red_hand_dists_elbow(2);
    
    %Remove points that are too close or far from the blue arm marker
    D3=pdist2(loc,all_medians(7,:,t));
    rmv1=D3<red_hand_dists_bluearm(1) | D3>red_hand_dists_bluearm(2);
    
    %Remove points that are too close or far from the red arm marker
    D4=pdist2(loc,all_medians(8,:,t));
    rmv2=D4<red_hand_dists_redarm(1) | D4>red_hand_dists_redarm(2);
    
    %Use above criteria to set points for removal
    %We will always remove points that are too close or far from the arm markers (rmv0, rmv1, rmv2).    
    %If the marker has been missing for <=4 frames, keep points close
    %enough to the marker's location in the previous frame
    if num_gone<=4
        rmv=~(keep1)| rmv0 | rmv1 | rmv2;
    else
    %If the marker has been missing for >4 frames, don't keep any points
    %based on distance to the marker's location in the previous frame
        rmv=rmv0 | rmv1 | rmv2;
    end
    
    %Actually remove
    loc(rmv,:)=[];
    
    
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    
    %Update how many frames markers have been missing
    %If the marker is missing, add 1 to num_gone. Otherwise set num_gone=0
    %(since it's been missing 0 frames)
    if isnan(medians(1,1,t))
        num_gone=num_gone+1;
    else
        num_gone=0;
    end   
    
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;


%% HAND MARKERS CORRECTIONS (REMOVING/SWITCHING) BELOW


%% Calculate/Plot hand distances from elbow

%Initialize some vectors that I use later for calculating the distance
%between points
dists1=NaN(1,n_times);
dists2=NaN(1,n_times);
dists3=NaN(1,n_times);
dists4=NaN(1,n_times);
dists5=NaN(1,n_times);

%Calculate distances from red elbow to points on the hand
for i=1:n_times
    dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i));
    dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i));
    dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
    dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
    dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));    
end

%Plot
% figure;
% plot(dists1,'g-x');
% hold on;
% plot(dists2,'b-x');
% plot(dists3,'r-x');
% plot(dists4,'m-x');
% plot(dists5,'c-x');


%% SET 13. Determine green hand points to remove (based on having similar distance from elbow)

%Find times when marker 1 and marker 5 are a similar distance to the elbow
%marker (which is a problem)
idxs=find(abs(dists1-dists5)<.01);

%Plot those times
for i=1:length(idxs)

    plot_together_4colors_func(idxs(i), [1 5], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)        
    title(num2str(idxs(i)));
    
    %Points to Remove
    str1='Pt 5 is a similar distance from elbow as Pt 1 \n';
    str2='Type in the points to remove \n';
    str3='e.g. 1, or [1,2] - Note that enter removes no points \n';
    rmv=input([str1 str2 str3]);
    for j=1:length(rmv)
        all_medians(rmv(j),:,idxs(i))=NaN;
    end
    
    %Points to Switch
    str2='Type in the points to switch \n';
    str3='e.g. [3,4], or [3,4; 5,6] - Note that enter switches no points \n';
    switches=input([str2 str3]);
    for j=1:size(switches,1)
        switch_pts(switches(j,:),idxs(i),all_medians,all_medians2);
    end
end

%% Recalculate distances from red elbow to points on the hand (due to above changes)

if ~isempty(idxs) %Only redo if there was a change above
    for i=1:n_times
        dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i));
        dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));
    end
end

%% SET 9. Determine red hand point 3 to remove (based on having a larger distance to the elbow than point 1)

%Find times (idxs) where the distance from the elbow to point 3 are
%greater than the distance from the elbow to point 1 (which shouldn't
%happen)
idxs=find(dists3>dists1); 

%Plot those times
for i=1:length(idxs)

    plot_together_4colors_func(idxs(i), [1 3 5], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)        
    title(num2str(idxs(i)));
    
    %Points to Remove
    str1='Pt 3 is farther from elbow than Pt 1 \n';
    str2='Type in the points to remove \n';
    str3='e.g. 1, or [1,2] - Note that enter removes no points \n';
    rmv=input([str1 str2 str3]);
    for j=1:length(rmv)
        all_medians(rmv(j),:,idxs(i))=NaN;
    end
    
    %Points to Switch
    str2='Type in the points to switch \n';
    str3='e.g. [3,4], or [3,4; 5,6] - Note that enter switches no points \n';
    switches=input([str2 str3]);
    for j=1:size(switches,1)
        switch_pts(switches(j,:),idxs(i),all_medians,all_medians2);
    end
end



%% Recalculate distances from red elbow to points on the hand (due to above changes)

if ~isempty(idxs) %Only redo if there was a change above
    for i=1:n_times
        dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i));
        dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));
    end
end

%% SET 10. Determine blue hand point 2 to remove (based on having a larger distance to the elbow than point 1)

%Find times (idxs) where the distance from the elbow to point 2 are
%greater than the distance from the elbow to point 1 (which shouldn't
%happen)
idxs=find(dists2>dists1);

%Plot those times
for i=1:length(idxs)

    plot_together_4colors_func(idxs(i), [1 2 5], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)        
    title(num2str(idxs(i)));
    
    %Points to Remove
    str1='Pt 2 is farther from elbow than Pt 1 \n';
    str2='Type in the points to remove \n';
    str3='e.g. 1, or [1,2] - Note that enter removes no points \n';
    rmv=input([str1 str2 str3]);
    for j=1:length(rmv)
        all_medians(rmv(j),:,idxs(i))=NaN;
    end
    
    %Points to Switch
    str2='Type in the points to switch \n';
    str3='e.g. [3,4], or [3,4; 5,6] - Note that enter switches no points \n';
    switches=input([str2 str3]);
    for j=1:size(switches,1)
        switch_pts(switches(j,:),idxs(i),all_medians,all_medians2);
    end
end



%% Recalculate distances from red elbow to points on the hand (due to above changes)

if ~isempty(idxs) %Only redo if there was a change above
    for i=1:n_times
        dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i));
        dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));
    end
end


%% SET 15. Check whether elbow-5 distance is greater than elbow-3 distance
%Which it shouldn't be

%Find times when marker 5 has a greater distance to the elbow
%than marker 3 (which is a problem)
idxs=find(dists5>dists3);

%Plot those times
for i=1:length(idxs)

    plot_together_4colors_func(idxs(i), [1 3 5], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)        
    title(num2str(idxs(i)));
    
    %Points to Remove
    str1='Pt 5 is farther from elbow than Pt 3 \n';
    str2='Type in the points to remove \n';
    str3='e.g. 1, or [1,2] - Note that enter removes no points \n';
    rmv=input([str1 str2 str3]);
    for j=1:length(rmv)
        all_medians(rmv(j),:,idxs(i))=NaN;
    end
    
    %Points to Switch
    str2='Type in the points to switch \n';
    str3='e.g. [3,4], or [3,4; 5,6] - Note that enter switches no points \n';
    switches=input([str2 str3]);
    for j=1:size(switches,1)
        switch_pts(switches(j,:),idxs(i),all_medians,all_medians2);
    end
end

%% Recalculate distances from red elbow to points on the hand (due to above changes)

if ~isempty(idxs) %Only redo if there was a change above
    for i=1:n_times
        dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i));
        dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));
    end
end


%% SET 15. Check whether elbow-5 distance is greater than elbow-2 distance
%Which it shouldn't be

%Find times when marker 5 has a greater distance to the elbow
%than marker 3 (which is a problem)
idxs=find(dists5>dists2);

%Plot those times
for i=1:length(idxs)

    plot_together_4colors_func(idxs(i), [2 5], [1:10], all_medians, color1, color2, color3, color4, start, finish, 1)        
    title(num2str(idxs(i)));
    
    %Points to Remove
    str1='Pt 5 is farther from elbow than Pt 2 \n';
    str2='Type in the points to remove \n';
    str3='e.g. 1, or [1,2] - Note that enter removes no points \n';
    rmv=input([str1 str2 str3]);
    for j=1:length(rmv)
        all_medians(rmv(j),:,idxs(i))=NaN;
    end
    
    %Points to Switch
    str2='Type in the points to switch \n';
    str3='e.g. [3,4], or [3,4; 5,6] - Note that enter switches no points \n';
    switches=input([str2 str3]);
    for j=1:size(switches,1)
        switch_pts(switches(j,:),idxs(i),all_medians,all_medians2);
    end
end

%% Recalculate distances from red elbow to points on the hand (due to above changes)

if ~isempty(idxs) %Only redo if there was a change above
    for i=1:n_times
        dists1(i)=pdist2(all_medians(10,:,i),all_medians(1,:,i));
        dists2(i)=pdist2(all_medians(10,:,i),all_medians(2,:,i));
        dists3(i)=pdist2(all_medians(10,:,i),all_medians(3,:,i));
        dists4(i)=pdist2(all_medians(10,:,i),all_medians(4,:,i));
        dists5(i)=pdist2(all_medians(10,:,i),all_medians(5,:,i));
    end
end

%% Yellow Hand (Redo)

%Initializations
plot_on=0;
marker_ids=yellow_hand_marker_ids;
color=color4;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids); 
within_clust_dist1=.07;
dist_min=0.07; 

medians=NaN(num_clust,3,n_times); 
medians2=NaN(num_clust,3,n_times); 

num_gone=0; %The number of frames the marker has been gone

% LOOP THROUGH TIME
t=0;
for i=start:finish
    
    t=t+1;
    
    %0. Get x,y,z positions
    temp=color{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    loc=[x; y; z]';
    
    %1. Filter some bad points (those that are really far away)
    %Get distances of all points to the marker in the previous frame
    if t==1
        D=pdist2(loc,prev_meds);
        prev_num_clust=num_clust;
    else
        D=pdist2(loc,medians2(:,:,t-1));
    end
    
    % Keep all the points close enough to the previous marker
    keep1=D(:,1)<within_clust_dist1;
    
    %Remove points that are too close or far from the red elbow marker
    D2=pdist2(loc,all_medians(10,:,t));
    rmv0=D2<yellow_hand_dists_elbow(1) | D2>yellow_hand_dists_elbow(2);
    
    %Remove points that are too close or far from the blue arm marker
    D3=pdist2(loc,all_medians(7,:,t));
    rmv1=D3<yellow_hand_dists_bluearm(1) | D3>yellow_hand_dists_bluearm(2);
    
    %Remove points that are too close or far from the red arm marker
    D4=pdist2(loc,all_medians(8,:,t));
    rmv2=D4<yellow_hand_dists_redarm(1) | D4>yellow_hand_dists_redarm(2);
    
    rmv3=D2>dists1(t); %Points are farther from elbow than marker1
    rmv4=D2>dists2(t); %Points are farther from elbow than marker2
    rmv5=D2>dists2(t); %Points are farther from elbow than marker3
    
    %Use above criteria to set points for removal
    %We will always remove points that are too close or far from the arm markers (rmv0, rmv1, rmv2).    
    %If the marker has been missing for <=4 frames, keep points close
    %enough to the marker's location in the previous frame
    if num_gone<=4
        rmv=~(keep1)| rmv0 | rmv1 | rmv2 |rmv3 |rmv4 |rmv5;
    else
    %If the marker has been missing for >4 frames, don't keep any points
    %based on distance to the marker's location in the previous frame
        rmv=rmv0 | rmv1 | rmv2;
    end
    
    %Actually remove
    loc(rmv,:)=[];
    
    
    %2. Cluster and assign
    [ prev_num_clust, prev_meds, medians, medians2  ] = cluster_func2(t, loc, num_clust, prev_num_clust, dist_min, prev_meds, medians, medians2 );
    
    
    %Update how many frames markers have been missing
    %If the marker is missing, add 1 to num_gone. Otherwise set num_gone=0
    %(since it's been missing 0 frames)
    if isnan(medians(1,1,t))
        num_gone=num_gone+1;
    else
        num_gone=0;
    end
    
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;



%% DO SOME ADDITIONAL HAND CORRECTIONS FOR TIMES WHEN THE ELBOW WASN'T THERE (SINCE ALL THE ABOVE WAS BASED ON DISTANCE TO THE RED ELBOW)


%% Remove marker 3 that is too far away from other hand markers - Automatic

%Calculate distance from marker 3 to other hand markers
for i=1:n_times
    dists4(i)=pdist2(all_medians(3,:,i),all_medians(4,:,i)); %Distance between marker 3 and marker 4...
    dists5(i)=pdist2(all_medians(3,:,i),all_medians(5,:,i));
    dists2(i)=pdist2(all_medians(3,:,i),all_medians(2,:,i));
end

%Plot
% if first_time   
%     figure;
%     hold on;
%     plot(dists4,'-x')
%     plot(dists5,'-x')
%     plot(dists2,'-x')
% end

%Determine frames when each of the distances is greater than expected
d2=dists2>nanmean(dists2)+.02;
d4=dists4>nanmean(dists4)+.02;
d5=dists5>nanmean(dists5)+.02;

%Remove when distance from all points is too large (including times when
%marker 2 is missing)
rmv3=(d4 & d5 & isnan(dists2)) | (d4 & d5 & d2);
all_medians(3,:,rmv3)=NaN;


%% Remove marker 2 that is too far away from other hand markers - Automatic

%Calculate distance from marker 2 to other hand markers
for i=1:n_times
    dists3(i)=pdist2(all_medians(2,:,i),all_medians(3,:,i)); %Distances from marker 2 to 3...
    dists4(i)=pdist2(all_medians(2,:,i),all_medians(4,:,i));
    dists5(i)=pdist2(all_medians(2,:,i),all_medians(5,:,i));
end

%Plot
% if first_time    
%     figure;
%     hold on;
%     plot(dists3,'-x')
%     plot(dists4,'-x')
%     plot(dists5,'-x')    
% end

%Determine frames when each of the distances is greater than expected
d3=dists3>nanmean(dists3)+.03;
d4=dists4>nanmean(dists4)+.03;
d5=dists5>nanmean(dists5)+.03;

%Remove when distance from all points is too large (including times when
%marker 3 is missing)
rmv2=(d4 & d5 & isnan(dists3)) | (d4 & d5 & d3);
all_medians(2,:,rmv2)=NaN;


%% Compare hand distances to shoulder (for times other markers are missing)

%Initialize some vectors that I use later for calculating the distance
%between points
dists1=NaN(1,n_times);
dists2=NaN(1,n_times);
dists3=NaN(1,n_times);
dists4=NaN(1,n_times);
dists5=NaN(1,n_times);

%Calculate the distances from marker 9 (green shoulder) to all the hand
%points. Note that all_medians2 is used for marker 9, since the marker will
%not move significantly across frames, and will allow us to have a value
%for every frame.
for i=1:n_times
    dists1(i)=pdist2(all_medians2(9,:,i),all_medians(1,:,i));
    dists2(i)=pdist2(all_medians2(9,:,i),all_medians(2,:,i));
    dists3(i)=pdist2(all_medians2(9,:,i),all_medians(3,:,i));
    dists4(i)=pdist2(all_medians2(9,:,i),all_medians(4,:,i));
    dists5(i)=pdist2(all_medians2(9,:,i),all_medians(5,:,i));
end

%Plot
if first_time
    figure; % Yellow
    plot(dists4,'y-x');
    figure; %Blue
    plot(dists2,'b-x');
    figure; %Red
    plot(dists3,'r-x');
    figure; %Green
    plot(dists1,'g-x');
    hold on;
    plot(dists5,'c-x');
end

%% SET 14. hand distance limits from the shoulder

if first_time
    
    str1='14A. Input green_keep \n';
    str2='Lower and upper limits of distances of the green hand markers (green and cyan above) to the green shoulder marker\n';
    str3='Value is generally ~ [.15,.45] \n';    
    green_keep=input([str1 str2 str3]);
    
    str1='14B. Input red_keep \n';
    str2='Lower and upper limits of distances of the red hand markers (red above) to the green shoulder marker\n';
    str3='Value is generally ~ [.15,.45] \n';    
    red_keep=input([str1 str2 str3]);
    
    str1='14C. Input blue_keep \n';
    str2='Lower and upper limits of distances of the blue hand markers (blue above) to the green shoulder marker\n';
    str3='Value is generally ~ [.15,.45] \n';    
    blue_keep=input([str1 str2 str3]);

    str1='14D. Input yellow_keep \n';
    str2='Lower and upper limits of distances of the yellow hand markers (yellow above) to the green shoulder marker\n';
    str3='Value is generally ~ [.15,.45] \n';    
    yellow_keep=input([str1 str2 str3]);
end
%% Remove hand points (because they're too close or far from shoulder)

rmv1=dists1<green_keep(1) | dists1>green_keep(2);
all_medians(1,:,rmv1)=NaN;
rmv2=dists2<blue_keep(1) | dists2>blue_keep(2);
all_medians(2,:,rmv2)=NaN;
rmv3=dists3<red_keep(1) | dists3>red_keep(2);
all_medians(3,:,rmv3)=NaN;
rmv4=dists4<yellow_keep(1) | dists4>yellow_keep(2);
all_medians(4,:,rmv4)=NaN;
rmv5=dists5<green_keep(1) | dists5>green_keep(2);
all_medians(5,:,rmv5)=NaN;







%% Update all_medians2 to deal with removals

%If the marker is present at a given time, set all_medians2=all_medians
%If the marker isn't present at a given time, set all_medians 2 as
%all_medians from the previous frame

for j=1:10 %Loop through markers
    for t=1:n_times %Loop through times
        if ~isnan(all_medians(j,1,t))
            all_medians2(j,:,t)=all_medians(j,:,t);
        else
            all_medians2(j,:,t)=all_medians2(j,:,t-1);
        end
    end
end

%% Make matrices line up correctly with start time

%Make the final matrices begin at time 1 instead of time "start."

temp=all_medians;
temp2=all_medians2;

all_medians=NaN(11,3,finish);
all_medians2=NaN(11,3,finish);

all_medians(:,:,start:finish)=temp;
all_medians2(:,:,start:finish)=temp2;


%% Get smoothed time points

all_medians_smooth=NaN(size(all_medians));
for i=1:10
    for j=1:3
        temp=reshape(all_medians(i,j,:),[1,size(all_medians,3)]);
        all_medians_smooth(i,j,:)=medfilt1nan(temp,5);
    end
end




%% save
savefile=1;
if savefile
    date2=['20' num2str(date(7:8)) num2str(date(1:2)) num2str(date(4:5))];
    fname_save=[main_dir monkey '/Color_Tracking/' date '/Markers/markers_' monkey '_' date2 '_' exp '_' num];
    save(fname_save,'all_medians','all_medians2','led_vals','times');
    
    if first_time
        fname_save_settings=[main_dir monkey '/Color_Tracking/' date '/Markers/settings_' monkey '_' date2];
        save(fname_save_settings,'red_elbow_dist_from_blue','red_blue_arm_dist_max',...
        'green_hand_dists_elbow','red_hand_dists_elbow','blue_hand_dists_elbow','yellow_hand_dists_elbow','green_separator',...
        'green_hand_dists_bluearm','red_hand_dists_bluearm','blue_hand_dists_bluearm','yellow_hand_dists_bluearm',...
        'green_hand_dists_redarm', 'red_hand_dists_redarm', 'blue_hand_dists_redarm','yellow_hand_dists_redarm',...
        'green_dist_min','red_keep','green_keep','blue_keep','marker_inits');     
    end
end