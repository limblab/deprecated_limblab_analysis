%% this batch file contains commands for exploring and analyzing the data

%% do the summary analysis of the data

% collect data from the cycles
[summary, all] = summarize_kinematics(onsets,c_allx,c_ally,c_allz,c_allframes,[1 2 3 4 5 6]);

% normalize all the cycles to be the same number of samples
NSAMP = 50;  % this is the number to have
n_all = normalize_structure(all,NSAMP);  % this command normalizes the data in the all structure
mn_all = average_structure(n_all);     % this averages the same information

% this normalizes the xyz marker positions and finds their averages
% it's basically the same as the above, but just allows the stick to be
% plotted so there are all positions included
[nx,ny,nz,mnx,mny,mnz] = normalize_marker_positions(onsets,newx,newy,newz,NSAMP);
[nx,ny,nz,mnx,mny,mnz] = normalize_marker_positions(onsets,c_allx,c_ally,c_allz,NSAMP);

%%  plot the animated stick figure for the mean trajectory
% you can comment the hold on/off statements as well

figure
hold on

% looking from the side (saggital plane)
animate_stick(mnx,mny,mnz,1:length(mnx))
plot([mnx(:,1) mnx(:,3)]',[mny(:,1) mny(:,3)]','bo-')
hold off

figure
hold on
% looking from the side (saggital plane)
animate_stick(mnx,mnz,mny,1:length(mnx))
plot([mnx(:,1) mnx(:,3)]',[mnz(:,1) mnz(:,3)]','bo-')
hold off


%% looking from underneath (horizontal plane)
% trajectory
inde = 1:30;
indf = 31:50;

figure
hold on
he = animate_stick(mnx(inde,:),mnz(inde,:),mny(inde,:),1:length(mnx));
hf = animate_stick(mnx(indf,:),mnz(indf,:),mny(indf,:),1:length(mnx));
hold off
set(hf,'Color',[1 0 0])

%% looking from behind (coronal)
% trajectory
figure
hold on
animate_stick(mnz,mny,mnx,1:length(mnx))
hold off

%% get rid of cycles based on data plot

plot(all.ankleang)  % plot all of the ankle angle trajectories

% the lines below allow you to identify the cycle number for each line by
% clicking on it
fig = gcf;
dcm_obj = datacursormode(fig);
set(dcm_obj,'UpdateFcn',@datacursor_callback);
datacursormode on


%% if you've identified some cycles that you don't want to plot...

figure
ncycles = size(all.ankle,2);
ind = setdiff(1:ncycles,41);  % skip the 41st cycle
plot(all.ankle(:,ind))

%% similar logic, but to eliminate according to cycle duration
ind = find(all.nsample < 45);  % this is the list of cycles excluding those longer than 45 frames
plot(all.ankleang(:,ind);  % only show cycles with the duration you want

%% so the code below is dedicated to reestimating the knee position
% the logic is that it assumes a fixed length for the femur and tibia -
% here based on the average distance between markers - then attempts to
% find a new knee position so that the estimated link lengths are
% relatively constant (within .1mm or so) and so that the new knee position
% is located within the plane spanned by the hip, ankle, and old knee
% position.  This is all currently being done using optimization, though it
% could be done analytically using Lagrangian multipliers.

%%  find the apparent lengths of each of the links

PELVIS_TIP = 1; PELVIS_BASE = 2; HIP = 3; KNEE = 4; ANKLE = 5; TOE = 6;
link1 = sqrt(diff(allx(:,[HIP KNEE])').^2 + diff(ally(:,[HIP KNEE])').^2 + diff(allz(:,[HIP KNEE])').^2); 
link2 = sqrt(diff(allx(:,[ANKLE KNEE])').^2 + diff(ally(:,[ANKLE KNEE])').^2 + diff(allz(:,[ANKLE KNEE])').^2); 
link3 = sqrt(diff(allx(:,[ANKLE TOE])').^2 + diff(ally(:,[ANKLE TOE])').^2 + diff(allz(:,[ANKLE TOE])').^2); 
pelvis = sqrt(diff(allx(:,[PELVIS_TIP PELVIS_BASE])').^2 + diff(ally(:,[PELVIS_TIP PELVIS_BASE])').^2 + diff(allz(:,[PELVIS_TIP PELVIS_BASE])').^2); 

mnlink1 = mean(link1);
mnlink2 = mean(link2);

%% recaluclate the knee, given the averaged link lengths observed across trials...
% this goes through all frames - takes some time

[rallx,rally,rallz] = recalculate_knee(allx,ally,allz,[mnlink1 mnlink2]);

%% now update all the kinematics
rc_allx = blocked2_cont(rallx,allframes);
rc_ally = blocked2_cont(rally,allframes);
rc_allz = blocked2_cont(rallz,allframes);
rc_allframes = blocked2_cont(allframes,allframes);

[rnewx, rnewy, rnewz] = zero_2_point(rc_allx,rc_ally,rc_allz,3);  % this normalizes everything relative to the hip - only optional

[rsummary, rall] = summarize_kinematics(onsets,rc_allx,rc_ally,rc_allz,rc_allframes,[1 2 3 4 5 6]);
rn_all = normalize_structure(rall,NSAMP);  % this command normalizes the data in the all structure
rmn_all = average_structure(rn_all);     % this averages the same information
[rnx,rny,rnz,rmnx,rmny,rmnz] = normalize_marker_positions(onsets,rnewx,newy,newz,NSAMP);

%%  plot the animated stick figure for the reestimated mean trajectory

figure
hold on
% looking from the side (saggital plane)
animate_stick(mnx,mny,mnz,1:length(mnx))
hold off

figure
hold on
% looking from the side (saggital plane)
animate_stick(rmnx,rmny,rmnz,1:length(mnx))
hold off

%% do the same thing for the view from the underneath

figure
hold on
animate_stick(mnx,mnz,mny,1:length(mnx))
hold off

figure
hold on
animate_stick(rmnx,rmnz,rmny,1:length(mnx))
hold off

%%
figure
hold on
animate_stick(mnz,mny,mnx,1:length(mnx))
hold off

figure
hold on
animate_stick(rmnz,rmny,rmnx,1:length(mnx))
hold off


%%  find the apparent lengths of each of the links

PELVIS_TIP = 1; PELVIS_BASE = 2; HIP = 3; KNEE = 4; ANKLE = 5; TOE = 6;
rlink1 = sqrt(diff(rallx(:,[HIP KNEE])').^2 + diff(rally(:,[HIP KNEE])').^2 + diff(rallz(:,[HIP KNEE])').^2); 
rlink2 = sqrt(diff(rallx(:,[ANKLE KNEE])').^2 + diff(rally(:,[ANKLE KNEE])').^2 + diff(rallz(:,[ANKLE KNEE])').^2); 
rlink3 = sqrt(diff(rallx(:,[ANKLE TOE])').^2 + diff(rally(:,[ANKLE TOE])').^2 + diff(rallz(:,[ANKLE TOE])').^2); 
rpelvis = sqrt(diff(rallx(:,[PELVIS_TIP PELVIS_BASE])').^2 + diff(rally(:,[PELVIS_TIP PELVIS_BASE])').^2 + diff(allz(:,[PELVIS_TIP PELVIS_BASE])').^2); 


%%  export the data to a Excel file

% sends the mean knee angle into excel file 'test' in sheet 'mean knee angle'
xlswrite('test',mn_all.kneeang,'mean knee angle')


