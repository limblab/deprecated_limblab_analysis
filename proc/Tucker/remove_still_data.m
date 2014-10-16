function sub_bdf=remove_still_data(bdf,pts,window)
    %creates a sub_bdf that excludes data where the handle was still.
    %should be used only for robot tasks where there are handle position
    %data streams
    %removes data points where the
    %handle was still for more than pts data samples. also excludes a
    %number of points equal to 'window' on either side of the still portion
    %of data
    
    %find indices where the handle was still:
    speed=sqrt(bdf.vel(:,2).^2+bdf.vel(:,3).^2);
    series=speed<=.0001;
    %find where the handle went from still to moving
    chng=find(diff(series));

    
    if series(1)==1
        %If the handle was still to start the recording, we want to prepend a
        %change point so that we properly consider the starting interval
        chng=[1,chng];
    end
    %initialize an additional counter for the actual still periods:
    j=0;
    %loop through and find still periods longer than pts
    for(i=1:2:length(chng))
        if i>=length(chng)
            %if we overran the chng vector we need to break the loop
            %this happens if we have a still spot to end the data file,
            %causing an odd number of change events
            break
        end
        if (chng(i+1)-chng(i))>pts
            j=j+1;
            still(j,:)=[chng(i) chng(i+1)];
        end
    end
    
    % add windows to ends of still regions:
    still(:,1)=still(:,1)-window;
    still(:,2)=still(:,2)+window;
    
    % merge still regions that overlap once windows are applied
%     temp=zeros(size(still));
%     if rows(still)>1
%         for i=1:rows(still)-1
%             if still(i,2)>still(i+1,1)
%                 %combine periods i and i+1
%                 still=[still(1:i,:);[];]
%                 %decriment i so that we don't miss another adjacent region:
%                 i=i-1;
%             end
%         end
%     end

    % clip leading and trailing still regions that extend beyond the
    % original dataset after windows are added
    if (still(1,1)-window)<0
        still(1,1)=0;
    end
    if (still(end,1)+window)>rows(bdf.vel)
        still(1,1)=0;
    end
    %create index pairs for onset/offset of movement periods
    
    
       
    %convert indices to time
    timestamps(:,1)=bdf.vel(times(:,1),1);
    timestamps(:,2)=bdf.vel(times(:,2),1);

    %get a sub-bdf with the times found above removed
    sub_bdf=get_sub_bdf(bdf,timestamps);

end