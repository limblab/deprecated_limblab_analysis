function format_for_lee(fhandle)
    %takes a figure and formats for Lee, accepts the handle of a figure and
    %operates on the current axes, accepts the handle of axes and operates
    %on those axes, accepts a child object of a an axes (lineseries handle
    %etc) and operates on the parent object of that series
    if ishghandle(fhandle,'figure')
        figure(fhandle)
        set(gca,'TickDir','out')
        set(gca, 'box', 'off')
        set(gca, 'XMinorTick', 'on')
        set(gca, 'YMinorTick', 'on')
    elseif ishghandle(fhandle,'axis')
        set(fhandle,'TickDir','out')
        set(fhandle, 'box', 'off')
        set(fhandle, 'XMinorTick', 'on')
        set(fhandle, 'YMinorTick', 'on')
    else %ishghandle(fhandle,'lineseries')
        set(get(fhandle,'Parent'),'TickDir','out')
        set(get(fhandle,'Parent'), 'box', 'off')
        set(get(fhandle,'Parent'), 'XMinorTick', 'on')
        set(get(fhandle,'Parent'), 'YMinorTick', 'on')
    end
end