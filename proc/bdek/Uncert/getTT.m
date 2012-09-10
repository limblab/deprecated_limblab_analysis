function tt = getTT(bdf)
% getTT - returns a table containing the key timestamps 
%                   for all of the 1D Uncertainty trials in BDF
%
% Each row of the table corresponds to a single trial.  Columns are as
% follows:
%    1: Trial Databurst Timestamp
%    2: Trial Prior  Perturbation (shift or rotation)
%    3: Trial Feedback Uncertainty
%    4: Trial Center Timestamp
%    5: Trial Target Timestamp
%    6: Trial Go     Timestamp (i.e. Movement Start)  NaN if not R or F
%    7: Trial End    Timestamp
%    8: Trial End  Result   -- R (32), A (33), F (34),
%                              I (35), or NaN

%%

cd C:\Users\limblab\Desktop\s1_analysis\proc\bdek\Uncert\;

fn = bdf.meta.filename;
while ~isempty(fn)
    [tok fn]=strtok(fn,'\\');
end
fn=strtok(tok,'.');
fn = ['tt_' fn '.mat'];

%% Get the Databurst timestamps and pull the first timestamp
dtb = bdf.databursts;
for dtbi=1:length(dtb)
    dtb_ts(dtbi) = dtb{dtbi,1};
    dtb_perts(dtbi) = bytes2float(dtb{dtbi,2}(7:10));
    dtb_fb_sig(dtbi) = bytes2float(dtb{dtbi,2}(11:14));
    
    % Set NAN for erroneous perturbation databurst (dropped)
    if abs(dtb_perts(dtbi))>50
        dtb_perts(dtbi)=NaN;
    end
end
% Only keep databursts that occur from 1 second and on
dtb_start_ind = find(dtb_ts>=1.0,1,'first');

%% Load and Process Words

% Find the first databurst time and truncate any words preceding it
words_first_ind = find(bdf.words(:,1) > dtb_ts(dtb_start_ind),1,'first');

%Find last trial end code index
words_end_ind=find(bdf.words(:,2)==hex2dec('20')|bdf.words(:,2)==hex2dec('21')|bdf.words(:,2)==hex2dec('22')|bdf.words(:,2)==hex2dec('23'),1,'last');
words_end_ts = bdf.words(words_end_ind,1);% last trial end time

% Truncate Words
wds = bdf.words(words_first_ind:words_end_ind,:);
wds_ts    = wds(:,1);
wds_codes = wds(:,2);

%% Process Full Databurst
% Truncate Databursts following the last end code time (if necessary)
dtb_last_ind = find(dtb_ts < words_end_ts,1,'last');
dtb_range = [dtb_start_ind:dtb_last_ind];

dtb_ts = dtb_ts(dtb_range);
dtb_perts = dtb_perts(dtb_range);

%% Process each trial
all_trial_word_inds = find(wds_codes>=32 & wds_codes<=35);
all_trial_word_ts = wds_ts(all_trial_word_inds);

% CENTER LOC   x30
% OUTER TARGET x40
% GO x31
% Reward       x20
% Abort        x21
% Failure      x22
% Incomplete   x23

center_code_inds     = find(wds_codes==hex2dec('30'));
outer_code_inds      = find(wds_codes==hex2dec('40'));
go_code_inds         = find(wds_codes==hex2dec('31'));
reward_code_inds     = find(wds_codes==hex2dec('20'));
abort_code_inds      = find(wds_codes==hex2dec('21'));
failure_code_inds    = find(wds_codes==hex2dec('22'));
incomplete_code_inds = find(wds_codes==hex2dec('23'));

center_ts       = wds_ts(center_code_inds);
outer_ts       = wds_ts(outer_code_inds);
go_ts           = wds_ts(go_code_inds);
reward_ts       = wds_ts(reward_code_inds);
failure_ts      = wds_ts(failure_code_inds);
abort_ts        = wds_ts(abort_code_inds);
incomplete_ts   = wds_ts(incomplete_code_inds);

% GETUNTRIALTABLE1D - returns a table containing the key timestamps 
%                   for all of the 1D Uncertainty trials in BDF
%
% Each row of the table corresponds to a single trial.  Columns are as
% follows:
%    1: Trial Databurst Timestamp
%    2: Trial Prior  Perturbation (shift or rotation)
%    3: Feedback variance
%    4: Trial Center Timestamp
%    5: Trial Target Timestamp
%    6: Trial Go     Timestamp (i.e. Movement Start)  NaN if not R or F
%    7: Trial End    Timestamp
%    8: Trial End  Result   -- R (32), A (33), F (34),
%                              I (35), or NaN

dropTrial = false;
trial_counter=1;
% For each trial complete code
for trial_i=1:length(all_trial_word_inds)
    
    %Output 1 and 2
    dtb_ind = find(dtb_ts < all_trial_word_ts(trial_i),1,'last');
    if ~isempty(dtb_ind)
        out_dtb_ts = dtb_ts(dtb_ind);
        out_dtb_pert = dtb_perts(dtb_ind);
        out_dtb_fb_sig = dtb_fb_sig(dtb_ind);
    else
        out_dtb_ts = NaN;
        out_dtb_pert = NaN;
        out_dtb_fb_sig = NaN;
        dropTrial=true;
    end
    
    out_end_ts = floor(1000*wds_ts(all_trial_word_inds(trial_i)))/1000;
    result_code = wds_codes(all_trial_word_inds(trial_i));
    if result_code==hex2dec('20')
        out_result = result_code;
        out_go_ts = go_ts(find(go_ts<out_end_ts,1,'last'));
        out_targ_ts = outer_ts(find(outer_ts<out_end_ts,1,'last'));
    elseif result_code==hex2dec('22')
        out_result = result_code;     
        out_go_ts = go_ts(find(go_ts<out_end_ts,1,'last'));        
        out_targ_ts = outer_ts(find(outer_ts<out_end_ts,1,'last'));    
    elseif result_code==hex2dec('21')
        out_result = result_code;
        out_go_ts = NaN;
        out_targ_ts = NaN;
    elseif result_code==hex2dec('23')
        out_result = result_code;
        out_go_ts = NaN;
        out_targ_ts = NaN;
    else
        out_result = NaN;
        out_go_ts = NaN;
        out_targ_ts = NaN; 
    end
    if isempty(out_go_ts)
        out_go_ts=NaN;
    end
    if isempty(out_targ_ts)
    	out_targ_ts=NaN;
    end
   
    %Output 3
    cn_ind = find(center_ts<out_end_ts,1,'last');
    out_center_ts = center_ts(cn_ind);
    if isempty(out_center_ts)
    	out_center_ts=NaN;
    end

    if ~dropTrial
        tt(trial_counter,:) = [...
            out_dtb_ts, ...
            out_dtb_pert, ...
            out_dtb_fb_sig, ...
            out_center_ts, ...
            out_targ_ts, ...
            out_go_ts, ...
            out_end_ts, ...
            out_result];  % Result of trial ('R', 'A', 'I', or 'N')
        trial_counter=trial_counter+1;
    end
    dropTrial=false;
end
cd C:\Users\limblab\Desktop\s1_analysis\proc\bdek\Uncert\;
save(fn,'tt');
return;