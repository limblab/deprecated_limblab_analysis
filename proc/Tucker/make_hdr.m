function hdr = make_hdr()
%build hdr object with associated column numbers

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
hdr.bump_angle              =   11;%    bump_dir=bytes2float(db(19:22));%14
hdr.rand_tgt_flag           =   12;%    random_tgt_flag=db(23);%15
hdr.tgt_floor               =   13;%    tgt_dir_floor=bytes2float(db(24:27));%16
hdr.tgt_ceil                =   14;%    tgt_dir_ceil=bytes2float(db(28:31));%17
hdr.bump_mag                =   15;%    bump_mag=bytes2float(db(32:35));%18
hdr.bump_dur                =   16;%    bump_dur=bytes2float(db(36:39));%19
hdr.bump_ramp               =   17;%    bump_ramp=bytes2float(db(40:43));%20
hdr.bump_floor              =   18;%    bump_floor=bytes2float(db(45:48));%22
hdr.bump_ceil               =   19;%    bump_ceil=bytes2float(db(49:52));%23
hdr.stim_trial              =   20;%    stim_trial_flag=db(57);%25
hdr.training_trial          =   21;%    training_trial_flag=(58);%26
hdr.training_freq           =   22;%    training_trial_freq=bytes2float(db(59:62));%27
hdr.stim_freq               =   23;%    stim_freq=bytes2float(db(63:66));%28
hdr.recenter_cursor         =   24;%    recenter_cursor_flag=db(67);%29
hdr.tgt_radius              =   25;%    tgt_radius=bytes2float(db(68:71));%30
hdr.tgt_size                =   26;%    tgt_size=bytes2float(db(72:75));%31
hdr.intertrial_time         =   27;%    intertrial_time=bytes2float(db(76:79));
hdr.penalty_time            =   28;%    penalty_time=bytes2float(db(80:83));
hdr.bump_hold_time          =   29;%    bump_hold_time=bytes2float(db(84:87));
hdr.ct_hold_time            =   30;%    ct_hold_time=bytes2float(db(88:71));
hdr.bump_delay              =   31;%    bump_delay_time=bytes2float(db(82:85));
hdr.targets_during_bump     =   32;%    targets_during_bump=db(86);
hdr.bump_increment          =   33;%    bump_increment=db(87:90);
hdr.primary_target          =   34;%    primary_target_flag=db(91);
hdr.trial_result            =   35;%    result of the trial
hdr.start_time              =   36;%    start time
hdr.bump_time               =   37;%    bump time
hdr.go_cue                  =   38;%    time of the go cue
hdr.end_time                =   39;%    time the trial ended
hdr.stim_code               =   40;%    
end
