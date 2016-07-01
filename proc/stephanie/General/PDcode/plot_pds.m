function figure_handles = plot_pds(pd_table)

figure_handles = [];

        %plot a histogram of the unit pds
        h=figure('name','unit_PDs');
        figure_handles=[figure_handles h];
        hist(pd_table.dir(~isnan(pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
  
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of unit PDs')
        
        %% polar plot of all pds, with radial length equal to scaled modulation depth
        
        %compute a scaling factor for the polar plots to use. Polar plots
        %will use a log function of moddepth so that the small modulation
        %PDs are visible. The scaling factor scales all the moddepths up so
        %that the log produces positive values rather than negative values.
        %all log scaled polar plots of the unit PDs will use the same
        %factor
        mag_scale=1/min(pd_table.moddepth);
        h=figure('name','unit_polar_PDs');
        
        figure_handles=[figure_handles h];
        angs=[pd_table.dir pd_table.dir]';
        mags=log((1+[zeros(size(pd_table.dir)), mag_scale*pd_table.moddepth])');
        %dummy plot to get the polar axes set:
        polar(0,max(mags(2,:)))
        %set the colororder so we get a nice continuous variation
        % colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
        % set(gca,'colororder',colorhsv)
        %set(gcf,'colormap',colorhsv)
        hold all
        h=polar(angs,mags);
        set(h,'linewidth',2)
        hold off
        title(['\fontsize{14}Polar plot of all unit PDs.','\newline',...
                '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])