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

tt = zeros(num_trials-1, 42);

disp('composing trial table assuming db v 2')
disp(strcat('db version:',num2str(bdf.databursts{1,2}(2))))
disp('If actual db version does not match assumed version, fix the trial table code')

for trial = 1:num_trials-1
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
%  * bytes 9-12:    float		=> target angle
%  * bytes 13-16:   float		=> bump direction
%  * byte  17:      uchar		=> random target flag
%  * bytes 18-21:   float		=> target floor (minimum angle(deg) target can take in random target assignment)
%  * bytes 22-25:   float		=> target ceiling (maximum angle(deg) target can take in random target assignment)
%  * bytes 26-29:   float		=> bump magnitude
%  * bytes 30-33:   float		=> bump duration
%  * bytes 34-37:   float		=> bump ramp
%  * bytes 38-41:   float		=> bump floor (minimum angle(deg) bump can take in random target assignment)
%  * bytes 42-45:   float		=> bump ceiling (maximum angle(deg) bump can take in random target assignment)
%  * byte  46:      uchar		=> stim trial flag
%  * bytes 47-50:   float		=> training trial frequency
%  * bytes 51-54:   float		=> stimulation probability 
%  * byte  55:      uchar		=> recenter cursor flag
%  * bytes 56-59:   float		=> target radius
%  * bytes 60-63:   float		=> target size
%  * bytes 64-67:   float		=> intertrial time
%  * bytes 68-71:   float		=> penalty time
%  * bytes 72-75:   float		=> bump hold time
%  * bytes 76-79:   float		=> center hold time
%  * bytes 80-83:   float		=> outer target delay time
%  * byte  84:      uchar		=> show target during bump
%  * bytes 85-88:   float		=> bump incriment
%  * byte  89:      uchar		=> is primary target
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

        target_angle=bytes2float(db(10:13));%13
        bump_dir=bytes2float(db(14:17));%14
        random_tgt_flag=db(18);%15
        tgt_dir_floor=bytes2float(db(19:22));%16
        tgt_dir_ceil=bytes2float(db(23:26));%17
        bump_mag=bytes2float(db(27:30));%18
        bump_dur=bytes2float(db(31:34));%19
        bump_ramp=bytes2float(db(35:38));%20
        bump_floor=bytes2float(db(39:42));%22
        bump_ceil=bytes2float(db(43:46));%23
        stim_trial_flag=db(47);%25
        training_trial_flag=(48);%26
        training_trial_freq=bytes2float(db(49:52));%27
        stim_freq=bytes2float(db(53:56));%28
        recenter_cursor_flag=db(57);%29
        tgt_radius=bytes2float(db(58:61));%30
        tgt_size=bytes2float(db(62:65));%31
        intertrial_time=bytes2float(db(66:69));
        penalty_time=bytes2float(db(70:73));
        bump_hold_time=bytes2float(db(74:77));
        ct_hold_time=bytes2float(db(78:81));
        bump_delay_time=bytes2float(db(82:85));
        targets_during_bump=db(86);
        bump_increment=db(87:90);
        primary_target_flag=db(91);
        

        temp=         [     numbytes,                   db_version,                 two,                        b,                          c, ...%5
                            behavior_version_maj,       behavior_version_minor,     behavior_version_micro1,    behavior_version_micro2,    target_angle,...%5
                            bump_dir,                   random_tgt_flag,            tgt_dir_floor,              tgt_dir_ceil,               bump_mag,... %5
                            bump_dur,                   bump_ramp,                  bump_floor,                 bump_ceil,                  stim_trial_flag,...
                            training_trial_flag,        training_trial_freq,        stim_freq,                  recenter_cursor_flag,       tgt_radius,...
                            tgt_size,                   intertrial_time,            penalty_time,               bump_hold_time,             ct_hold_time,...
                            bump_delay_time,            targets_during_bump,        bump_increment,             primary_target_flag,        trial_result,...
                            start_time,                 bump_time,                  go_cue,                     end_time  ];
        
        disp(size(temp))
         tt(trial,:)=temp;
end



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
hdr.start_time              =   37;%    start time
hdr.bump_time               =   38;%    bump time
hdr.go_cue                  =   39;%    time of the go cue
hdr.end_time                =   40;%    time the trial ended
hdr.trial_result            =   41;%    result of the trial

