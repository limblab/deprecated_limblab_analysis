 function [sub_bdf]=get_sub_trials(bdf,timestamps)
    %takes in the bdf and the start and end times for the block to be used
    %from each trial. times should be a nx2 matrix where n is the number of
    %events in the session. The first column should be the start time of 
    %the event of interest within the trial specified by the row. the 
    %second column should be the ending time of the event. If there is no 
    %event of interest during a given trial the first column should contain
    %zero

    sub_bdf=bdf;
    sub_bdf.pos=[];
    sub_bdf.vel=[];
    sub_bdf.acc=[];
    if isfield(bdf,'force')
        sub_bdf.force=[];
    end
    
    %clear neural data in each of the units
    for unit=1:length(sub_bdf.units)
        sub_bdf.units(unit).ts=zeros(1000000,1);%fill with zero matrix so we don't have to reallocate
        if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates, null the firing rates as well
            sub_bdf.units(unit).fr=[];
        end
    end
    %set up a tracker to keep count of how many spikes we actually have in each unit
    unitcount=zeros(length(bdf.units),1);
    %set up a kinematic tracker to keep count of how many points we have in
    %each kinematic set
    kincount=0;
    fr_count=zeros(length(bdf.units),1);
    
    %find the kinematic sample rate. this will be used for a sanity check
    %on the kinematic sub-samples later
    kin_sr=mean(diff(bdf.pos(:,1)));
    
    ind=[0,0];
    %loop through the trials
    for trial=1:length(timestamps)
        disp(strcat('Working on trial #: ',num2str(trial)))
        if ~(timestamps(trial,1)==0)
            %find kinematics timestamps between the start and end times and
            %concatenate data to the end of the kinematics data in the
            %sub_bdf
            %using logical indexing to select elements meeting the time
            %criteria for the rows, and all columns associated with those
            %rows
            i1 = find(  (bdf.pos(:,1) > timestamps(trial,1))   ,1);     
            i2 = find(  (bdf.pos(:,1) > timestamps(trial,2))   ,1); 
            
            if i1<ind(2)
                %we have a problem with how our trial times are being
                %computed
                warning('get_sub_trials:BAD_TRIAL_TIMING',strcat('new go cue for trial #: ',num2str(trial),' is earlier than the end of the previous trial.'))
            end
            
            ind(1)=i1;
            ind(2)=i2;
            %disp(strcat('kin_ind: ',num2str(ind(1)),', ',num2str(ind(2))))
            num_ind=diff(ind)+1;
            if abs(num_ind-(diff(timestamps(trial,:))/kin_sr))>10
                %we have a problem computing the sample range for this
                %trial
                warning('get_sub_trials:BAD_KINEMATIC_RANGE_SELECTION',strcat('The range of kinematic data selected for trial #: ',num2str(trial),' is inappropriate given the trial length'))
            end
            
            %disp(strcat('num_ind: ',num2str(num_ind)))
            sub_bdf.pos((kincount+1):(kincount+num_ind),:)     =   bdf.pos(ind(1):ind(2),:);
            sub_bdf.vel((kincount+1):(kincount+num_ind),:)     =   bdf.vel(ind(1):ind(2),:);
            sub_bdf.acc((kincount+1):(kincount+num_ind),:)     =   bdf.acc(ind(1):ind(2),:);
            
            if isfield(bdf,'force')
                sub_bdf.force((kincount+1):(kincount+num_ind),:)   =   bdf.force(ind(1):ind(2),:);
            end
            %disp(strcat('old kincount: ',num2str(kincount)))
            kincount=kincount+num_ind+1;
            if kincount>length(bdf.pos(:,1))
                %we have managed to generate more data than the original
                %set
                warning('get_sub_trials:DATA_OVERRUN',strcat('At trial #: ',num2str(trial),'we have more data kinematic data points in the sub-set than was in the original data.'))
            end
            
            %disp(strcat('new kincount: ',num2str(kincount)))
            %find neural timestamps between the start and end times and            
            %concatenate neural data to the end of the neural data in the
            %sub_bdf

            for unit=1:length(sub_bdf.units)
                
                if (isempty(find( bdf.units(unit).ts > timestamps(trial,1),1)) | isempty(find(bdf.units(unit).ts < timestamps(trial,2),1)))
                    disp(strcat('ran out of spikes while processing channel number: ', num2str(sub_bdf.units(unit).id(1)),' (bdf unit number: ', num2str(unit), '). probably processing bad channel.'))
                else
                    s1=find(bdf.units(unit).ts > timestamps(trial,1),1);
                    s2=find(bdf.units(unit).ts > timestamps(trial,2),1);
                    %disp(strcat('spike_ind: ',num2str(s1),', ',num2str(s2)))
                    if (~isempty(s1)&~isempty(s2))%only update the unit entries if we found a range to update from
                        spike_ind(1)=s1;
                        spike_ind(2)=s2;
                        numspikes=diff(spike_ind)+1;
                        sub_bdf.units(unit).ts((unitcount(unit)+1):(unitcount(unit)+numspikes))= bdf.units(unit).ts( spike_ind(1):spike_ind(2));
                        %disp(strcat('old unit count: ', num2str(unitcount(unit))))
                        %disp(strcat('number of spikes: ', num2str(numspikes)))
                        unitcount(unit)=unitcount(unit)+numspikes+1;
                        %disp(strcat('new unit count: ', num2str(unitcount(unit))))
                    end
                    
                    if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates, clip the firing rates as well
                        if (~isempty(bdf.units(unit).id))
                            fr_ind(1)=find( bdf.units(unit).fr(:,1) > timestamps(trial,1),1);
                            fr_ind(2)=find( bdf.units(unit).fr(:,1) > timestamps(trial,2),1);
                            num_fr=diff(fr_ind)+1;
                            sub_bdf.units(unit).fr((fr_count(unit)+1):(fr_count(unit)+num_fr),:)=bdf.units(unit).fr( fr_ind(1):fr_ind(2),:);
                            fr_count(unit)=fr_count(unit)+num_fr+1;
                        end
                    end
                end
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
            for unit=1:length(sub_bdf.units)
                sub_bdf.units(unit).ts = sub_bdf.units(unit).ts(any(sub_bdf.units(unit).ts ,2),:) ;
            end
        end
    end
end