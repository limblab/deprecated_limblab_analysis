function plotwindows(data,windows)
    figure
    hold on
    for i=1:size(windows,1)
        mask=data(:,1)>=windows(i,1) & data(:,1)<=windows(i,2);
        plot(data(mask,2),data(mask,3))
    end

