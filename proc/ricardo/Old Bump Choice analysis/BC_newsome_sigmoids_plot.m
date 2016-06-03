function [h,sigmoid_fit_bumps,...
    sigmoid_fit_stim] = BC_newsome_sigmoids_plot(bump_table_summary,stim_table_summary,...
        sigmoid_fit_bumps_params, sigmoid_fit_stim_params,bump_directions,bumps_ordered,filename)

fit_func = 'a+b/(1+exp(x*c+d))';
f_sigmoid = fittype(fit_func,'independent','x');

% bump_magnitudes = unique(bump_table(:,7));
% bump_directions = unique(bump_table(:,6));
% 
% if bump_directions~=stim_pd
%     error(['Stim PD (' num2str(stim_pd) ') does not match file bump directions ('...
%         num2str(bump_directions(1)) ', ' num2str(bump_directions(2)) '), check BC_newsome_experiment_list.m']); %#ok<WNTAG>
% end
% 
% bump_directions = [bump_directions(bump_directions==stim_pd) bump_directions(bump_directions~=stim_pd)];
% bumps_ordered = unique(2*[-bump_magnitudes(end:-1:1);bump_magnitudes]); %convert bumps to forces
% 
% bump_table_summary = BC_table_summary(bump_table,bump_directions);
% stim_table_summary = BC_table_summary(stim_table,bump_directions);

bump_ratios = bump_table_summary(:,1)./(bump_table_summary(:,1)+bump_table_summary(:,2));
stim_ratios = stim_table_summary(:,1)./(stim_table_summary(:,1)+stim_table_summary(:,2));

% sigmoid_fit_bumps_params = sigmoid_fit_bootstrap(bump_table_summary,bumps_ordered,num_iter);
% sigmoid_fit_stim_params = sigmoid_fit_bootstrap(stim_table_summary,bumps_ordered,num_iter);

bump_null_bias = sigmoid_fit_bumps_params(:,1)+sigmoid_fit_bumps_params(:,2)./(1+exp(sigmoid_fit_bumps_params(:,4)));
stim_null_bias = sigmoid_fit_stim_params(:,1)+sigmoid_fit_stim_params(:,2)./(1+exp(sigmoid_fit_stim_params(:,4)));
bump_pse = sigmoid_fit_bumps_params(:,4)./sigmoid_fit_bumps_params(:,3);
stim_pse = sigmoid_fit_stim_params(:,4)./sigmoid_fit_stim_params(:,3);

% bump_null_bias = sort(bump_null_bias);
% stim_null_bias = sort(stim_null_bias);        
% bump_null_bias = bump_null_bias(1+round(num_iter*.01):round(num_iter*.99));
% stim_null_bias = stim_null_bias(1+round(num_iter*.01):round(num_iter*.99));
% 
% bump_pse = sort(bump_pse);
% stim_pse = sort(stim_pse);        
% bump_pse = bump_pse(1+round(num_iter*.01):round(num_iter*.99));
% stim_pse = stim_pse(1+round(num_iter*.01):round(num_iter*.99));        

null_bias_bins = [min(mean(bump_null_bias)-3*std(bump_null_bias),...
    mean(stim_null_bias)-3*std(stim_null_bias)),...
    max(mean(bump_null_bias)+3*std(bump_null_bias),...
    mean(stim_null_bias)+3*std(stim_null_bias))];        
bump_null_bias = bump_null_bias(bump_null_bias>null_bias_bins(1) &...
    bump_null_bias<null_bias_bins(2));
stim_null_bias = stim_null_bias(stim_null_bias>null_bias_bins(1) &...
    stim_null_bias<null_bias_bins(2));
null_bias_bins = linspace(null_bias_bins(1),null_bias_bins(2),50);

pse_bins = [min(mean(bump_pse)-3*std(bump_pse),...
    mean(stim_pse)-3*std(stim_pse)),...
    max(mean(bump_pse)+3*std(bump_pse),...
    mean(stim_pse)+3*std(stim_pse))];
bump_pse = bump_pse(bump_pse>pse_bins(1) &...
    bump_pse<pse_bins(2));
stim_pse = stim_pse(stim_pse>pse_bins(1) &...
    stim_pse<pse_bins(2));
pse_bins = linspace(pse_bins(1),pse_bins(2),50);

h = figure;
subplot(2,2,1)
hold on
target_distance = 10;
target_size = 3;

xlim([-target_distance-target_size target_distance+target_size])
ylim([-target_distance-target_size target_distance+target_size])
set(gca,'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Visible','off')

target_coord = [-target_size/2 -target_size/2 target_size/2 target_size/2 -target_size/2;...
    -target_size/2 target_size/2 target_size/2 -target_size/2 -target_size/2];
area(target_coord(1,:),target_coord(2,:),'FaceColor','r','LineStyle','none')

area(cos(bump_directions(1))*target_distance+target_coord(1,:),...
    sin(bump_directions(1))*target_distance+target_coord(2,:),'FaceColor','r','LineStyle','none')
text(cos(bump_directions(1))*target_distance,...
    sin(bump_directions(1))*target_distance+target_size,1,'T1','Color','k','HorizontalAlignment','center')

area(cos(bump_directions(2))*target_distance+target_coord(1,:),...
    sin(bump_directions(2))*target_distance+target_coord(2,:),'FaceColor','r','LineStyle','none')
text(cos(bump_directions(2))*target_distance,...
    sin(bump_directions(2))*target_distance+target_size,1,'T2','Color','k','HorizontalAlignment','center')

area(target_size/4*cos(0:.1:2*pi),target_size/4*sin(0:.1:2*pi),'FaceColor','y','LineStyle','none')
vectarrow([0 0],[target_distance/2*cos(bump_directions(1)) target_distance/2*sin(bump_directions(1))],.1,.1,'k')
hold on
text(target_distance/2*cos(bump_directions(1)),target_distance/2*sin(bump_directions(1))+target_distance/5,1,...
    'Bump','HorizontalAlignment','center')

vectarrow([-.6*target_distance target_distance],...
    [-.6*target_distance+target_distance/2*cos(bump_directions(1)) target_distance+target_distance/2*sin(bump_directions(1))],...
    .1,.1,'k')
text(-target_distance*.8, target_distance+target_distance/5,1,'PD','HorizontalAlignment','center')

subplot(2,2,2)
hold on
plot(bumps_ordered, bump_ratios,'r.','MarkerSize',10)
plot(bumps_ordered, stim_ratios,'b.','MarkerSize',10)

% sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios,f_sigmoid,...
%             'StartPoint',[1 -1 100 0]);
% sigmoid_fit_stim = fit(bumps_ordered,stim_ratios,f_sigmoid,...
%             'StartPoint',[1 -1 100 0]);
        
sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios,f_sigmoid,...
    'StartPoint',[1 1 100 -1],'Lower',[0 0 0 -inf],'Upper',[inf inf inf inf]);
sigmoid_fit_stim = fit(bumps_ordered,stim_ratios,f_sigmoid,...
    'StartPoint',[1 1 100 -1],'Lower',[0 0 0 -inf],'Upper',[inf inf inf inf]);
    
    
h_temp = plot(sigmoid_fit_bumps,'r');
set(h_temp,'LineWidth',2)

h_temp = plot(sigmoid_fit_stim,'b');
set(h_temp,'LineWidth',2)

text(min(bumps_ordered)+mean(diff(bumps_ordered))/2,.15,'Bump','Color','r')
text(min(bumps_ordered)+mean(diff(bumps_ordered))/2,.05,'Bump + ICMS','Color','b')
legend off

ylim([0 1]);
xlim([min(bumps_ordered) max(bumps_ordered)]);

xlabel('Bump magnitude [N]')
ylabel('P(moving to T1)')
title(filename)

subplot(4,2,5)          
hold on; 
hist(bump_null_bias,sort(null_bias_bins));
h1 = findobj(gca,'Type','patch');
hist(stim_null_bias,sort(null_bias_bins));        
h2 = findobj(gca,'Type','patch');
h2 = h2(h2~=h1);
set(h1,'FaceColor','r','EdgeColor','r'); 
set(h2,'FaceColor','b','EdgeColor','b'); 
%         set(h1,'FaceColor','r','FaceAlpha',.7,'EdgeColor','r'); 
%         set(h2,'FaceColor','b','FaceAlpha',.7,'EdgeColor','b'); 
xlim([0.25 0.75])
ylabel('Count'); xlabel('Null bias');

subplot(4,2,6)
hold on;
num_samples = min(length(bump_null_bias),length(stim_null_bias));
stim_samples = randperm(num_samples);
bump_samples = randperm(num_samples);

[temp_hist hist_bins]= hist(bump_null_bias(bump_samples)-...
    stim_null_bias(stim_samples),100);
hist(bump_null_bias(bump_samples)-...
    stim_null_bias(stim_samples),100)
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','r'); 
p_value = sum(temp_hist(hist_bins<0))/sum(temp_hist);
text(hist_bins(round(.75*length(hist_bins))),1.1*max(temp_hist),['p = ' num2str(p_value)])

subplot(4,2,7)        
hold on;        
hist(bump_pse,pse_bins);
h1 = findobj(gca,'Type','patch');
hist(stim_pse,pse_bins);  
ylabel('Count'); xlabel('PSE [N]');
h2 = findobj(gca,'Type','patch');
h2 = h2(h2~=h1);
set(h1,'FaceColor','r','EdgeColor','r'); 
set(h2,'FaceColor','b','EdgeColor','b'); 
%         set(h1,'FaceColor','r','FaceAlpha',.7,'LineStyle','none'); 
%         set(h2,'FaceColor','b','FaceAlpha',.7,'LineStyle','none'); 

subplot(4,2,8)
hold on;
num_samples = min(length(bump_pse),length(stim_pse));
stim_samples = randperm(num_samples);
bump_samples = randperm(num_samples);
[temp_hist hist_bins]= hist(bump_pse(bump_samples)-...
    stim_pse(stim_samples),100);
hist(bump_pse(bump_samples)-...
    stim_pse(stim_samples),100);
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','r'); 
p_value = sum(temp_hist(hist_bins<0))/sum(temp_hist);
text(hist_bins(round(.75*length(hist_bins))),1.1*max(temp_hist),['p = ' num2str(p_value)])    


