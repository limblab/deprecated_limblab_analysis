%%
num_times = 50;
num_neurons = zeros(num_times,1);
num_same = zeros(num_times,1);
median_t = zeros(num_times,1);
median_cos = zeros(num_times,1);

for i = 1:num_times
    [num_neurons(i),num_same(i),median_t(i),median_cos(i)] = get_stat_stats;
end

%% R^2 scatter plot
figure
h_scattergood = plot(VAF_unc(VAF_unc>0.4 & VAF_con>0.4),VAF_con(VAF_unc>0.4 & VAF_con>0.4), '.');
hold on
h_scatterbad = plot(VAF_unc(VAF_unc<0.4 | VAF_con<0.4),VAF_con(VAF_unc<0.4 | VAF_con<0.4), '.');
set(h_scatterbad,'Color',[0.5 0.5 1])
plot([0.4 0.4],[0 1],'k--')
plot([0 1],[0.4 0.4],'k--')
% title 'Goodness of linear fit (R^2) for neural activity'
xlabel 'Unconstrained R^2'
ylabel 'Constrained R^2'
axis([0 1 0 1])

%%
figure(1)
figure(2)
% for i = 1:length(neurons)
for i = [11 52]
    figure(1)
    plot_heat_map(activity_unc(i,:)',zerod_ep);
    title(['Neuron ' num2str(i) ': Unconstrained'])
    figure(2)
    plot_heat_map(activity_con(i,:)',zerod_ep);
    title(['Neuron ' num2str(i) ': Constrained'])
    waitforbuttonpress
end

% %%
% for i = 1:length(neurons)
%     plot_polar_heatmap(activity_unc(i,:)',rs,as);
%     title(['Neuron ' num2str(i)])
%     plot_polar_heatmap(activity_con(i,:)',rs,as);
%     waitforbuttonpress
% end

%%
figure(1)
figure(2)
% for i = 1:length(neurons)
for i = [11 52]
    figure(1)
    plot_real_v_predicted(activity_unc(i,:)',pol_fit_unc{i},[x1' x2'])
    title(['Neuron ' num2str(i) ': Unconstrained'])
    xlabel('Actual Firing Rate')
    ylabel('Predicted Firing Rate from Linear Model')
    legend('Firing Rates','Identity Line')
    legend('Location','SouthEast')
    legend('boxoff')
    axis equal
    
    figure(2)
    plot_real_v_predicted(activity_con(i,:)',pol_fit_unc{i},[x1' x2'])
    title(['Neuron ' num2str(i) ': Constrained'])
    xlabel('Actual Firing Rate')
    ylabel('Predicted Firing Rate from Linear Model')
    legend('Firing Rates','Identity Line')
    legend('Location','SouthEast')
    legend('boxoff')
    axis equal
    
    waitforbuttonpress
end

%% pd distribution plot
figure
plot_PD_distr(yupd,50)
title 'Distribution of Preferred Directions: Unconstrained'
figure
plot_PD_distr(ycpd,50)
title 'Distribution of Preferred Directions: Constrained'

%% comparison histogram plot
figure;hist(abs(tStat_neuron(VAF_unc>0.4 & VAF_con>0.4)),20)
title 'Histogram of Constraint-related t-statistics'
xlabel 't-statistic'
ylabel 'Number of Neurons'
% median +-2.6717
%%% COMPARE TO SUPERVISED BY PLOTTING TOGETHER WITH IT

figure;plot_PD_distr(ycpd(VAF_unc>0.4 & VAF_con>0.4) - yupd(VAF_unc>0.4 & VAF_con>0.4),30)
title 'Distribution of Change in Preferred Direction: Contrained-Unconstrained'
% median +-15.5438 degrees

%% muscle length plot
total_length = sum(scaled_lengths_unc,2);
figure;plot_heat_map(total_length,zerod_ep);

muscle_fit = LinearModel.fit(zerod_ep,total_length);
muscle_coef = muscle_fit.Coefficients.Estimate;
muscle_PD = atan2(muscle_coef(3),muscle_coef(2));
title(['PD: ' num2str(180/pi*muscle_PD)])

%% plot sigmoid
input = linspace(-10,10,100)';
output = 60./(1+exp(-input));

figure;
plot(input,output,'k-',[0 0],[0 70],'k-',[-10 10],[0 0],'k-',[-10 10],[60 60],'k--', 'Linewidth', 2)
axis off

%% Plane regression figures
asg_corners = [asg(1,1) asg(1,10) asg(10,10) asg(10,1)]';
rsg_corners = [rsg(1,1) rsg(1,10) rsg(10,10) rsg(10,1)]';
rsg_list = reshape(rsg,1,100)';
asg_list = reshape(asg,1,100)';

figure(1)
for i = [11]
    plane_list = predict(pol_fit_unc{i},[rsg_list asg_list]);
    plane_corners = predict(pol_fit_unc{i},[rsg_corners asg_corners]);
    figure(1)
    plot3([rsg_corners(1) rsg_corners(2)],180/pi*[asg_corners(1) asg_corners(2)],[plane_corners(1) plane_corners(2)],'k-')
    hold on
    plot3([rsg_corners(2) rsg_corners(3)],180/pi*[asg_corners(2) asg_corners(3)],[plane_corners(2) plane_corners(3)],'k-')
    plot3([rsg_corners(3) rsg_corners(4)],180/pi*[asg_corners(3) asg_corners(4)],[plane_corners(3) plane_corners(4)],'k-')
    plot3([rsg_corners(4) rsg_corners(1)],180/pi*[asg_corners(4) asg_corners(1)],[plane_corners(4) plane_corners(1)],'k-')
    plot3(rsg_list,180/pi*asg_list,plane_list,'k.')
    plot3(rsg_list,180/pi*asg_list,activity_unc(i,:)','bo')
    for j = 1:100
        plot3([rsg_list(j) rsg_list(j)],180/pi*[asg_list(j) asg_list(j)],[plane_list(j) activity_unc(i,j)],'k-')
    end
end

figure(2)
for i = [11]
    plane_list = predict(pol_fit_con{i},[rsg_list asg_list]);
    plane_corners = predict(pol_fit_con{i},[rsg_corners asg_corners]);
    figure(2)
    plot3([rsg_corners(1) rsg_corners(2)],180/pi*[asg_corners(1) asg_corners(2)],[plane_corners(1) plane_corners(2)],'k-')
    hold on
    plot3([rsg_corners(2) rsg_corners(3)],180/pi*[asg_corners(2) asg_corners(3)],[plane_corners(2) plane_corners(3)],'k-')
    plot3([rsg_corners(3) rsg_corners(4)],180/pi*[asg_corners(3) asg_corners(4)],[plane_corners(3) plane_corners(4)],'k-')
    plot3([rsg_corners(4) rsg_corners(1)],180/pi*[asg_corners(4) asg_corners(1)],[plane_corners(4) plane_corners(1)],'k-')
    plot3(rsg_list,180/pi*asg_list,plane_list,'k.')
    plot3(rsg_list,180/pi*asg_list,activity_con(i,:)','bo')
    for j = 1:100
        plot3([rsg_list(j) rsg_list(j)],180/pi*[asg_list(j) asg_list(j)],[plane_list(j) activity_con(i,j)],'k-')
    end
end
    