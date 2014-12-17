function [outstruct]=parse_for_tuning(bdf,method,varargin)
    %gets a structure of arm data and a matrix of firing rate data 
    % function call is of the form:
    %[outstruct]=parse_for_tuning(bdf,method)
    %the bdf must be a standard bdf extended with the following fields:
    %   -bdf.TT, containg the trial table
    %   -bdf.TT_hdr, containg a header structure for the trial table
    %   -bdf.units.FR, containing a 2 column matrix containing timestamps
    %   and associated firing rate or bin counts
    %   -bdf.meta.task, a string defining the task used for the dat
    %
    %Details of the function operation may be specified as follows:
    %[outstruct]=parse_for_tuning(bdf,method,key,value)
    % valid key-value pairs are:
    %   -('opts',struct), in this case the structure will contain options
    %   detailing how parse_for_tuning will implement the selected method.
    %   options not included in the options struct will be set to default
    %   values
    %   -('units',unit_list), where unit_list is a vector of integers
    %   specifying which units to generate FR series for
    
    %Details of the options struct:
    %options struct may contain the following fields:
    %   -lags: a vector containing the specific lags in ms to compute 
    %       kinetics for. positive lags indicate kinetic data preceding the
    %       current point, negative lags indicate kinetic data following the
    %       current point
    %   -comptute_pos_pds: flag that will be passed to the output struct
    %   -comptute_vel_pds: flag that will be passed to the output struct
    %   -comptute_acc_pds: flag that will be passed to the output struct
    %   -comptute_force_pds: flag that will be passed to the output struct
    %   -data_offset: offset in ms between kinetic and Firing rate data. Used to
    %       account for transmission latency. negative offset for FR data after
    %       kinetic data (sensory), positive offset for FR leading kinetic
    %       data (motor)
    %   -data_window: time in ms to include in output struct. used for
    %       methods that sample the mean kinematics and FR around some point of
    %       interest, such as target onset or peak velocity
    
    %the output structure outstruct has the following fields:
    %   -armdata, which is a cell array formatted for the calculate tuning
    %       function. 
    %   -FR, which is a matrix of firing rates for each unit
    %   -unitlist, which is the ordered list of units in the FR matrix
    %outstruct.armdata has cells each containing a structure with the 
    %following fields:
    %   -data, a column matrix of data points, each row corresponding to an
    %   observation
    %   -name, a string defining the type of data e.g. 'pos', 'vel',
    %   'force'
    %   -num_lags, an integer specifying the number of lags included in the
    %   data field. 
    %   -num_base_col, an integer telling how many data columns there are
    %   before including additional lags
    %   
    
    %% sanity check BDF:
        if ~isfield(bdf.meta,'task')
            error('parse_for_tuning:NoTaskField','The BDF does not have the bdf.meta.task field indicating what task the data came from')
        end
        if ~isfield(bdf,'TT')
            error('parse_for_tuning:NoTrialTableField','The BDF does not have the bdf.TT field containing the trial table')
        end
        if ~isfield(bdf,'TT_hdr')
            error('parse_for_tuning:NoTrialTableHeaderField','The BDF does not have the bdf.TT_hdr field containing the trial table header')
        end
        if ~isfield(bdf.units,'FR')
            error('parse_for_tuning:NoFiringRateField','The BDF does not have the bdf.units.FR field containing the firing rate')
        end
        
    
    %% set up optional inputs to the function
    method_opts=[];
    which_units=[1:length(bdf.units)];
    for i=1:length(varargin)
        switch varargin{i}
            case 'opts'
                method_opts=varargin{i+1};
            case 'units'
                which_units=varargin{i+1};
            otherwise
                error('Parse_for_tuning:UnrecognizedFlag',strcat('The ',num2str(i+2),'input is not a valid input'))
        end
    end
    
    %% set generic variables for parsing by the various methods from task specific data 

    switch bdf.meta.task
        %this switch is to implement custom mappings to the standard
        %elements of the armdata output. The canonical example is the
        %isometric task where the vel and acc fields are mapped to the
        %first and second derivitive of force if those derivitives exist in
        %the bdf, and the postition maps to an empty matrix
        case 'isometric'
            pos=[];
            acc=[];
            if isfield(bdf,'dfdt')
                vel=bdf.dfdt;
            else
                vel=[];
            end
            if isfield(bdf,'dfdtdt')
                vel=bdf.dfdtdt;
            else
                vel=[];
            end
            force=bdf.force;
        otherwise
            if (strcmp(bdf.meta.task,'RW') || strcmp(bdf.meta.task,'RW_chaotic') || strcmp(bdf.meta.task,'CO') || strcmp(bdf.meta.task,'CO_bump') )
                pos=bdf.pos;
                vel=bdf.vel;
                acc=bdf.acc;
                if isfield(bdf,'force')
                    force=bdf.force;
                else
                    force=[];
                end
            else
                error('Parse_for_tuning:UnrecognizedTask','Parsing for the task specified in bdf.meta.task is not implemented in parse_for_tuning. Check the task code is correct')
            end
    end

    %% do generic processing common to all methods:
        %compute data for lags
            pos_lag_data=[];
            vel_lag_data=[];
            acc_lag_data=[];
            force_lag_data=[];
            if isfield(method_opts,'lags')
                num_lags=length(method_opts.lags);
            else
                num_lags=0;
            end
            if num_lags>0
                for i=1:length(method_opts.lags)
                    tmp=bdf.pos(:,1)-method_opts.lags(i);
                    pos_lag_data=[pos_lag_data,interp1(pos(:,1),pos(:,2:end),tmp)];
                    vel_lag_data=[vel_lag_data,interp1(vel(:,1),vel(:,2:end),tmp)];
                    acc_lag_data=[acc_lag_data,interp1(acc(:,1),acc(:,2:end),tmp)];
                    force_lag_data=[force_lag_data,interp1(force(:,1),force(:,2:end),tmp)];
                end
            end
        % set up offset and window
            if isfield(method_opts,'offset')
                data_offset=method_opts.data_offset;
            else
                data_offset=0;
            end
            if isfield(method_opts,'window')
                data_window=method_opts.data_window;
            else
                data_window=100;
            end
        % get firing rate timeseries to use in parsing kinematic data
            FR_timeseries=bdf.units(which_units(1)).FR(:,1);
        % get sequence of target onsets, trial starts, and trial ends,
        % go-cues etc
            switch bdf.meta.task
                case 'RW'
                    trial_starts=bdf.TT(:,bdf.TT_hdr.trial_start);
                    trial_ends=bdf.TT(:,bdf.TT_hdr.trial_end);

                    num_targets=bdf.TT(:,2);
                    target_onsets=bdf.TT(:,7+num_targets:7+2*num_targets-1);
                    target_onsets=reshape(target_onsets',(size(target_onsets,1)*size(target_onsets,2)),1);%make it a column vector
                    mask=target_onsets>1;%exclude reaches that weren't done (time is -1 in trial table)
                    target_onsets=target_onsets(mask);

                    go_cues=target_onsets;
                    bump_times=[];
                case 'RW_chaotic'
                    trial_starts=bdf.TT(:,bdf.TT_hdr.trial_start);
                    trial_ends=bdf.TT(:,bdf.TT_hdr.trial_end);

                    num_targets=bdf.TT(:,2);
                    target_onsets=bdf.TT(:,7+num_targets:7+2*num_targets-1);
                    target_onsets=reshape(target_onsets',(size(target_onsets,1)*size(target_onsets,2)),1);%make it a column vector
                    mask=target_onsets>1;%exclude reaches that weren't done (time is -1 in trial table)
                    target_onsets=target_onsets(mask);

                    go_cues=target_onsets;
                    bump_times=[];
                case 'CO'
                    trial_starts=bdf.TT(:,bdf.TT_hdr.trial_start);
                    trial_ends=bdf.TT(:,bdf.TT_hdr.trial_end);
                    target_onsets=bdf.TT(:,bdf.TT_hdr.trial_start);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    bump_times=[];
                case 'CO_bump'
                    trial_starts=bdf.TT(:,bdf.TT_hdr.trial_start);
                    trial_ends=bdf.TT(:,bdf.TT_hdr.trial_end);
                    target_onsets=bdf.TT(:,bdf.TT_hdr.trial_start);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    bump_times=bdf.TT(:,bdf.TT_hdr.bump_time);
                case 'isometric'
                    trial_starts=bdf.TT(:,bdf.TT_hdr.trial_start);
                    trial_ends=bdf.TT(:,bdf.TT_hdr.trial_end);
                    target_onsets=bdf.TT(:,bdf.TT_hdr.trial_start);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    bump_times=bdf.TT(:,bdf.TT_hdr.bump_time);
            end
    %% perform method specific selection of times of interest
        switch method
            case 'continuous'
                %viable method_opts for the continuous method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -data_offset

                % interpolate to firing rate time points to the firing rate
                % timeseries with the specified offset
                pos=interp1(pos(:,1),[pos(:,2:end),pos_lag_data],FR_timeseries);
                vel=interp1(vel(:,1),[vel(:,2:end),vel_lag_data],FR_timeseries);
                acc=interp1(acc(:,1),[acc(:,2:end),acc_lag_data],FR_timeseries);
                force=interp1(force(:,1),[force(:,2:end),force_lag_data],FR_timeseries);
                
            case 'peak dt'
                %viable method_opts for the peak dt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -data_offset
                %   -data_window

                % prune FR_timeseries to time windows around peaks in the
                % speed (euclidean norm of vel variable) during trials
                
                %compute speed
                    spd=sqrt(sum(vel.^2));
                    [B,A]=butter(3,.1,'low');
                    sspd=filtfilt(B,A,spd);
                %get number of targets
                    num_targets=size(target_onsets,1);
                %loop through targets finding the speed peaks
                    T=zeros(num_targets-1,1);%excludes the last point, which will be dealt with outside the loop
                    for i=1:length(target_onsets)-1
                        %just find first peak in speed after target appearance
                        inds=find(bdf.pos(:,1)>target_onsets(i) & bdf.pos(:,1)<target_onsets(i+1));
                        [maxVal,maxInd]=extrema(sspd(inds));
                        if isempty(maxInd)
                            warning('testAllTuning:NoMaxVel',strcat('Could not find a speed maxima for target onset# ',num2str(i)))
                            disp('skipping target')
                            continue
                        end
                        if maxInd(1)==1 & length(maxInd)>1
                            T(i)=inds(1)+maxInd(2);
                        else
                            T(i)=inds(1)+maxInd(1);
                        end

                    end
                    %deal with last point:
                    i=i+1;%adds a single index to the array for the last point
                    test_end=bdf.TT(bdf.TT(:,7+2*num_targets(end)-1)==target_onset(i),7+2*num_targets(end));%;locate the correct row
                    if ~isempty(test_end)
                        inds=find(bdf.pos(:,1)>targetOn(i) & bdf.pos(:,1)<test_end);
                        [maxVal,maxInd]=extrema(sspd(inds));
                        if isempty(maxInd)
                            warning('testAllTuning:NoMaxVel',strcat('Could not find a velocity maxima for target onset# ',num2str(i)))
                            T=T(1:end-1);
                            disp('skipping target')
                        elseif maxInd(1)==1 & length(maxInd)>1
                            T(i)=inds(1)+maxInd(2);
                        else
                            T(i)=inds(1)+maxInd(1);
                        end
                    end
                %get firing rates in windows around the peak speed with the
                %appropriate offset
                sample_times=[];
                for i=1:length(T)
                    mask=FR_timeseries > (T(i)+data_offset-data_window) && (FR_timeseries+data_offset)<T(i);
                    sample_times=[sample_times;FR_timeseries(mask)];
                end
                % interpolate to firing rate time points to the firing rate
                % timeseries with the specified offset
                pos=interp1(pos(:,1),[pos(:,2:end),pos_lag_data],sample_times);
                vel=interp1(vel(:,1),[vel(:,2:end),vel_lag_data],sample_times);
                acc=interp1(acc(:,1),[acc(:,2:end),acc_lag_data],sample_times);
                force=interp1(force(:,1),[force(:,2:end),force_lag_data],sample_times);
                %get matrix of FR data 
                FR=-1*ones(length(bdf.units(1).FR),length(which_units));
                for i=1:length(bdf.units)
                    FR(:,i)=interp1(bdf.units(which_units(i)).FR,(sample_times-data_offset));
                end
            case 'peak force'
                %viable method_opts for the peak dt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -data_offset
                %   -data_window

            case 'tgt onset'
                %viable method_opts for the peak dt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -data_offset
                %   -data_window

            case 'trials'
                %viable method_opts for the peak dt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -data_offset

            case 'bumps'
                %viable method_opts for the peak dt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -data_offset

            otherwise
                 error('Parse_for_tuning:UnrecognizedMethod','The given method is not a valid parsing type')
        end
    
    %% add data to the output struct 
        %compose armdata cell array for position
        outstruct.armdata{1}.data=pos;
        outstruct.armdata{1}.name='pos';
        outstruct.armdata{1}.num_lags=num_lags;
        outstruct.armdata{1}.num_base_cols=size(pos,2)-1;
        if isfield(method_opts,'compute_pos_pds')
            outstruct.armdata{1}.doPD=method_opts.compute_pos_pds;
        else
            outstruct.armdata{1}.doPD=1;
        end
        %compose armdata cell array for velocity
        outstruct.armdata{2}.data=vel;
        outstruct.armdata{2}.name='vel';
        outstruct.armdata{2}.num_lags=num_lags;
        outstruct.armdata{2}.num_base_cols=size(vel,2)-1;
        if isfield(method_opts,'compute_vel_pds')
            outstruct.armdata{2}.doPD=method_opts.compute_vel_pds;
        else
            outstruct.armdata{2}.doPD=1;
        end
        %compose armdata cell array for acceleration
        outstruct.armdata{3}.data=acc;
        outstruct.armdata{3}.name='acc';
        outstruct.armdata{3}.num_lags=num_lags;
        outstruct.armdata{3}.num_base_cols=size(acc,2)-1;
        if isfield(method_opts,'compute_acc_pds')
            outstruct.armdata{3}.doPD=method_opts.compute_acc_pds;
        else
            outstruct.armdata{3}.doPD=1;
        end
        %compose armdata cell array for force
        outstruct.armdata{4}.data=force;
        outstruct.armdata{4}.name='force';
        outstruct.armdata{4}.num_lags=num_lags;
        outstruct.armdata{4}.num_base_cols=size(force,2)-1;
        if isfield(method_opts,'compute_force_pds')
            outstruct.armdata{4}.doPD=method_opts.compute_force_pds;
        else
            outstruct.armdata{4}.doPD=0;
        end
        %compose FR field
        outstruct.FR=FR;
        %compose unit list field
        outstruct.which_units=which_units;
end