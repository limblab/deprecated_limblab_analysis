function features = compFeat_SpatioTemporal (Left_FO, Left_FS, freq)

%%% IMPORTANT! THE GAIT EVENTS MUST BE CONSECUTIVE!!!

% First Left FO after the first Left FS
ind_FO = find(Left_FO>Left_FS(1));

if ~ind_FO(1)==1
    Left_FO = Left_FO(ind_FO);
end

% To make sure that # Foot Strike events is equal to # Foot Off events ---
lFO = length(Left_FO);
lFS = length(Left_FS);
if lFO>lFS
    Left_FO = Left_FO(1:lFS);
end

if lFO<lFS
    Left_FS = Left_FS(1:lFO);
end
%%% ----------------------------------------------------------------------
                                                      
stride               = diff(Left_FS);
stride_duration_Left = stride/freq;                 % Stride duration [s]
% TODO: stride length

stance               = Left_FO-Left_FS;             % Stance
per_stance_Left      = stance(1:end-1)./stride*100; % Stance percentage [%]
duration_stance_Left = stance/freq;                 % Stance duration [s]

cadence              = 60./stride_duration_Left;    % Cadence (strides/min)

%{
% %Stance;
% Duration of stance (s);
if ind_FO(1)==1
    for i=1:length(Left_FS)-1
        per_stance_Left(i) = (Left_FO(i)-Left_FS(i))/(Left_FS(i+1)-Left_FS(i))*100;
        duration_stance_Left(i) = (Left_FO(i)-Left_FS(i))/100;
    end
else
    for i=1:length(Left_FS)-1
        per_stance_Left(i) = (Left_FO(i+1)-Left_FS(i))/(Left_FS(i+1)-Left_FS(i))*100;
        duration_stance_Left(i) = (Left_FO(i+1)-Left_FS(i))/100;
    end
end

% Stride length (m)
% Cadence (strides/minute);
% Stride duration (s)
for i=1:length(Left_FS)-1
%     stride_length_Left(i) = abs(FootPosition(Left_FS(i+1),2)-FootPosition(Left_FS(i),2))/1000;
    stride_duration_Left(i) = (Left_FS(i+1)-Left_FS(i))/100;
    cadence(i) = 60/((Left_FS(i+1)-Left_FS(i))/100);
end
%}

features.stancePer = per_stance_Left;
features.stanceDur = duration_stance_Left;
features.strideDur = stride_duration_Left;
features.strideCad = cadence;