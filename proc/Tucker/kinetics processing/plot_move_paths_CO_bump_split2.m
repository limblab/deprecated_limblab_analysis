function h=plot_move_paths_CO_bump_split2(tdf,varargin)

    %magic variable for shifting plots out from center to keep the
    %different reach directions distinct
    offset=15;

    h=figure;
    %put the targets on the figure first
    plot_ctr_out_targets(tdf,h,offset,{'r','g'})
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
            case 'pos'
                %start all movements at 0,0 by offsetting the points in the
                %movement by the displacement from 0,0 logged at the
                %synchronizing time
                t=tdf.pos(:,1);
                x=tdf.pos(:,2);
                y=tdf.pos(:,3);
            case 'vel'
                t=tdf.vel(:,1);
                x=tdf.vel(:,1);
                y=sqrt(tdf.vel(:,2).^2+tdf.vel(:,3).^2);
        end
        
    else
        %assume position
        t=tdf.pos(:,1);
        x=tdf.pos(:,2);
        y=tdf.pos(:,3);
    end
    
    %loop across the trial table and plot the movements for each trial
    for i=1:length(tdf.tt(:,1))
        %find the start and stop index for this trial
        if tdf.tt(i,tdf.tt_hdr.trial_result )==1
            continue
        else   
            t_1=find(t>startpoint(i),1,'first');
            %t_2=find(t>tdf.tt(i,tdf.tt_hdr.end_time),1,'first');
            t_2=t_1+ round(1000*(tdf.tt(i,tdf.tt_hdr.bump_hold_time) + tdf.tt(i,tdf.tt_hdr.bump_delay)));
            if (t_1<0 | t_2<0 | t_1==1 | t_2==1)
                disp(strcat('skipping trial: ', num2str(i)))
                continue
            end
            
            if length(varargin)>2
                switch varargin{3}
                    case 'center'
                        %start all movements at 0,0 by offsetting the points in the
                        %movement by the displacement from 0,0 logged at the
                        %synchronizing time
                        x_temp=x(t_1:t_2)-x(t_1)+offset*cos(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
                        y_temp=y(t_1:t_2)-y(t_1)+offset*sin(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
                    case 'fixed'
                        %don't do anything, just assign the vectors to plot
                        x_temp=x(t_1:t_2)+offset*cos(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
                        y_temp=y(t_1:t_2)+offset*sin(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);

                end
            else
                %don't do anything, just assign the vectors to plot
                x_temp=x(t_1:t_2)+offset*cos(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
                y_temp=y(t_1:t_2)+offset*sin(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
            end
            
            
            %add the current trial to the figure
            add_trace(h,tdf,x_temp,y_temp,i)
                        
        end
    end
    figure(h)
    hold off
end
function add_trace(h,tdf,x_temp,y_temp,i)
    figure(h)
    
    %set the color of the line to plot
    if tdf.tt(i,tdf.tt_hdr.stim_trial)
        trace_color='b';
    elseif tdf.tt(i,tdf.tt_hdr.bump_mag)
        if tdf.tt(i,tdf.tt_hdr.bump_angle)==90
            trace_color='r';
        elseif tdf.tt(i,tdf.tt_hdr.bump_angle)==270
            trace_color='g';
        end
    else
        trace_color='k';
    end
    
    %offset the trace in the target direction so that the clusters of
    %reaches are distinct
    plot(x_temp,y_temp,trace_color)
    hold on
    axis equal
end