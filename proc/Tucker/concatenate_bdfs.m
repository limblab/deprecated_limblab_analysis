function full_bdf=concatenate_bdfs(bdf1,bdf2,lag)
    %concatenates two bdf's into a single bdf. Ignores the raw fields.
    %Inserts a lag the specified amount between the last timestamp of the
    %first bdf and the first timestamp of the second bdf. the lag should be
    %in s
    
    %this function should be called prior to computation of the trial table
    %in order to ensure that the timestamps for the words are synchronized
    %with the new kinematic timestamps
            
            
    shift_time = bdf1.meta.duration+lag;        
            
            
    %meta
    full_bdf.meta.filename='Concatentated from multiple bdf files';
    full_bdf.meta.datetime=datestr(now);
    full_bdf.meta.duration=bdf1.meta.duration+bdf2.meta.duration+lag;
    
    %units
    if (length(bdf1.units) ~= length(bdf2.units))
        error('concatenate_bdfs:UnitNumberChange','There are a different number of units in the two source bdfs.')
    end
    for i=1:length(bdf1.units)
        %first clean out the 1s of timestamps before the kinematic data
        %starts and shift the timestamps for the second bdf
        bdf1.units(i).ts=bdf1.units(i).ts(bdf1.units(i).ts>1);
        bdf2.units(i).ts=bdf2.units(i).ts(bdf2.units(i).ts>1) + shift_time;
        %the unit id's should be the same so just use the ones from bdf1
        full_bdf.units(i).id=bdf1.units(i).id;
        %concatenate the cleaned timestamps into 
        full_bdf.units(i).ts=[bdf1.units(i).ts ; bdf2.units(i).ts];
    end
    
    %raw
    full_bdf.raw=[];
    
    %words
    bdf2.words(:,1) = bdf2.words(:,1) + shift_time;
    full_bdf.words = [bdf1.words ; bdf2.words];
    
    %databursts
    for i = 1:size(bdf2.databursts,1)
        bdf2.databursts{i,1} = bdf2.databursts{i,1} + shift_time;
    end
    full_bdf.databursts = [bdf1.databursts; bdf2.databursts];
    
    %pos
    bdf2.pos(:,1) = bdf2.pos(:,1) + shift_time;
    full_bdf.pos = [bdf1.pos ; bdf2.pos];
    
    %vel
    bdf2.vel(:,1) = bdf2.vel(:,1) + shift_time;
    full_bdf.vel = [bdf1.vel ; bdf2.vel];
    
    %acc
    bdf2.acc(:,1) = bdf2.acc(:,1) + shift_time;
    full_bdf.acc = [bdf1.acc ; bdf2.acc];
    
    %force
    bdf2.force(:,1) = bdf2.force(:,1) + shift_time;
    full_bdf.force = [bdf1.force ; bdf2.force];
    
end