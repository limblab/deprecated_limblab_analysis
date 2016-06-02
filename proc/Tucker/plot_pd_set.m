function h=plot_pd_set(channel_list,PD,chans)
    
    h = figure;
    polar(0,1)
    hold on
    r=1;
    for i=1:length(chans)
        angle=PD(channel_list==chans(i))*pi/180;
        polar([0 angle],[0,r]);

    end
end