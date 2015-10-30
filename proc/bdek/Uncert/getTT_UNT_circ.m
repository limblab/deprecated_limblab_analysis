function [tt,sep_tt, priors,DB_inds] = getTT_UNT_circ(bdf)
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

%cd C:\Users\limblab\Desktop\s1_analysis\proc\bdek\Uncert\;

fn = bdf.meta.filename;
while ~isempty(fn)
    [tok, fn]=strtok(fn,'\\');
end
fn=strtok(tok,'.');
fn = ['tt_' fn '.mat'];

%% Get the Databurst timestamps and pull the first timestamp
dtb = bdf.databursts;
burstlengths = cellfun(@(x) length(x),dtb(:,2));
dtb(burstlengths < 10,:) = [];
for dtbi=1:length(dtb)
    dtb_ts(dtbi) = dtb{dtbi,1};
    dtb_perts(dtbi) = bytes2float(dtb{dtbi,2}(10:13));
    dtb_prior(dtbi) = bytes2float(dtb{dtbi,2}(14:17));
    dtb_fb_sig(dtbi) = bytes2float(dtb{dtbi,2}(18:21));
    % Set NAN for erroneous perturbation databurst (dropped)
%     if abs(dtb_perts(dtbi))>50
%         dtb_perts(dtbi)=NaN;
%     end
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
dtb_prior = dtb_prior(dtb_range);
dtb_fb_sig = dtb_fb_sig(dtb_range);

%% Process each trial
all_trial_word_inds = find(wds_codes>=32 & wds_codes<=34);
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
outer_ts        = wds_ts(outer_code_inds);
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
DB_inds = nan(length(dtb_range),1);
% For each trial complete code
for trial_i=1:length(all_trial_word_inds)
    
    %Output 1 and 2
    dtb_ind = find(dtb_ts < all_trial_word_ts(trial_i),1,'last');
    
    if ~isempty(dtb_ind) && ~ismember(dtb_ind,DB_inds)
        out_dtb_ts = dtb_ts(dtb_ind);
        out_dtb_pert = dtb_perts(dtb_ind);
        out_dtb_prior = dtb_prior(dtb_ind);
        if dtb_fb_sig(dtb_ind) <= 100000 
            out_dtb_fb_sig = dtb_fb_sig(dtb_ind);
            dropTrial = false;
        else
            out_dtb_fb_sig = NaN;
            dropTrial = true; %fprintf('%d',trial_i);
        end
        out_dtb_ind = dtb_ind;
    else
        out_dtb_ts = NaN;
        out_dtb_pert = NaN;
        out_dtb_prior = NaN;
        out_dtb_fb_sig = NaN;
        dropTrial=true; %fprintf('%d',trial_i);
        out_dtb_ind = NaN;
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
    if out_targ_ts < out_dtb_ts || out_targ_ts < 1
        out_targ_ts = NaN;
    end
    if out_go_ts < out_dtb_ts || out_go_ts < 1
        out_go_ts = NaN;
    end
    if out_end_ts < out_dtb_ts || out_end_ts < 1
        out_end_ts = NaN;
    end
    %Output 3
    cn_ind = find(center_ts<out_end_ts,1,'last');
    try
        cn_ind2 = find(center_ts>dtb_ts(out_dtb_ind),1,'first');
    catch err
        cn_ind2 = [];
    end
    if ~isempty(cn_ind) && ~isempty(cn_ind2)
      
        if cn_ind==cn_ind2
            out_center_ts = center_ts(cn_ind);
        elseif (center_ts(cn_ind) < dtb_ts(dtb_ind)) && (center_ts(cn_ind2) < out_end_ts)
            out_center_ts = center_ts(cn_ind2);
        elseif (center_ts(cn_ind) > dtb_ts(dtb_ind)) && (center_ts(cn_ind2) > out_end_ts)
            out_center_ts = center_ts(cn_ind);
        else
            out_center_ts = NaN;
        end
    else
        out_center_ts = NaN;
    end

    if 1%~dropTrial
        DB_inds(trial_counter) = out_dtb_ind;
        tt(trial_counter,:) = [...
            out_dtb_ts, ...
            out_dtb_pert, ...
            out_dtb_fb_sig, ...
            out_center_ts, ...
            out_targ_ts, ...
            out_go_ts, ...
            out_end_ts, ...
            out_result];  % Result of trial ('R', 'A', 'I', or 'N')
        
        prior_list(trial_counter) = out_dtb_prior;
        trial_counter=trial_counter+1; 
    end
    dropTrial=false;
end

bad_trials = sum(isnan(tt(:,4:7)),2)>=1;
tt(bad_trials,:) = [];
prior_list(bad_trials) = [];
%cd C:\Users\limblab\Desktop\s1_analysis\proc\bdek\Uncert\;
% save(fn,'tt');

% Deal with weird prior databursts
check_bb = @(burst) burst < 10e-5 | burst > 1e5+1 | isnan(burst);
bad_bursts = find(check_bb(prior_list));
good_bursts = find(~check_bb(prior_list));
for i = 1:length(bad_bursts)
    bb = bad_bursts(i);
    ind_dists = abs(good_bursts - bb);
    replacer_ind = good_bursts(find(ind_dists==min(ind_dists),1,'first'));
    replacer = prior_list(replacer_ind);
    prior_list(bb)= replacer;
end

prior_switches = [0 find(diff(prior_list)~=0) length(prior_list)];
sep_tt = cell(length(prior_switches)-1,1);
priors = cell(length(prior_switches)-1,1);
for i = 1:length(prior_switches)-1
    sep_tt{i} = tt((prior_switches(i)+1):prior_switches(i+1),:);
    priors{i}.inds = (prior_switches(i)+1):prior_switches(i+1);
    priors{i}.val = prior_list(prior_switches(i)+1);
end

return