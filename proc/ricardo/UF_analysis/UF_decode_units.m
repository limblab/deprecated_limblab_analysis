function UF_decode_units(UF_struct,bdf,save_figs)
    tic
    fr_tc = 0.02;
    num_rep = 10;
    
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

    units = unit_list(bdf);   
    all_chans = reshape([bdf.units.id],2,[])';

    neuron_t_axis = (0:(UF_struct.trial_range(2)-UF_struct.trial_range(1))/bin_size-1)*bin_size+UF_struct.trial_range(1);

    fr_mat = zeros(size(UF_struct.trial_table,1),length(neuron_t_axis),size(units,1));

    for iUnit = 1:size(units,1)  
        unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
        fr = spikes2FrMovAve(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);  
        for iTrial = 1:size(UF_struct.trial_table,1)
            idx = UF_struct.idx_table(iTrial,:);
            fr_temp = fr(idx)+rand(length(idx),1)*.00001-.00001/2;
            fr_temp = resample(fr_temp,1,bin_size/dt)';
            fr_mat(iTrial,:,iUnit) = fr_temp;
        end
    end

    % Bias
    correct_ratio_matrix_bias = zeros(length(neuron_t_axis),num_rep);
    for iT = 1:length(neuron_t_axis)
        for iRep=1:num_rep
            temp = randperm(size(UF_struct.trial_table,1));
            training_idx = temp(1:floor(length(temp)*.9));
            testing_idx = temp(floor(length(temp)*.9)+1:end);
            BayesModel = NaiveBayes.fit(squeeze(fr_mat(training_idx,iT,:)),categories(training_idx,1));
            prediction = BayesModel.predict(squeeze(fr_mat(testing_idx,iT,:)));
            correct_ratio_matrix_bias(iT,iRep) = sum(~abs(categories(testing_idx,1)-prediction))/length(prediction);
        end
    end
    plot(neuron_t_axis,mean(correct_ratio_matrix_bias,2))
    title('Bias prediction from units')
    xlabel('time (s)')    

    % Field
    correct_ratio_matrix_field = zeros(length(neuron_t_axis),num_rep);
    for iT = 1:length(neuron_t_axis)
        for iRep=1:num_rep
            temp = randperm(size(UF_struct.trial_table,1));
            training_idx = temp(1:floor(length(temp)*.9));
            testing_idx = temp(floor(length(temp)*.9)+1:end);
            BayesModel = NaiveBayes.fit(squeeze(fr_mat(training_idx,iT,:)),categories(training_idx,2));
            prediction = BayesModel.predict(squeeze(fr_mat(testing_idx,iT,:)));
            correct_ratio_matrix_field(iT,iRep) = sum(~abs(categories(testing_idx,2)-prediction))/length(prediction);
        end
    end
    figure; plot(neuron_t_axis,mean(correct_ratio_matrix_field,2))
    title('Field prediction from units')
    xlabel('time (s)')

    % Bump
    correct_ratio_matrix_bump = zeros(length(neuron_t_axis),num_rep);
    for iT = 1:length(neuron_t_axis)
        for iRep=1:num_rep
            temp = randperm(size(UF_struct.trial_table,1));
            training_idx = temp(1:floor(length(temp)*.9));
            testing_idx = temp(floor(length(temp)*.9)+1:end);
            BayesModel = NaiveBayes.fit(squeeze(fr_mat(training_idx,iT,:)),categories(training_idx,3));
            prediction = BayesModel.predict(squeeze(fr_mat(testing_idx,iT,:)));
            correct_ratio_matrix_bump(iT,iRep) = sum(~abs(categories(testing_idx,3)-prediction))/length(prediction);
        end
    end
    figure; plot(neuron_t_axis,mean(correct_ratio_matrix_bump,2))
    title('Bump prediction from units')
    xlabel('time (s)')
    
    % Field given bump/bias direction
    f_field = figure;
    for iBias = 1:length(UF_struct.bias_indexes)
        for iBump = 1:length(UF_struct.bump_indexes)
            correct_ratio_matrix_field_given_bump = zeros(length(neuron_t_axis),num_rep);
            for iT = 1:length(neuron_t_axis)                        
                temp_indexes = find(categories(:,1)==iBias & categories(:,3)==iBump);                
                for iRep=1:num_rep
                    temp = temp_indexes(randperm(length(temp_indexes)));
                    training_idx = temp(1:floor(length(temp)*.9));
                    testing_idx = temp(floor(length(temp)*.1)+1:end);
                    BayesModel = NaiveBayes.fit(squeeze(fr_mat(training_idx,iT,:)),categories(training_idx,2));
                    prediction = BayesModel.predict(squeeze(fr_mat(testing_idx,iT,:)));
                    correct_ratio_matrix_field_given_bump(iT,iRep) = sum(~abs(categories(testing_idx,2)-prediction))/length(prediction);
                end                
            end
            subplot(length(UF_struct.bias_force_directions),length(UF_struct.bump_directions),...
                (iBias-1)*length(UF_struct.bump_directions) + iBump)
            plot(neuron_t_axis,mean(correct_ratio_matrix_field_given_bump,2))
            xlabel('t (s)')
            ylabel('Correct ratio')
            title(['Bias: ' num2str(round(UF_struct.bias_force_directions(iBias)*180/pi)) ' deg. Bump: '...
                num2str(round(UF_struct.bump_directions(iBump)*180/pi)) ' deg.'])
            drawnow
        end
    end
    set_figure_title(f_field,['Field prediction. ' UF_struct.UF_file_prefix])
    
    toc
end