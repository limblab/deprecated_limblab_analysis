function [figure_handles, output_data]=get_PDs(folder,options)
    figure_handles=[];
    
%     matfilelist=dir([folder filesep options.prefix '*.mat']);
%     nevfilelist=dir([folder filesep options.prefix '*.nev']);
%     if ~isempty(matfilelist)
%         temp=load([folder filesep matfilelist(1).name]);
%         y=fieldnames(temp);
%         if length(y)==1
%             NSx=temp.(y{1});
%         else
%             error('get_PDs: loaded multiple variables from .mat file')
%         end
%     elseif ~isempty(nevfilelist)
%         NSx=cerebus2NEVNSx(folder,options.prefix);
%     else
%         error('get_PDs:found no matching files')
%     end
    NSx=cerebus2NEVNSx(folder,options.prefix);
    bdf = get_nev_mat_data(NSx,options.labnum);

    %% prep bdf
    if isfield(options,'task')
        bdf.meta.task=options.task;
    else
        bdf.meta.task = 'RW';
    end
    %detect a bad pos field for the 'WF' task
    if strcmp(bdf.meta.task,'WF');
        bdf.force.data=double(bdf.force.data);
        if size(bdf.pos,1)~=size(bdf.force.data,1)
            warning('position data is bad, replacing pos field with bdf.force.data')
            bdf.pos=bdf.force.data;
        end
    end
    %add firing rate to the units fields of the bdf
    if isfield(options,'offset')
        opts.offset=options.offset;
    else
        %opts.offset=-.015;
        opts.offset=0;
    end
    if isfield(options,'binsize')
        opts.binsize=options.binsize;
    else
        opts.binsize=0.05;
    end
    opts.do_trial_table=1;
    opts.do_firing_rate=1;
    bdf=postprocess_bdf(bdf,opts);
    
    output_data.bdf=bdf;
    %% set up parse for tuning
    if isfield(options,'pos_pd')
        optionstruct.compute_pos_pds=options.vel_pd;
    else
        optionstruct.compute_pos_pds=0;
    end
    
    if isfield(options,'vel_pd')
        optionstruct.compute_vel_pds=options.vel_pd;
    else
        optionstruct.compute_vel_pds=1;
    end
    
    if isfield(options,'acc_pd')
        optionstruct.compute_acc_pds=options.acc_pd;
    else
        optionstruct.compute_acc_pds=0;
    end
    
    if isfield(options,'force_pd')
        optionstruct.compute_force_pds=options.force_pd;
    else
        optionstruct.compute_force_pds=0;
    end
    
    if isfield(options,'dfdt_pd')
        optionstruct.compute_dfdt_pds=options.dfdt_pd;
    else
        optionstruct.compute_dfdt_pds=0;
    end
    
    if isfield(options,'dfdtdt_pd')
        optionstruct.compute_dfdtdt_pds=options.dfdtdt_pd;
    else
        optionstruct.compute_dfdtdt_pds=0;
    end
    
    if isfield(options,'offset')%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
        optionstruct.data_offset=options.offset;
    else
        optionstruct.data_offset=0;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
    end
    
    which_units=1:length(bdf.units);
    if isfield(options, 'only_sorted')
        if options.only_sorted
            for i=1:length(bdf.units)
                temp(i)=~(bdf.units(i).id(2)==0 | bdf.units(i).id(2)==255);
            end
            ulist=1:length(bdf.units);
            which_units=which_units(temp);
        end
    end
    
    %% if we are doing unit pds, generate the parsed behavioral data
    if options.do_unit_pds
        %get the timepoints of interest from the bdf and compose them into
        %a structure to use with compute tuning
        behaviors = parse_for_tuning(bdf,'continuous','opts',optionstruct,'units',which_units);

        output_data.unit_tuning_stats = compute_tuning(behaviors,[1 1 0 0 0 0 0],struct('num_rep',10),'poisson');
        output_data.unit_pd_table=get_pd_table(output_data.unit_tuning_stats,behaviors,bdf);
        %make a table that only has the best tuned units:
        output_data.unit_best_modulated_table=output_data.unit_pd_table(output_data.unit_pd_table.moddepth>median(output_data.unit_pd_table.moddepth),:);
        
        %plot a histogram of the unit pds
        h=figure('name','unit_PDs');
        figure_handles=[figure_handles h];
        hist(output_data.unit_pd_table.dir(~isnan(output_data.unit_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
  
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of unit PDs')
        %make a histogram of the best modulated PDs
        h=figure('name','unit_best_modulated_PDs');
        figure_handles=[figure_handles h];
        hist(output_data.unit_best_modulated_table.dir(~isnan(output_data.unit_best_modulated_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
  
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of the best modulated electrode PDs')
        
        %polar plot of all pds, with radial length equal to scaled 
        %modulation depth
        %compute a scaling factor for the polar plots to use. Polar plots
        %will use a log function of moddepth so that the small modulation
        %PDs are visible. The scaling factor scales all the moddepths up so
        %that the log produces positive values rather than negative values.
        %all log scaled polar plots of the unit PDs will use the same
        %factor
        mag_scale=1/min(output_data.unit_pd_table.moddepth);
        h=figure('name','unit_polar_PDs');
        
        figure_handles=[figure_handles h];
        angs=[output_data.unit_pd_table.dir output_data.unit_pd_table.dir]';
        mags=log((1+[zeros(size(output_data.unit_pd_table.dir)), mag_scale*output_data.unit_pd_table.moddepth])');
        %dummy plot to get the polar axes set:
        polar(0,max(mags(2,:)))
        %set the colororder so we get a nice continuous variation
        colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
        set(gca,'colororder',colorhsv)
        %set(gcf,'colormap',colorhsv)
        hold all
        h=polar(angs,mags);
        set(h,'linewidth',2)
        hold off
        title(['\fontsize{14}Polar plot of all unit PDs.','\newline',...
                '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])
        
        %polar plot of best modulated pds, with radial length equal to 
        %scaled modulation depth
        h=figure('name','unit_best_modulated_polar_PDs');
        figure_handles=[figure_handles h];
        angs=[output_data.unit_best_modulated_table.dir output_data.unit_best_modulated_table.dir]';
        mags=log((1+[zeros(size(output_data.unit_best_modulated_table.dir)), mag_scale*output_data.unit_best_modulated_table.moddepth])');
        %dummy plot to get the polar axes set:
        polar(0,max(mags(2,:)))
        %set the colororder so we get a nice continuous variation
        colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
        set(gca,'colororder',colorhsv)
        %set(gcf,'colormap',colorhsv)
        hold all
        h=polar(angs,mags);
        set(h,'linewidth',2)
        hold off
        title(['\fontsize{14}Polar plot of best modulated unit PDs.','\newline',...
                '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])
            
        output_data.unit_behaviors=behaviors;
        if optionstruct.compute_vel_pds
            output_data.unit_tuning_stats = compute_tuning(behaviors,[1 1 0 0 0 0 0],struct('num_rep',10),'poisson');
            output_data.unit_pd_table=get_pd_table(output_data.unit_tuning_stats,'vel');

            %make a table that only has the best tuned units:
            output_data.unit_best_modulated_table=output_data.unit_pd_table(output_data.unit_pd_table.moddepth>median(output_data.unit_pd_table.moddepth),:);

            %plot a histogram of the unit pds
            h=figure('name','unit_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.unit_pd_table.dir(~isnan(output_data.unit_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('PD counts')
            title('Histogram of unit PDs')
            %make a histogram of the best modulated PDs
            h=figure('name','unit_best_modulated_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.unit_best_modulated_table.dir(~isnan(output_data.unit_best_modulated_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('PD counts')
            title('Histogram of the best modulated electrode PDs')

            %polar plot of all pds, with radial length equal to scaled 
            %modulation depth
            %compute a scaling factor for the polar plots to use. Polar plots
            %will use a log function of moddepth so that the small modulation
            %PDs are visible. The scaling factor scales all the moddepths up so
            %that the log produces positive values rather than negative values.
            %all log scaled polar plots of the unit PDs will use the same
            %factor
            mag_scale=1/min(output_data.unit_pd_table.moddepth);
            h=figure('name','unit_polar_PDs');

            figure_handles=[figure_handles h];
            angs=[output_data.unit_pd_table.dir output_data.unit_pd_table.dir]';
            mags=log((1+[zeros(size(output_data.unit_pd_table.dir)), mag_scale*output_data.unit_pd_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            %set(gcf,'colormap',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of all unit PDs.','\newline',...
                    '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])

            %polar plot of best modulated pds, with radial length equal to 
            %scaled modulation depth
            h=figure('name','unit_best_modulated_polar_PDs');
            figure_handles=[figure_handles h];
            angs=[output_data.unit_best_modulated_table.dir output_data.unit_best_modulated_table.dir]';
            mags=log((1+[zeros(size(output_data.unit_best_modulated_table.dir)), mag_scale*output_data.unit_best_modulated_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            %set(gcf,'colormap',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of best modulated unit PDs.','\newline',...
                    '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])
        end
        if optionstruct.compute_force_pds
            output_data.unit_force_tuning_stats = compute_tuning(behaviors,[0 0 0 1 0 0 0],struct('num_rep',10),'poisson');
            output_data.unit_force_pd_table=get_pd_table(output_data.unit_force_tuning_stats,'force');

            %make a table that only has the best tuned units:
            output_data.unit_best_modulated_force_table=output_data.unit_force_pd_table(output_data.unit_force_pd_table.moddepth>median(output_data.unit_force_pd_table.moddepth),:);

            %plot a histogram of the unit pds
            h=figure('name','unit_force_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.unit_force_pd_table.dir(~isnan(output_data.unit_force_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('force PD counts')
            title('Histogram of unit force PDs')
            %make a histogram of the best modulated PDs
            h=figure('name','unit_best_modulated_force_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.unit_best_modulated_force_table.dir(~isnan(output_data.unit_best_modulated_force_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('force PD counts')
            title('Histogram of the best modulated unit force PDs')

            %polar plot of all pds, with radial length equal to scaled 
            %modulation depth
            %compute a scaling factor for the polar plots to use. Polar plots
            %will use a log function of moddepth so that the small modulation
            %PDs are visible. The scaling factor scales all the moddepths up so
            %that the log produces positive values rather than negative values.
            %all log scaled polar plots of the unit PDs will use the same
            %factor
            mag_scale=1/min(output_data.unit_force_pd_table.moddepth);
            h=figure('name','unit_polar_force_PDs');

            figure_handles=[figure_handles h];
            angs=[output_data.unit_force_pd_table.dir output_data.unit_force_pd_table.dir]';
            mags=log((1+[zeros(size(output_data.unit_force_pd_table.dir)), mag_scale*output_data.unit_force_pd_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            %set(gcf,'colormap',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of all unit force PDs.','\newline',...
                    '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])

            %polar plot of best modulated pds, with radial length equal to 
            %scaled modulation depth
            h=figure('name','unit_best_modulated_polar_force_PDs');
            figure_handles=[figure_handles h];
            angs=[output_data.unit_best_modulated_force_table.dir output_data.unit_best_modulated_force_table.dir]';
            mags=log((1+[zeros(size(output_data.unit_best_modulated_force_table.dir)), mag_scale*output_data.unit_best_modulated_force_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            %set(gcf,'colormap',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of best modulated unit force PDs.','\newline',...
                    '\fontsize{10}Amplitude normalized and log scaled for pretty picture.'])
        end
    end
    
    if options.do_electrode_pds
        %make a bdf with all the spikes in unsorted units, with one unit
        %per channel
        multiunit_bdf=remove_sorting(bdf);
        
        %recalculate the firing rate for each unit
        opts.do_trial_table=0;
        opts.do_firing_rate=1;
        multiunit_bdf=postprocess_bdf(multiunit_bdf,opts);
        output_data.multiunit_bdf=multiunit_bdf;
        %if we already parsed the behavior for single units:
        if exist('behaviors','var')
            %skip parsing the arm behavior again, and just find the firing
            %rate at the correct times
            behaviors.FR=-1*ones(length(behaviors.T),length(multiunit_bdf.units));
            behaviors.which_units=[1:length(multiunit_bdf.units)];
            for i=1:length(multiunit_bdf.units)
                behaviors.FR(:,i)=interp1(multiunit_bdf.units(1).FR(:,1),multiunit_bdf.units(i).FR(:,2),(behaviors.T));
                behaviors.unit_ids(i,:) = multiunit_bdf.units(i).id;
            end
        else
            %if we didn't parse the arm behavior for the single units, then
            %we need to compute it and the firing rate matrix now
            behaviors = parse_for_tuning(multiunit_bdf,'continuous','opts',optionstruct,'units',which_units);
        end
        output_data.electrode_behaviors=behaviors;
        if optionstruct.compute_vel_pds
            output_data.electrode_tuning_stats = compute_tuning(behaviors,[1 1 0 0 0 0 0],struct('num_rep',10),'poisson');
            output_data.electrode_pd_table=get_pd_table(output_data.electrode_tuning_stats);
            %make a table that only has the best tuned electrodes:
            output_data.electrode_best_modulated_table=output_data.electrode_pd_table(output_data.electrode_pd_table.moddepth>median(output_data.electrode_pd_table.moddepth),:);

            %make a histogram of all PDs
            h=figure('name','electrode_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.electrode_pd_table.dir(~isnan(output_data.electrode_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('PD counts')
            title('Histogram of electrode PDs')
            %make a histogram of the best modulated PDs
            h=figure('name','electrode_best_modulated_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.electrode_best_modulated_table.dir(~isnan(output_data.electrode_best_modulated_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('PD counts')
            title('Histogram of the best modulated electrode PDs')

            %polar plot of all pds, with radial length equal to scaled 
            %modulation depth
            %compute a scaling factor for the polar plots to use. Polar plots
            %will use a log function of moddepth so that the small modulation
            %PDs are visible. The scaling factor scales all the moddepths up so
            %that the log produces positive values rather than negative values.
            %all log scaled polar plots of the unit PDs will use the same
            %factor
            mag_scale=1/min(output_data.electrode_pd_table.moddepth);
            h=figure('name','electrode_polar_PDs');
            figure_handles=[figure_handles h];
            angs=[output_data.electrode_pd_table.dir output_data.electrode_pd_table.dir]';
            mags=log((1+[zeros(size(output_data.electrode_pd_table.dir)), mag_scale*output_data.electrode_pd_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of all electrode PDs.','\newline',...
                    '\fontsize{10} Amplitude normalized and log scaled for pretty picture.'])

            %polar plot of best modulated pds, with radial length equal to 
            %scaled modulation depth
            h=figure('name','electrode_best_modulated_polar_PDs');
            figure_handles=[figure_handles h];
            angs=[output_data.electrode_best_modulated_table.dir output_data.electrode_best_modulated_table.dir]';
            mags=log((1+[zeros(size(output_data.electrode_best_modulated_table.dir)), mag_scale*output_data.electrode_best_modulated_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of best modulated electrode PDs.','\newline',...
                    '\fontsize{10} Amplitude normalized and log scaled for pretty picture.'])
        end
        if optionstruct.compute_force_pds
            output_data.electrode_force_tuning_stats = compute_tuning(behaviors,[0 0 0 1 0 0 0],struct('num_rep',10),'poisson');
            output_data.electrode_force_pd_table=get_pd_table(output_data.electrode_force_tuning_stats);
            %make a table that only has the best tuned electrodes:
            output_data.electrode_best_modulated_force_table=output_data.electrode_force_pd_table(output_data.electrode_force_pd_table.moddepth>median(output_data.electrode_force_pd_table.moddepth),:);

            %make a histogram of all PDs
            h=figure('name','electrode_force_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.electrode_force_pd_table.dir(~isnan(output_data.electrode_force_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('force PD counts')
            title('Histogram of electrode force PDs')
            %make a histogram of the best modulated PDs
            h=figure('name','electrode_best_modulated_force_PDs');
            figure_handles=[figure_handles h];
            hist(output_data.electrode_best_modulated_force_table.dir(~isnan(output_data.electrode_best_modulated_force_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths

            xlabel('degrees')
            ylabel('force PD counts')
            title('Histogram of the best modulated electrode force PDs')

            %polar plot of all pds, with radial length equal to scaled 
            %modulation depth
            %compute a scaling factor for the polar plots to use. Polar plots
            %will use a log function of moddepth so that the small modulation
            %PDs are visible. The scaling factor scales all the moddepths up so
            %that the log produces positive values rather than negative values.
            %all log scaled polar plots of the unit PDs will use the same
            %factor
            mag_scale=1/min(output_data.electrode_force_pd_table.moddepth);
            h=figure('name','electrode_polar_force_PDs');
            figure_handles=[figure_handles h];
            angs=[output_data.electrode_force_pd_table.dir output_data.electrode_force_pd_table.dir]';
            mags=log((1+[zeros(size(output_data.electrode_force_pd_table.dir)), mag_scale*output_data.electrode_force_pd_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of all electrode force PDs.','\newline',...
                    '\fontsize{10} Amplitude normalized and log scaled for pretty picture.'])

            %polar plot of best modulated pds, with radial length equal to 
            %scaled modulation depth
            h=figure('name','electrode_best_modulated_polar_force_PDs');
            figure_handles=[figure_handles h];
            angs=[output_data.electrode_best_modulated_force_table.dir output_data.electrode_best_modulated_force_table.dir]';
            mags=log((1+[zeros(size(output_data.electrode_best_modulated_force_table.dir)), mag_scale*output_data.electrode_best_modulated_force_table.moddepth])');
            %dummy plot to get the polar axes set:
            polar(0,max(mags(2,:)))
            %set the colororder so we get a nice continuous variation
            colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),[0,angs(1,:)]);
            set(gca,'colororder',colorhsv)
            hold all
            h=polar(angs,mags);
            set(h,'linewidth',2)
            hold off
            title(['\fontsize{14}Polar plot of best modulated electrode force PDs.','\newline',...
                    '\fontsize{10} Amplitude normalized and log scaled for pretty picture.'])
            
        end
    end
end
