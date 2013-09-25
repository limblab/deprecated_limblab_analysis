function h=plot_move_paths_CO_bump(tdf,varargin)
    %this function plots all abort trials from a single tdf on the same
    %plot
    h=figure;
    hold on
    
    if ~isempty(varargin)
        switch varargin{1}
            case 'go'
                startpoint=tdf.tt(:,tdf.tt_hdr.go_cue);
            case 'move'
                disp('move synchronization not coded yet')
                %startpoint=tdf.tt(:,tdf.tt_hdr.go_cue);
            case 'bump'
                startpoint=tdf.tt(:,tdf.tt_hdr.bump_time);
        end
    else
        
    end
    
    if length(varargin)>1
        switch varargin{2}
            case 'center'
                %start all movements at 0,0 by offsetting the points in the
                %movement by the displacement from 0,0 logged at the
                %synchronizing time
                
            case 'fixed'
                
        end
    end
    
    t=tdf.pos(:,1);
    x=tdf.pos(:,2);
    y=tdf.pos(:,3);
    axis equal
    title('Abort trial paths')
    %loop across the trial table and plot the movements for each trial
    for i=1:length(tdf.tt(:,1))
        %find the start and stop index for this trial
        if tdf.tt(i,tdf.tt_hdr.bump_time)>0
            
            t_1=find(t>startpoint(i),1,'first');
            t_2=find(t>tdf.tt(i,tdf.tt_hdr.end_time),1,'first');
            if strcmp(varargin{1},'pos')
                %add the current trial to the figure
                plot(x(t_1:t_2),y(t_1:t_2))
            elseif strcmp(varargin{1},'vel')
                plot(spd(t_1:t_2))
            end
        end
    end
    hold off
end