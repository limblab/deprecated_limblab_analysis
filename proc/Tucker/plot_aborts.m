function plot_aborts(tdf,stimcode,varargin)
    %this function plots all abort trials from a single tdf on the same
    %plot
    figure
    hold on
    
    if nargin>2
        switch varargin{1}
            case 'pos'
                t=tdf.pos(:,1);
                x=tdf.pos(:,2);
                y=tdf.pos(:,3);
                axis equal
                title('Abort trial paths')
            case 'vel'
                t=tdf.vel(:,1);
                x=tdf.vel(:,2);
                y=tdf.vel(:,3);
                spd=sqrt(x.^2+y.^2);
                title('Abort trial speed')
        end
    else
        t=tdf.pos(:,1);
        x=tdf.pos(:,2);
        y=tdf.pos(:,3);
    end
    % compose trial table for only abort trials
    tt = tdf.tt( ( tdf.tt(:,tdf.tt_hdr.trial_result) == 1 &  tdf.tt(:,tdf.tt_hdr.stim_code) == stimcode) ,  :);
    disp(strcat('Found ',num2str(length(tt(:,1))),' abort trials.'))

    
    %loop across the trial table and plot the movements for each trial
    for i=1:length(tt(:,1))
        %find the start and stop index for this trial
        if tt(i,tdf.tt_hdr.bump_time)>0
            
            t_1=find(t>tt(i,tdf.tt_hdr.bump_time),1,'first');
            t_2=find(t>tt(i,tdf.tt_hdr.end_time),1,'first');
            if strcmp(varargin{1},'pos')
                %add the current trial to the figure
                plot(x(t_1:t_2),y(t_1:t_2))
            elseif strcmp(varargin{1},'vel')
                plot(spd(t_1:t_2))
            end
        end
    end
    
end