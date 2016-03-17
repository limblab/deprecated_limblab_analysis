function tt = getTT_UNT1D(bdf)
% getTT - returns a table containing the key timestamps 
%                   for all of the 1D Uncertainty trials in BDF
%
% Each row of the table corresponds to a single trial.  Columns are as
% follows:
%    1: Trial Databurst Timestamp
%    2: Trial Prior  Perturbation (shift or rotation)
%    3: Trial Feedback Uncertainty
%    4: Trial Center Timestamp
%    5: Trial Target Timestamp (NaN for ABORT trials)
%    6: Trial Go     Timestamp (NaN for ABORT trials)
%    7: Trial End    Timestamp
%    8: Trial End  Result   -- R (32), A (33), F (34),
%                              I (35), or NaN

%%

cd C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\;



%% Get the Databurst timestamps and pull the first timestamp
dtb = bdf.databursts;
for dtbi=1:length(dtb)
    dtb_ts(dtbi) = dtb{dtbi,1};
    
%   dtb_code = dtb{dtbi,2}(3:5)    'UNT'
    % trial perturbation
    dtb_perts(dtbi) = bytes2float(dtb{dtbi,2}(10:13));
    % trial feedback stdev
    dtb_fb_sig(dtbi) = bytes2float(dtb{dtbi,2}(14:17));
    % number of dots used
    dtb_num_dots(dtbi) = bytes2float(dtb{dtbi,2}(18:21));
    
    for ci=1:20
        dtb_clouds(dtbi,ci) =  bytes2float(dtb{dtbi,2}(18+ci*4:21+ci*4));
    end
end

% Only keep databursts that occur from 1 second and on
dtb_start_ind = find(dtb_ts>=1.0,1,'first');

%% Load and Process Words

% Find the first databurst time and truncate any words preceding it
words_first_ind = find(bdf.words(:,1) >= dtb_ts(dtb_start_ind),1,'first');

%Find last trial end code index
words_end_ind=find(bdf.words(:,2)==hex2dec('20')|bdf.words(:,2)==hex2dec('21')|bdf.words(:,2)==hex2dec('22')|bdf.words(:,2)==hex2dec('23'),1,'last');
words_end_ts = bdf.words(words_end_ind,1);% last trial end time stamp

% Truncate Words
wds = bdf.words(words_first_ind:words_end_ind,:);
wds_ts    = wds(:,1);
wds_codes = wds(:,2);

%% Process Full Databurst
% Truncate Databursts following the last end code time (if necessary)
dtb_last_ind    = find(dtb_ts <= words_end_ts,1,'last');
dtb_range       = [dtb_start_ind:dtb_last_ind];

dtb_ts          = dtb_ts(dtb_range);
dtb_perts       = dtb_perts(dtb_range);
dtb_fb_sig      = dtb_fb_sig(dtb_range);
dtb_num_dots    = dtb_num_dots(dtb_range);
dtb_clouds      = dtb_clouds(dtb_range,:);

%% Process each trial
% START TRIAL        x1F
% CENTER TARGET ON   x30
% CENTER TARGET HOLD xA0
% OUTER TARGET  ON   x40
% GO CUE             x31
% OUTER TARGET HOLD  xA1
% REWARD             x20
% ABORT              x21
% FAILURE            x22
% INCOMPLETE         x23
start_trial_code     = hex2dec('1F');
center_on_code       = hex2dec('30');
center_hold_code     = hex2dec('A0');
outer_on_code        = hex2dec('40');
go_cue_code          = hex2dec('31');
outer_hold_code      = hex2dec('A1');
reward_code          = hex2dec('20');
abort_code           = hex2dec('21');
failure_code         = hex2dec('22');
incomplete_code      = hex2dec('23');


% Each row of the table corresponds to a single trial.  Columns are as
% follows:
%    1: Trial Databurst Timestamp
%    2: Trial Prior  Perturbation (shift or rotation)
%    3: Trial Feedback Uncertainty
%    4: Number of dots/slices
%    5: start trial (for the next trial)
%    6: center on
%    7: center hold
%    8: outer on
%    9: go
%   10: outer hold
%   11: trial end time
%   12: Trial End  Result   -- R (32), A (33), F (34),
%                              I (35), or NaN
%   13--->  clouds (x,y x,y x,y x,y x,y....)

numtrials = length(dtb_ts);
% %
% dtb_ts          = dtb_ts(dtb_range);
% dtb_perts       = dtb_perts(dtb_range);
% dtb_fb_sig      = dtb_fb_sig(dtb_range);
% dtb_num_dots    = dtb_num_dots(dtb_range);
% dtb_clouds      = dtb_clouds(dtb_range,:);
for ti=1:numtrials
    % db timestamp
    tt(ti,1) = dtb_ts(ti);
    % db shift
    tt(ti,2) = dtb_perts(ti);
    % db fb
    tt(ti,3) = dtb_fb_sig(ti);    
    % db numdots
    tt(ti,4) = dtb_num_dots(ti);
    
    % preload with NaNs
    tt(ti,5:12) = NaN;
    tt(ti,13) = 0; % BAD WORD COUNT
    tt(ti,14:33) = dtb_clouds(ti,:);
    
    
    % The set of words that fall between this databurst and the next
    if ti==numtrials
        wd_inds = find(wds_ts>=dtb_ts(ti));
    else
        wd_inds = find(wds_ts>=dtb_ts(ti) & wds_ts<dtb_ts(ti+1));
    end
    % parse these words
    start_trial_code     = hex2dec('1F');
    center_on_code       = hex2dec('30');
    center_hold_code     = hex2dec('A0');
    outer_on_code        = hex2dec('40');
    go_cue_code          = hex2dec('31');
    outer_hold_code      = hex2dec('A1');
    reward_code          = hex2dec('20');
    abort_code           = hex2dec('21');
    failure_code         = hex2dec('22');
    incomplete_code      = hex2dec('23');
    
    for wi=wd_inds'
        switch wds_codes(wi)
            case start_trial_code
                if ~isnan(tt(ti,5))
                    warning('Duplicate Start Trial Code for DB #%d',ti);
                else
                    tt(ti,5)=wds_ts(wi);
                end
            case center_on_code
                if ~isnan(tt(ti,6))
                    warning('Duplicate Center On Code for DB #%d',ti);
                else
                    tt(ti,6)=wds_ts(wi);
                end
            case center_hold_code
                if ~isnan(tt(ti,7))
                    warning('Duplicate Center Hold Code for DB #%d',ti);
                else
                    tt(ti,7)=wds_ts(wi);
                end
            case outer_on_code
                if ~isnan(tt(ti,8))
                    warning('Duplicate Outer On Code for DB #%d',ti);
                else
                    tt(ti,8)=wds_ts(wi);
                end
            case go_cue_code
                if ~isnan(tt(ti,9))
                    warning('Duplicate Go Code for DB #%d',ti);
                else
                    tt(ti,9)=wds_ts(wi);
                end
            case outer_hold_code
                if ~isnan(tt(ti,10))
                    warning('Duplicate Outer Hold Code for DB #%d',ti);
                else
                    tt(ti,10)=wds_ts(wi);
                end
            case reward_code
                if ~isnan(tt(ti,11))
                    warning('Duplicate Outcome Code for DB #%d',ti);
                else
                    tt(ti,11)=wds_ts(wi);
                    tt(ti,12)=wds_codes(wi);
                    if isnan(tt(ti,9))
                        tt(ti,13)=tt(ti,13)+1;
                        warning('Missing Go Code for Complete Trial for DB #%d',ti);
                    end
                end
            case abort_code
                if ~isnan(tt(ti,11))
                    warning('Duplicate Outcome Code for DB #%d',ti);
                else
                    tt(ti,11)=wds_ts(wi);
                    tt(ti,12)=wds_codes(wi);
                end
            case failure_code
                if ~isnan(tt(ti,11))
                    warning('Duplicate Outcome Code for DB #%d',ti);
                else
                    tt(ti,11)=wds_ts(wi);
                    tt(ti,12)=wds_codes(wi);
                    if isnan(tt(ti,9))
                        tt(ti,13)=tt(ti,13)+1;
                        warning('Missing Go Code for Complete Trial for DB #%d',ti);
                    end
                end
            case incomplete_code
                if ~isnan(tt(ti,11))
                    warning('Duplicate Outcome Code for DB #%d',ti);
                else
                    tt(ti,11)=wds_ts(wi);
                    tt(ti,12)=wds_codes(wi);
                end    
            otherwise
                tt(ti,13)=tt(ti,13)+1;
                warning('Bad Word Detected %s',dec2hex(wds_codes(wi)));
        end
    end

end


cd C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\;

return;