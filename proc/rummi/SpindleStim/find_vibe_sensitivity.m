function [figure_handles, output_data]=find_vibe_sensitivity(folder,options)
    try
        %%
        figure_handles=[];
%         figure_t = figure_title;

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
        if(~isfield(options,'bdf') || ~isfield(options,'bdf'))
            if(folder(end)~=filesep)
                folder = [folder filesep];
            end
            bdf = get_nev_mat_data([folder options.prefix],options.labnum,'nokin','noforce');
        else
            bdf = options.bdf;
        end
        %% prep bdf
        %add firing rate to the units fields of the bdf
        opts.binsize=0.05;
        opts.offset=-.015;
        opts.do_trial_table=0;
        opts.do_firing_rate=1;
        bdf=postprocess_bdf(bdf,opts);
        output_data.bdf=bdf;
        
        if(isfield(options,'which_units'))
            which_units = options.which_units;
        elseif options.only_sorted
            for i=1:length(bdf.units)
                temp(i)=bdf.units(i).id(2)~=0 && bdf.units(i).id(2)~=255;
            end
            ulist=1:length(bdf.units);
            which_units=ulist(temp);
        end

        %% figures
        figure_handles = [];
        figure_title = options.figure_title;
        
        % basic raster plot over vibration
        h = figure('name',figure_title);
        figure_handles = [figure_handles h];
        
        plot(bdf.analog.ts',bdf.analog.data/max(abs(bdf.analog.data)),'-b');
        hold on
        
        num_units = length(which_units);
        for i=1:num_units
            spike_times = bdf.units(which_units(i)).ts; 
            plot(spike_times,i,'k.')'
        end
        
        labels = strcat(repmat({'Unit '},num_units,1),cellstr(strtrim(num2str((1:num_units)'))))';
        labels = [{'Vibration'} labels];
        set(gca,'ylim',[-1 i+1],'ytick',0:i,'yticklabels',labels,'tickdir','out')
        
        % gaussian convolution
        for i=1:num_units
            FR_time = bdf.units(which_units(i)).FR(:,1);
            FR_data = bdf.units(which_units(i)).FR(:,2);
            G = fspecial('gaussian', [20,1], 5);
            FR_data_conv = conv(FR_data, G, 'same');
            FR_data_conv_norm = FR_data_conv/(max((abs(FR_data_conv))));
            plot(FR_time,FR_data_conv_norm+i, 'g')
        end
      
        
        
    catch MExc
        output_data.MExc = MExc;
        warning('Code did not fully execute. Check ''MExc'' in output data for more information.')
    end
end
