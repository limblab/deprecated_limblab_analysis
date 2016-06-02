function States = mvt_clas(bdf,tt)
%
% argin
%    bdf : bdf data set
%    tt  : trial table
%
% Return ts of beginning and end of each classified state.
% v1.0 : Returns [Hold_State, Mvt_State]
%            Hold_State and Mvt_State are (2*N)x2 vectors of ts.
%            Columns are beginning and end of respective state.
%            N is the number of complete successful trials.
%            (There are two occurences of each state per trial)
%
% State transitions are find between specific words:
% (e.g.for VS task, trials 1 and 2) 
% 1. CT_Hold1             : Hold start                  : Hold_State(1,1)
% 2. OT_On1  <-> OT_Hold1 : Hold to Movement transition : Mvt_State(1,1) & Hold_State(1,2)
% 3. OT_Hold1             : Movement to Hold transition : Hold_State(1,2)
% 4. Reward1 <-> CT_Hold2 : Hold to Movement transition : Mvt_State(1,2)
% 5. CT_Hold2             : Movement to Hold transition : Hold_State(2,1)
%
%
% Each row of the trial table coresponds to a single trial.
% Columns are as follows:
%    1: Start time
%    2: Target id                -- -1 for none
%    3: CT_ON
%    4: CT_Hold
%    5: OT_ON
%    6: Reach
%    7: OT_Hold
%    8: Movement start time
%    9: Trial End time
%   10: Trial result            -- R, A, I, or N (N coresponds to no-result)
%

num_trials  = size(tt,1);

Hold_State  = NaN(2*num_trials,2);
Mvt_State   = NaN(2*num_trials,2);

for trial = 1:num_trials-1 % -- skip last trial --
    if tt(trial,10) == double('R')
        
        % Important ts:
        CT_Hold1_ts = tt(trial,4);
        OT_On1_ts   = tt(trial,5);
        OT_Hold1_ts = tt(trial,7);
        Reward1_ts  = tt(trial,9);
        CT_Hold2_ts = tt(trial+1,4);

        % 0. Extract velocity signals for relevant time segment:
        start_time = CT_Hold1_ts; stop_time = CT_Hold2_ts;        
        sidx = find(bdf.vel(:,1) > start_time,1,'first'):find(bdf.vel(:,1) > stop_time,1,'first');

        t = bdf.vel(sidx,1);                                % Set up time index vector
        s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);  % Calculate speeds
        d = [0; diff(smooth(s,100))*25];                    % Absolute acceleration (dSpeed/dt)
        dd = [diff(smooth(d,100)); 0];                      % d^2 Speed / dt^2
        peaks = dd(1:end-1)>0 & dd(2:end)<0;                % zero crossings are abs. acc. peaks
        
        % 1. CT_Hold1
        Hold_State(2*trial-1,1) = CT_Hold1_ts; %Hold1 start
        
        % 2. OT_On1  <-> OT_Hold1 : Hold1 to Movement1 transition
        mvt_start = OT_On1_ts;
        mvt_peak = find(peaks & t(2:end) > mvt_start & d(2:end) > 1, 1, 'first'); 
        thresh = d(mvt_peak)/2;                             % Threshold is half max of acceleration peak
        onset = t(find(d<thresh & t<t(mvt_peak),1,'last')); % Movement onset is last threshold crossing before peak
        Hold_State(2*trial-1,2) = onset;  % Hold1 end
        Mvt_State(2*trial-1,1)  = onset;  % Mvt1 start
        
        % 3. OT_Hold1 : Movement1 to Hold2 transition
        Mvt_State(2*trial-1,2)= OT_Hold1_ts; % Mvt1 end
        Hold_State(2*trial,1) = OT_Hold1_ts; % Hold2 start
        
        % 4. Reward1 <-> CT_Hold2 : Hold2 to Movement2 transition
        mvt_start = Reward1_ts;
        mvt_peak = find(peaks & t(2:end) > mvt_start & d(2:end) > 1, 1, 'first'); 
        thresh = d(mvt_peak)/2;                             % Threshold is half max of acceleration peak
        onset = t(find(d<thresh & t<t(mvt_peak),1,'last')); % Movement onset is last threshold crossing before peak
        Hold_State(2*trial,2)= onset; %Hold 2 end
        Mvt_State(2*trial,1) = onset; %Mvt2 start
        
        % 5. CT_Hold2 : Movement2 to Hold3 transition
        Mvt_State(2*trial,2) = CT_Hold2_ts;
    end
end

good_rows = ~isnan(Hold_State(:,1));

Hold_State = Hold_State(good_rows,:);
Mvt_State  = Mvt_State(good_rows,:);

States = {Hold_State,Mvt_State};
            
            
            
            