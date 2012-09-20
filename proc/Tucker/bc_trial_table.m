function tt = bc_trial_table(bdf)
% BC_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the 2 bump choice trials in BDF

% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Staircase used
%    3: Target_dir
%    4: Bump direction
%    5: Bump time
%    6: Time of go queue
%    7: End trial time
%    8: Trial result            -- R, F, or A
%    9: Direction moved         -- 1 for primary, 2 for secondary

words = bdf.words;
db_times = cell2mat( bdf.databursts(:,1) );

result_codes = 'RAFI------------';

bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';

word_start = hex2dec('1F');
start_words = words(words(:,2) == word_start, 1);

num_trials = length(start_words);
disp(strcat('Found: ',num2str(num_trials),' trials'))

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

tt = zeros(num_trials-1, 31);

for trial = 1:num_trials-1
%    try
        start_time = start_words(trial);
        next_trial_start = start_words(trial+1);
        trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
        if isempty(trial_end_idx)
            end_time = next_trial_start - .001;
            trial_result = -1;
        else
            end_time = end_words(trial_end_idx);
            trial_result = double(result_codes(bitand(hex2dec('0f'),end_codes(trial_end_idx)) + 1));
        end

        idx = find(all_bumps > start_time & all_bumps < end_time, 1);
        if ~isempty(idx)
            bump_time = all_bumps(idx);
        else
            bump_time = 0;
        end

        idx = find(go_cues > start_time & go_cues < end_time, 1);
        if ~isempty(idx)
            go_cue = go_cues(idx);
        else
            go_cue = 0;
        end
% % * Databurst version descriptions
%  * ==============================
%  *
%  * Version 0 (0x01)
%  * ----------------
%  * byte 0:		uchar		=> number of bytes to be transmitted
%  * byte 1:		uchar		=> version number (in this case one)
%  * byte 2:		uchar		=> task code (0x01)
%  * bytes 3-6:     uchar       => version code
%  * byte 7-8:      uchar		=> version code (micro)
%  * byte 9:		uchar		=> staircase id
%  * bytes 10-13:	int			=> staircase iteration
%  * bytes 14-17:   float		=> target angle
%  * bytes 18-21:   float		=> bump direction
%  * byte 22:		uchar		=> random target flag
%  * bytes 23-26:   int			=> target floor (minimum angle(deg) target can take in random target assignment)
%  * bytes 27-30:   int			=> target ceiling (maximum angle(deg) target can take in random target assignment)
%  * bytes 31-34:   float		=> bump magnitude
%  * bytes 35-38:   float		=> bump duration
%  * bytes 39-42:   float		=> bump ramp
%  * byte 43:		uchar		=> random bump flag
%  * bytes 44-47:   int			=> bump floor (minimum angle(deg) bump can take in random target assignment)
%  * bytes 48-51:	int			=> bump ceiling (maximum angle(deg) bump can take in random target assignment)
%  * bytes 52-55:   int			=> staircase ratio
%  * byte 56:		uchar		=> stim trial flag
%  * bytes 57-60:   float		=> training trial frequency
%  * bytes 61-64:   float		=> stimulation probability 
%  * byte 65:		uchar		=> recenter cursor flag
%  * bytes 66-69:   float		=> target radius
%  * bytes 70-73:   float		=> target size
%  * bytes 74-77:   float		=> intertrial time
%  * bytes 78-81:   float		=> penalty time
%  * bytes 82-85:   float		=> bump hold time
%  * bytes 86-89:   float		=> center hold time
%  * bytes 90-93:   float		=> outer target delay time
%  * bytes 94-97:   float		=> bump rate skew (varies between 0 and 1 adjusting the skew towards bumping at the forward limit)
%  * byte  98:      uchar       => show targets during bump flag
%  */
        db = bdf.databursts{trial,2};

        staircase_id=db(9);
        target_angle=bytes2float(db(14:17));
        bump_dir=bytes2float(db(18:21));
        random_tgt_flag=db(22);
        tgt_dir_floor=bytes2float(db(23:26));
        tgt_dir_ceil=bytes2float(db(27:30));
        bump_mag=bytes2float(db(31:34));
        bump_dur=bytes2float(db(35:38));
        bump_ramp=bytes2float(db(39:42));
        rand_bump_flag=db(43);
        bump_floor=bytes2float(db(44:47));
        bump_ceil=bytes2float(db(48:51));
        staircase_ratio=bytes2float(db(52:55));
        stim_trial_flag=db(56);
        training_trial_freq=bytes2float(db(57:60));
        stim_freq=bytes2float(db(61:64));
        recenter_cursor_flag=db(65);
        tgt_radius=bytes2float(db(66:69));
        tgt_size=bytes2float(db(70:73));
        intertrial_time=bytes2float(db(74:77));
        penalty_time=bytes2float(db(78:81));
        bump_hold_time=bytes2float(db(82:85));
        ct_hold_time=bytes2float(db(86:89));
        ot_delay_time=bytes2float(db(90:93));
        bump_rate_skew=bytes2float(db(94:97));
        targets_during_bump_flag=db(98);
        
        tt(trial,:) = [start_time, bump_time, go_cue, end_time, ct_hold_time, bump_hold_time, ot_delay_time, penalty_time, intertrial_time, ... 9 elements
            random_tgt_flag, rand_bump_flag, stim_trial_flag, recenter_cursor_flag, targets_during_bump_flag, ... 5 elements
            tgt_radius, tgt_size, tgt_dir_floor, tgt_dir_ceil, target_angle, ... 5 elements
            staircase_id, staircase_ratio, bump_rate_skew, bump_floor, bump_ceil, bump_mag, bump_dur, bump_ramp, bump_dir, ... 9 elements
            training_trial_freq, stim_freq, trial_result ];

%     catch
%         tt(trial,:) = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
%                        NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
%                        NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
%                        NaN];
%     end
end

tt = tt(~isnan(tt(:,1)),:);

lr = (tt(:,7)==double('R') & tt(:,2)==1) | (tt(:,2)==0 & tt(:,7)==double('F'));
lr = lr | ((tt(:,7)==double('R') & tt(:,2)==3) | (tt(:,2)==2 & tt(:,7)==double('F')));
tt(:,8) = lr;
