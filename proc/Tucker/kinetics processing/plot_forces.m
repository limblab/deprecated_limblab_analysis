function plot_forces(bumps,tdf,range)
    plot(bumps(range(1):range(2),1),bumps(range(1):range(2),2))
    hold on
    plot(tdf.force(range(1):range(2),1),tdf.force(range(1):range(2),2),'r')
    title('x forces')
    legend('expected','actual')
    figure
    plot(bumps(range(1):range(2),1),bumps(range(1):range(2),3))
    hold on
    plot(tdf.force(range(1):range(2),1),tdf.force(range(1):range(2),3),'r')
    title('y forces')
    legend('expected','actual')
end