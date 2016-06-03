function sigmoid_results = sigmoid_fit_bootstrap(moved_t1,moved_t2,bumps_ordered,num_iter)

colors = colormap(jet);
percentiles = [2.5 97.5];

% fit_func = 'a+b/(1+exp(x*c+d))';
fit_func = 'Pmin + (Pmax - Pmin)/(1+exp(beta*(xthr-x)))';
f_sigmoid = fittype(fit_func,'independent','x');
f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 0 100 0],...
    'MaxFunEvals',10000,'MaxIter',1000,'Lower',[0.3 0 0 3*min(bumps_ordered)],'Upper',[1 0.7 inf 3*max(bumps_ordered)]);

mean_resamp = zeros(size(moved_t1,1),size(moved_t1,2),num_iter);
conf_bounds = zeros(size(moved_t1,1),size(moved_t1,2),2);

t1t2ratio = moved_t1./(moved_t1+moved_t2);

for iStim = 1:size(moved_t1,1)
    stim_vector = [];
    for iBump = 1:size(moved_t1,2)
        stim_results_i = [ones(moved_t1(iStim,iBump),1);zeros(moved_t2(iStim,iBump),1)];
        stim_results_boot = stim_results_i(ceil(length(stim_results_i)*rand(length(stim_results_i),num_iter)));
        conf_bounds(iStim,iBump,:) = prctile(mean(stim_results_boot),percentiles);
        stim_vector = [stim_vector;[repmat(bumps_ordered(iBump),length(stim_results_i),1) stim_results_i]];
    end
    sigmoid_fit_data{iStim} = fit(stim_vector(:,1),stim_vector(:,2),f_sigmoid,f_opts);
%     sigmoid_fit_data{iStim} = fit(bumps_ordered,t1t2ratio(iStim,:,:)',f_sigmoid,f_opts);
%     sigmoid_fit_boot_lower{iStim} = fit(bumps_ordered,conf_bounds(iStim,:,1)',f_sigmoid,f_opts);
%     sigmoid_fit_boot_upper{iStim} = fit(bumps_ordered,conf_bounds(iStim,:,2)',f_sigmoid,f_opts);
%     sigmoid_fit_params(i,:) = [sigmoid_fit_temp.a sigmoid_fit_temp.b...
%         sigmoid_fit_temp.c sigmoid_fit_temp.d];
    conf_temp = confint(sigmoid_fit_data{iStim});
    xthr(iStim) = sigmoid_fit_data{iStim}.xthr;
    xthr_conf(:,iStim) = conf_temp(:,4);
    thr_level(iStim) = sigmoid_fit_data{iStim}.Pmin + 0.5*...
        (sigmoid_fit_data{iStim}.Pmax - sigmoid_fit_data{iStim}.Pmin);
    bump_idx = find(bumps_ordered<sigmoid_fit_data{iStim}.xthr,1,'last');
    if bump_idx < length(bumps_ordered)
        bumps_around_thr = bumps_ordered(bump_idx:bump_idx+1);
        upper_conf_around_threshold = conf_bounds(iStim,bump_idx:bump_idx+1,2);
        lower_conf_around_threshold = conf_bounds(iStim,bump_idx:bump_idx+1,1);  

        upper_conf_interp(iStim) = interp1(bumps_ordered(bump_idx:bump_idx+1),upper_conf_around_threshold',xthr(iStim));
        lower_conf_interp(iStim) = interp1(bumps_ordered(bump_idx:bump_idx+1),lower_conf_around_threshold',xthr(iStim));
    else
        upper_conf_interp(iStim) = conf_bounds(iStim,bump_idx,2);
        lower_conf_interp(iStim) = conf_bounds(iStim,bump_idx,1);        
    end    
    uncertainty_slope(iStim) = .25*(sigmoid_fit_data{iStim}.Pmax-sigmoid_fit_data{iStim}.Pmin)*...
        sigmoid_fit_data{iStim}.beta;
end

% upper_conf_interp = diag(interp1(bumps_ordered(bump_idx:bump_idx+1),upper_conf_around_threshold',xthr));
% lower_conf_interp = diag(interp1(bumps_ordered(bump_idx:bump_idx+1),lower_conf_around_threshold',xthr));
deltaYthr = (upper_conf_interp-lower_conf_interp)/2;
deltaXthr = abs(deltaYthr./uncertainty_slope);

%null hypothesis
combined_moved_t1 = sum(moved_t1);
combined_moved_t2 = sum(moved_t2);
t1t2ratio_combined = combined_moved_t1./(combined_moved_t1+combined_moved_t2);
all_vector = [];
for iBump = 1:length(combined_moved_t1)
    all_results_i = [ones(combined_moved_t1(iBump),1);zeros(combined_moved_t2(iBump),1)];
    all_results_boot = all_results_i(ceil(length(all_results_i)*rand(length(all_results_i),num_iter)));
    conf_bounds_all(iBump,:) = prctile(mean(all_results_boot),percentiles);
    all_vector = [all_vector;[repmat(bumps_ordered(iBump),length(all_results_i),1) all_results_i]];
end

sigmoid_fit_data_null = fit(all_vector(:,1),all_vector(:,2),f_sigmoid,f_opts);
xthr_null = sigmoid_fit_data_null.xthr;
conf_temp = confint(sigmoid_fit_data_null);
xthr_null_conf = conf_temp(:,4);
thr_null_level = sigmoid_fit_data_null.Pmin + 0.5*...
    (sigmoid_fit_data_null.Pmax - sigmoid_fit_data_null.Pmin);
bump_idx = find(bumps_ordered<sigmoid_fit_data_null.xthr,1,'last');
if bump_idx < length(bumps_ordered)
    bumps_around_thr = bumps_ordered(bump_idx:bump_idx+1);
    upper_conf_around_threshold = conf_bounds_all(bump_idx:bump_idx+1,2);
    lower_conf_around_threshold = conf_bounds_all(bump_idx:bump_idx+1,1);  
    upper_conf_interp_null = interp1(bumps_ordered(bump_idx:bump_idx+1),upper_conf_around_threshold',xthr_null);
    lower_conf_interp_null = interp1(bumps_ordered(bump_idx:bump_idx+1),lower_conf_around_threshold',xthr_null);
else
    upper_conf_around_threshold = conf_bounds_all(bump_idx,2);
    lower_conf_around_threshold = conf_bounds_all(bump_idx,1); 
    upper_conf_interp_null = upper_conf_around_threshold';
    lower_conf_interp_null = lower_conf_around_threshold';
end
uncertainty_slope_null = .25*(sigmoid_fit_data_null.Pmax-sigmoid_fit_data_null.Pmin)*...
    sigmoid_fit_data_null.beta;

deltaYthr_null = (upper_conf_interp_null-lower_conf_interp_null)/2;
deltaXthr_null = abs(deltaYthr_null./uncertainty_slope_null);

cont_bump_plot = linspace(bumps_ordered(1),bumps_ordered(end));

%%
% Stats sanity check
stats_vector = all_vector;
num_trials = length(stats_vector);
unique_x = unique(stats_vector(:,1));
num_iter = 10;
y_mean = zeros(num_iter,length(unique_x));

conf_count = 0;
conf_series = zeros(1,num_iter);
for iIter = 1:num_iter
    iIter
    rand_idx = randperm(num_trials);
    rand_idx_1 = rand_idx(1:round(end/3));
    rand_idx_2 = rand_idx;
    half_vector_1 = stats_vector(rand_idx_1,:);
    half_vector_2 = stats_vector(rand_idx_2,:);
    fit_vector_1 = fit(half_vector_1(:,1),half_vector_1(:,2),f_sigmoid,f_opts);
    conf_vector_1 = confint(fit_vector_1);
    conf_vector_1 = conf_vector_1(:,4);
    fit_vector_2 = fit(half_vector_2(:,1),half_vector_2(:,2),f_sigmoid,f_opts);
    conf_vector_2 = confint(fit_vector_2);
    conf_vector_2 = conf_vector_2(:,4);
    if (fit_vector_1.xthr > conf_vector_2(1) && fit_vector_1.xthr < conf_vector_2(2))
        conf_count = conf_count +1;
    end
%     if (fit_vector_2.xthr > conf_vector_1(1) && fit_vector_2.xthr < conf_vector_1(2))
%         conf_count = conf_count +1;
%     end
    conf_series(iIter) = conf_count/(iIter);
end
conf_count/(num_iter);
figure; plot(conf_series);
% 
% %%
% % Stats sanity check
% stats_vector = all_vector;
% num_trials = length(stats_vector);
% unique_x = unique(stats_vector(:,1));
% num_iter = 100;
% y_mean = zeros(num_iter,length(unique_x));
% 
% conf_count = 0;
% conf_series = zeros(1,num_iter);
% half_mean_1 = zeros(length(unique_x),1);
% half_mean_2 = zeros(length(unique_x),1);
% cont_bumps = linspace(min(unique_x),max(unique_x),20);
% cont_matrix_1 = zeros(num_trials,length(cont_bumps));
% cont_matrix_2 = zeros(num_trials,length(cont_bumps));
% for iIter = 1:num_iter
%     iIter
%     rand_idx = randperm(num_trials);
%     rand_idx_1 = rand_idx(1:end/2);
%     rand_idx_2 = rand_idx(end/2+1:end);
%     half_vector_1 = stats_vector(rand_idx_1,:);
%     half_vector_2 = stats_vector(rand_idx_2,:);
%     for iBump = 1:length(unique_x)
%         half_mean_1(iBump) = mean(half_vector_1(half_vector_1(:,1)==unique_x(iBump),2));
%         half_mean_2(iBump) = mean(half_vector_2(half_vector_2(:,1)==unique_x(iBump),2));
%     end   
%     fit_vector_1 = fit(unique_x,half_mean_1,f_sigmoid,f_opts);
%     cont_matrix_1(iIter,:) = fit_vector_1(cont_bumps)';
%     conf_vector_1 = confint(fit_vector_1);
%     conf_vector_1 = conf_vector_1(:,4);
%     fit_vector_2 = fit(unique_x,half_mean_2,f_sigmoid,f_opts);
%     cont_matrix_2(iIter,:) = fit_vector_2(cont_bumps)';
%     conf_vector_2 = confint(fit_vector_2);
%     conf_vector_2 = conf_vector_2(:,4);
%     if (fit_vector_1.xthr > conf_vector_2(1) && fit_vector_1.xthr < conf_vector_2(2))
%         conf_count = conf_count +1;
%     end
%     if (fit_vector_2.xthr > conf_vector_1(1) && fit_vector_2.xthr < conf_vector_1(2))
%         conf_count = conf_count +1;
%     end
%     conf_series(iIter) = conf_count/(iIter*2);
% end
% conf_count/(num_iter*2)
% figure; plot(conf_series);
% figure; 
% plot(cont_bumps,cont_matrix_1,'b')
% hold on
% plot(cont_bumps,cont_matrix_2,'r')

% %%
% % Stats sanity check
% stats_vector = all_vector;
% num_trials = length(stats_vector);
% unique_x = unique(stats_vector(:,1));
% num_iter = 1000;
% y_mean = zeros(num_iter,length(unique_x));
% 
% conf_count = 0;
% conf_series = zeros(1,num_iter);
% half_mean_1 = zeros(length(unique_x),1);
% half_mean_2 = zeros(length(unique_x),1);
% cont_bumps = linspace(min(unique_x),max(unique_x),20);
% cont_matrix_1 = zeros(num_trials,length(cont_bumps));
% xthr_difference = zeros(1,num_iter);
% for iIter = 1:num_iter
%     iIter
%     rand_idx = randperm(num_trials);
%     rand_idx_1 = rand_idx(1:end/3);
%     rand_idx_2 = rand_idx;
%     half_vector_1 = stats_vector(rand_idx_1,:);
%     half_vector_2 = stats_vector(rand_idx_2,:);
%     for iBump = 1:length(unique_x)
%         half_mean_1(iBump) = mean(half_vector_1(half_vector_1(:,1)==unique_x(iBump),2));
%         half_mean_2(iBump) = mean(half_vector_2(half_vector_2(:,1)==unique_x(iBump),2));
%     end   
%     fit_vector_1 = fit(unique_x,half_mean_1,f_sigmoid,f_opts);
%     cont_matrix_1(iIter,:) = fit_vector_1(cont_bumps)';
%     conf_vector_1 = confint(fit_vector_1);
%     conf_vector_1 = conf_vector_1(:,4);
%     fit_vector_2 = fit(unique_x,half_mean_2,f_sigmoid,f_opts);
%     cont_matrix_2(iIter,:) = fit_vector_2(cont_bumps)';
%     conf_vector_2 = confint(fit_vector_2);
%     conf_vector_2 = conf_vector_2(:,4);
%     xthr_difference(iIter) = fit_vector_1.xthr - fit_vector_2.xthr;
%     if (fit_vector_1.xthr > conf_vector_2(1) && fit_vector_1.xthr < conf_vector_2(2))
%         conf_count = conf_count +1;
%     end
%     conf_series(iIter) = conf_count/(iIter);
% end
% conf_count/(num_iter)
% figure; plot(conf_series);
% figure; 
% plot(cont_bumps,cont_matrix_1,'b')
% hold on
% plot(cont_bumps,cont_matrix_2,'r')
% figure;
% hist(xthr_difference,100)

% %%
% figure; 
% plot(unique_x,y_mean,'Color',[0.7 0.7 0.7])
% hold on
% plot(cont_bump_plot',sigmoid_fit_data_null(cont_bump_plot),'k')
% plot(xthr_null_conf,[thr_null_level thr_null_level],'k-')
% xlabel('Bump magnitude [N]')
% ylabel('Move to target 1')
% title(['Stats sanity check. All conditions combined. ' num2str(size(y_mean,1)) ' iterations.'...
%     ' Error bar: 95% confidence'])

%%
figure
hold on
for iStim = 1:size(moved_t1,1)
    plot(bumps_ordered,t1t2ratio(iStim,:,:),'.',...
        'Color',colors(round(iStim/size(moved_t1,1)*64),:));
end
plot(bumps_ordered,t1t2ratio_combined,'.',...
    'Color','k');
for iStim = 1:size(moved_t1,1)
    plot(cont_bump_plot',sigmoid_fit_data{iStim}(cont_bump_plot),...
        'Color',colors(round(iStim/size(moved_t1,1)*64),:))
    plot(xthr_conf(:,iStim)',[thr_level(iStim) thr_level(iStim)],'-',...
        'Color',colors(round(iStim/size(moved_t1,1)*64),:))    
    
    errorbar(bumps_ordered,t1t2ratio(iStim,:,:),t1t2ratio(iStim,:,:)-conf_bounds(iStim,:,1),...
        conf_bounds(iStim,:,2)-t1t2ratio(iStim,:,:),'.',...
        'Color',colors(round(iStim/size(moved_t1,1)*64),:));
end
plot(cont_bump_plot',sigmoid_fit_data_null(cont_bump_plot),'k--')
plot(xthr_null_conf,[thr_null_level thr_null_level],'k-')

errorbar(bumps_ordered,t1t2ratio_combined,t1t2ratio_combined-conf_bounds_all(:,1)',...
    conf_bounds_all(:,2)'-t1t2ratio_combined,'.',...
    'Color','k');
ylim([0 1])
xlim([min(bumps_ordered) max(bumps_ordered)])
    
sigmoid_results.sigmoid_fit_data = sigmoid_fit_data;
% sigmoid_results.sigmoid_fit_data_null = sigmoid_fit_data_null;
sigmoid_results.xthr = xthr;
sigmoid_results.xthr_conf = xthr_conf;
sigmoid_results.xthr_level = thr_level;
sigmoid_results.bumps_ordered = bumps_ordered;

