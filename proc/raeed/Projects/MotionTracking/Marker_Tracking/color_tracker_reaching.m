%Get arm positions (normally)
%Maybe I don't have to correct for the elbow??

%Get approximate distances to hand points from elbow
%--based on a few examples I type in

%Get hand markers based on these approximate distances (assignments will be wrong)

%Determine better hand marker distance metrics from elbow

%Get hand markers again
%--Only do it when we have the elbow markers
%--Start a segment when there are at least 3 markers
%--Stop the segment when there is 1 marker (or 0)
%--Do assignments like usual (but w/ extra blue marker)


%% Load ColorTracking File

main_dir='/Users/jig289/Box Sync/Tracking_Data/';


%File to load
monkey='Whistlepig';
date='11-24-15'; %mo-day-yr
exp='reach';
num='002';

fname_load=ls([main_dir monkey '/Color_Tracking/' date '/Tracking/color_tracking ' exp '_' num '*']);
load(deblank(fname_load));

% load(ls([main_dir monkey '/Color_Tracking/' date '/Tracking/color_tracking ' exp '_' num '*']))

%% Marker location reminder figure

marker_demo_locs=[0 0; 1 1; 1 -1; 2 1; 2 -1;...
    10 -1; 10 3; 10 6; 10 9; 9 0;...
    2 -3];
r=[1 0 0];
g=[0 1 0];
b=[0 1 1];
marker_demo_colors=[g; b; r; r; g; g; b; r; g; r; b];

figure; scatter(marker_demo_locs(:,1),marker_demo_locs(:,2),200,marker_demo_colors,'filled');
str={'1','2','3','4','5','6','7','8','9','10','11'};
text(marker_demo_locs(:,1),marker_demo_locs(:,2),str)
xlim([-5 15]);
ylim([-5 15]);

%% SET 0. Initializations


first_time=1; %If this is the first file from a date, set equal to 1 (there are more initializations)

%Load all of the settings if it's not the first file 
if ~first_time
    date2=['20' num2str(date(7:8)) num2str(date(1:2)) num2str(date(4:5))];
    fname_load_settings=[main_dir monkey '/Color_Tracking/' date '/Markers/settings_' monkey '_' date2];
    load(fname_load_settings);
end

%TIME INITIALIZATIONS
start=190; %Time point we're starting at
n=length(color1);
finish=1000;%n %Time point we're finishing at
n_times=finish-start+1; %Number of time points (frames)

%MARKER NUMBER INITIALIZATIONS
red_arm_marker_ids=[8,10];
blue_arm_marker_ids=[7];
green_shoulder_marker_ids=[9]; %Sometimes empty
green_elbow_marker_ids=[6];
red_hand_marker_ids=[3,4];
blue_hand_marker_ids=[2,11]; %Sometimes just 2, sometimes 2 and 11
green_hand_marker_ids=[1,5];

%MARKER LOCATION INITIALIZATIONS
marker_inits=NaN(11,3);
% marker_inits(1,:)=[.9,-.06,-.15];
% marker_inits(2,:)=[.9,-.04,-.15];
% marker_inits(3,:)=[.9,-.05,-.16];
% marker_inits(4,:)=[.9,-.03,-.14];
% marker_inits(5,:)=[.9,-.02,-.16];
marker_inits(6,:)=[.86,.08,-.05];
marker_inits(7,:)=[.88,.04,-.04];
marker_inits(8,:)=[.89,-.02,-.04];
marker_inits(9,:)=[.91,-.07,-.05];
marker_inits(10,:)=[.87,.08,-.04];

%I plot z,x,y (instead of x,y,z), so I input z,x,y above. Here, switch to x,y,z
marker_inits_temp=marker_inits;
marker_inits(:,1)=marker_inits_temp(:,2);
marker_inits(:,2)=marker_inits_temp(:,3);
marker_inits(:,3)=marker_inits_temp(:,1);

%Keeps track of all the cluster locations
all_medians=NaN(11,3,n_times); %Has NaNs when a marker is missing
all_medians2=NaN(11,3,n_times); %Estimates where markers are when they are missing

%Initialize some vectors that I use later for calculating the distance
%between points
dists=NaN(1,n_times);
dists1=NaN(1,n_times);
dists2=NaN(1,n_times);
dists3=NaN(1,n_times);
dists4=NaN(1,n_times);
dists5=NaN(1,n_times);

%% Plotting Initializations

fig=figure;
dcm_obj = datacursormode(fig);
set(gca,'NextPlot','replacechildren');
xlims=[-.5 .5];
ylims=[-.5 .5];
zlims=[0.5 1.5];

pause_time=.03;

%% Blue Arm

%Initializations
plot_on=1; %Whether to plot while it's running
marker_ids=blue_arm_marker_ids; %Set the marker_ids specified in "Initializations"
color=color1; %Blue=1, Green=2, Red=3
prev_meds=marker_inits(marker_ids,:); %Set initial "previous marker locations" as the start locations input in "Initializations"
num_clust=length(marker_ids); %Number of clusters
within_clust_dist1=0.08; %How close points must be to the previous frame's marker to be considered
dist_min=0.08; %Minimum distance between markers (cluster medians aren't allowed w/ distance < min_dist)

medians=NaN(num_clust,3,n_times); %Has NaNs when a marker is missing
medians2=NaN(num_clust,3,n_times); %Has previous known positions when a marker is missing

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
    
    %Remove points (those we're not keeping)
    rmv=~(keep1);
    
    %Actually remove the points
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
    if num_gone>2
    plot_colors=[1 0 0];
        temp=color1{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'b')
        hold on;
        temp=color2{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'g')
        temp=color3{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'r')
    scatter3(medians(:,1,t),medians(:,2,t),medians(:,3,t),200,plot_colors,'filled')
    hold off;
    xlim(xlims)
    ylim(ylims)
    zlim(zlims)
    title(i)
    pause(pause_time);
    
    
    k=waitforbuttonpress;
    if ~k
        f = getCursorInfo(dcm_obj);
        medians(1,:,t)=f.Position;
        medians2(1,:,t)=f.Position;
        prev_meds=f.Position;
        prev_num_clust=1;
        num_gone=0;
    end
    end
    
    
end

%Put the markers found here in the matrix of all markers
all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;


%% Green Shoulder

if ~isempty(green_shoulder_marker_ids) %Only do this if it is a file with a green shoulder marker
    %Initializations
    plot_on=1;
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
        if plot_on
        plot_colors=[1 0 0];
        temp=color1{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'b')
        hold on;
        temp=color2{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'g')
        temp=color3{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'r')
        scatter3(medians(:,1,t),medians(:,2,t),medians(:,3,t),200,plot_colors,'filled')
        hold off;
        xlim(xlims)
        ylim(ylims)
        zlim(zlims)
        title(i)
        pause(pause_time);
        end
    end
    
    all_medians(marker_ids,:,:)=medians;
    all_medians2(marker_ids,:,:)=medians2;
end


%% Red Arm

if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Initializations
    plot_on=1;
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
%% Plot Red elbow to Blue Arm Distance

if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Calculate distances for each time point
    for i=1:n_times
        dists(i)=pdist2(all_medians(10,:,i),all_medians(7,:,i)); %Distance between markers 7 and 10 (blue arm and red elbow)
        dists2(i)=pdist2(all_medians(8,:,i),all_medians(7,:,i)); %Distance between markers 7 and 9 (blue arm and red arm)
    end
    
    %Plot
    figure; plot(dists); 
    hold on;
    plot(dists2)
    legend('7-10','7-9')
end
%% SET 1: Red Elbow/Arm to Blue Arm Distance

if first_time
    
    str1='1A. Input red_elbow_dist_from_blue \n';
    str2='The blue values in the above plot should be below this value (the red elbow should always be within this distance of the blue arm)\n';
    str3='Value is generally ~ .05 \n';    
    red_elbow_dist_from_blue=input([str1 str2 str3]);
    
    str1='1B. Input red_blue_arm_dist_max \n';
    str2='%All values in above plot should be below this value (Maximum distance from a red arm point to the blue)\n';
    str3='Value is generally ~ .08 \n';   
    red_blue_arm_dist_max=input([str1 str2 str3]);
        
end


%% Plot Red elbow/arm to Green Shoulder Distance

if first_time %If this is not the first file from a date, we don't need to run this.
    
    %Calculate distances for each time point
    for i=1:n_times
        dists(i)=pdist2(all_medians(10,:,i),all_medians2(9,:,i)); %Distance between markers 9 and 10 (green arm and red elbow)
        dists2(i)=pdist2(all_medians(8,:,i),all_medians2(9,:,i)); %Distance between markers 9 and 8 (green arm and red arm)
    end
    
    %Plot
    figure; plot(dists); 
    hold on;
    plot(dists2)
    legend('9-10','9-8')
end
%% Set threshold of red arm points from green shoulder

red_green_thresh=.11;

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
    
    %Correct assignments
    
    %If one missing
    if (isnan(medians(1,1,t)) && ~isnan(medians(2,1,t)))
        if pdist2(medians(2,:,t),all_medians2(9,:,t))<red_green_thresh
            temp=medians(1,:,t);
            temp2=medians2(1,:,t);
            medians(1,:,t)=medians(2,:,t);
            medians(2,:,t)=temp;
            medians2(1,:,t)=medians2(2,:,t);
            medians2(2,:,t)=temp2;
        end
    end
    if (~isnan(medians(1,1,t)) && isnan(medians(2,1,t)))
        if pdist2(medians(1,:,t),all_medians2(9,:,t))>red_green_thresh
            temp=medians(1,:,t);
            temp2=medians2(1,:,t);
            medians(1,:,t)=medians(2,:,t);
            medians(2,:,t)=temp;
            medians2(1,:,t)=medians2(2,:,t);
            medians2(2,:,t)=temp2;
        end
    end
    
    %If both there
    if pdist2(medians(1,:,t),all_medians2(9,:,t))>pdist2(medians(2,:,t),all_medians2(9,:,t))
        temp=medians(1,:,t);
        temp2=medians2(1,:,t);
        medians(1,:,t)=medians(2,:,t);
        medians(2,:,t)=temp;
        medians2(1,:,t)=medians2(2,:,t);
        medians2(2,:,t)=temp2;
    end
    
    
%     if ~isnan(all_medians(9,1,t))
%             if pdist2(medians(1,:,t),all_medians(9,:,t))<pdist2(medians(2,:,t),all_medians(9,:,t))
%                 temp=medians(1,:,t);
%                 temp2=medians2(1,:,t);
%                 medians(1,:,t)=medians(2,:,t);
%                 medians(2,:,t)=temp;
%                 medians2(1,:,t)=medians2(2,:,t);
%                 medians2(2,:,t)=temp2;
%             end
%     else if ~isnan(all_medians(7,1,t))
%             if pdist2(medians(1,:,t),all_medians(7,:,t))>pdist2(medians(2,:,t),all_medians(7,:,t))
%                 temp=medians(1,:,t);
%                 temp2=medians2(1,:,t);
%                 medians(1,:,t)=medians(2,:,t);
%                 medians(2,:,t)=temp;
%                 medians2(1,:,t)=medians2(2,:,t);
%                 medians2(2,:,t)=temp2;
%             end
%         end
%     end
    
    
    %3. Plot original image and cluster centers
    plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;



%% REMOVE RED ARM POINTS

%% Plot distances from red arm points to blue arm (and each other)

for i=1:n_times
    dists(i)=pdist2(all_medians(10,:,i),all_medians(7,:,i)); %Distance between markers 7 and 10 (blue arm and red elbow)
    dists2(i)=pdist2(all_medians(10,:,i),all_medians(8,:,i)); %Distance between markers 8 and 10 (red arm and red elbow)
    dists3(i)=pdist2(all_medians(8,:,i),all_medians(7,:,i)); %Distance between markers 7 and 8 (blue arm and red arm)
end


if first_time %If this is not the first file from a date, we don't need to plot this.
    
    figure; plot(dists); 
    hold on;
    plot(dists2)
    plot(dists3)
    legend('7-10','8-10','7-8')
    
end


%% Plot red elbow angle relative to arm (based on angle)

%This calculates (and plots) the angle made by points 7,8,10
%Problems with the red elbow marker (point 10) will make this angle wrong

%Note- look back at version 10 for code that has to do with distance from
%the line, instead of the angle

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
if first_time   
    figure; plot(angle)   
end
%% SET 3. red elbow points to remove (based on angle)

% red_elbow_angle_thresh=2.55;
red_elbow_angle_thresh=nanmean(angle)-4*nanstd(angle); %Frames with an angle below this will have marker 10 removed
%% Remove red elbow points (based on angle)

rmv10=angle<red_elbow_angle_thresh;
all_medians(10,:,rmv10)=NaN;

%% Green Elbow

%Initializations
plot_on=1;
marker_ids=green_elbow_marker_ids;
color=color2;
prev_meds=marker_inits(marker_ids,:);
num_clust=length(marker_ids);
within_clust_dist1=.12;
dist_min=0.1;

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
%     plot_clusts( plot_on, num_clust, x, y, z, medians, i, t, pause_time, xlims, ylims, zlims )
    if plot_on
        plot_colors=[0.5 0.5 0];
        temp=color1{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'b')
        hold on;
        temp=color2{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'g')
        temp=color3{i};
        x=temp(1:end/3);
        y=temp(end/3+1:2*end/3);
        z=temp(2*end/3+1:end);
        scatter3(x,y,z,'r')
        scatter3(medians(:,1,t),medians(:,2,t),medians(:,3,t),200,plot_colors,'filled')
        hold off;
        xlim(xlims)
        ylim(ylims)
        zlim(zlims)
        title(i)
        pause(pause_time);
        end
    
end

all_medians(marker_ids,:,:)=medians;
all_medians2(marker_ids,:,:)=medians2;

%% Plot green elbow angle relative to arm (based on angle)

%This calculates (and plots) the angle made by points 7,8,6
%Problems with the green elbow marker (point 6) will make this angle wrong

%Note- look back at version 10 for code that has to do with distance from
%the line, instead of the angle


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
if first_time   
    figure; plot(angle)   
end
%% SET 4. green elbow points to remove (based on angle)

% green_elbow_angle_thresh=2.55;
green_elbow_angle_thresh=nanmean(angle)-3*nanstd(angle); %Frames with an angle below this will have marker 6 removed
%% Remove green elbow points

rmv6=angle<green_elbow_angle_thresh;
all_medians(6,:,rmv6)=NaN;

%Note that in version 10 and previous, there were other attempted methods
%for removing green elbow problems (based on distance to the other arm
%points)






%%

for i=1:n_times
    dists(i)=pdist2(all_medians(7,:,i),marker_inits(9,:)); %Distance between markers 7 and 10 (blue arm and red elbow)
end


    
    figure; plot(dists); 
    








%%

fig=figure;
dcm_obj = datacursormode(fig);
for i=1:5
scatter3(rand(1,10),rand(1,10),rand(1,10));
k=waitforbuttonpress;
if ~k
f = getCursorInfo(dcm_obj);
f.Position
end
end
% for i=start:5000
%     figure;
%     h=scatter3(rand(1,10),rand(1,10),rand(1,10));
%     points=get(h,'Children');
% %     pos=get(gca,'CurrentPoint');
% 
% % end
% %%
% 
% 
% h=scatter(x,y,S,C); points=get(h,'Children');
% for i=1:numel(children)
% set(points(i),'HitTest','on','ButtonDownFcn',{'myFunction',i});
% end