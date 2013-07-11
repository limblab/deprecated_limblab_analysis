function sub_bdf=remove_still_data(bdf,pts,window)
    %removes data points from both kinetic and neural data where the
    %handle was still for more than pts data samples. also excludes a
    %number of points equal to 'window' on either side of the still portion
    %of data
    
    %find indices where the handle was still:
    series=sqrt(bdf.vel(:,2)^2+bdf.vel(:,3)^2)<=.0001;
    chng=find(diff(series));
    j=0;
    if series(1)>0
        start=1;
    else
        start=2;
    end
    
    for(i=1:2:length(chng))
        if (chng(i+1)-chng(i))>pts
            j=j+1;
            still(j,:)=[chng(i) chng(i+1)];
        end
    end
    
    %get indices to keep
    j=1;
    if still(1,1)-window>0
        times(1,:)=[0  (still(1,1)-window)];
    end
    for i=1:length(still)-1
        i1=still(i,2)+window;
        i2=still(i+1,1)-window;
        times(i+1,:)=[i1,i2];
    end
    if still(end,2)+window<length(still(:,1))
        times(length(times(:,1)),:)=[   (still(end,2)+window)   ,   length(times(:,1))       ];
    end
    
    %convert indices to time
    timestamps(:,1)=bdf.vel(times(:,1),1);
    timestamps(:,2)=bdf.vel(times(:,2),1);
    
    
    %get a sub-bdf with the times found above removed
    sub_bdf=get_sub_trials(bdf,timestamps);
    
    
end