%function [figure_list,data_struct]=BumpDirection_PDs2(folderpath,input_data)

%% set variables
    folderpath='Z:\MrT_9I4\Processed\experiment_20140903_BD_forPDs\';
    input_data.labnum=6;
    input_data.matchstring='MrT';
    figure_list=[];
    
%% load bdf 
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,input_data.matchstring,input_data.labnum);
    data_struct.file_list=file_list;
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,input_data.matchstring,0,0,0);

    % get trial table for the aggregate data
        [bdf.TT,bdf.TT_hdr]=bc_trial_table4(bdf);
        ts = 50;
        offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

        if isfield(bdf,'units')
            vt = bdf.vel(:,1);
            t = vt(1):ts/1000:vt(end);

            for i=1:length(bdf.units)
                if isempty(bdf.units(i).id)
                    %bdf.units(unit).id=[];
                else
                    spike_times = bdf.units(i).ts+ offset;%the offset here will effectively align the firing rate to the kinematic data
                    spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
                    bdf.units(i).fr = [t;train2bins(spike_times, t)]';
                end
            end
        end

        data_struct.Aggregate_bdf=bdf;

    % remove unit sorting from bdf
        bdf_multiunit=remove_sorting(bdf);
        data_struct.Multiunit_Aggregate_bdf=bdf_multiunit;
%% generate sub_bdfs for move and bump data
    % find bump periods
        bump_onset=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_time);
        bump_delay=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_delay);
        bump_hold=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_dur);
        bump_ramp=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_ramp);
        mask=bump_onset>1;
        bump_onset=bump_onset(mask);
        bump_delay=bump_delay(mask);
        bump_hold=bump_hold(mask);
        timestamps=[(bump_onset+bump_delay) , (bump_onset+bump_delay+bump_hold+2*bump_ramp)];
        
    % make sub_bdf for bump periods
        bdf_bump=get_sub_bdf(bdf,timestamps);
        data_struct.bump_bdf=bdf_bump;
        bdf_bump.TT=[];
        bdf_bump.TT_hdr=[];
    % find move periods
        cue_times=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.go_cue);
        end_times=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.end_time);
        mask=cue_times>1;
        cue_times=cue_times(mask);
        end_times=end_times(mask);
        timestamps=[cue_times,end_times];

    % make sub_bdf for move periods
        bdf_move=get_sub_bdf(bdf,timestamps);
        data_struct.move_bdf=bdf_move;
        bdf_move.TT=[];
        bdf_move.TT_hdr=[];
%% process single unit GLM
%     time=bdf_bump.units(1,1).fr(:,1);
%     pos = interp1(bdf_bump.pos(:,1), bdf_bump.pos(:,2:3), time);
%     vel = interp1(bdf_bump.vel(:,1), bdf_bump.vel(:,2:3), time);
%     data=[bdf_bump.units(1,1).fr(:,2),pos,vel];
% 
%     bootstrap_opts.reps=1000;
%     bootstrap_opts.n_samp=size(data,1);
%     bootstrap_opts.replace=true;
%     bootstrap_opts.CI_int=0.95;
%     statTest={'bootstrap',bootstrap_opts};
%     
%     model.mdl='posvel';
%     model.noisemodel='poisson';
%     method={'glm',model};
    

%     [tuning,stats,methodData]=get_unit_tuning(data,method,statTest);
%% process single unit with 'fit'
    time=bdf_bump.units(1,1).fr(:,1);
    pos = interp1(bdf_bump.pos(:,1), bdf_bump.pos(:,2:3), time);
    vel = interp1(bdf_bump.vel(:,1), bdf_bump.vel(:,2:3), time);
    data=[bdf_bump.units(1,1).fr(:,2),pos,vel];
    
    bootstrap_opts.reps=1000;
    bootstrap_opts.n_samp=size(data,1);
    bootstrap_opts.replace=true;
    bootstrap_opts.CI_int=0.95;
    statTest={'bootstrap',bootstrap_opts};

    method={'fit'}; 
    [tuning,stats,methodData]=get_unit_tuning(data,method,statTest);
%% process all units






