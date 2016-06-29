function [figure_handles, output_data] = compare_actpas_RW(folder, options)
% ACTPAS_TUNING show tuning curves for active and passive movements

    try
        %% setup
        figure_handles=[];
        if(~isfield(options,'bdf_COactpas'))
            if(folder(end)~=filesep)
                folder = [folder filesep];
            end
            bdfCOactpas = get_nev_mat_data([folder options.prefix '_COactpas'],options.labnum);
        else
            bdfCOactpas = options.bdfCOactpas;
        end
        bdfCOactpas.meta.task = 'CO';
        
        if(~isfield(options,'bdf_RW'))
            if(folder(end)~=filesep)
                folder = [folder filesep];
            end
            bdfRW = get_nev_mat_data([folder options.prefix '_RW'],options.labnum);
        else
            bdfRW = options.bdfRW;
        end
        bdfRW.meta.task = 'RW';
        
        %% get individual tuning curves
        bumpopts = options;
        bumpopts.bdf = bdfCOactpas;
        bumpopts.plot_curves = 0;
        bumpopts.binsize = 0.05;
        bumpopts.time_selection = 'bumps';
        [~,tuning_out_bumps] = get_tuning_curves(folder,bumpopts);
        
        moveopts = options;
        moveopts.bdf = bdfCOactpas;
        moveopts.plot_curves = 0;
        moveopts.binsize = 0.05;
        moveopts.time_selection = 'target moves';
        [~,tuning_out_moves] = get_tuning_curves(folder,moveopts);
        
        RWopts = options;
        RWopts.bdf = bdfRW;
        RWopts.plot_curves = 0;
        RWopts.binsize = 0.05;
        RWopts.time_selection = 'trials';
        [~,tuning_out_RW] = get_tuning_curves(folder,RWopts);

        %% figures
        if(options.dual_array)
            array_break = options.array_break;
        end

        figure_handles = [];

        % Plot all tuning curves
        % plot tuning curves
        unit_ids = tuning_out_bumps.behaviors.unit_ids;
        for i=1:length(unit_ids)
            h = figure('name',['channel_' num2str(unit_ids(i,1)) '_unit_' num2str(unit_ids(i,2)) '_tuning_plot']);
            figure_handles = [figure_handles h];

            % Figure out max size to display at
%             rad_DL = unit_pd_table_DL.moddepth(i);
%             rad_PM = unit_pd_table_PM.moddepth(i);
            max_rad = max([tuning_out_moves.binned_FR(:,i); tuning_out_bumps.binned_FR(:,i)]);
            rad_DL = max_rad;
            rad_PM = max_rad;

            % plot initial point
            h=polar(0,max_rad);
            set(h,'color','w')
            hold all

            % active tuning curve
            h=polar(repmat(tuning_out_moves.bins,2,1),repmat(tuning_out_moves.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',[1 0 0])
            th_fill = [flipud(tuning_out_moves.bins); tuning_out_moves.bins(end); tuning_out_moves.bins(end); tuning_out_moves.bins];
            r_fill = [flipud(tuning_out_moves.binned_CI_high(:,i)); tuning_out_moves.binned_CI_high(end,i); tuning_out_moves.binned_CI_low(end,i); tuning_out_moves.binned_CI_low(:,i)];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[1 0 0],'facealpha',0.3,'edgealpha',0);

            % passive tuning curve
            h=polar(repmat(tuning_out_bumps.bins,2,1),repmat(tuning_out_bumps.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',[0.6 0.5 0.7])
            th_fill = [flipud(tuning_out_bumps.bins); tuning_out_bumps.bins(end); tuning_out_bumps.bins(end); tuning_out_bumps.bins];
            r_fill = [flipud(tuning_out_bumps.binned_CI_high(:,i)); tuning_out_bumps.binned_CI_high(end,i); tuning_out_bumps.binned_CI_low(end,i); tuning_out_bumps.binned_CI_low(:,i)];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[0.6 0.5 0.7],'facealpha',0.3,'edgealpha',0);
            
            % RW tuning curve
            curve_color = [0 0 1];
            h=polar(repmat(tuning_out_RW.bins,2,1),repmat(tuning_out_RW.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',curve_color)
            th_fill = [flipud(tuning_out_RW.bins); tuning_out_RW.bins(end); tuning_out_RW.bins(end); tuning_out_RW.bins];
            r_fill = [flipud(tuning_out_RW.binned_CI_high(:,i)); tuning_out_RW.binned_CI_high(end,i); tuning_out_RW.binned_CI_low(end,i); tuning_out_RW.binned_CI_low(:,i)];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,curve_color,'facealpha',0.3,'edgealpha',0);
            
            hold off
        end
        
    catch MExc
        output_data.MExc = MExc;
        warning('Code did not fully execute. Check ''MExc'' in output data for more information.')
    end
end
