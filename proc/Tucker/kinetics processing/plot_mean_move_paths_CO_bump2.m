function h=plot_mean_move_paths_CO_bump2(tdf,varargin)
    %similar to plot_mean_move_paths_CO_bump but does not assume targets
    %are along cardinal axes

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
    meanlength=max(t_2-t_1)+1;
    
    means.meancounts_90=zeros(1,length(targets));%uses same indexing as subplot for consistency
    means.meantraj_x_90=zeros(length(targets),meanlength);
    means.meantraj_y_90=zeros(length(targets),meanlength);
    means.meancounts_270=zeros(1,length(targets));%uses same indexing as subplot for consistency
    means.meantraj_x_270=zeros(length(targets),meanlength);
    means.meantraj_y_270=zeros(length(targets),meanlength);
    means.meancounts_null=zeros(1,length(targets));%uses same indexing as subplot for consistency
    means.meantraj_x_null=zeros(length(targets),meanlength);
    means.meantraj_y_null=zeros(length(targets),meanlength);
    means.meancounts_stim=zeros(1,length(targets));%uses same indexing as subplot for consistency
    means.meantraj_x_stim=zeros(length(targets),meanlength);
    means.meantraj_y_stim=zeros(length(targets),meanlength);
    
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
            x_temp=x_temp+offset*cos(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
            y_temp=y_temp+offset*sin(tdf.tt(i,tdf.tt_hdr.tgt_angle)*pi/180);
            
            
            %add the current trial to the appropriate mean
            means=fill_means(find(targets==tdf.tt(i,tdf.tt_hdr.tgt_angle)),i,tdf,x_temp,y_temp,means);
            
    end
    %normalize trajectories
    for i=1:length(targets)
%         if i==5
%             continue
%         end
        means.meantraj_x_90(i,:)=means.meantraj_x_90(i,:)/means.meancounts_90(i);
        means.meantraj_y_90(i,:)=means.meantraj_y_90(i,:)/means.meancounts_90(i);
        means.meantraj_x_270(i,:)=means.meantraj_x_270(i,:)/means.meancounts_270(i);
        means.meantraj_y_270(i,:)=means.meantraj_y_270(i,:)/means.meancounts_270(i);
        means.meantraj_x_null(i,:)=means.meantraj_x_null(i,:)/means.meancounts_null(i);
        means.meantraj_y_null(i,:)=means.meantraj_y_null(i,:)/means.meancounts_null(i);
        means.meantraj_x_stim(i,:)=means.meantraj_x_stim(i,:)/means.meancounts_stim(i);
        means.meantraj_y_stim(i,:)=means.meantraj_y_stim(i,:)/means.meancounts_stim(i);
        
    end
    %make the plot of mean reaches:
    figure(h)
    hold on
    for i=1:length(targets)
%         if i==5
%             continue
%         end
        plot(means.meantraj_x_90(i,:),means.meantraj_y_90(i,:),'r')
        axis equal
        hold on
        plot(means.meantraj_x_270(i,:),means.meantraj_y_270(i,:),'g')
        axis equal
        hold on
        plot(means.meantraj_x_null(i,:),means.meantraj_y_null(i,:),'k')
        axis equal
        hold on
        plot(means.meantraj_x_stim(i,:),means.meantraj_y_stim(i,:),'b')
        axis equal
        hold on
    end
    
end
function [means]=fill_means(ind,idx,tdf,x_temp,y_temp,means)
    if tdf.tt(idx,tdf.tt_hdr.stim_trial)
        means.meantraj_x_stim(ind,:)=means.meantraj_x_stim(ind,:)+x_temp';
        means.meantraj_y_stim(ind,:)=means.meantraj_y_stim(ind,:)+y_temp';
        means.meancounts_stim(ind)=means.meancounts_stim(ind)+1;
    else
        if ~tdf.tt(idx,tdf.tt_hdr.bump_mag)
            means.meantraj_x_null(ind,:)=means.meantraj_x_null(ind,:)+x_temp';
            means.meantraj_y_null(ind,:)=means.meantraj_y_null(ind,:)+y_temp';
            means.meancounts_null(ind)=means.meancounts_null(ind)+1;
        elseif(tdf.tt(idx,tdf.tt_hdr.bump_angle)==90)
            means.meantraj_x_90(ind,:)=means.meantraj_x_90(ind,:)+x_temp';
            means.meantraj_y_90(ind,:)=means.meantraj_y_90(ind,:)+y_temp';
            means.meancounts_90(ind)=means.meancounts_90(ind)+1;
        elseif (tdf.tt(idx,tdf.tt_hdr.bump_angle)==270)
            means.meantraj_x_270(ind,:)=means.meantraj_x_270(ind,:)+x_temp';
            means.meantraj_y_270(ind,:)=means.meantraj_y_270(ind,:)+y_temp';
            means.meancounts_270(ind)=means.meancounts_270(ind)+1;
        end
    end
end