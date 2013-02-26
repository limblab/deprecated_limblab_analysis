%% testFS.m
% Script to demonstrate use of the databurst fetch and scrub utility
% dbFetchAndScrub()
% Create the format for the databurst below; assign header names and
% offsets in make_hdr.m
%
% testFS.m
%
% Example showing usage of function FetchAndScrub()
% This example uses the extracted databursts to generate live psychometric
% plots per function bc_psychometric_curve_stim_live()
%
% The psychometric plot function returns handles for the lines drawn, so
% they can be deleted as they age; the code here keeps only the last
% KEEPCOUNT lines.

global ghist;	% history of parameter estimates
global idxg;	% current index to parameter history
idxg=1;
ghist = zeros(200,16);
%% Set up the string for format conversion of the databurst. Byte count must
% be the first byte.
%
%   b=byte
%   h=halfword (16 bits)
%   w=word (32 bits)
%   f=float (64 bits)
close all
dbfmt = [...
    'b' ...    % numbytes
    'b'...     % db_+version
    'b'...     % two
    'b'...     % b
    'b'...     % c
    'b'...     % behavior_version_maj
    'b'...     % behavior_version_minor
    'b'...     % behavior_version_micro1
    'b'...     % behavior_version_micro2
    'ffff'...   % target_angle
    'ffff'...   % bump_dir
    'b'...     % random_tgt_flag
    'ffff'...   % tgt_dir_floor
    'ffff'...   % tgt_dir_ceil
    'ffff'...   % bump_mag
    'ffff'...   % bump_dur
    'ffff'...   % bump_ramp
    'ffff'...   % bump_floor
    'ffff'...   % bump_ceil
    'b'...     % stim_trial_flag
    'b'...     % training_trial_flag
    'ffff'...   % training_trial_freq
    'ffff'...   % stim_freq
    'b'...     % recenter_cursor_flag
    'ffff'...   % tgt_radius
    'ffff'...   % tgt_size
    'ffff'...   % intertrial_time
    'ffff'...   % penalty_time
    'ffff'...   % bump_hold_time
    'ffff'...   % ct_hold_time
    'ffff'...   % bump_delay_time
    'b'...     % targets_during_bump
    'ffff'...   % bump_increment
    'b'...     % primary_target_flag
    ];
tt_hdr = make_hdr();
%% Assign constants, initialize arrays, & run
MAXCOUNT=1000;
KEEPCOUNT = 1; % Discard lines older than the last KEEPCOUNT lines
LINELIST=zeros(MAXCOUNT,8);
TT_HDR_SIZE = 40;
jj=1; % counter for elements in each databurst
kk = 1; % counter for
tt1=zeros(TT_HDR_SIZE,1);
[tt Pending] = dbFetchAndScrub('open',dbfmt);
tt1(1:size(tt,1),jj:jj+size(tt,2)-1)= tt;
for ii=1:MAXCOUNT
    jj=size(tt1,2)+1;
    tt1(:,jj)=zeros(TT_HDR_SIZE,1);
    [tt, Pending] = dbFetchAndScrub('update',dbfmt, Pending, tt_hdr);
    tt1(1:size(tt,1),jj:jj+size(tt,2)-1)= tt;
    %% Now generate psychometric plots. Not every handle is populated at each call.    
    handle_list = bc_psychometric_curve_stim_live(tt1', tt_hdr,0,0,0);
    LINELIST(ii,1:numel(handle_list)) = handle_list;
    % Only keep the last KEEPCOUNT plots
    if ii > KEEPCOUNT
        tmp = LINELIST(ii-KEEPCOUNT,:);
        for zz=1:size(tmp,2)
            if ishandle(tmp(zz)) && tmp(zz)>0
                delete(tmp(zz));
            end
        end
    end
    M(ii)=getframe(gcf);	% this array can be used to build a movie per:
							% aivo=avifile(filename);avio=M(ii);....;avio=close(avio);
end
