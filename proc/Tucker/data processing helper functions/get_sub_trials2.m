 function [sub_bdf]=get_sub_trials(bdf,times)
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
        sub_bdf.units(unit).ts=[];
        if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates, null the firing rates as well
            sub_bdf.units(unit).fr=[];
        end
    end
    
    %set up an index vector to keep track of start and end indicees of
    %trials
    spike_ind=zeros(length(sub_bdf.units),length(times),2);
    fr_ind=zeros(length(sub_bdf.units),length(times),2);
    kin_ind=zeros(length(times),2);
    
    %loop through the trials
    for trial=1:length(times)
        disp(strcat('Working on trial #: ',num2str(trial)))
        if ~(times(trial,1)==0)
            %find the indices for the start and end of each trial in the
            %kinematic data
            kin_ind(trial,1)= find(  bdf.pos(:,1)  >   times(trial,1)   ,1);
            kin_ind(trial,2)= find(  bdf.pos(:,1)  <   times(trial,2)   ,1);
            

            %find neural timestamps between the start and end times and            
            %concatenate neural data to the end of the neural data in the
            %sub_bdf
            for unit=1:length(sub_bdf.units)
                %using the same logical indexing for rows as above, but
                %there is only one column in bdf.units(i).ts
                if (isempty(find( bdf.units(unit).ts > times(trial,1),1)) | isempty(find(bdf.units(unit).ts < times(trial,2),1)))
                    disp('ran out of spikes. probably processing bad channel.')
                    spike_ind(unit,trial,1)=0;
                    spike_ind(unit,trial,2)=0;
                else
                    spike_ind(unit,trial,1)=find( bdf.units(unit).ts > times(trial,1),1);
                    spike_ind(unit,trial,2)=find(bdf.units(unit).ts < times(trial,2),1);
                end
                
                if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates
                    fr_ind(unit,trial,1)=find( bdf.units(unit).fr(:,1) > times(trial,1),1);
                    fr_ind(unit,trial,2)=find( bdf.units(unit).fr(:,1) > times(trial,2),1);
                end
            end
        end
        
    end
    %use the kinematic indices to fill in the kinematic data
    %allocate empty arrays:
    
    %fill the arrays:
    j=1;
    for i=1:length(times)
        num_points=kin_ind(i,1)-kin_ind(i,2);
        sub_bdf.pos(j:(j+num_points))     = bdf.pos((kin_ind(i,1):kin_ind(i,1)),:);
        sub_bdf.vel(j:(j+num_points))     = bdf.vel((kin_ind(i,1):kin_ind(i,1)),:);
        sub_bdf.acc(j:(j+num_points))     = bdf.acc((kin_ind(i,1):kin_ind(i,1)),:);
        if isfield(bdf,'force')
            sub_bdf.force(j:(j+num_points))   = bdf.force((kin_ind(i,1):kin_ind(i,1)),:);
        end 
        j=j+num_points+1;
    end
     %now fill in the unit data
    for unit=1:length(sub_bdf.units)
        %allocate an array of the correct size
        sub_bdf.units(unit).ts=zeros(sum(  spike_ind(unit,:,2)  -   spike_ind(unit,:,1)     )  ,1  );
        if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates
            sub_bdf.units(unit).fr=zeros(sum(  fr_ind(unit,:,2)     - 	fr_ind(unit,:,1)        )  ,1  );
        end
        %now fill in all the elements:
        j=1;
        for i=1:length(times)
            num_spikes=spike_ind(unit,i,1)-spike_ind(unit,i,2);
            sub_bdf.units(unit).ts(j:(j+num_spikes))=bdf.units(unit).ts(spike_ind(unit,i,1):spike_ind(unit,i,2));
            j=j+num_spikes+1;
        end
        if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates
        j=1;
        for i=1:length(times)
            num_bins=kin_ind(i,1)-kin_ind(i,2);
            sub_bdf.units(unit).fr(j:(j+num_bins))=bdf.units(unit).fr(kin_ind(i,1):kin_ind(i,2));
            j=j+num_bins+1;
        end
        
    end   
 end