 function [sub_bdf]=get_sub_bdf(bdf,timestamps)
    %takes in the bdf and the start and end times for the block to be used
    %from each trial. times should be a nx2 matrix where n is the number of
    %events in the session. The first column should be the start time of 
    %the event of interest within the trial specified by the row. the 
    %second column should be the ending time of the event. If there is no 
    %event of interest during a given trial the first column should contain
    %zero

    %create the sub_bdf structure
    sub_bdf.meta=bdf.meta;
    sub_bdf.pos=[];
    sub_bdf.vel=[];
    sub_bdf.acc=[];
    sub_bdf.raw=[];
    sub_bdf.words=[];
    sub_bdf.databursts=[];
    sub_bdf.raw='This is a sub_bdf, not a complete data session. Find the original bdf to see the raw data';
    if isfield(bdf,'force')
        sub_bdf.force=[];
    end
    if isfield(bdf,'targets')
        sub_bdf.targets.centers=[];
    end
    if isfield(bdf,'units')
        for i=1:length(bdf.units)
            sub_bdf.units(i).id=bdf.units(i).id;
        end
    end
    %set up a kinematic tracker to keep count of how many points we have in
    %each kinematic set
    kincount=0;

    %create a log of the kinematic discontinuities 
    sub_bdf.discontinuity.time=[];
    sub_bdf.discontinuity.index=[];
    %clear neural data in each of the units
    if isfield(bdf,'units')
        for unit=1:length(bdf.units)
            %fill units with zero matrix so we don't have to reallocate. 
            %Trailing zeros will be pruned at the end of the function
            sub_bdf.units(unit).ts=zeros(length(bdf.units(unit).ts),1);
            if isfield(bdf.units(unit),'fr')
                %if we have a bdf extended so that the units include the firing
                %rates, null the firing rates as well
                sub_bdf.units(unit).fr=[];
            end
        end
        %set up a tracker to keep count of how many spikes we actually have
        %in each unit. This allows for preallocated memory, rather than
        %increasing vectors with each loop iteration
        unitcount=zeros(length(bdf.units),1);
        %if the BDF already has firing rates computed and added to the
        %structure, then create a count so that we can deal with firing
        %rates as well
        if isfield(bdf.units(1),'fr')
            fr_count=zeros(length(bdf.units),1);
        end
    end

    %clear the words
    sub_bdf.words=[];
    
    %find the kinematic sample rate. this will be used for a sanity check
    %on the kinematic sub-samples later
    kin_sr=mean(diff(bdf.pos(:,1)));% this is the time of a single sample, not really the rate
    %initialize variables for first pass through loop
    ind=[0,0];
    timeshift=0;
    %loop through the timestamps
    for trial=1:length(timestamps)
        if ~(timestamps(trial,1)==0)
            
            %%%%%%%%% kinematics %%%%%%%%%%%%%%%%%
            %find kinematics data between trial start and end times 
            i1 = find(  (bdf.pos(:,1) > timestamps(trial,1))   ,1);     
            i2 = find(  (bdf.pos(:,1) > timestamps(trial,2))   ,1)-1; 
            
            if i1<ind(2)
                %we have a problem with how our trial times are being
                %computed
                warning('get_sub_bdf:BAD_TRIAL_TIMING',...
                    strcat('new go cue for trial #: ',num2str(trial),...
                    ' is earlier than the end of the previous trial.'))
            end
            
            ind(1)=i1;
            ind(2)=i2;
            num_ind=diff(ind)+1;%how many kinematic points are between the timestamps
            
            if abs((num_ind)-(round(diff(timestamps(trial,:))/kin_sr)))>1
                %if the expected number of points and the found number of
                %points are different by more than 1 points. 1 points is
                %reasonable since we may include or exclude and extra point
                %due to alignment of the window on the data samples
                disp(strcat('found: ', num2str(num_ind),' data points in time window: ', num2str(trial)));
                disp(strcat('Expected to find: ',num2str(round(diff(timestamps(trial,:))/kin_sr)),' points'));
                error('get_sub_bdf:BAD_KINEMATIC_RANGE_GENERATION',...
                    strcat('The range of kinematic data generated for trial #: ',...
                    num2str(trial),' is inappropriate given the input times'))
            end
            %log time of new discontinuity in sub-bdf
            if trial>1 
                    %the first trial won't have a discontinuity at its
                    %start
                    if isempty(sub_bdf.discontinuity.time)
                        if isempty(sub_bdf.pos)
                            warning('GET_SUB_BDF:MISALIGNED_DISCONTINUITIES','The discontinuity vector appears to be misaligned to the position data')
                        end
                        %if this is the first entry, start the vector
                        sub_bdf.discontinuity.time=(sub_bdf.pos(kincount,1)+kin_sr);
                        sub_bdf.discontinuity.index=(kincount+1);
                    else
                        %if this is not the first entry, add to the vector
                        sub_bdf.discontinuity.time=[sub_bdf.discontinuity.time,(sub_bdf.pos(kincount,1)+kin_sr)];
                        sub_bdf.discontinuity.index=[sub_bdf.discontinuity.index,(kincount+1)];
                    end
            end
            if ~isempty(sub_bdf.pos)
                %if we are beyond the first trial compute time shift for 
                %this trial. The first trial will use the default shift set
                %before the main loop
                timeshift=timeshift+timestamps(trial,1)-timestamps(trial-1,2);
                %adjust timeshift so that shift is in 50ms steps
                timeshift=timeshift-.05;
                timeshift=timeshift-rem(timeshift,.05);
            end
                
            %add current trial kinematics to new sub-bdf:
            ts1=bdf.pos(ind(1):ind(2),1)-timeshift;
            temp=[ts1,bdf.pos(ind(1):ind(2),2:3)];
                sub_bdf.pos((kincount+1):(kincount+num_ind),:)    =    temp;
            temp=[ts1,bdf.vel(ind(1):ind(2),2:3)];
                sub_bdf.vel((kincount+1):(kincount+num_ind),:)      =    temp;
            temp=[ts1,bdf.acc(ind(1):ind(2),2:3)];
                sub_bdf.acc((kincount+1):(kincount+num_ind),:)      =    temp;
            if isfield(bdf,'force')
                ts1=bdf.force(ind(1):ind(2),1)-timeshift;
                temp=[ts1,bdf.force(ind(1):ind(2),2:3)];
                    sub_bdf.force((kincount+1):(kincount+num_ind),:)   =   temp;
            end
            %update the count of kinematic points
            kincount=kincount+num_ind;
            if kincount>length(bdf.pos(:,1))
                %we have managed to generate more data than the original
                %bdf
                error('get_sub_bdf:DATA_OVERRUN',strcat('At trial #: ',...
                    num2str(trial),'we have more data kinematic data points in the sub-set than was in the original data.'))
            end
            %%%%%%%%% units %%%%%%%%%%%%%%%%%
            %find neural timestamps between the start and end times and            
            %concatenate neural data to the end of the neural data in the
            %sub_bdf
            if isfield(bdf,'units')
                for unit=1:length(bdf.units)
                    %loop across all the units
                    if (isempty(find( bdf.units(unit).ts > timestamps(trial,1),1)) | ...
                            isempty(find(bdf.units(unit).ts < timestamps(trial,2),1)))
%                         disp(strcat('ran out of spikes while processing channel number: ',...
%                             num2str(bdf.units(unit).id(1)),' (bdf unit number: ', num2str(unit),...
%                             '). probably processing bad channel.'))
                    else
                        s1=find(bdf.units(unit).ts > timestamps(trial,1),1);
                        s2=find(bdf.units(unit).ts > timestamps(trial,2),1)-1;
                        %disp(strcat('spike_ind: ',num2str(s1),', ',num2str(s2)))
                        if (~isempty(s1)&~isempty(s2))%only update the unit entries if we found a range to update from
                            spike_ind(1)=s1;
                            spike_ind(2)=s2;
                            numspikes=s2-s1+1;
                            sub_bdf.units(unit).ts((unitcount(unit)+1):(unitcount(unit)+numspikes))= ...
                                bdf.units(unit).ts( spike_ind(1):spike_ind(2))-timeshift;
                            unitcount(unit)=unitcount(unit)+numspikes+1;
                        end
                    end
                    if (isfield(bdf.units(unit),'fr') & ~isempty(bdf.units(unit).id))
                        %if we have a bdf extended so that the units include the firing rates, clip the firing rates as well
                        fr_ind(1)=find( bdf.units(unit).fr(:,1) > timestamps(trial,1),1);
                        fr_ind(2)=find( bdf.units(unit).fr(:,1) > timestamps(trial,2),1);
                        num_fr=diff(fr_ind)+1;
                        temp1=bdf.units(unit).fr( fr_ind(1):fr_ind(2),1)-timeshift;
                        temp2=bdf.units(unit).fr( fr_ind(1):fr_ind(2),2);
                        sub_bdf.units(unit).fr((fr_count(unit))+1:(fr_count(unit)+num_fr),:)=[temp1 temp2];

                        fr_count(unit)=fr_count(unit)+num_fr;
                    end
                end
            end
            %%%%%%%%% words/databursts %%%%%%%%%%%%%%%%%
            temp=bdf.words((timestamps(trial,1)<bdf.words(:,1) & bdf.words(:,1)<timestamps(trial,2)),:);
            sub_bdf.words=[sub_bdf.words;temp];
            temp=bdf.databursts((timestamps(trial,1)<[bdf.databursts{:,1}] & [bdf.databursts{:,1}]<timestamps(trial,2)),:);
            sub_bdf.databursts=[sub_bdf.databursts;temp];
            
            %%%%%%%%% targets %%%%%%%%%%%%%%%%%
            if isfield(bdf,'targets')
                
            end
            
        end
        if trial==length(timestamps)
            %truncate the extraneous zeros from the sub_bdf fields
            sub_bdf.pos     =   sub_bdf.pos(any(sub_bdf.pos,2),:);
            sub_bdf.vel     =   sub_bdf.vel(any(sub_bdf.vel,2),:);
            sub_bdf.acc     =   sub_bdf.acc(any(sub_bdf.acc,2),:);
            if isfield(bdf,'force')
                sub_bdf.force     =   sub_bdf.force(any(sub_bdf.force,2),:);
            end
            if isfield(bdf,'units')
                for unit=1:length(sub_bdf.units)
                    sub_bdf.units(unit).ts = sub_bdf.units(unit).ts(any(sub_bdf.units(unit).ts ,2),:) ;
                end
            end
        end
    end
end