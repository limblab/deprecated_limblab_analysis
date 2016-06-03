
%generates a structure session_summary, that contains descriptive metrics
%of the session in the bdf
%% general
    %source file:
    session_summary.general.source_file={bdf.meta.filename};
    %collection date:
    session_summary.general.collection_date={bdf.meta.datetime};
    %processed using:
    if isfield(bdf.meta,'processed_with')
        if ispc
            [~,hostname]=system('hostname');
            hostname=strtrim(hostname);
            username=strtrim(getenv('UserName'));
        else
            hostname=[];
            username=[];
        end
        bdf.meta.processed_with(end+1,:)={'make_session_summary',date,hostname,username};
        session_summary.general.processed_with=bdf.meta.processed_with;
    end
    %total time
    session_summary.general.total_time={bdf.meta.duration};
    %# files concatenated into the session
    if isfield(bdf.meta,'file_sep_times')
        session_summary.general.number_files={length(bdf.meta.file_sep_times)};
    end
    %known problems
    if isfield(bdf.meta,'known_problems')
        session_summary.general.known_problems=bdf.meta.known_problems;
    end
%% timing and quality metrics
    %time with bad kinematics
        if isfield(bdf,'good_kin_data')
            temp=diff(bdf.pos(:,1));
            session_summary.quality.bad_time={sum(temp(~bdf.good_kin_data))};
            session_summary.quality.percent_bad_time={100*session_summary.quality.bad_time{1}/session_summary.general.total_time{1}};
        else
            session_summary.quality.bad_time={-1};
            session_summary.quality.percent_bad_time={-1};
        end
    %time with still data
        session_summary.quality.still_pos={sum(diff(bdf.pos(is_still(sqrt(bdf.pos(:,2).^2+bdf.pos(:,3).^2)),1)))};
        session_summary.quality.still_vel={sum(diff(bdf.vel(is_still(sqrt(bdf.vel(:,2).^2+bdf.vel(:,3).^2)),1)))};
        if isfield(bdf,'force')
            session_summary.quality.still_force={sum(diff(bdf.force(is_still(sqrt(bdf.force(:,2).^2+bdf.force(:,3).^2)),1)))};
        end
%% generic trial stats
    if (isfield(bdf,'TT') && isfield(bdf,'TT_hdr'))
        %num trials
            session_summary.trials.num_trials={size(bdf.TT,1)};
        %num rewards
            session_summary.trials.rewards={sum(bdf.TT(:,bdf.TT_hdr.trial_result)==0)};
        %num aborts
            session_summary.trials.aborts={sum(bdf.TT(:,bdf.TT_hdr.trial_result)==1)};
        %num failures
            session_summary.trials.fails={sum(bdf.TT(:,bdf.TT_hdr.trial_result)==2)};
        %num incomplete
            session_summary.trials.incomplete={sum(bdf.TT(:,bdf.TT_hdr.trial_result)==3)};
        %mean trial time
            session_summary.trials.mean_time={mean(bdf.TT(:,bdf.TT_hdr.end_time)-bdf.TT(:,bdf.TT_hdr.start_time))};
        %max trial time
            session_summary.trials.max_time={max(bdf.TT(:,bdf.TT_hdr.end_time)-bdf.TT(:,bdf.TT_hdr.start_time))};
        %min trial time
            session_summary.trials.min_time={min(bdf.TT(:,bdf.TT_hdr.end_time)-bdf.TT(:,bdf.TT_hdr.start_time))};
    else
        disp('did not find a trial table in the BDF skipping generic trial stats')
    end
%% task specific data
    if isfield(bdf.meta,'task') && isfield(bdf,'TT') && isfield(bdf,'TT_hdr')
        switch bdf.meta.task
            case 'RW'
                session_summary.task.task={'RW'};
                session_summary.task.num_targets=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.num_targets)));
            case 'CO'
                session_summary.task.task={'CO'};
                session_summary.task.num_targets=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.num_targets)));
            case 'BD'
                session_summary.task.task={'BD'};
                session_summary.task.stim_freq=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.stim_freq)));
                session_summary.task.num_stim_levels={numel(unique(bdf.TT(:,bdf.TT_hdr.stim_code)))};
                session_summary.task.bump_mag=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.bump_mag)));
                session_summary.task.bump_steps=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.bump_increment)));
                session_summary.task.bump_min_angle=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.stim_freq)));
                session_summary.task.bump_max_angle=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.bump_floor)));
                session_summary.task.bump_catch_trial_rate=mat2cell(unique(bdf.TT(:,bdf.TT_hdr.bump_ceil)));
            otherwise
                warning('make_session_summary:UnrecognizedTask',['Summary parsing of task specific data not implemented for task: ',bdf.meta.task])
                disp('Skipping task specific summary')
        end
    else
        disp('Did not find a task, trial table, or header in the BDF. Skipping task specific metrics')
    end

%% unit stats
    %sorted units:
    units=unit_list(bdf,1);%gets a list of all unit fields in the bdf that aren't flagged as invalid
    %number of sorted units
        sorted_units=units(:,2)~=0;
        session_summary.units.num_sorted_units={sum(sorted_units)};
    %mean FR of sorted units
        session_summary.units.mean_unit_FR={mean(cellfun('length',{bdf.units(sorted_units).ts}))/bdf.meta.duration};
    %max FR of sorted units
        session_summary.units.max_unit_FR={max(cellfun('length',{bdf.units(sorted_units).ts}))/bdf.meta.duration};
    %min FR of sorted units
        session_summary.units.min_unit_FR={min(cellfun('length',{bdf.units(sorted_units).ts}))/bdf.meta.duration};
        
    %unsorted spikes:
    %number of unsorted units
        unsorted_units=units(:,2)==0;
        session_summary.units.num_unsorted={sum(unsorted_units)};
    %mean FR of unsorted units
        session_summary.units.mean_unsorted_FR={mean(cellfun('length',{bdf.units(unsorted_units).ts}))/bdf.meta.duration};
    %max FR of unsorted units
        session_summary.units.max_unsorted_FR={max(cellfun('length',{bdf.units(unsorted_units).ts}))/bdf.meta.duration};
    %min FR of unsorted units
        session_summary.units.min_unsorted_FR={min(cellfun('length',{bdf.units(unsorted_units).ts}))/bdf.meta.duration};
        
%% append to bdf
    bdf.meta.session_summary=session_summary;