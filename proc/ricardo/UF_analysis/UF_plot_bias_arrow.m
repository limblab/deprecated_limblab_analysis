function UF_plot_bias_arrow(figHandle,hAxes,UF_struct,iBias,iField,num_rows,position)
    if UF_struct.bias_magnitude~=0
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
        bias_arrow_x = [0 8 6 8 6 8];
        bias_arrow_y = [0 0 2 0 -2 0];
        rot_arrow_x = bias_arrow_x*cos(UF_struct.bias_force_directions(iBias)) - bias_arrow_y*sin(UF_struct.bias_force_directions(iBias));
        rot_arrow_y = bias_arrow_x*sin(UF_struct.bias_force_directions(iBias)) + bias_arrow_y*cos(UF_struct.bias_force_directions(iBias));
        trans_arrow_x = x_limit(1)+rot_arrow_x+diff(x_limit)/5+(iField-1)*20-10;
        trans_arrow_y = rot_arrow_y+y_offset; 
        plot(trans_arrow_x,trans_arrow_y,'Color',UF_struct.colors_field_bias((iBias-1)*length(UF_struct.field_indexes)+iField,:),'LineWidth',2)
        set(gca_arrows,'Visible','off')      
        axis equal
        ylim([0 100])
        xlim(x_limit)    
        set(figHandle,'currentaxes',hAxes)
    end
end