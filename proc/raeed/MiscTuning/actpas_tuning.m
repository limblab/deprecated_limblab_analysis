function [figure_handles, output_data] = actpas_tuning(folder, options)
% ACTPAS_TUNING show tuning curves for active and passive movements

%     try
        %% setup
        figure_handles=[];
        if(~isfield(options,'bdf'))
            if(folder(end)~=filesep)
                folder = [folder filesep];
            end
            bdf = get_nev_mat_data([folder options.prefix],options.labnum);
        else
            bdf = options.bdf;
        end
        
        %% get individual tuning curves
        bumpopts = options;
        bumpopts.bdf = bdf;
        bumpopts.plot_curves = 0;
        bumpopts.binsize = 0.05;
        bumpopts.time_selection = 'bumps';
        [~,tuning_out_bumps] = get_tuning_curves(folder,bumpopts);
        
        moveopts = options;
        moveopts.bdf = bdf;
        moveopts.plot_curves = 0;
        moveopts.binsize = 0.05;
        moveopts.time_selection = 'target moves';
        [~,tuning_out_moves] = get_tuning_curves(folder,moveopts);

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

            % DL workspace tuning curve
            h=polar(repmat(tuning_out_moves.bins,2,1),repmat(tuning_out_moves.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',[1 0 0])
            th_fill = [flipud(tuning_out_moves.bins); tuning_out_moves.bins(end); tuning_out_moves.bins(end); tuning_out_moves.bins];
            r_fill = [flipud(tuning_out_moves.binned_CI_high(:,i)); tuning_out_moves.binned_CI_high(end,i); tuning_out_moves.binned_CI_low(end,i); tuning_out_moves.binned_CI_low(:,i)];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[1 0 0],'facealpha',0.3,'edgealpha',0);

            % PM workspace tuning curve
            h=polar(repmat(tuning_out_bumps.bins,2,1),repmat(tuning_out_bumps.binned_FR(:,i),2,1));
            set(h,'linewidth',2,'color',[0.6 0.5 0.7])
            th_fill = [flipud(tuning_out_bumps.bins); tuning_out_bumps.bins(end); tuning_out_bumps.bins(end); tuning_out_bumps.bins];
            r_fill = [flipud(tuning_out_bumps.binned_CI_high(:,i)); tuning_out_bumps.binned_CI_high(end,i); tuning_out_bumps.binned_CI_low(end,i); tuning_out_bumps.binned_CI_low(:,i)];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[0.6 0.5 0.7],'facealpha',0.3,'edgealpha',0);
            
            hold off
        end
        
        % assign output data
        output_data.tuning_out_bumps = tuning_out_bumps;
        output_data.tuning_out_moves = tuning_out_moves;
        
%     catch MExc
%         output_data.MExc = MExc;
%         warning('Code did not fully execute. Check ''MExc'' in output data for more information.')
%     end
end
