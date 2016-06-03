% let the user choose the file and then read it in
[filename,pathname] = uigetfile('*.csv');
fname = fullfile(pathname, filename);
raw_data = xlsread(fname);

%% preprocess the data
% find blocks of continuously marked frames and rotate them so they're in
% the treadmill frame of reference (XY is sagittal plane, Z is ML position
% on the treadmill, X is horizontal, Y is vertical)

[allx,ally,allz,allframes,blocked_data] = preprocess(raw_data,OPTS);

%%  this deals with the breaks between blocks, to make them visible in the plots below
c_allx = blocked2_cont(allx,allframes);
c_ally = blocked2_cont(ally,allframes);
c_allz = blocked2_cont(allz,allframes);
c_allframes = blocked2_cont(allframes,allframes);
 
[newx, newy, newz] = zero_2_point(c_allx,c_ally,c_allz,3);  % this normalizes everything relative to the hip - only optional

%%  you can take a look at the walking by animating it
animate_stick(allx,ally,allz,allframes);
%animate_stick(c_allx,c_ally,c_allz,1:max(c_allframes))  % use this line if you want to plot blanks when things aren't tracked

%% so from here we can find the saggital plane angles

% [dist,ang] = calc_point2point_dist_ang(ally,allx,allz,3,6);  % from the hip(3) to the toe(6)
% [hip,knee,ankle] = calc_joint_angles(ally,allx,allz,[1 2 3 4 5 6]);  

[c_dist,c_ang] = calc_point2point_dist_ang(c_allx,c_ally,c_allz,3,6);  % from the hip(3) to the toe(6)
[c_hip,c_knee,c_ankle] = calc_joint_angles(c_allx,c_ally,c_allz,[1 2 3 4 5 6]);  

%% now use a GUI to find teh divisions between steps

ts = mytimeseries;
ts.Data = c_ang - nanmean(c_ang);  % this is using the limb angle - could use other measures as well
ts.Time = 1:length(c_ang);
initialize_ts_gui(ts);

%%  when you're done identifying the times, the read them off of the GUI
 
ided_times = round(get_ided_times);

%% now process them (using the maxima within the windows selected)

onsets = get_cycle_onsets_from_ided_times(c_ang,ided_times,[OPTS.MIN_STEP_DUR OPTS.MAX_STEP_DUR]);

%%  you can take a look at these cycle definitions now and edit them if you like
% NB: the windows should each contain a full step

initialize_ts_gui(ts);
set_ided_times(onsets)
 
%% run this command if you want to use the edited onsets from your window
% (after editing the window of course)
%
onsets = round(get_ided_times); 

%% take a look at the identified cycles
ncycles = size(onsets,1);
for ii = 1:ncycles
     ind = onsets(ii,1):onsets(ii,2);
     animate_stick(c_allx(ind,:),c_ally(ind,:),c_allz(ind,:),c_allframes(ind));
     pause
end

%% or relative to the hip, to get rid of translation
ncycles = size(onsets,1);
for ii = 1:ncycles
     ind = onsets(ii,1):onsets(ii,2);
     animate_stick(newx(ind,:),newy(ind,:),newz(ind,:),c_allframes(ind));
     pause
end

%% now summarize all the relevant kinematic information for all the cycles
% the information is returned in the structure all_kinematics

[summary, all] = summarize_kinematics(onsets,c_allx,c_ally,c_allz,c_allframes,[1 2 3 4 5 6]);

NSAMP = 50;

n_all = normalize_structure(all,NSAMP);  % this command normalizes the data in the all structure
mn_all = average_structure(n_all);     % this averages the same information

