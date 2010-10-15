function sigmoid_fit_params = sigmoid_fit_bootstrap(table,bumps_ordered,num_iter)

fit_func = 'a+b/(1+exp(x*c+d))';
f_sigmoid = fittype(fit_func,'independent','x');

mean_resamp = zeros(size(table,1),num_iter);

for i = 1:size(table,1)
    stim_results_i = [ones(table(i,1),1);zeros(table(i,2),1)];
    resamp_stim_i = stim_results_i(ceil(length(stim_results_i)*rand(length(stim_results_i),num_iter)));
    mean_resamp(i,:) = mean(resamp_stim_i);          
end

sigmoid_fit_params = zeros(num_iter,4);

for i=1:num_iter
    if i==11
        tic
    end
    if i==21
        time_10 = toc;           
    end
    if mod(i,100)==0 && i>20
        eta = ((num_iter-i)*time_10/10)/60;
        disp(['Iteration: ' num2str(i) ' of ' num2str(num_iter) '. ETA: ' num2str(eta,3) 'min'])
    end
    sigmoid_fit_temp = fit(bumps_ordered,mean_resamp(:,i),f_sigmoid,...
        'StartPoint',[1 1 100 -1],'Lower',[0 0 0 -inf],'Upper',[inf inf inf inf]);
    sigmoid_fit_params(i,:) = [sigmoid_fit_temp.a sigmoid_fit_temp.b...
        sigmoid_fit_temp.c sigmoid_fit_temp.d];
end