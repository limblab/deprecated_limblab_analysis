function [figure_handles, output_data]=compare_workspace_PDs(folder,options)
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
    if(folder(end)~=filesep)
        folder = [folder filesep];
    end
    bdf_DL = get_nev_mat_data([folder options.prefix '_DL'],options.labnum);
    bdf_PM = get_nev_mat_data([folder options.prefix '_PM'],options.labnum);
    output_data.bdf_DL=bdf_DL;
    output_data.bdf_PM=bdf_PM;
    %% prep bdf
    bdf_DL.meta.task = 'RW';
    bdf_PM.meta.task = 'RW';

    %add firing rate to the units fields of the bdf
    opts.binsize=0.05;
    opts.offset=-.015;
    opts.do_trial_table=1;
    opts.do_firing_rate=1;
    bdf_DL=postprocess_bdf(bdf_DL,opts);
    bdf_PM=postprocess_bdf(bdf_PM,opts);
    output_data.bdf_DL=bdf_DL;
    output_data.bdf_PM=bdf_PM;
    %% set up parse for tuning
    optionstruct.compute_pos_pds=0;
    optionstruct.compute_vel_pds=1;
    optionstruct.compute_acc_pds=0;
    optionstruct.compute_force_pds=0;
    optionstruct.compute_dfdt_pds=0;
    optionstruct.compute_dfdtdt_pds=0;
    if options.only_sorted
        for i=1:length(bdf_DL.units)
            temp(i)=bdf_DL.units(i).id(2)~=0 && bdf_DL.units(i).id(2)~=255;
        end
        ulist=1:length(bdf_DL.units);
        which_units_DL=ulist(temp);
        
        for i=1:length(bdf_PM.units)
            temp(i)=bdf_PM.units(i).id(2)~=0 && bdf_PM.units(i).id(2)~=255;
        end
        ulist=1:length(bdf_PM.units);
        which_units_PM=ulist(temp);
    end
    optionstruct.data_offset=-.015;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
    %% if we are doing unit pds, generate the parsed behavioral data
    if options.do_unit_pds
        %% set the model terms
        model_terms = [1 1 0 0 0 0 0];
        model_terms_full = [1 1 0 0 0 0 0 1];
        
        %get the timepoints of interest from the bdf and compose them into
        %a structure to use with compute tuning
        behaviors_DL = parse_for_tuning(bdf_DL,'continuous','opts',optionstruct,'units',which_units_DL);
        behaviors_PM = parse_for_tuning(bdf_PM,'continuous','opts',optionstruct,'units',which_units_PM);
        
        %compose full behaviors structure
        behaviors_full = behaviors_PM;
        armdata_terms_PM = behaviors_PM.armdata(logical(model_terms));
        armdata_terms_DL = behaviors_DL.armdata(logical(model_terms));
        behaviors_full.armdata(length(model_terms)+1).data = [ones(size([armdata_terms_DL.data],1),1) [armdata_terms_DL.data]];
        behaviors_full.armdata(length(model_terms)+1).data = [zeros(size([behaviors_PM.armdata(length(model_terms)).data],1),size([armdata_terms_PM.data],2)+1); [behaviors_full.armdata(length(model_terms)+1).data]];
        behaviors_full.armdata(length(model_terms)+1).name = 'condition';
        behaviors_full.armdata(length(model_terms)+1).num_lags = 0;
        behaviors_full.armdata(length(model_terms)+1).num_base_cols = size([armdata_terms_PM.data],2)+1;
        behaviors_full.armdata(length(model_terms)+1).doPD = 0;
        behaviors_full.FR = [behaviors_PM.FR;behaviors_DL.FR];
        behaviors_full.T = [behaviors_PM.T;behaviors_DL.T];
        behaviors_full.which_units = behaviors_PM.which_units;
        behaviors_full.unit_ids = behaviors_PM.unit_ids;
        behaviors_full.lags = behaviors_PM.lags;
        for i = 1:length(model_terms)
            behaviors_full.armdata(i).data = [behaviors_full.armdata(i).data; behaviors_DL.armdata(i).data];
        end
        
        %Compute individual tunings
        output_data.unit_tuning_stats_DL = compute_tuning(behaviors_DL,model_terms,struct('num_rep',10),'poisson');
        output_data.unit_tuning_stats_PM = compute_tuning(behaviors_PM,model_terms,struct('num_rep',10),'poisson');
        output_data.unit_pd_table_DL=sortrows(get_pd_table(output_data.unit_tuning_stats_DL),[1 2]);
        output_data.unit_pd_table_PM=sortrows(get_pd_table(output_data.unit_tuning_stats_PM),[1 2]);
        
        %Compute full tunings
        output_data.unit_tuning_stats_full = compute_tuning(behaviors_full,model_terms_full,struct('num_rep',10),'poisson');
        output_data.unit_pd_table_full=sortrows(get_pd_table(output_data.unit_tuning_stats_full),[1 2]);
        
        %make a table that only has the best tuned units:
        output_data.unit_best_modulated_table_DL=output_data.unit_pd_table_DL(abs(diff(output_data.unit_pd_table_DL.dir_CI,1,2))<pi/4,:);
        output_data.unit_best_modulated_table_PM=output_data.unit_pd_table_PM(abs(diff(output_data.unit_pd_table_PM.dir_CI,1,2))<pi/4,:);
        [~,best_combined_idx_DL,best_combined_idx_PM] = intersect(double(output_data.unit_best_modulated_table_DL(:,1:2)),double(output_data.unit_best_modulated_table_PM(:,1:2)),'rows');
        output_data.unit_best_combined_table_DL = output_data.unit_best_modulated_table_DL(best_combined_idx_DL,:);
        output_data.unit_best_combined_table_PM = output_data.unit_best_modulated_table_PM(best_combined_idx_PM,:);
        
        output_data.behaviors_DL = behaviors_DL;
        output_data.behaviors_PM = behaviors_PM;
        output_data.behaviors_full = behaviors_full;
        
        %% figures
        if(options.dual_array)
            array_break = options.array_break;
        end
        
        figure_handles = [];
        
        %polar plot of all pds, with radial length equal to scaled 
        %modulation depth
        %compute a scaling factor for the polar plots to use. Polar plots
        %will use a log function of moddepth so that the small modulation
        %PDs are visible. The scaling factor scales all the moddepths up so
        %that the log produces positive values rather than negative values.
        %all log scaled polar plots of the unit PDs will use the same
        %factor
        mag_scale_DL=1/min(output_data.unit_pd_table_DL.moddepth);
        angs_DL=[output_data.unit_pd_table_DL.dir output_data.unit_pd_table_DL.dir]';
        mags_DL=log((1+[zeros(size(output_data.unit_pd_table_DL.dir)), mag_scale_DL*output_data.unit_pd_table_DL.moddepth])');
        angs_best_DL=[output_data.unit_best_modulated_table_DL.dir output_data.unit_best_modulated_table_DL.dir]';
        mags_best_DL=log((1+[zeros(size(output_data.unit_best_modulated_table_DL.dir)), mag_scale_DL*output_data.unit_best_modulated_table_DL.moddepth])');
        
        %Plot the DL set in unsaturated colors
        h=figure('name','unit_polar_PDs_DL');
        figure_handles=[figure_handles h];
        polar(0,max(mags_DL(2,:)))
        hold all
        if(options.dual_array)
            %assumes table is sorted by channel and then unit
            array_break_idx = find(output_data.unit_pd_table_DL.channel>array_break,1,'first');
            h=polar(angs_DL(:,1:array_break_idx-1),mags_DL(:,1:array_break_idx-1));
            set(h,'linewidth',2,'color',[0.8 0.8 1])
            h=polar(angs_DL(:,array_break_idx:end),mags_DL(:,array_break_idx:end));
            set(h,'linewidth',2,'color',[0.8 01 0.8])
            
            array_break_idx = find(output_data.unit_best_modulated_table_DL.channel>array_break,1,'first');
            h=polar(angs_best_DL(:,1:array_break_idx-1),mags_best_DL(:,1:array_break_idx-1));
            set(h,'linewidth',2,'color',[0 0 1])
            h=polar(angs_best_DL(:,array_break_idx:end),mags_best_DL(:,array_break_idx:end));
            set(h,'linewidth',2,'color',[0 1 0])
        else
            h=polar(angs_DL,mags_DL);
            set(h,'linewidth',2,'color',[0.8 0.8 1])
            h=polar(angs_best_DL,mags_best_DL);
            set(h,'linewidth',2,'color',[0 0 1])
        end
        hold off
        title(['\fontsize{14}Polar plot of all DL unit PDs.','\newline',...
                '\fontsize{10}Amplitude normalized and log scaled'])
        
        %Set up the PM things
        mag_scale_PM=1/min(output_data.unit_pd_table_PM.moddepth);
        angs_PM=[output_data.unit_pd_table_PM.dir output_data.unit_pd_table_PM.dir]';
        mags_PM=log((1+[zeros(size(output_data.unit_pd_table_PM.dir)), mag_scale_PM*output_data.unit_pd_table_PM.moddepth])');
        angs_best_PM=[output_data.unit_best_modulated_table_PM.dir output_data.unit_best_modulated_table_PM.dir]';
        mags_best_PM=log((1+[zeros(size(output_data.unit_best_modulated_table_PM.dir)), mag_scale_PM*output_data.unit_best_modulated_table_PM.moddepth])');
        
        %Plot the PM set in unsaturated colors
        h=figure('name','unit_polar_PDs_PM');
        figure_handles=[figure_handles h];
        polar(0,max(mags_PM(2,:)))
        hold all
        if(options.dual_array)
            %assumes table is sorted by channel and then unit
            array_break_idx = find(output_data.unit_pd_table_PM.channel>array_break,1,'first');
            h=polar(angs_PM(:,1:array_break_idx-1),mags_PM(:,1:array_break_idx-1));
            set(h,'linewidth',2,'color',[0.8 0.8 1])
            h=polar(angs_PM(:,array_break_idx:end),mags_PM(:,array_break_idx:end));
            set(h,'linewidth',2,'color',[0.8 01 0.8])
            
            array_break_idx = find(output_data.unit_best_modulated_table_PM.channel>array_break,1,'first');
            h=polar(angs_best_PM(:,1:array_break_idx-1),mags_best_PM(:,1:array_break_idx-1));
            set(h,'linewidth',2,'color',[0 0 1])
            h=polar(angs_best_PM(:,array_break_idx:end),mags_best_PM(:,array_break_idx:end));
            set(h,'linewidth',2,'color',[0 1 0])
        else
            h=polar(angs_PM,mags_PM);
            set(h,'linewidth',2,'color',[0.8 0.8 1])
            h=polar(angs_best_PM,mags_best_PM);
            set(h,'linewidth',2,'color',[0 0 1])
        end
        hold off
        title(['\fontsize{14}Polar plot of all PM unit PDs.','\newline',...
                '\fontsize{10}Amplitude normalized and log scaled'])
        
        
        %Plot PD change diagram
        h=figure('name','unit_polar_PD_differences');
        figure_handles=[figure_handles h];
        %plot circles
        h=polar(linspace(-pi,pi,1000),ones(1,1000));
        set(h,'linewidth',1,'color',[0.5 0.5 0.5])
        hold all
        h=polar(linspace(-pi,pi,1000),0.5*ones(1,1000));
        set(h,'linewidth',1,'color',[0.5 0.5 0.5])
        %plot desaturated changes
        if(options.dual_array)
            %assumes table is sorted by channel and then unit
            array_break_idx = find(output_data.unit_pd_table_DL.channel>array_break,1,'first');
        else
            array_break_idx=inf;
        end
        for unit_ctr = 1:length(output_data.unit_pd_table_DL.dir)
            if(unit_ctr<array_break_idx)
                h=polar(linspace(angs_PM(1,unit_ctr),angs_DL(1,unit_ctr),2),linspace(0.5,1,2));
                set(h,'linewidth',2,'color',[0.8 0.8 1])
            else
                h=polar(linspace(angs_PM(1,unit_ctr),angs_DL(1,unit_ctr),2),linspace(0.5,1,2));
                set(h,'linewidth',2,'color',[0.8 1 0.8])
            end
        end
        %plot best modulated changes
        angs_best_comb_PM=[output_data.unit_best_combined_table_PM.dir output_data.unit_best_combined_table_PM.dir]';
        angs_best_comb_DL=[output_data.unit_best_combined_table_DL.dir output_data.unit_best_combined_table_DL.dir]';
        if(options.dual_array)
            %assumes table is sorted by channel and then unit
            array_break_idx = find(output_data.unit_best_combined_table_DL.channel>array_break,1,'first');
        else
            array_break_idx=inf;
        end
        for unit_ctr = 1:length(output_data.unit_best_combined_table_DL.dir)
            if(unit_ctr<array_break_idx)
                h=polar(linspace(angs_best_comb_PM(1,unit_ctr),angs_best_comb_DL(1,unit_ctr),2),linspace(0.5,1,2));
                set(h,'linewidth',2,'color',[0 0 1])
            else
                h=polar(linspace(angs_best_comb_PM(1,unit_ctr),angs_best_comb_DL(1,unit_ctr),2),linspace(0.5,1,2));
                set(h,'linewidth',2,'color',[0 1 0])
            end
        end
        title('Plot of PD changes')
        
        % Plot all tuning curves
        % get tuning curves for DL
        tuningopts_DL.behaviors = behaviors_DL;
        tuningopts_DL.plot_curves = 0;
        [~,tuning_out_DL] = get_tuning_curves(folder,tuningopts_DL);
        
        % get tuning curves for PM
        tuningopts_PM.behaviors = behaviors_PM;
        tuningopts_PM.plot_curves = 0;
        [~,tuning_out_PM] = get_tuning_curves(folder,tuningopts_PM);
        
        % plot tuning curves
        unit_ids = behaviors_DL.unit_ids;
        dir_CI_DL = output_data.unit_pd_table_DL.dir_CI;
        dir_CI_PM = output_data.unit_pd_table_PM.dir_CI;
        for i=1:length(unit_ids)
            h = figure('name',['channel_' num2str(unit_ids(i,1)) '_unit_' num2str(unit_ids(i,2)) '_tuning_plot']);
            figure_handles = [figure_handles h];
            
            % Figure out max size to display at
            rad_DL = max(tuning_out_DL.binned_FR(:,i));
            rad_PM = max(tuning_out_PM.binned_FR(:,i));
            max_rad = max([tuning_out_DL.binned_FR(:,i); tuning_out_PM.binned_FR(:,i)]);
            
            h=polar(0,max_rad);
            set(h,'color','w')
            hold all
            
            % DL workspace
            h=polar(repmat(tuning_out_DL.bins,2,1),repmat(tuning_out_DL.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',[1 0 0])
            h=polar(angs_DL(:,i),max_rad*[0;1]);
            set(h,'linewidth',2,'color',[1 0 0])
            th_fill = [dir_CI_DL(i,2) angs_DL(1,i) dir_CI_DL(i,1) 0];
            r_fill = [max_rad max_rad max_rad 0];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[1 0 0],'facealpha',0.3);
            
            % PM workspace
            h=polar(repmat(tuning_out_PM.bins,2,1),repmat(tuning_out_PM.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',[0.6 0.5 0.7])
            h=polar(angs_PM(:,i),max_rad*[0;1]);
            set(h,'linewidth',2,'color',[0.6 0.5 0.7])
            th_fill = [dir_CI_PM(i,2) angs_PM(1,i) dir_CI_PM(i,1) 0];
            r_fill = [max_rad max_rad max_rad 0];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[0.6 0.5 0.7],'facealpha',0.3);
            hold off
        end
        
        %% Statistics on PD changes
        % only look at best tuned units
        % find how many significantly change PD (non-overlapping CI)
        dir_CI_DL = output_data.unit_best_combined_table_DL.dir_CI;
        dir_CI_PM = output_data.unit_best_combined_table_PM.dir_CI;
        sig_change = ~( (dir_CI_DL(:,1)>dir_CI_PM(:,1) & dir_CI_DL(:,1)<dir_CI_PM(:,2)) | (dir_CI_DL(:,2)>dir_CI_PM(:,1) & dir_CI_DL(:,2)<dir_CI_PM(:,2)) );
        output_data.sig_change = sig_change;
        % separate stats
        if(options.dual_array)
            %assumes table is sorted by channel and then unit
            % Check if change over each array is significantly different
            % from zero
            array_break_idx = find(output_data.unit_best_combined_table_DL.channel>array_break,1,'first');
            [hyp1,p1] = ttest(angs_best_comb_PM(1,1:array_break_idx-1),angs_best_comb_DL(1,1:array_break_idx-1));
            [hyp2,p2] = ttest(angs_best_comb_PM(1,array_break_idx:end),angs_best_comb_DL(1,array_break_idx:end));
            mean1 = mean(angs_best_comb_DL(1,1:array_break_idx-1)-angs_best_comb_PM(1,1:array_break_idx-1));
            mean2 = mean(angs_best_comb_DL(1,array_break_idx:end)-angs_best_comb_PM(1,array_break_idx:end));
            output_data.array_change_signif = [hyp1;hyp2];
            output_data.array_change_pval = [p1;p2];
            output_data.array_change_mean = [mean1;mean2];
            
            % Test if changes over arrays are different from each other
            PD_diff1 = angs_best_comb_DL(1,1:array_break_idx-1)-angs_best_comb_PM(1,1:array_break_idx-1);
            PD_diff2 = angs_best_comb_DL(1,array_break_idx:end)-angs_best_comb_PM(1,array_break_idx:end);
            [hyp,p] = ttest2(PD_diff1,PD_diff2,'Vartype','unequal');
            output_data.between_array_signif = hyp;
            output_data.between_array_pval = p;
            output_data.between_array_mean = mean1-mean2;
            
            output_data.num_changed = [sum(sig_change(1:array_break_idx-1));sum(sig_change(array_break_idx:end))];
            output_data.num_units = [sum(output_data.unit_best_combined_table_DL.channel<=array_break); sum(output_data.unit_best_combined_table_DL.channel>array_break)];
        else
            % Check if change over array is significantly different from
            % zero
            [hyp,p] = ttest(angs_best_comb_PM(1,:),angs_best_comb_DL(1,:));
            output_data.array_change_signif = hyp;
            output_data.array_change_pval = p;
            output_data.array_change_mean = mean(angs_best_comb_DL(1,:)-angs_best_comb_PM(1,:));
            
            output_data.num_changed = sum(sig_change);
            output_data.num_units = length(sig_change);
        end
        
    end
    
    if options.do_electrode_pds
        % DEPRECATED FOR THIS FILE. NEEDS TO MATCH ABOVE SECTION (JUST COPY
        % PASTE, PROBABLY)
        
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
            behaviors = parse_for_tuning(multiunit_bdf,'continuous','opts',optionstruct);
        end
        output_data.electrode_tuning_stats = compute_tuning(behaviors,[1 1 0 0 0 0],struct('num_rep',10),'poisson');
        output_data.electrode_pd_table=get_pd_table(output_data.electrode_tuning_stats,behaviors,multiunit_bdf);
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
        colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),angs(1,:));
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
        colorhsv = interp1(linspace(-pi,pi,360)',hsv(360),angs(1,:));
        set(gca,'colororder',colorhsv)
        hold all
        h=polar(angs,mags);
        set(h,'linewidth',2)
        hold off
        title(['\fontsize{14}Polar plot of best modulated electrode PDs.','\newline',...
                '\fontsize{10} Amplitude normalized and log scaled for pretty picture.'])
    end
end
