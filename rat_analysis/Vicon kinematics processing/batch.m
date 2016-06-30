%% constants to define the analysis
clear

% ROOT = '5-14-13';
ROOT = 'mouse326_';

% rat1 12 and 14 speeds
FILE_LIST = {'04' '07' '10' '13' '16'};
FILE_LIST = {'05' '08' '11' '14' '17'};

% rat2 12 and 14 speeds
FILE_LIST = {'20' '23' '26'};
FILE_LIST = {'21' '24' '27'};
 
FILE_LIST = {'01'};

% %PATTERN 1
% NMARKERS = 6;
% HIP = 1;
% PELVIS_TIP = 2;
% PELVIS_END = 3;
% KNEE = 4;
% ANKLE = 5;
% TOE = 6;
% FRAME_OFFSET = 7;
% FRAME_BACK = 8;
% FRAME_FRONT = 9;
% FRAME_MIDDLE = 10;

%PATTERN 2
NMARKERS = 6;
HIP = 5;
PELVIS_TIP = 6;
PELVIS_END = 7;
KNEE = 8;
ANKLE = 9;
TOE = 10;
FRAME_OFFSET = 1;
FRAME_BACK = 2;
FRAME_FRONT = 3;
FRAME_MIDDLE = 4;

ALL_FRAME = [FRAME_OFFSET FRAME_BACK FRAME_FRONT FRAME_MIDDLE];
ALL_LEG = [HIP PELVIS_TIP PELVIS_END KNEE ANKLE TOE];

MIN_DUR = 25;
MAX_DUR = 70;
 
for curr_file = 1:length(FILE_LIST)
    
    FILE = FILE_LIST{curr_file};
    disp(FILE)
    % load in the data and preprocess it
    raw_data = xlsread([ROOT FILE '.CSV']);
    [blocked_data, frames] = preprocess(raw_data);
    
    % rotate the markers so xy plane is sagittal
    % and allow the possibilitiy to go through and label the markers correctly
    nblocks = length(blocked_data);
    new_data = blocked_data;
    for blockn = 1:nblocks
        [x,y,z] = separate_points(blocked_data{blockn});
        [newx,newy,newz] = rotate_markers(x,y,z, ALL_FRAME, ALL_LEG);
        % [x2, y2,z2] = edit_markers(x,y,z);   % NB this is reversed for some of the animals - should be xyz or yzx
        temp = combine_points(newx,newy,newz,frames{blockn});
        new_data{blockn} = temp;
    end
    %  pull all the blocks together into single variables
    nblocks = length(new_data);
    allx = zeros(1,NMARKERS);
    ally = allx; allz = allx;  allframes = 0;
    for blockn = 1:nblocks
        [x,y,z] = separate_points(new_data{blockn}(:,3:end));
        %     [newx, newy, newz] = zero_2_point(x,y,z,2);
        allx = [allx; x];
        ally = [ally; y];
        allz = [allz; z];
        allframes = [allframes; frames{blockn}];
    end
    allx = allx(2:end,:);
    ally = ally(2:end,:);
    allz = allz(2:end,:);
    allframes = allframes(2:end);
%     [dist,ang] = calc_point2point_dist_ang(ally,allx,allz,HIP,TOE);
%     ang = -ang;  % reverse the angle to avoid discontinuities

end

%%
    % find the onset indices
    thresh = 0.04;  % for 07
    % thresh = .1; % for 13
    
    ind = find(diff(ang) > thresh);  % this is looking for the fast step forward, for the initiation of the swing phase
    ind2 = find(diff(ind) > 5);    % find the gaps that are larger than 5 frames - these are borders between cycles
    onsets = ind(ind2+1);
    on_off = [onsets(1:(end-1)); onsets(2:end)]';
    % plot(allframes(1:end-1),diff(ang))
    % hold on
    temp = diff(ang);
    nsamples = diff(on_off');
    
    good_ind = find((nsamples < MAX_DUR) & (nsamples > MIN_DUR));
    % plot(allframes(onsets(good_ind)),temp(onsets(good_ind)),'g.')
    % hold off
    
    % pull out all cycles and collect the kinematics over each
    
    [newx, newy, newz] = zero_2_point(allx,ally,allz,HIP);
    [dist,ang] = calc_point2point_dist_ang(ally,allx,allz,HIP,TOE);
    nsamples = diff(on_off')+1;
    allang = NaN*zeros(length(on_off),max(nsamples));
    alldist = allang;  allnewx = allang; allnewy = allang; allnewz = allang;
    allknee = allang; allhip = allang; allankle = allang;
    for ii = 1:length(on_off)
        ind = on_off(ii,1):on_off(ii,2);
        if ((nsamples(ii) < MAX_DUR) & (nsamples(ii) > MIN_DUR))
            allang(ii,1:(nsamples(ii))) = ang(ind)';
            alldist(ii,1:(nsamples(ii))) = dist(ind);
            allnewx(ii,1:(nsamples(ii))) = newx(ind,TOE);
            allnewy(ii,1:(nsamples(ii))) = newy(ind,TOE);
            allnewz(ii,1:(nsamples(ii))) = newz(ind,TOE);

            v1 = [newx(ind,HIP) newy(ind,HIP)] - [newx(ind,KNEE) newy(ind,KNEE)];
            v2 = [newx(ind,ANKLE) newy(ind,ANKLE)] - [newx(ind,KNEE) newy(ind,KNEE)];
            allknee(ii,1:(nsamples(ii))) = find_angle(v1,v2);
            
            v1 = [newx(ind,KNEE) newy(ind,KNEE)] - [newx(ind,ANKLE) newy(ind,ANKLE)];
            v2 = [newx(ind,TOE) newy(ind,TOE)] - [newx(ind,ANKLE) newy(ind,ANKLE)];
            allankle(ii,1:(nsamples(ii))) = find_angle(v1,v2);
            
            v1 = [newx(ind,PELVIS_TIP) newy(ind,PELVIS_TIP)] - [newx(ind,HIP) newy(ind,HIP)];
            v2 = [newx(ind,KNEE) newy(ind,KNEE)] - [newx(ind,HIP) newy(ind,HIP)];
            allhip(ii,1:(nsamples(ii))) = find_angle(v1,v2);
            
        end
    end
    nsamples = diff(on_off');
    
    for ii = 1:length(on_off')
        limb_ang(ii,:) = [max(allang(ii,:)) min(allang(ii,:))];
        limb_length(ii,:) = [max(alldist(ii,:)) min(alldist(ii,:))];
        step_length(ii,:) = [max(allnewx(ii,:)) min(allnewx(ii,:))];
        step_height(ii,:) = [max(allnewy(ii,:)) min(allnewy(ii,:))];
        hip_angle(ii,:) = [max(allhip(ii,:)) min(allhip(ii,:))];
        knee_angle(ii,:) = [max(allknee(ii,:)) min(allknee(ii,:))];
        ankle_angle(ii,:) = [max(allankle(ii,:)) min(allankle(ii,:))];
    end
    
    results.limb_ang = limb_ang;
    results.limb_length = limb_length;
    results.length = step_length;
    results.height = step_height;
    results.hip = hip_angle;
    results.knee = knee_angle;
    results.ankle = ankle_angle;    
    results.onsets = onsets;
    results.file = FILE;
    all_results{curr_file} = results;
    
end


% cycles.allang = allang;
% cycles.alldist = alldist;
% cycles.allnewx = allnewx;
% cycles.allnewy = allnewy;
% cycles.allnewz = allnewz;
%
% kinematics.allx = allx;
% kinematics.ally = ally;
% kinematics.allz = allz;
% kinematics.newx = newx;
% kinematics.newy = newy;
% kinematics.newz = newz;

%% now dump the results into an excel spreadsheet
% clear
% str = ['file' mouse '_results'];
% load(str)
% ind = find(~isnan(results.limb_ang(:,1)));
% xlswrite('kinematic_results',results.limb_ang(ind,:),FILE,'A1')
% xlswrite('kinematic_results',results.limb_length(ind,:),FILE,'C1')
% xlswrite('kinematic_results',results.length(ind,:),FILE,'E1')
% xlswrite('kinematic_results',results.height(ind,:),FILE,'G1')

% str = ['new_post_' mouse '_results'];
% load(str)
% ind = find(~isnan(results.limb_ang(:,1)));
% xlswrite('kinematic_results',results.limb_ang(ind,:),mouse,'J1')
% xlswrite('kinematic_results',results.limb_length(ind,:),mouse,'L1')
% xlswrite('kinematic_results',results.length(ind,:),mouse,'N1')
% xlswrite('kinematic_results',results.height(ind,:),mouse,'P1')

%%
%
% [dist,ang] = calc_point2point_dist_ang(allx,ally,allz,2,5);
% dframe = diff(allframes(onsets));
% ind = find(dframe < 50);  %  flag the breaks due to different epochs
%
% [newx, newy, newz] = zero_2_point(allx,ally,allz,2);
%
% jj = 0;
% ncycles = length(onsets);
% for ii = 1:(ncycles-1)
%     if onsets(ii+1)-onsets(ii) < 100
%         jj = jj+1;
%         cycles_x{jj} = allx(onsets(ii):onsets(ii+1),:);
%         cycles_y{jj} = ally(onsets(ii):onsets(ii+1),:);
%         cycles_z{jj} = allz(onsets(ii):onsets(ii+1),:);
%         cycles_frames{jj} = allframes(onsets(ii):onsets(ii+1),:);
%         cycles_ang{jj} = ang(onsets(ii):onsets(ii+1));
%         cycles_dist{jj} = dist(onsets(ii):onsets(ii+1));
%         cycles_newx{jj} = newx(onsets(ii):onsets(ii+1),5);
%         cycles_newy{jj} = newy(onsets(ii):onsets(ii+1),5);
%         cycles_newz{jj} = newz(onsets(ii):onsets(ii+1),5);
%     end
% end
%
% ncycles = length(cycles_x);
% for ii = 1:ncycles
%     ang_summ(ii,:) = [max(cycles_ang{ii}) min(cycles_ang{ii}) range(cycles_ang{ii})];
%     dist_summ(ii,:) = [max(cycles_dist{ii}) min(cycles_dist{ii}) range(cycles_dist{ii})];
%     step_xdist_summ(ii,:) = [max(cycles_newx{ii}) min(cycles_newx{ii}) range(cycles_newx{ii})];
%     step_ydist_summ(ii,:) = [max(cycles_newy{ii}) min(cycles_newy{ii}) range(cycles_newy{ii})];
%     step_zdist_summ(ii,:) = [max(cycles_newz{ii}) min(cycles_newz{ii}) range(cycles_newz{ii})];
% end
%

%%
% scale = 4.7027;  % this is taken from the recalibration wand for the first, week1 data set
% blockn = 7;
% [x,y,z] = separate_points(post{blockn}(:,3:end));
% [newx, newy, newz] = zero_2_point(x/scale,y/scale,z/scale,2);
% % animate_stick(newx,newy,newz)

%%
% npoints = size(x,2);
% nframes = size(x,1);
% for kk = 1:nframes
%     p1 = [x2(kk,3) y2(kk,3) z2(kk,3)];
%     for ii = 1:npoints
%         p2 = [x2(kk,ii) y2(kk,ii) z2(kk,ii)];
%         dist(kk,ii) = sqrt(sum((p1-p2).^2));
%     end
% end

%%  reorder the results so they'll be a large matrix

% define the columns where the data will be stored
NCOL = 22;
FILE_N = 1;
LIMB_ANGLE_MAX = 2;
LIMB_ANGLE_MIN = 3;
LIMB_ANGLE_RANGE = 4;
LIMB_LENGTH_MAX = 5;
LIMB_LENGTH_MIN = 6;
LIMB_LENGTH_RANGE = 7; 
STEP_LENGTH_MAX = 8;
STEP_LENGTH_MIN = 9;
STEP_LENGTH_RANGE = 10; 
STEP_HEIGHT_MAX = 11;
STEP_HEIGHT_MIN = 12;
STEP_HEIGHT_RANGE = 13; 
HIP_MAX = 14;
HIP_MIN = 15;
HIP_RANGE = 16;
KNEE_MAX = 17;
KNEE_MIN = 18;
KNEE_RANGE = 19;
ANKLE_MAX = 20;
ANKLE_MIN = 21;
ANKLE_RANGE = 22;

all_results_mat = zeros(1,NCOL);  % initialize the results matrix
nn = 1;
for ii = 1:length(FILE_LIST)
    results = all_results{ii};
    
    ind = find(~isnan(results.limb_ang(:,1)));
    ncycles = length(ind);
    all_results_mat(nn:(nn+ncycles-1),FILE_N) = str2num(results.file);
    all_results_mat(nn:(nn+ncycles-1),LIMB_ANGLE_MAX) = results.limb_ang(ind,1);
    all_results_mat(nn:(nn+ncycles-1),LIMB_ANGLE_MIN) = results.limb_ang(ind,2);
    all_results_mat(nn:(nn+ncycles-1),LIMB_ANGLE_RANGE) = results.limb_ang(ind,1) - results.limb_ang(ind,2);

    all_results_mat(nn:(nn+ncycles-1),LIMB_LENGTH_MAX) = results.limb_length(ind,1);
    all_results_mat(nn:(nn+ncycles-1),LIMB_LENGTH_MIN) = results.limb_length(ind,2);
    all_results_mat(nn:(nn+ncycles-1),LIMB_LENGTH_RANGE) = results.limb_length(ind,1) - results.limb_length(ind,2);
    
    all_results_mat(nn:(nn+ncycles-1),STEP_LENGTH_MAX) = results.length(ind,1);
    all_results_mat(nn:(nn+ncycles-1),STEP_LENGTH_MIN) = results.length(ind,2);
    all_results_mat(nn:(nn+ncycles-1),STEP_LENGTH_RANGE) = results.length(ind,1) - results.length(ind,2);
    
    all_results_mat(nn:(nn+ncycles-1),STEP_HEIGHT_MAX) = results.height(ind,1);
    all_results_mat(nn:(nn+ncycles-1),STEP_HEIGHT_MIN) = results.height(ind,2);
    all_results_mat(nn:(nn+ncycles-1),STEP_HEIGHT_RANGE) = results.height(ind,1) - results.height(ind,2);
    
    all_results_mat(nn:(nn+ncycles-1),HIP_MAX) = results.hip(ind,1);
    all_results_mat(nn:(nn+ncycles-1),HIP_MIN) = results.hip(ind,2);
    all_results_mat(nn:(nn+ncycles-1),HIP_RANGE) = results.hip(ind,1) - results.hip(ind,2);
    
    all_results_mat(nn:(nn+ncycles-1),KNEE_MAX) = results.knee(ind,1);
    all_results_mat(nn:(nn+ncycles-1),KNEE_MIN) = results.knee(ind,2);
    all_results_mat(nn:(nn+ncycles-1),KNEE_RANGE) = results.knee(ind,1) - results.knee(ind,2);
    
    all_results_mat(nn:(nn+ncycles-1),ANKLE_MAX) = results.ankle(ind,1);
    all_results_mat(nn:(nn+ncycles-1),ANKLE_MIN) = results.ankle(ind,2);
    all_results_mat(nn:(nn+ncycles-1),ANKLE_RANGE) = results.ankle(ind,1) - results.ankle(ind,2);

    nn = nn+ncycles;
end

% xlswrite('results_rat2_14_matrix_wangles',all_results_mat);
 
