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
    bdf.meta.task = 'RW';

    %add firing rate to the units fields of the bdf
    opts.binsize=0.05;
    opts.offset=-.015;
    opts.do_trial_table=1;
    opts.do_firing_rate=1;
    bdf=postprocess_bdf(bdf,opts);
    
    %% set up parse for tuning
    optionstruct.compute_pos_pds=0;
    optionstruct.compute_vel_pds=1;
    optionstruct.compute_acc_pds=0;
    optionstruct.compute_force_pds=0;
    optionstruct.compute_dfdt_pds=0;
    optionstruct.compute_dfdtdt_pds=0;
    if options.only_sorted
        for i=1:length(bdf.units)
            temp(i)=~(bdf.units(i).id(2)==0 | bdf.units(i).id(2)==255);
        end
        ulist=1:length(bdf.units);
        optionstruct.which_units=ulist(temp);
    end
    optionstruct.data_offset=-.015;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
    %% if we are doing unit pds, generate the parsed behavioral data
    if options.do_unit_pds
        %get the timepoints of interest from the bdf and compose them into
        %a structure to use with compute tuning
        behaviors = parse_for_tuning(bdf,'continuous','opts',optionstruct);
        output_data.unit_tuning_stats = compute_tuning(behaviors.FR,behaviors.armdata,[1 1 0 0 0 0],struct('num_rep',10),'poisson');

        output_data.unit_pd_table=get_pd_table(output_data.unit_tuning_stats,behaviors,bdf);
        h=figure('name','unit_PDs');
        figure_handles=[figure_handles h];
        hist(output_data.unit_pd_table.dir(~isnan(output_data.unit_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
  
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of unit PDs')
    
    end
    
    if options.do_electrode_pds
        %make a bdf with all the spikes in unsorted units, with one unit
        %per channel
        multiunit_bdf=remove_sorting(bdf);
        %recalculate the firing rate for each unit
        opts.do_trial_table=0;
        opts.do_firing_rate=1;
        multiunit_bdf=postprocess_bdf(multiunit_bdf,opts);
        %if we already parsed the behavior for single units:
        if exist('behaviors','var')
            %skip parsing the arm behavior again, and just find the firing
            %rate at the correct times
            behaviors.FR=-1*ones(length(behaviors.T),length(multiunit_bdf.units));
            behaviors.which_units=[1:length(multiunit_bdf.units)];
            for i=1:length(multiunit_bdf.units)
                behaviors.FR(:,i)=interp1(multiunit_bdf.units(1).FR(:,1),multiunit_bdf.units(i).FR(:,2),(behaviors.T));
            end
        else
            %if we didn't parse the arm behavior for the single units, then
            %we need to compute it and the firing rate matrix now
            behaviors = parse_for_tuning(bdf,'continuous','opts',optionstruct);
        end
        output_data.electrode_tuning_stats = compute_tuning(behaviors.FR,behaviors.armdata,[1 1 0 0 0 0],struct('num_rep',10),'poisson');
        output_data.electrode_pd_table=get_pd_table(output_data.electrode_tuning_stats,behaviors,bdf);
        h=figure('name','electrode_PDs');
        figure_handles=[figure_handles h];
        hist(output_data.electrode_pd_table.dir(~isnan(output_data.electrode_pd_table.dir))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
  
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of electrode PDs')
    end
end
