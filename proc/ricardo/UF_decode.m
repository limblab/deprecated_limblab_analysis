function UF_decode(input,UF_struct,bdf,save_figs)
    tic
    fr_tc = 0.02;

    dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;
    bin_size = .01;

    categories = zeros(size(UF_struct.trial_table,1),3);
    for iBias = 1:length(UF_struct.bias_indexes)
        categories(UF_struct.bias_indexes{iBias},1) = iBias;
    end
    for iField = 1:length(UF_struct.field_indexes)
        categories(UF_struct.field_indexes{iField},2) = iField;
    end
    for iBump = 1:length(UF_struct.bump_indexes)
        categories(UF_struct.bump_indexes{iBump},3) = iBump;
    end

    t_axis = (0:(UF_struct.trial_range(2)-UF_struct.trial_range(1))/bin_size-1)*bin_size+UF_struct.trial_range(1);
    
    switch input
        case 'units'
            units = unit_list(bdf);   
            all_chans = reshape([bdf.units.id],2,[])';
            input_mat = zeros(size(UF_struct.trial_table,1),length(t_axis),size(units,1));
            for iUnit = 1:size(units,1)  
                unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
                fr = spikes2FrMovAve(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);  
                for iTrial = 1:size(UF_struct.trial_table,1)
                    idx = UF_struct.idx_table(iTrial,:);
                    fr_temp = fr(idx)+rand(length(idx),1)*.00001-.00001/2;
                    fr_temp = resample(fr_temp,1,bin_size/dt)';
                    input_mat(iTrial,:,iUnit) = fr_temp;
                end
            end
        case 'emg'
            temp = permute(UF_struct.emg_all,[2 3 1]);
            input_mat = zeros(size(UF_struct.trial_table,1),length(t_axis),size(temp,3));
            for i = 1:size(temp,3)
                input_mat(:,:,i) = resample(temp(:,:,i)',1,bin_size/dt)';
            end
        case 'kinematics'
            input_mat(:,:,1) = resample(UF_struct.x_pos',1,bin_size/dt)';
            input_mat(:,:,2) = resample(UF_struct.y_pos',1,bin_size/dt)';
            input_mat(:,:,3) = resample(UF_struct.x_vel',1,bin_size/dt)';
            input_mat(:,:,4) = resample(UF_struct.y_vel',1,bin_size/dt)';
            input_mat(:,:,5) = resample(UF_struct.x_force',1,bin_size/dt)';
            input_mat(:,:,6) = resample(UF_struct.y_force',1,bin_size/dt)';            
        case 'lfp'
            
    end

    % Bias
    correct_ratio_matrix_bias = zeros(length(t_axis),size(categories,1));
    for iT = 1:length(t_axis)
        correct_ratio_matrix_bias(iT,:) = bootstrap_bayes(squeeze(input_mat(:,iT,:)),categories(:,1));
    end
    figHandles(1) = figure;
    figuretitle{1} = {['bias from ' input]};
    plot(t_axis,mean(correct_ratio_matrix_bias,2))
    hold on
    plot(t_axis,repmat(1/length(unique(categories(:,1))),1,length(t_axis)),'--k')
    errorarea(t_axis,mean(correct_ratio_matrix_bias,2),...
        1.96*std(correct_ratio_matrix_bias,[],2)/sqrt(size(correct_ratio_matrix_bias,2)),'b')
    ylim([0 1])
    title([UF_struct.UF_file_prefix '. Bias prediction from ' input],'Interpreter','none')
    xlabel('time (s)')    

    % Field
    correct_ratio_matrix_field = zeros(length(t_axis),size(categories,1));
    for iT = 1:length(t_axis)
        correct_ratio_matrix_field(iT,:) = bootstrap_bayes(squeeze(input_mat(:,iT,:)),categories(:,2));       
    end
    figHandles(end+1) = figure;
    figuretitle{end+1} = {['field from ' input]};
    plot(t_axis,mean(correct_ratio_matrix_field,2))
    hold on
    plot(t_axis,repmat(1/length(unique(categories(:,2))),1,length(t_axis)),'--k')
    errorarea(t_axis,mean(correct_ratio_matrix_field,2),...
        1.96*std(correct_ratio_matrix_field,[],2)/sqrt(size(correct_ratio_matrix_field,2)),'b')
    ylim([0 1])
    title([UF_struct.UF_file_prefix '. Field prediction from ' input],'Interpreter','none')
    xlabel('time (s)')
    
    % Field given bias
    figHandles(end+1) = figure;
    figuretitle{end+1} = {['field given bias from ' input]};
    for iBias = 1:length(UF_struct.bias_indexes)
        temp_indexes = find(categories(:,1)==iBias);  
        correct_ratio_matrix_field = zeros(length(t_axis),length(temp_indexes));
        for iT = 1:length(t_axis) 
            correct_ratio_matrix_field(iT,:) = bootstrap_bayes(squeeze(input_mat(temp_indexes,iT,:)),categories(temp_indexes,2));
        end
        subplot(length(UF_struct.bias_indexes),1,iBias)
        plot(t_axis,mean(correct_ratio_matrix_field,2),'k')
        hold on
        plot(t_axis,repmat(1/length(unique(categories(:,2))),1,length(t_axis)),'--k')
        errorarea(t_axis,mean(correct_ratio_matrix_field,2),...
            1.96*std(correct_ratio_matrix_field,[],2)/sqrt(size(correct_ratio_matrix_field,2)),'b')
        ylim([0 1])
        title([UF_struct.UF_file_prefix '. Bias ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg'],'Interpreter','none')
        xlabel('time (s)')
    end
    set_figure_title(figHandles(end),[UF_struct.UF_file_prefix '. Field prediction from ' input])


    % Bump
    correct_ratio_matrix_bump = zeros(length(t_axis),size(categories,1));
    for iT = 1:length(t_axis)
        correct_ratio_matrix_bump(iT,:) = bootstrap_bayes(squeeze(input_mat(:,iT,:)),categories(:,3));        
    end
    figHandles(end+1) = figure;
    figuretitle{end+1} = {['bump from ' input]};
    plot(t_axis,mean(correct_ratio_matrix_bump,2))
    hold on
    plot(t_axis,repmat(1/length(unique(categories(:,3))),1,length(t_axis)),'--k')
    errorarea(t_axis,mean(correct_ratio_matrix_bump,2),...
        1.96*std(correct_ratio_matrix_bump,[],2)/sqrt(size(correct_ratio_matrix_bump,2)),'b')       
    ylim([0 1])
    title([UF_struct.UF_file_prefix '. Bump prediction from ' input],'Interpreter','none')
    xlabel('time (s)')
    
    % Field given bump/bias direction
    figHandles(end+1) = figure;
    figuretitle{end+1} = {['field given bump and bias from ' input]};
    for iBias = 1:length(UF_struct.bias_indexes)
        for iBump = 1:length(UF_struct.bump_indexes)
            temp_indexes = find(categories(:,1)==iBias & categories(:,3)==iBump);  
            correct_ratio_matrix_field_given_bump = zeros(length(t_axis),length(temp_indexes));
            for iT = 1:length(t_axis)  
                correct_ratio_matrix_field_given_bump(iT,:) = bootstrap_bayes(squeeze(input_mat(temp_indexes,iT,:)),categories(temp_indexes,2));               
            end
            subplot(length(UF_struct.bump_directions),length(UF_struct.bias_force_directions),...
                (iBump-1)*length(UF_struct.bias_force_directions) + iBias)
            plot(t_axis,mean(correct_ratio_matrix_field_given_bump,2))
            hold on
            plot(t_axis,repmat(1/length(unique(categories(:,2))),1,length(t_axis)),'--k')
            errorarea(t_axis,mean(correct_ratio_matrix_field_given_bump,2),...
                1.96*std(correct_ratio_matrix_field_given_bump,[],2)/sqrt(size(correct_ratio_matrix_field_given_bump,2)),'b')
            ylim([0 1])
            xlabel('t (s)')
            ylabel('Correct ratio')
            title(['Bias: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg. Bump: '...
                num2str(round(UF_struct.bump_directions(iBump)*180/pi)) ' deg.'])
            drawnow
        end
    end
    set_figure_title(figHandles(end),[UF_struct.UF_file_prefix '. Field prediction from ' input])
    
    toc
    
    if save_figs
        save_figures(figHandles,UF_struct.UF_file_prefix,UF_struct.datapath,'Decode',figuretitle)
    end
end