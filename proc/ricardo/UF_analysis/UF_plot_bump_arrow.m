function UF_plot_bump_arrow(figHandle,hAxes,UF_struct,iBump,num_rows,position)
    if num_rows == 2
        y_offset = 40;
    else
        y_offset = 60;
    end
    if strcmpi(position,'south')
        y_offset = 80;
    end
    set(hAxes,'Visible','on')
    temp_axes = gca;
    gca_arrows = axes;
    axes_pos = get(temp_axes,'Position');
    set(gca_arrows,'Position',axes_pos);
    axis equal
    ylim([0 100])
    x_limit = get(gca_arrows,'XLim');
    bump_arrow_x = [0 12 9 12 9 12];
    bump_arrow_y = [0 0 3 0 -3 0];
    rot_arrow_x = bump_arrow_x*cos(UF_struct.bump_directions(iBump)) - bump_arrow_y*sin(UF_struct.bump_directions(iBump));
    rot_arrow_y = bump_arrow_x*sin(UF_struct.bump_directions(iBump)) + bump_arrow_y*cos(UF_struct.bump_directions(iBump));
    trans_arrow_x = x_limit(1)+rot_arrow_x+diff(x_limit)/5;
    trans_arrow_y = rot_arrow_y+y_offset;
    area([min(trans_arrow_x) min(trans_arrow_x) max(trans_arrow_x) max(trans_arrow_x) min(trans_arrow_x)],...
        [min(trans_arrow_y) max(trans_arrow_y) max(trans_arrow_y) min(trans_arrow_y) min(trans_arrow_y)],...
        'FaceColor','w','LineStyle','none');
    hold on  
    plot(trans_arrow_x,trans_arrow_y,'Color','k','LineWidth',2)
    set(gca_arrows,'Visible','off')      
    axis equal
    ylim([0 100])
    xlim(x_limit)    
    set(figHandle,'currentaxes',hAxes)
end