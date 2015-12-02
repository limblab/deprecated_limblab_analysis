function bdf2cds(cds,bdf,varargin)
%this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %convert a bdf into a commmon data structure (cds)
    %bdf2cds(bdf,varargin) variable inputs must be strings indicating an
    %option. implemented options:
    %'array*'   -sets the array name string to *
    %'task*'    -sets the task string to *
    %labnum     -sets the lab number to the specified integer
    
    %% parse inputs into opts struct:
        opts=struct('array','Unknown',...
            'lab',1,...
            'task',[]); 
        
        if isfield(bdf.meta,'lab')
            opts.lab=bdf.meta.lab;
        end
        
        % Parse arguments
        if ~isempty(varargin)
            for i = 1:length(varargin)
                opt_str = char(varargin{i});           
                if  ischar(opt_str) && length(opt_str)>4 && strcmp(opt_str(1:4),'task')
                    task=opt_str(5:end);
                elseif ischar(opt_str) && length(opt_str)>5 && strcmp(opt_str(1:5),'array')
                    opts.array=opt_str(6:end);
                elseif isnumeric(varargin{i})
                    opts.labnum=varargin{i};    %Allow entering of the lab number               
                else 
                    error('Unrecognized option: %s', opt_str);
                end
            end
        end

    %% convert kinematics to tables
        cdskinfreq=1/cds.filter_config.kinSR;
        
        pos_labels={'t','x','y','still','good'};
        if isfield(bdf,'pos')
            [pos]=decimate_kin(bdf.pos,cds.kinFilterConfig);
            %get our good data and is still flag vectors:
            if isfield(bdf,'good_kin_data')
                goodData=uint8(interp1(pos(:,1),bdf.good_kin_data,cds.pos.t));
            else
                goodData=ones(size(pos(:,1)));
            end
            %compute whether the handle was still:
            isStill=is_still(sqrt(pos(:,2).^2+pos(:,3).^2));
            %resample at the crequency in cds.filter_config and put into cds position field
            pos=array2table([pos,isStill,goodData],'VariableNames',pos_labels);
            clear goodData
            clear isStill
            %configure labels on pos
            pos.Properties.VariableUnits={'s','cm','cm','bool','bool'};
            pos.Properties.VariableDescriptions={'time','x position in room coordinates. ','y position in room coordinates','Flag indicating whether the cursor was still','Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)'};
            pos.Properties.Description='For the robot this will be handle position, for other tasks this is whatever is fed into the encoder stream';
            cds.setField('pos',pos);
            clear pos
        end
        
        vel_labels={'t','vx','vy','still','good'};
        %dont pull data from bdf.vel as that will be poorly filtered
        if ~isempty(cds.pos)
            % get derivatives of full frequency signal
            dx = gradient(cds.pos.x,cdskinfreq);
            dy = gradient(cds.pos.y,cdskinfreq);
            vel=table(cds.pos.t,dx,dy,cds.pos.still,cds.pos.good,'VariableNames',vel_labels);
            clear dx
            clear dy
            vel.Properties.VariableUnits={'s','cm/s','cm/s','bool','bool'};
            vel.Properties.VariableDescriptions={'time','x velocity in room coordinates. ','y velocity in room coordinates','Flag indicating whether the cursor was still','Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)'};
            vel.Properties.Description='For the robot this will be handle velocity. For all tasks this is the derivitive of position';
            cds.setField('vel',vel)
            clear vel
        end
        
        acc_labels={'t','ax','ay','good'};
        %dont pull data from bdf.vel as that will be poorly filtered
        if ~isempty(cds.vel)
            % get derivatives
            ddx = gradient(cds.vel.vx,cdskinfreq);%we know the cds uses 100hz
            ddy = gradient(cds.vel.vy,cdskinfreq);
            acc=table(cds.vel.t,ddx,ddy,cds.pos.still,cds.pos.good,'VariableNames',acc_labels);
            clear ddx
            clear ddy
            acc.Properties.VariableUnits={'s','cm/s^2','cm/s^2','bool','bool'};
            acc.Properties.VariableDescriptions={'time','x acceleration in room coordinates. ','y acceleration in room coordinates','Flag indicating whether the cursor was still','Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)'};
            acc.Properties.Description='For the robot this will be handle acceleration. For all tasks this is the derivitive of velocity';
            cds.setField('acc',acc)
            clear acc
        end
    
    %% convert kinetics to table
        %check whether this is a robot type bdf or a lab1 type bdf
        if isfield(bdf,'force')
            if (isstruct(bdf.force))
                xcol=strcmpi(bdf.force.labels,'force_x');
                ycol=strcmpi(bdf.force.labels,'force_y');

                if sum(xcol+ycol)==2
                    mask=~(xcol+ycol);
                    force=double([bdf.force.data(:,1),bdf.force.data(:,xcol),bdf.force.data(:,ycol),bdf.force.data(:,mask)]);
                    force_labels={bdf.force.labels{xcol},bdf.force.labels{ycol},bdf.force.labels{mask}};
                else
                    force=double(bdf.force.data);
                    force_labels=bdf.force.labels;
                end
            else
                force=double(bdf.force);
            end

            %get the bdf force sample frequency
            if isstruct(bdf.force)
                bdf_SR=double(mode(diff(bdf.force.data(:,1))));
            else
                bdf_SR=double(mode(diff(bdf.force(:,1))));
            end
            if bdf_SR>cds.filter_config.kin_SR
                %filter and resample 
                [force]=decimate_kin(force,cds.filter_config);
            else
                %if there was no kinematic data build a time vector for forces
                if size(cds.pos,1)==0
                    if isstruct(bdf.force)
                        t_force=[bdf.force.data(1,1):cdskinfreq:bdf.force.data(end,1)]';
                    else
                        t_force=[bdf.force(1,1):cdskinfreq:bdf.force(end,1)]';
                    end
                else
                    %use the kinematic time
                    t_force=cds.pos.t;
                end
            end
            forcetable=table(t_force,'VariableNames',{'t'});
            clear t_force
            for i=1:size(force,2)
                forcetable=[forcetable,table(force,'VariableNames',force_labels(i))];
            end
            cds.setForce([forcetable,gd])
            clear forcetable
            clear force
        end
    
    %% convert EMG to table
        if isfield(bdf,'emg')
            emg=table(bdf.emg.data(:,1),'VariableNames',{'t'});
            for i=1:length(bdf.emg.emgnames)
                emg=[emg,table(bdf.emg.data(:,i+1),'VariableNames',bdf.emg.emgnames(i))];
            end
            cds.setEMG(emg);
            clear emg
        end
    %% convert lfp
        %assume that lfp has same format as emg
        if isfield(bdf,'lfp')
            lfp=table(bdf.lfp.data(:,1),'VariableNames',{'t'});
            for i=1:length(bdf.lfp.labels)
                lfp=[lfp,table(bdf.lfp.data(:,i+1),'VariableNames',bdf.lfp.labels(i))];
            end
            cds.setLFP(lfp);
            clear lfp
        end
    %% convert units
        if isfield(bdf,'units')
            times=[min(cds.pos.t):.001:max(cds.pos.t)]';
            spikes=uint8(zeros(numel(times),numel(bdf.units)+1));
            temp=-1*ones(numel(bdf.units),1);
            id=table(temp,temp,repmat({'?'},length(temp),1),'VariableNames',{'channel','unit','array'});
            clear temp
            array_labels=[];
            for i=1:numel(bdf.units)
                %convert timestamps to 1khz flag vector
                spikes(:,i)=uint8(hist(bdf.units(i).ts,times));
                %put waveforms into array
                if isfield(bdf.units(i),'waveforms')
                    waveforms{i}=table(bdf.units(i).ts,bdf.units(i).waveforms,'VariableNames',{'ts','wave'});
                else
                    waveforms{i}=[];
                end
                %put unit_id and array_id into id table
                id.channel(i)=bdf.units(i).id(1);
                id.unit(i)=bdf.units(i).id(2);
                %copy array ID if available
                if isfield(bdf.units(i),'array_ID')
                    id.array(i)={bdf.units(i).array_ID};
                end
            end
            %get sortign mask
            mask=(id.unit>0);
            cds.setSorted(table(times,spikes(:,mask),'VariableNames',{'t','spike_count'}),id(mask,:),waveforms(mask));
            cds.setUnsorted(table(times,spikes(:,~mask),'VariableNames',{'t','spike_count'}),id(~mask,:),waveforms(~mask))
            clear spikes
            clear id
            clear waveforms
            clear mask
        end
        
    %% convert words
        cds.setWords(table(bdf.words(:,2),bdf.words(:,2),'VariableNames',{'ts','word'}));
    %% try to identify task from words:
        [task,opts]=cds.getTask(task,opts);
    %% convert databursts
        cds.setDatabursts(table(bdf.databursts(:,1),cell2mat(bdf.databursts(:,2)),'VariableNames',{'ts','db'}));
    %% build a table of trial data
        cds.getTrialTable
    %% move the meta field over and check all the fields:
        if isfield(meta,'filename')
            meta.rawFilename=bef.meta.filename;
        else
            meta.filename='unknown_source_file';
        end
        meta.dataSource='bdf';
        meta.datetime=bdf.meta.datetime;
        meta.duration=bdf.meta.duration;
        meta.lab=opts.labnum;
        meta.task=task;
        
        meta.knownProblems={'Initially loaded as bdf. Some processing may be inconsistent with cds loading or not logged'};
        %put together the 'processed with' field:
        %construct the processed_with field
        if ispc
            [~,hostname]=system('hostname');
            hostname=strtrim(hostname);
            username=strtrim(getenv('UserName'));
        else
            hostname=[];
            username=[];
        end
        scriptName=mfilename('fullpath');
        gitLog=getGitLog(scriptName);
        %get the commit hash from the gitLog
        gitHash=[];
        if ~isempty(gitLog) %if we found a git repo for this script
            for i=1:length(gitLog)
                if strfind(gitLog{i},'commit ')
                    gitHash=gitLog{i}(8:end);
                    break
                end
            end
        end
        if isempty(gitHash)
            gitHash='Not in git repo';
        end
        [~,fname,~]=fileparts(scriptName);
        bdfInfo=strsplit(bdf.meta.bdf_info,' ');
        meta.processedWith={'function','date','computer name','user name','Git revision hash';...
                            bdf.Info{2},[bdf.Info{3},' ',bdf.Info{4}],'Unknown','Unknown','Not in git repo';...
                            fname,date,hostname,username,gitHash};
        if isfield(bdf.meta,'FileSepTime')
            cds.fileSepTime=bdf.meta.FileSepTime;
        else
            cds.fileSepTime=[];
        end
        %check that the meta field contains all the expected fields, and add
        %them if they are missing
        
        cds.setMeta(meta);
        clear meta
end
