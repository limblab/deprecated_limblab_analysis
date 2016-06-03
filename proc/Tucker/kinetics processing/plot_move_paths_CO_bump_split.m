function h=plot_move_paths_CO_bump_split(tdf,varargin)

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
            t_2=t_1+700;
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
                        x_temp=x(t_1:t_2)-x(t_1);
                        y_temp=y(t_1:t_2)-y(t_1);
                    case 'fixed'
                        %don't do anything, just assign the vectors to plot
                        x_temp=x(t_1:t_2);
                        y_temp=y(t_1:t_2);

                end
            else
                %don't do anything, just assign the vectors to plot
                x_temp=x(t_1:t_2);
                y_temp=y(t_1:t_2);
            end
            
            
            %add the current trial to the figure
            switch tdf.tt(i,tdf.tt_hdr.tgt_angle)
                case 0
                    make_subplot(h,tdf,x_temp,y_temp,i,6)
                case 45
                    make_subplot(h,tdf,x_temp,y_temp,i,3)
                case 90
                    make_subplot(h,tdf,x_temp,y_temp,i,2)
                case 135
                    make_subplot(h,tdf,x_temp,y_temp,i,1)
                case 180
                    make_subplot(h,tdf,x_temp,y_temp,i,4)
                case 225
                    make_subplot(h,tdf,x_temp,y_temp,i,7)
                case 270
                    make_subplot(h,tdf,x_temp,y_temp,i,8)
                case 315
                    make_subplot(h,tdf,x_temp,y_temp,i,9)
            end
            
        end
    end
    figure(h)
    hold off
end
function make_subplot(h,tdf,x_temp,y_temp,i,pos)
    figure(h)
    if tdf.tt(i,tdf.tt_hdr.stim_trial)
        subplot(3,3,pos),plot(x_temp,y_temp,'b')
            hold on
            axis equal
    else
        if tdf.tt(i,tdf.tt_hdr.bump_mag)
            if tdf.tt(i,tdf.tt_hdr.bump_angle)==90
                subplot(3,3,pos),plot(x_temp,y_temp,'r')
            elseif tdf.tt(i,tdf.tt_hdr.bump_angle)==270
                subplot(3,3,pos),plot(x_temp,y_temp,'g')
            end
            hold on
            axis equal
        else
            subplot(3,3,pos),plot(x_temp,y_temp,'k')
            hold on
            axis equal
        end
    end
end