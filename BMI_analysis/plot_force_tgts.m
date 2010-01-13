function plot_pos_and_tgts(out_struct)

    out_struct = LoadDataStruct(out_struct,'bdf');

    w=WF_Words;
    
    %extract target onset and offset times
    tgt_on = out_struct.words(out_struct.words(:,2)==w.Go_Cue | out_struct.words(:,2) == w.Catch,1);
    tgt_off = out_struct.words(out_struct.words(:,2)>=w.End_Code & out_struct.words(:,2)< w.End_Code+5);
    
    %make sure first time stamp is tgt_on and last is tgt_off 
    %and that there is target information for that trial (tgt_on preceded
    %by databurst)
    tgt_on = tgt_on( (tgt_on < tgt_off(end)) & ( tgt_on > out_struct.databursts{1,1}) );
    tgt_off = tgt_off(tgt_off > tgt_on(1));
    
    %plot targets
    tgt_x = out_struct.targets.corners(:,[2 4]);
    tgt_y = out_struct.targets.corners(:,[3 5]);
    
    figure;
    hold on;
    
    %plot cursor position
    plot(out_struct.pos(:,1),out_struct.pos(:,2),'b'); % x pos in blue
    plot(out_struct.pos(:,1),out_struct.pos(:,3),'g'); % y pos in green
    
    
    %plot targets
    for i=1:length(tgt_on)
        tgt_time_tmp=[tgt_on(i) tgt_on(i) tgt_off(i) tgt_off(i) tgt_on(i)];
        tgt_x_tmp = [tgt_x(i,1) tgt_x(i,2) tgt_x(i,2) tgt_x(i,1) tgt_x(i,1)];
        tgt_y_tmp = [tgt_y(i,1) tgt_y(i,2) tgt_y(i,2) tgt_y(i,1) tgt_y(i,1)];
        plot(tgt_time_tmp,tgt_x_tmp,'b'); % x target bounds in blue
        plot(tgt_time_tmp,tgt_y_tmp,'g'); % y target bounds in green
    end
       
end