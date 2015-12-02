function RList=power60HzRatio(x)
    %takes a table, where the first column is time (t), and computes the
    %ratio of power in the 55-65Hz window to power in the whole signal.
    %returns the ratio for each column of data (time excluded). 
    
    F=1/mode(diff(x.t));
    RList=zeros(size(x,2)-1,1);
    for i=2:size(x,2)
        %for each EMG we have, get the power of the whole signal, and the
        %60hz power
        pAll=bandpower(x{:,i},F,[0 F/2]);
        p60=bandpower(x{:,i},F,[55 65]);
        RList(i)=p60/pAll;
    end
end