function UF_plot_field_arrows(figHandle,hAxes,UF_struct,iBias,iField,num_rows,position)
    if num_rows == 2
        y_offset = 100-20*iBias;
    else
        y_offset = 80;
    end
    if strcmpi(position,'south')
        y_offset = 100 - y_offset;
    end
        
    set(hAxes,'Visible','on')
    temp_axes = gca;
    gca_arrows = axes;
    axes_pos = get(temp_axes,'Position');
    set(gca_arrows,'Position',axes_pos);
    axis equal
    ylim([0 100])
    x_limit = get(gca_arrows,'XLim');
    field_arrows_x = [0 8 6 8 6 8 12 10 12 10 12 -8 -6 -8 -6 -8 -12 -10 -12 -10];            
    field_arrows_y = [0 0 2 0 -2 0 0 2 0 -2 0 0 2 0 -2 0 0 2 0 -2];
    rot_mat = [cos(UF_struct.field_orientations(iField)) -sin(UF_struct.field_orientations(iField));sin(UF_struct.field_orientations(iField)) cos(UF_struct.field_orientations(iField))];                
    rot_arrow_x = field_arrows_x*cos(UF_struct.field_orientations(iField)) - field_arrows_y*sin(UF_struct.field_orientations(iField));
    rot_arrow_y = field_arrows_x*sin(UF_struct.field_orientations(iField)) + field_arrows_y*cos(UF_struct.field_orientations(iField));
    trans_arrow_x = x_limit(1)+rot_arrow_x+diff(x_limit)/5+(iField-1)*20-10;
    trans_arrow_y = rot_arrow_y+y_offset;
%     plot(trans_arrow_x,trans_arrow_y,'Color','w','LineWidth',10);
    area([min(trans_arrow_x) min(trans_arrow_x) max(trans_arrow_x) max(trans_arrow_x) min(trans_arrow_x)],...
        [min(trans_arrow_y) max(trans_arrow_y) max(trans_arrow_y) min(trans_arrow_y) min(trans_arrow_y)],...
        'FaceColor','w','LineStyle','none');
    hold on    
    plot(trans_arrow_x,trans_arrow_y,'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:))
    hold on
    set(gca_arrows,'Visible','off')      
    axis equal
    ylim([0 100])
    xlim(x_limit)
    set(figHandle,'currentaxes',hAxes)
end