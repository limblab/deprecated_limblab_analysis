function movetimes=get_move_time(tdf,varargin)
    %takes in a tdf and returns the time of movement start for each trial,
    %or -1 if a move was never made (abort, incomplete, time-out etc),
    %accepts an optional flag to specify what method will be used to
    %determine move start. Assumes that movement will start after the go
    %cue
    
    
    
    
    if ~isempty(varargin)
        temp=varargin{1};
    else
        temp='boundary_crossing';
    end
    
    %get the reduced trial table with only the success and failure trials
    tt=tdf.tt(  tdf.tt(:,tdf.tt_hdr.trial_result)==0 || tdf.tt(:,tdf.tt_hdr.trial_result)==2 ,:);
    
    t=tdf.vel(:,1);
    %get the start and end times for the trials
    tstart=find(t>tt(:,tdf.tt_hdr.go_cue),1,'first');
    tend=find(t>tt(:,tdf.tt_hdr.end_time),1,'first');
    %convert start and end times into indices on the kinematic data
    [temp,istart,temp]=intersect(t,round(tstart*1000)/1000);
    [temp,iend,temp]=intersect(t,round(tend*1000)/1000);
    switch temp
            case 'velocity_inflection'
                %finds first minima in hand speed prior to peak hand
                %speed that is below 5% of peak hand speed, or, the
                %go cue, whichever comes later
                
                %get speed
                x=tdf.vel(:,2);
                y=tdf.vel(:,3);
                spd=sqrt(x.^2+y.^2);
                %get an index
                idx = arrayfun(@colon, istart, iend, 'Uniform',false);
                idx = [idx{:}];
                %find speed minimas inside the trials:
                [temp,imax,temp,imin]=max(spd(idx));
                %find local minima in speed
                
                
            case 'boundary_crossing'
                %the cursor left the start circle
            end
    
    
end