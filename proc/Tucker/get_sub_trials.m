function [sub_bdf]=get_sub_trials(bdf,times)
    %takes in the bdf and the start and end times for the block to be used
    %from each trial. times should be a nx2 matrix where n is the number of
    %trials in the session. The first column should be the start time of 
    %the event of interest within the trial specified by the row. the 
    %second column should be the ending time of the event. If there is no 
    %event of interest during a given trial the first column should contain
    %zero

    sub_bdf=bdf;
    sub_bdf.pos=[];
    sub_bdf.vel=[];
    sub_bdf.acc=[];
    sub_bdf.force=[];
    
    %clear neural data in each of the units
    for unit=1:length(sub_bdf.units)
        sub_bdf.units(unit).ts=[];
        if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates, null the firing rates as well
            sub_bdf.units(unit).fr=[];
        end
    end
    
    %loop through the trials
    for trial=1:length(times)
        %disp(strcat('Working on trial #: ',num2str(trial)))
        if ~(times(trial,1)==0)
            %find kinematics timestamps between the start and end times and
            %concatenate data to the end of the kinematics data in the
            %sub_bdf
            %using logical indexing to select elements meeting the time
            %criteria for the rows, and all columns associated with those
            %rows
            
            sub_bdf.pos     = [ sub_bdf.pos;    bdf.pos(    bdf.pos(:,1)    >   times(trial,1)      &   ( bdf.pos(:,1)      < times(trial,2) )   ,: ) ];
            sub_bdf.vel     = [ sub_bdf.vel;    bdf.vel(    bdf.vel(:,1)    >   times(trial,1)      &   ( bdf.vel(:,1)      < times(trial,2) )   ,: ) ];
            sub_bdf.acc     = [ sub_bdf.acc;    bdf.acc(    bdf.acc(:,1)    >   times(trial,1)      &   ( bdf.acc(:,1)      < times(trial,2) )   ,: ) ];
            sub_bdf.force   = [ sub_bdf.force;  bdf.force(  bdf.force(:,1)  >   times(trial,1)      &   ( bdf.force(:,1)    < times(trial,2) )   ,: ) ];
            %find neural timestamps between the start and end times and            
            %concatenate neural data to the end of the neural data in the
            %sub_bdf
            for unit=1:length(sub_bdf.units)
                %using the same logical indexing for rows as above, but
                %there is only one column in bdf.units(i).ts
                sub_bdf.units(unit).ts=[sub_bdf.units(unit).ts;bdf.units(unit).ts( bdf.units(unit).ts>times(trial,1) & bdf.units(unit).ts<times(trial,2) )];
                if isfield(bdf.units(unit),'fr')%if we have a bdf extended so that the units include the firing rates, clip the firing rates as well
                    if (~isempty(bdf.units(unit).id))
                        sub_bdf.units(unit).fr=[sub_bdf.units(unit).fr ; bdf.units(unit).fr(  (bdf.units(unit).fr(:,1)>times(trial,1) & bdf.units(unit).fr(:,1)<times(trial,2) ),:)];
                    end
                end
            end
        end
    end
end