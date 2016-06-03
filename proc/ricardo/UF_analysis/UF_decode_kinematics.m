function UF_decode_kinematics(UF_struct,bdf,save_figs)
    tic    
    num_rep = 10;
    dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;
    bin_size = dt;
    
    bin_size = 0.01;
    
    x_pos = resample(UF_struct.x_pos',1,bin_size/dt)';
    y_pos = resample(UF_struct.y_pos',1,bin_size/dt)';
    x_force = resample(UF_struct.x_force',1,bin_size/dt)';
    y_force = resample(UF_struct.y_force',1,bin_size/dt)';

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

    neuron_t_axis = (0:(UF_struct.trial_range(2)-UF_struct.trial_range(1))/bin_size-1)*bin_size+UF_struct.trial_range(1);

    % Bias
    correct_ratio_matrix_bias = zeros(length(neuron_t_axis),num_rep);
    for iT = 1:length(neuron_t_axis)
        kin_mat = [x_pos(:,iT) y_pos(:,iT) x_force(:,iT) y_force(:,iT)];
        for iRep=1:num_rep
            temp = randperm(size(UF_struct.trial_table,1));
            training_idx = temp(1:floor(length(temp)*.9));
            testing_idx = temp(floor(length(temp)*.9)+1:end);
            BayesModel = NaiveBayes.fit(kin_mat(training_idx,:),categories(training_idx,1));
            prediction = BayesModel.predict(kin_mat(testing_idx,:));
            correct_ratio_matrix_bias(iT,iRep) = sum(~abs(categories(testing_idx,1)-prediction))/length(prediction);
        end
    end
    figure; plot(neuron_t_axis,mean(correct_ratio_matrix_bias,2))
    title('Bias prediction')
    xlabel('time (s)')

    % Field
    correct_ratio_matrix_field = zeros(length(neuron_t_axis),num_rep);
    for iT = 1:length(neuron_t_axis)        
        kin_mat = [x_pos(:,iT) y_pos(:,iT) x_force(:,iT) y_force(:,iT)];
        for iRep=1:num_rep
            temp = randperm(size(UF_struct.trial_table,1));
            training_idx = temp(1:floor(length(temp)*.9));
            testing_idx = temp(floor(length(temp)*.9)+1:end);
            BayesModel = NaiveBayes.fit(kin_mat(training_idx,:),categories(training_idx,2));
            prediction = BayesModel.predict(kin_mat(testing_idx,:));
            correct_ratio_matrix_field(iT,iRep) = sum(~abs(categories(testing_idx,2)-prediction))/length(prediction);
        end
    end
    figure; plot(neuron_t_axis,mean(correct_ratio_matrix_field,2))
    title('Field prediction')
    xlabel('time (s)')

    % Bump
    correct_ratio_matrix_bump = zeros(length(neuron_t_axis),num_rep);
    for iT = 1:length(neuron_t_axis)
        kin_mat = [x_pos(:,iT) y_pos(:,iT) x_force(:,iT) y_force(:,iT)];
        for iRep=1:num_rep
            temp = randperm(size(UF_struct.trial_table,1));
            training_idx = temp(1:floor(length(temp)*.9));
            testing_idx = temp(floor(length(temp)*.9)+1:end);
            BayesModel = NaiveBayes.fit(kin_mat(training_idx,:),categories(training_idx,3));
            prediction = BayesModel.predict(kin_mat(testing_idx,:));
            correct_ratio_matrix_bump(iT,iRep) = sum(~abs(categories(testing_idx,3)-prediction))/length(prediction);
        end
    end
    figure; plot(neuron_t_axis,mean(correct_ratio_matrix_bump,2))
    title('Bump prediction')
    xlabel('time (s)')
    
    % Field given bump/bias direction
    figure    
    for iBias = 1:length(UF_struct.bias_indexes)
        for iBump = 1:length(UF_struct.bump_indexes)
            correct_ratio_matrix_field_given_bump = zeros(length(neuron_t_axis),num_rep);
            for iT = 1:length(neuron_t_axis)    
                kin_mat = [x_pos(:,iT) y_pos(:,iT) x_force(:,iT) y_force(:,iT)];
                temp_indexes = find(categories(:,1)==iBias & categories(:,3)==iBump);                
                for iRep=1:num_rep
                    temp = temp_indexes(randperm(length(temp_indexes)));
                    training_idx = temp(1:floor(length(temp)*.9));
                    testing_idx = temp(floor(length(temp)*.1)+1:end);
                    BayesModel = NaiveBayes.fit(kin_mat(training_idx,:),categories(training_idx,2));
                    prediction = BayesModel.predict(kin_mat(testing_idx,:));
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
            ylim([0 1])
            drawnow
        end
    end
    
    toc
end