function plot_bump_errors(bumps,tdf,range)

    err=bumps(:,2:3)-tdf.force(:,2:3);

    plot(bumps(range(1):range(2),1),err(range(1):range(2),1))
    title('err fx')
    figure
    plot(bumps(range(1):range(2),1),err(range(1):range(2),2))
    title('err fy')




end