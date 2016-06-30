function feat = compFeat_Kinematic(Left_FO, Left_FS, hip, knee, ankle, MTP, varargin)

%%% IMPORTANT! THE GAIT EVENTS MUST BE CONSECUTIVE!!!


% %%%%%%%%%%%%%%%%%%% Kinematics data %%%%%%%%%%%%%%%%%%%
% % Low pass filtered - 4th orther Butterworth
% LP = 20;
% fNorm = LP/(sampling_frequency/2);
% [b,a] = butter(4, fNorm, 'low');
% 
% [n_rows, n_columns] = size(Kinematics);
% 
% for i = 1:n_columns % number of variables
%     Filtered_Kinematics(1:n_rows, i) = filtfilt(b, a, Kinematics(1:n_rows, i));
% end
% 
% Kinematics = Filtered_Kinematics;


%% Hip %%

% Peak of hip flexion
% Peak of hip extension
% Range of hip flexion
% Pre-swing hip angle
% Peak of hip abduction in swing
% Range of hip abduction
% Mean hip rotation in stance (ROM)
for i=1:length(Left_FS)-1
    
    peak_flexion_hip(i)   = max(hip(Left_FS(i):Left_FS(i+1)));
    peak_extension_hip(i) = min(hip(Left_FS(i):Left_FS(i+1)));
    range_flexion_hip(i)  = peak_flexion_hip(i) - peak_extension_hip(i);
    
%     range_abduction_hip_Left(i) = max(angle_hip_interpolated(Left_FS(i):Left_FS(i+1),2) - min(angle_hip_interpolated(Left_FS(i):Left_FS(i+1),2)));
    
%     % First Left FO after the ith Left FS
%     ind_Left_FO = find(Left_FO>Left_FS(i));
%     % First Right FS after the ith Left FS
%     ind_Right_FS = find(Right_FS>Left_FS(i));
%     pre_swing_angle_hip(i) = min(angle_hip_interpolated(Right_FS(ind_Right_FS(1)):Left_FO(ind_Left_FO(1))));
%     peak_abduction_swing_hip_Left(i) = max(angle_hip_interpolated(Left_FO(ind_Left_FO(1)):Left_FS(i+1),2));
%     mean_rotation_stance_hip_Left(i) = max(angle_hip_interpolated(Left_FS(i):Left_FO(ind_Left_FO(1)),3)) - min(angle_hip_interpolated(Left_FS(i):Left_FO(ind_Left_FO(1)),3));
end

feat.hip_peakFlex = peak_flexion_hip(:);
feat.hip_peakExt  = peak_extension_hip(:);
feat.hip_range    = range_flexion_hip(:);


%% Knee %%

% Knee flexion at initial contact
% Time of peak knee flexion (%Gait)
% Peak knee flexion
% Time of peak knee extension (%Gait)
% Peak knee extension
% Range of knee flexion
for i=1:length(Left_FS)-1
    flexion_initial_contact_knee(i) = knee(Left_FS(i));
    [num idx]                       = min(knee(Left_FS(i):Left_FS(i+1)));
    time_peak_flexion_knee(i)       = idx/(Left_FS(i+1)-Left_FS(i))*100;
    peak_flexion_knee(i)            = num;
    [num idx]                       = max(knee(Left_FS(i):Left_FS(i+1)));
    time_peak_extension_knee(i)     = idx/(Left_FS(i+1)-Left_FS(i))*100;
    peak_extension_knee(i)          = num;
    range_flexion_knee(i)           = peak_extension_knee(i) - peak_flexion_knee(i);
end

feat.knee_flexInCont    = flexion_initial_contact_knee(:);
feat.knee_peakFlexTPerc = time_peak_flexion_knee(:);
feat.knee_peakFlex      = peak_flexion_knee(:);
feat.knee_peakExtTPerc  = time_peak_extension_knee(:);
feat.knee_peakExt       = peak_extension_knee(:);
feat.knee_range         = range_flexion_knee(:);


%% Ankle %%

% Peak ankle dorsiflexion in stance
% Peak ankle dorsiflexion in swing
% Peak ankle dorsiflexion
% Peak ankle plantarflexion
% Range of ankle flexion
for i=1:length(Left_FS)-1
    % First Left FO after the ith Left FS
    ind_Left_FO                       = find(Left_FO>Left_FS(i));
    peak_dorsiflexion_stance_ankle(i) = min(ankle(Left_FS(i):Left_FO(ind_Left_FO(1))));
    peak_dorsiflexion_swing_ankle(i)  = min(ankle(Left_FO(ind_Left_FO(1)):Left_FS(i+1)));
    peak_dorsiflexion_ankle(i)        = min(ankle(Left_FS(i):Left_FS(i+1)));
    
    peak_plantarflexion_ankle(i)      = max(ankle(Left_FS(i):Left_FS(i+1)));
    range_flexion_ankle(i)            = peak_plantarflexion_ankle(i) - peak_dorsiflexion_ankle(i);
end

feat.ankle_peakDorsiFlex_St = peak_dorsiflexion_stance_ankle(:);
feat.ankle_peakDorsiFlex_Sw = peak_dorsiflexion_swing_ankle(:);
feat.ankle_peakDorsiFlex    = peak_dorsiflexion_ankle(:);
feat.ankle_peakPlantFlex    = peak_plantarflexion_ankle(:);
feat.ankle_range            = range_flexion_ankle(:);


%% MTP %%

% Peak MTP flexion
% Peak MTP extension
% Range of MTP flexion
for i=1:length(Left_FS)-1
    [num idx]             = min(MTP(Left_FS(i):Left_FS(i+1)));
    peak_flexion_MTP(i)   = num;
    [num idx]             = max(MTP(Left_FS(i):Left_FS(i+1)));
    peak_extension_MTP(i) = num;
    range_flexion_MTP(i)  = peak_extension_MTP(i) - peak_flexion_MTP(i); 
end

feat.mtp_peakFlex = peak_flexion_MTP(:);
feat.mtp_peakExt  = peak_extension_MTP(:);
feat.mtp_range    = range_flexion_MTP(:);


%% limb Vector %%

if nargin>6
    
    limbV = varargin{1};
    
    for i=1:length(Left_FS)-1
        [num idx]               = min(limbV(Left_FS(i):Left_FS(i+1)));
        peak_flexion_limbV(i)   = num;
        [num idx]               = max(limbV(Left_FS(i):Left_FS(i+1)));
        peak_extension_limbV(i) = num;
        range_flexion_limbV(i)  = peak_extension_limbV(i) - peak_flexion_limbV(i); 
    end

    feat.limbV_ang_peakFlex = peak_flexion_limbV(:);
    feat.limbV_ang_peakExt  = peak_extension_limbV(:);
    feat.limbV_ang_range    = range_flexion_limbV(:);

end