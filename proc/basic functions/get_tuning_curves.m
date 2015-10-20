function [figure_handles, output_data]=get_tuning_curves(folder,options)
% GET_TUNING_CURVES bins robot handle movement by direction and 

% if behaviors not in options, create it
if(~isfield(options,'behaviors'))
    % if bdf is in options, use it
    if(~isfield(options,'bdf'))
        if(folder(end)~=filesep)
            folder = [folder filesep];
        end
        bdf = get_nev_mat_data([folder options.prefix],options.labnum);
    else
        bdf=options.bdf;
    end

    %% prep bdf
    if ~isfield(bdf,'meta') || ~isfield(bdf.meta,'task')
        % default to random walk
        bdf.meta.task = 'RW';
    end

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
    which_units=1:length(bdf.units);
    if(isfield(options,'which_units'))
        which_units = options.which_units;
    elseif options.only_sorted
        for i=1:length(bdf.units)
            temp(i)=bdf.units(i).id(2)~=0 && bdf.units(i).id(2)~=255;
        end
        ulist=1:length(bdf.units);
        which_units=ulist(temp);
    end
    optionstruct.data_offset=-.015;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
    behaviors = parse_for_tuning(bdf,'continuous','opts',optionstruct,'units',which_units);
else
    behaviors = options.behaviors;
end

% find velocities and directions
armdata = behaviors.armdata;
if(~isfield(options,'move_corr') || strcmp(options.move_corr,'vel'))
    move_corr = armdata(strcmp('vel',{armdata.name})).data;
else
    move_corr = armdata(strcmp(options.move_corr,{armdata.name})).data;
end
dir = atan2(move_corr(:,2),move_corr(:,1));
spd = sum(move_corr.^2,2);

% bin directions
dir_bins = round(dir/(pi/4))*(pi/4);
dir_bins(dir_bins==-pi) = pi;

% find baseline move_corr


% average firing rates for directions
bins = -3*pi/4:pi/4:pi;
bins = bins';
for i = 1:length(bins)
    FR_in_bin = behaviors.FR(dir_bins==bins(i),:);
    spd_in_bin = spd(dir_bins==bins(i));
    
    % normalize by bin size to get estimate of firing rate
    if(isfield(options,'binsize'))
        FR_in_bin = FR_in_bin/options.binsize;
    else %default to 50 ms bins
        FR_in_bin = FR_in_bin/0.05;
    end
    
    % Mean binned FR has normal-looking distribution (checked with
    % bootstrapping)
    binned_FR(i,:) = mean(FR_in_bin); % mean firing rate
    binned_spd(i,:) = mean(spd_in_bin); % mean speed
    binned_stderr(i,:) = std(FR_in_bin)/sqrt(length(FR_in_bin)); % standard error
    tscore = tinv(0.975,length(FR_in_bin)-1); % t-score for 95% CI
    binned_CI_high(i,:) = binned_FR(i,:)+tscore*binned_stderr(i,:); %high CI
    binned_CI_low(i,:) = binned_FR(i,:)-tscore*binned_stderr(i,:); %low CI
end

% find tuning curve features
frac_moddepth = (max(binned_FR)-min(binned_FR))./mean(binned_FR);

% plot tuning curves
if isfield(options,'plot_curves')
    if options.plot_curves
        figure_handles = zeros(size(binned_FR,2),1);
        unit_ids = behaviors.unit_ids;
        for i=1:length(figure_handles)
            figure_handles(i) = figure('name',['channel_' num2str(unit_ids(i,1)) '_unit_' num2str(unit_ids(i,2)) '_tuning_plot']);

            % plot tuning curve
            polar(repmat(bins,2,1),repmat(binned_FR(:,i),2,1))

            % plot confidence intervals 
            th_fill = [flipud(bins); bins(end); bins(end); bins];
            r_fill = [flipud(binned_CI_high(:,i)); binned_CI_high(end,i); binned_CI_low(end,i); binned_CI_low(:,i)];
            [x_fill,y_fill] = pol2cart(th_fill,r_fill);
            patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0);
        end
    else
        figure_handles = [];
    end
else
    figure_handles = [];
end

output_data.bins = bins;
output_data.binned_FR = binned_FR;
output_data.binned_stderr = binned_stderr;
output_data.binned_CI_high = binned_CI_high;
output_data.binned_CI_low = binned_CI_low;
output_data.move = move_corr;
output_data.dir_dins = dir_bins;
output_data.unit_ids = behaviors.unit_ids;
output_data.frac_moddepth = frac_moddepth;
output_data.binned_spd = binned_spd;
output_data.bdf = bdf;
output_data.behaviors = behaviors;