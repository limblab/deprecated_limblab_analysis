function plot_ctr_out_targets(tdf,H,offset,c)
    %takes a tdf and plots the start locations and targets Assumes that the
    %start location is at [0,0], and that the target radius and size are
    %the same for all trials. c is a text flag for the color. offset allows
    %you to displace the target further along its axis by the distance in
    %cm given by offset

    
    %find unique targets:
    targets=unique(tdf.tt(:,tdf.tt_hdr.tgt_angle))*pi/180;
    radius=tdf.tt(5,tdf.tt_hdr.tgt_radius);
    tgt_size=tdf.tt(5,tdf.tt_hdr.tgt_size);       %radius
    target_loc=(radius+offset)*[cos(targets),sin(targets)];
    ctr_loc=offset*[cos(targets),sin(targets)];
    %plot targets
    figure(H)
    hold on
    for i=1:length(targets)
        ctr=target_loc(i,:);
        draw_circle(H,ctr,tgt_size,c{1})
    end
    
    %plot start circles
    if offset==0
        draw_circle(H,[0,0],tgt_size,c{2})
    else
        for i=1:length(targets)
            draw_circle(H,ctr_loc(i,:),tgt_size,c{2})
        end
    end
    axis equal
end