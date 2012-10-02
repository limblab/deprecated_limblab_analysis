function [tt, hdr]= bc_trial_table2(bdf)
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

tt = zeros(num_trials-1, 41);

for trial = 1:num_trials-1
      try
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

        numbytes=db(1); %1
        db_version=db(2);%2
        two=db(3);%3
        b=db(4);%4
        c=db(5);%5
        behavior_version_maj=db(6);%6
        behavior_version_minor=db(7);%7
        behavior_version_micro1=db(8);%8
        behavior_version_micro2=db(9);%9
        staircase_id=db(10);        %10
        staircase_step=bytes2float(db(11:14));%this was acast as an int, but comes in 4 words
        target_angle=round((180/3.1415)*bytes2float(db(15:18)));%13
        bump_dir=bytes2float(db(19:22));%14
        random_tgt_flag=db(23);%15
        tgt_dir_floor=bytes2float(db(24:27));%16
        tgt_dir_ceil=bytes2float(db(28:31));%17
        bump_mag=bytes2float(db(32:35));%18
        bump_dur=bytes2float(db(36:39));%19
        bump_ramp=bytes2float(db(40:43));%20
        rand_bump_flag=db(44);%21
        bump_floor=bytes2float(db(45:48));%22
        bump_ceil=bytes2float(db(49:52));%23
        staircase_ratio=bytes2float(db(53:56));%24
        stim_trial_flag=db(57);%25
        training_trial_flag=(58);%26
        
        training_trial_freq=bytes2float(db(59:62));%27
        stim_freq=bytes2float(db(63:66));%28
        recenter_cursor_flag=db(67);%29
        tgt_radius=bytes2float(db(68:71));%30
        tgt_size=bytes2float(db(72:75));%31
        intertrial_time=bytes2float(db(76:79));
        penalty_time=bytes2float(db(80:83));
        bump_hold_time=bytes2float(db(84:87));
        ct_hold_time=bytes2float(db(88:71));
        ot_delay_time=bytes2float(db(92:95));
        bump_rate_skew=bytes2float(db(96:99));
        targets_during_bump_flag=db(100);
        
         tt(trial,:)= [     numbytes,                   db_version,                 two,                        b,                          c, ...
                            behavior_version_maj,       behavior_version_minor,     behavior_version_micro1,    behavior_version_micro2,    staircase_id,...
                            staircase_step,             target_angle,               bump_dir,                   random_tgt_flag,            tgt_dir_floor,...
                            tgt_dir_ceil,               bump_mag,                   bump_dur,                   bump_ramp,rand_bump_flag,   bump_floor,   ...
                            bump_ceil,                  staircase_ratio,            stim_trial_flag,            training_trial_flag,        training_trial_freq, ...
                            stim_freq,                  recenter_cursor_flag,       tgt_radius,                 tgt_size,                   intertrial_time,  ...
                            penalty_time,               bump_hold_time,             ct_hold_time,               ot_delay_time,              bump_rate_skew, ...
                            targets_during_bump_flag,   start_time,                 bump_time,                  go_cue,                     end_time,  ...
                            trial_result];
        
       catch
           tt(trial,:) = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
                          NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
                          NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
                          NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
                          NaN];
       end
end

disp('composing trial table assuming db v 1')
disp(strcat('db version:',num2str(bdf.databursts{trial,2}(2))))
disp('If actual db version does not match assumed version, fix the trial table code')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build hdr object with associated column numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdr.numbytes                =   1;%     bytes transmitted
hdr.db_version              =   2;%     db_version=db(2);%2
                      %                 two=db(3);%3
                      %                 b=db(4);%4
                      %                 c=db(5);%5
hdr.Behavior_version_major  =   6;%     behavior_version_maj=db(6);%6
hdr.Behavior_version_minor  =   7;%     behavior_version_minor=db(7);%7
hdr.Behavior_version_micro1 =   8;%     behavior_version_micro1=db(8);%8
hdr.Behavior_version_micro2 =   9;%     behavior_version_micro2=db(9);%9
hdr.staircase_id            =   10;%    staircase_id=db(10);        %10
hdr.staircase_iteration     =   11;%    staircase_step=bytes2float(db(11:14));%this was acast as an int, but comes in 4 words
hdr.tgt_angle               =   12;%    target_angle=round((180/3.1415)*bytes2float(db(15:18)));%13
hdr.bump_angle              =   13;%    bump_dir=bytes2float(db(19:22));%14
hdr.rand_tgt_flag           =   14;%    random_tgt_flag=db(23);%15
hdr.tgt_floor               =   15;%    tgt_dir_floor=bytes2float(db(24:27));%16
hdr.tgt_ceil                =   16;%    tgt_dir_ceil=bytes2float(db(28:31));%17
hdr.bump_mag                =   17;%    bump_mag=bytes2float(db(32:35));%18
hdr.bump_dur                =   18;%    bump_dur=bytes2float(db(36:39));%19
hdr.bump_ramp               =   19;%    bump_ramp=bytes2float(db(40:43));%20
hdr.rand_bump_flag          =   20;%    rand_bump_flag=db(44);%21
hdr.bump_floor              =   21;%    bump_floor=bytes2float(db(45:48));%22
hdr.bump_ceil               =   22;%    bump_ceil=bytes2float(db(49:52));%23
hdr.staircase_ratio         =   23;%    staircase_ratio=bytes2float(db(53:56));%24
hdr.stim_trial              =   24;%    stim_trial_flag=db(57);%25
hdr.training_trial          =   25;%    training_trial_flag=(58);%26
hdr.training_freq           =   26;%    training_trial_freq=bytes2float(db(59:62));%27
hdr.stim_freq               =   27;%    stim_freq=bytes2float(db(63:66));%28
hdr.recenter_cursor         =   28;%    recenter_cursor_flag=db(67);%29
hdr.tgt_radius              =   29;%    tgt_radius=bytes2float(db(68:71));%30
hdr.tgt_size                =   30;%    tgt_size=bytes2float(db(72:75));%31
hdr.intertrial_time         =   31;%    intertrial_time=bytes2float(db(76:79));
hdr.penalty_time            =   32;%    penalty_time=bytes2float(db(80:83));
hdr.bump_hold_time          =   33;%    bump_hold_time=bytes2float(db(84:87));
hdr.ct_hold_time            =   34;%    ct_hold_time=bytes2float(db(88:71));
hdr.ot_delay_time           =   35;%    ot_delay_time=bytes2float(db(92:95));
hdr.bump_rate_skew          =   36;%    bump_rate_skew=bytes2float(db(96:99));
hdr.targets_during_bump     =   37;%    targets_during_bump_flag=db(100);
hdr.start_time              =   38;%    start time
hdr.bump_time               =   39;%    bump time
hdr.go_cue                  =   40;%    time of the go cue
hdr.end_time                =   41;%    time the trial ended
hdr.trial_result            =   42;%    result of the trial

