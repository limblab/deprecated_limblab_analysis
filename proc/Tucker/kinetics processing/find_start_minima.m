function [movetimes,movetime_index]=find_start_minima(tdf,idx)
    %finds the starts of movement for trials defined by the cell array idx.
    %each element of idx is a list of indices for the points included in
    %that trial. movement start is defined as the time of the first minima
    %in hand speed prior to peak velocity that is below 5% of peak hand 
    %velocity 
    
    %get speed
    x=tdf.vel(:,2);
    y=tdf.vel(:,3);
    spd=sqrt(x.^2+y.^2);
    %get an index

    for i=1:length(idx)
        [smax,imax,smin,imin] = extrema(spd(idx{i}));
        %find speed maximas inside the trials:
        [vmax,imax_temp]=max(smax);
        imax=imax(imax_temp);
        smax=smax(imax_temp);
        %find last minima before peak velocity that is below 5%
        %of the peak velocity
        imin_temp=find([imin<imax && smin<.05*smax],1,'last');
        movetime_index(i)=imin(imin_temp)+istart(i);
%        smin=smin(imin_temp);
        movetimes(i)=t(movetime_index(i));
    end
end