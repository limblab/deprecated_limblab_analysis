function reaches=export_reaches_for_Lee(tdf,varargin)
    %similar to plot_mean_move_paths_CO_bump but does not assume targets
    %are along cardinal axes

    %magic variable for shifting plots out from center to keep the
    %different reach directions distinct
    offset=15;

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
    
    %find the target directions
    targets=unique(tdf.tt(:,tdf.tt_hdr.tgt_angle));
    
    %loop across the trial table and plot the movements for each trial
    t_1=-1*ones(1,length(tdf.tt(:,1)));
    t_2=-1*ones(1,length(tdf.tt(:,1)));
    
    %get the start and end times
    for i=1:length(tdf.tt(:,1))
        %find the start and stop index for this trial
        if tdf.tt(i,tdf.tt_hdr.trial_result )==1
            continue
        else           
            t_1(i)=find(t>startpoint(i),1,'first');
            %t_2(i)=find(t>tdf.tt(i,tdf.tt_hdr.end_time),1,'first');
            t_2(i)=round(t_1(i)+tdf.tt(i,tdf.tt_hdr.bump_hold_time )*1000);%bump hold time is the variable used for the amount of time the animal has after bump to complete the reach. It's in seconds and we are working in ms so multiply by 1000
            if (t_1(i)<0 | t_2(i)<0 | t_1(i)==1 | t_2(i)==1)
                disp(strcat('skipping trial: ', num2str(i)))
                continue
            end
        end
    end
    
    %compose mean trajectories
    trial_length=max(t_2-t_1)+1;
    
    reaches=zeros(length(t_1),2,trial_length);

    
    for i=1:length(t_1)
        %skip trials with bad trial times
            if t_1(i)<0
                disp(strcat('Trial: ',num2str(i),' has a bad start time, skipping it.'))
                disp('line locator: a;aln_12042013')
                continue
            end
            if length(varargin)>2
                switch varargin{3}
                    case 'center'
                        %start all movements at 0,0 by offsetting the points in the
                        %movement by the displacement from 0,0 logged at the
                        %synchronizing time
                        x_temp=x(t_1(i):t_2(i))-x(t_1(i));
                        y_temp=y(t_1(i):t_2(i))-y(t_1(i));
                    case 'fixed'
                        %don't do anything, just assign the vectors to plot
                        x_temp=x(t_1(i):t_2(i));
                        y_temp=y(t_1(i):t_2(i));

                end
            else
                %don't do anything, just assign the vectors to plot
                x_temp=x(t_1(i):t_2(i));
                y_temp=y(t_1(i):t_2(i));
            end
            
            %offset position so paths are clear:
            reaches(i,1,:)=x_temp+offset*cos(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
            reaches(i,2,:)=y_temp+offset*sin(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
           
    end
    

    
end
