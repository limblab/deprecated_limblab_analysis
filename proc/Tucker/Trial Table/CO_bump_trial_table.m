function [tt, hdr]= CO_bump_trial_table(bdf)
% BC_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the bump choice trials in BDF. In addition to the trial
%                  table, this function returns a header struct that maps
%                  the column number of each field
%


words = bdf.words;
db_times = cell2mat( bdf.databursts(:,1) );

result_codes = 'RAFI------------';

bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';

word_start = hex2dec('1F');
start_words = words(words(:,2) == word_start, 1);

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);%hex2dec('f0') is a bitwise mask for the leading bit
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

word_stim=hex2dec('60');
stim_words=words( bitand(hex2dec('f0'),words(:,2)) == word_stim,1);
stim_codes=words( bitand(hex2dec('f0'),words(:,2)) == word_stim,2);


burst_times=zeros(length(bdf.databursts),1);
for i=1:length(burst_times)
    burst_times(i)=bdf.databursts{i,1};
end
num_trials = length(burst_times);
disp(strcat('Found: ',num2str(num_trials),' trials'))

disp('composing trial table assuming db v 0')
disp(strcat('db version:',num2str(bdf.databursts{2,2}(2))))
disp('If actual db version does not match assumed version, fix the trial table code')



tt = zeros(num_trials-1, 38);
skip_counter=0;
for trial = 1:num_trials-1
    
        start_time = start_words(trial);
        if length(start_words)>trial
            next_trial_start = start_words(trial+1);
        else
            %if we have the last trial of the session, just use all the
            %remaining data
            next_trial_start = start_words(trial)+100;
        end
        
        burstindex= find((burst_times > start_time) & (burst_times < next_trial_start));
        if length(burstindex)>1 
            %if we have two start times kill the burst index. this is
            %usually the result of concatenating two files where the trial
            %did not end properly
            burstindex=[];
        end
            
        if ( isempty(burstindex) ) %if we don't have a databurst, or the databurst is empty
            skip_counter=skip_counter+1;
            continue
        else
            if isnan(bdf.databursts{burstindex,2})
                skip_counter=skip_counter+1;
                continue
            else
                db = bdf.databursts{ burstindex,2};
            end
        end
        trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
        if isempty(trial_end_idx)
            end_time = next_trial_start - .001;
            trial_result = -1;
        else
            end_time = end_words(trial_end_idx);
            trial_result = mod(end_codes(trial_end_idx),32); %0 is reward, 1 is abort, 2 is fail, and 3 is incomplete (incomplete should never happen)
        end

        idx = find(all_bumps > start_time & all_bumps < end_time, 1);
        if ~isempty(idx)
            bump_time = all_bumps(idx);
        else
            bump_time = -1;
        end

        idx = find(go_cues > start_time & go_cues < end_time, 1);
        if ~isempty(idx)
            go_cue = go_cues(idx);
        else
            go_cue = -1;
        end
        
        idx = find(stim_words > start_time & stim_words < end_time,1);
        if ~isempty(idx)
            stim_code = bitand(hex2dec('0f'),stim_codes(idx));%hex2dec('0f') is a bitwise mask for the trailing bit of the word
        else
            stim_code = -1;
        end
% 

% * Version 1 (0x01)
%  * ----------------
%  * byte  0:		uchar		=> number of bytes to be transmitted
%  * byte  1:		uchar		=> version number (in this case 0)
%  * byte  2-4:	uchar		=> task code 'C' 'O' 'B'
%  * bytes 5-6:	uchar       => version code
%  * byte  7-8:	uchar		=> version code (micro)
%  * bytes 9-12:  float		=> target angle
%  * byte	 13:	uchar		=> random target flag
%  * bytes 14-17:	float		=> target floor (minimum angle(deg) target can take in random target assignment)
%  * bytes 18-21:	float		=> target ceiling (maximum angle(deg) target can take in random target assignment)
%  * bytes 22-25:	float		=> target incriment(deg)
%  * bytes 26-29: float		=> bump magnitude
%  * bytes 30-33: float		=> bump direction
%  * bytes 34-37: float		=> bump duration
%  * bytes 38-41: float		=> bump ramp

%  * byte  42:	uchar		=> stim trial flag
%  * bytes 43-46: float		=> stimulation probability 
%  * bytes 47-50: float		=> target radius
%  * bytes 51-54: float		=> target size
%  * bytes 55-58: float		=> intertrial time
%  * bytes 59-62: float		=> penalty time
%  * bytes 63-66: float		=> bump hold time
%  * bytes 67-70: float		=> center hold time
%  * bytes 71-74: float		=> bump delay time
%  * byte  75:	uchar		=> flag for whether or not the cursor is hidden during movement
%  * bytes 76-79: float		=> radius from center within which the cursor will be hidden
%  */

        numbytes=db(1);
        db_version=db(2);
        C=db(3);
        O=db(4);
        B=db(5);
        behavior_version_maj=db(6);
        behavior_version_minor=db(7);
        behavior_version_micro1=db(8);
        behavior_version_micro2=db(9);

        target_angle=bytes2float(db(10:13));
        random_target=db(14);
        target_floor=bytes2float(db(15:18));
        target_ceiling=bytes2float(db(19:22));
        target_incr=bytes2float(db(23:26));
        bump_mag=bytes2float(db(26:30));
        bump_dir=bytes2float(db(31:34));
        bump_duration=bytes2float(db(35:38));
        bump_ramp=bytes2float(db(39:42));

        stim_flag=db(43);
        stim_prob=bytes2float(db(44:47));
        target_radius=bytes2float(db(48:51));
        target_size=bytes2float(db(52:55));
        intertrial=bytes2float(db(56:59));
        penalty_time=bytes2float(db(60:63));
        bump_hold_time=bytes2float(db(64:67));
        center_hold_time=bytes2float(db(68:71));
        bump_delay=bytes2float(db(72:75));
        hidden_cursor=db(76);
        hidden_cursor_radius=bytes2float(db(77:80));

        
        temprow =  [     numbytes,                  db_version,                 C,                          O,                          B, ...%5
                         behavior_version_maj,      behavior_version_minor,     behavior_version_micro1,    behavior_version_micro2,    target_angle,...%5
                         random_target,             target_floor,               target_ceiling,             target_incr,                bump_mag,...
                         bump_dir,                  bump_duration,              bump_ramp,                  bump_floor,                 bump_ceiling,...
                         bump_incr,                 stim_flag,                  stim_prob,                  target_radius,              target_size,...
                         intertrial,                penalty_time,               bump_hold_time,             center_hold_time,           bump_delay,...
                         hidden_cursor,             hidden_cursor_radius,       trial_result,               start_time,                 bump_time,...
                         go_cue,                    end_time,                   stim_code];
        if ~isempty(find(abs(temprow)>100000000000))
            skip_counter=skip_counter+1;
            continue
        else
            tt(trial-skip_counter,:)=temprow;
        end
end

disp(strcat('Found ',num2str(skip_counter),' bad databursts. Trials associated with these databursts were skipped'))

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
hdr.tgt_angle               =   10;%    target_angle=round((180/3.1415)*bytes2float(db(15:18)));%13
hdr.rand_tgt_flag           =   11;%    random_tgt_flag=db(23);%15
hdr.tgt_floor               =   12;%    tgt_dir_floor=bytes2float(db(24:27));%16
hdr.tgt_ceil                =   13;%    tgt_dir_ceil=bytes2float(db(28:31));%17
hdr.tgt_incr                =   14;%    target incriment(deg)
hdr.bump_mag                =   15;%    bump_mag=bytes2float(db(32:35));%18
hdr.bump_angle              =   16;%    bump_dir=bytes2float(db(19:22));%14
hdr.bump_dur                =   17;%    bump_dur=bytes2float(db(36:39));%19
hdr.bump_duration           =   18;
hdr.bump_ramp               =   19;%    bump_ramp=bytes2float(db(40:43));%20
hdr.bump_floor              =   20;%    bump_floor=bytes2float(db(45:48));%22
hdr.bump_ceil               =   21;%    bump_ceil=bytes2float(db(49:52));%23
hdr.bump_incr               =   22;
hdr.stim_trial              =   23;%    stim_trial_flag=db(57);%25
hdr.stim_freq               =   23;%    stim_freq=bytes2float(db(63:66));%28
hdr.tgt_radius              =   24;%    tgt_radius=bytes2float(db(68:71));%30
hdr.tgt_size                =   25;%    tgt_size=bytes2float(db(72:75));%31
hdr.intertrial_time         =   26;%    intertrial_time=bytes2float(db(76:79));
hdr.penalty_time            =   27;%    penalty_time=bytes2float(db(80:83));
hdr.bump_hold_time          =   28;%    bump_hold_time=bytes2float(db(84:87));
hdr.ct_hold_time            =   29;%    ct_hold_time=bytes2float(db(88:71));
hdr.bump_delay              =   30;%    bump_delay_time=bytes2float(db(82:85));
hdr.hidden_cursor           =   31;
hdr.hidden_cursor_radius    =   32;
hdr.trial_result            =   33;%    result of the trial
hdr.start_time              =   34;%    start time
hdr.bump_time               =   35;%    bump time
hdr.go_cue                  =   36;%    time of the go cue
hdr.end_time                =   37;%    time the trial ended
hdr.stim_code               =   38;%    the code for the stimulus with the base stim word removed


