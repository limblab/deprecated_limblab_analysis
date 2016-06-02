function AT_plot_behavior(AT_struct,bdf,file_details,save_figs)

fit_func = @(Pmin,Pmax,beta,xthr1,xthr2,x) (((x<=90).*(Pmin+(Pmax-Pmin)./(1+exp(beta.*(xthr1-x)))) +...
    (x>=90).*(Pmin+(Pmax-Pmin)./(1+exp(-beta.*(xthr2-x))))).*(.5.*(x==90) + 1.*(x~=90)));

f_sigmoid = fittype(fit_func,'independent','x');
f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[.3 .7 .01 0 180],...
    'MaxFunEvals',100000,'MaxIter',10000,'Lower',[0 0.3 0 -60 120],'Upper',[0.7 1 inf 60 240]);

%%
% Bump direction figure
figure; 
plot(cos(AT_struct.bump_directions(AT_struct.visual_trials)),sin(AT_struct.bump_directions(AT_struct.visual_trials)),'b.')
hold on
plot(cos(AT_struct.bump_directions(AT_struct.proprio_trials)),sin(AT_struct.bump_directions(AT_struct.proprio_trials)),'r.')
title('Bump directions')
xlabel('X force (N)')
ylabel('Y force (N)')


%% Position figure
figure; 
plot(AT_struct.x_pos_translated(AT_struct.visual_trials,:)',AT_struct.y_pos_translated(AT_struct.visual_trials,:)','b-')
hold on
plot(AT_struct.x_pos_translated(AT_struct.proprio_trials,:)',AT_struct.y_pos_translated(AT_struct.proprio_trials,:)','r-')
axis square
title('Hand displacement')
xlabel('X position (cm)')
ylabel('Y position (cm)')
lim = 1.1*max(max(max(abs(AT_struct.x_pos))),max(max(abs(AT_struct.y_pos))));
xlim([-lim lim])
ylim([-lim lim])

%% Projection figure
x_projection = AT_struct.x_pos_translated.*(repmat(cos(AT_struct.bump_directions),1,length(AT_struct.t_axis)))+...
    AT_struct.y_pos_translated.*(repmat(sin(AT_struct.bump_directions),1,length(AT_struct.t_axis)));
y_projection = -AT_struct.x_pos_translated.*(repmat(sin(AT_struct.bump_directions),1,length(AT_struct.t_axis)))+...
    AT_struct.y_pos_translated.*(repmat(cos(AT_struct.bump_directions),1,length(AT_struct.t_axis)));
x_force_projection = AT_struct.x_force.*(repmat(cos(AT_struct.bump_directions),1,length(AT_struct.t_axis)))+...
                AT_struct.y_force.*(repmat(sin(AT_struct.bump_directions),1,length(AT_struct.t_axis)));
y_force_projection = -AT_struct.x_force.*(repmat(sin(AT_struct.bump_directions),1,length(AT_struct.t_axis)))+...
    AT_struct.y_force.*(repmat(cos(AT_struct.bump_directions),1,length(AT_struct.t_axis)));

figure; 
plot(x_projection(AT_struct.visual_trials,AT_struct.t_zero_idx:AT_struct.t_end_bump_idx)',...
    y_projection(AT_struct.visual_trials,AT_struct.t_zero_idx:AT_struct.t_end_bump_idx)','b-')
hold on
plot(x_projection(AT_struct.proprio_trials,AT_struct.t_zero_idx:AT_struct.t_end_bump_idx)',...
    y_projection(AT_struct.proprio_trials,AT_struct.t_zero_idx:AT_struct.t_end_bump_idx)','r-')
axis equal
title('Bump projection (cm)')
xlabel('Projection parallel to bump direction (cm)')
ylabel('Projection perpendicular to bump direction (cm)')

%% Comparison of same bump directions for different trial types

averaged_x_pos_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_y_pos_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_x_pos_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_y_pos_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));

averaged_x_force_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_y_force_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_x_force_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_y_force_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));

averaged_x_projection_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_y_projection_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_x_projection_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_y_projection_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
max_x_projection_visual = zeros(length(AT_struct.unique_bump_directions),1);
max_y_projection_visual = zeros(length(AT_struct.unique_bump_directions),1);
max_x_projection_proprio = zeros(length(AT_struct.unique_bump_directions),1);
max_y_projection_proprio = zeros(length(AT_struct.unique_bump_directions),1);

averaged_displacement_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_displacement_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
max_displacement_visual = zeros(length(AT_struct.unique_bump_directions),1);
max_displacement_proprio = zeros(length(AT_struct.unique_bump_directions),1);

averaged_forces_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
averaged_forces_proprio = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));

stiffness_x_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));
stiffness_y_visual = zeros(length(AT_struct.unique_bump_directions),length(AT_struct.t_axis));

stiffness_visual = zeros(length(AT_struct.unique_bump_directions),1);
stiffness_proprio = zeros(length(AT_struct.unique_bump_directions),1);

for iBumpDir = 1:length(AT_struct.unique_bump_directions)
    averaged_x_pos_visual(iBumpDir,:) = mean(AT_struct.x_pos(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_y_pos_visual(iBumpDir,:) = mean(AT_struct.y_pos(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_x_pos_proprio(iBumpDir,:) = mean(AT_struct.x_pos(AT_struct.proprio_idx{iBumpDir},:),1);
    averaged_y_pos_proprio(iBumpDir,:) = mean(AT_struct.y_pos(AT_struct.proprio_idx{iBumpDir},:),1);
    
    averaged_x_force_visual(iBumpDir,:) = mean(AT_struct.x_force(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_y_force_visual(iBumpDir,:) = mean(AT_struct.y_force(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_x_force_proprio(iBumpDir,:) = mean(AT_struct.x_force(AT_struct.proprio_idx{iBumpDir},:),1);
    averaged_y_force_proprio(iBumpDir,:) = mean(AT_struct.y_force(AT_struct.proprio_idx{iBumpDir},:),1);
    
    averaged_x_projection_visual(iBumpDir,:) = mean(x_projection(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_y_projection_visual(iBumpDir,:) = mean(y_projection(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_x_projection_proprio(iBumpDir,:) = mean(x_projection(AT_struct.proprio_idx{iBumpDir},:),1);
    averaged_y_projection_proprio(iBumpDir,:) = mean(y_projection(AT_struct.proprio_idx{iBumpDir},:),1);
    max_x_projection_visual(iBumpDir) = max(averaged_x_projection_visual(iBumpDir,:));
    max_y_projection_visual(iBumpDir) = max(averaged_y_projection_visual(iBumpDir,:));
    max_x_projection_proprio(iBumpDir) = max(averaged_x_projection_proprio(iBumpDir,:));
    max_y_projection_proprio(iBumpDir) = max(averaged_y_projection_proprio(iBumpDir,:));
    
    averaged_displacement_visual(iBumpDir,:) = sqrt(averaged_x_projection_visual(iBumpDir,:).^2 +...
        averaged_y_projection_visual(iBumpDir,:).^2);
    averaged_displacement_proprio(iBumpDir,:) = sqrt(averaged_x_projection_proprio(iBumpDir,:).^2 +...
        averaged_y_projection_proprio(iBumpDir,:).^2);
    max_displacement_visual(iBumpDir) = max(averaged_displacement_visual(iBumpDir,:));
    max_displacement_proprio(iBumpDir) = max(averaged_displacement_proprio(iBumpDir,:));
    
    averaged_forces_visual(iBumpDir,:) = mean(x_force_projection(AT_struct.visual_idx{iBumpDir},:),1);
    averaged_forces_proprio(iBumpDir,:) = mean(x_force_projection(AT_struct.proprio_idx{iBumpDir},:),1);    
    
    large_displacement_idx = find(abs(averaged_x_projection_visual(iBumpDir,:))>0.5);
    
    stiffness_visual(iBumpDir) =  abs(mean(averaged_forces_visual(iBumpDir,large_displacement_idx)./...
        averaged_x_projection_visual(iBumpDir,large_displacement_idx)));
    
    large_displacement_idx = find(abs(averaged_x_projection_proprio(iBumpDir,:))>0.5);
    
    stiffness_proprio(iBumpDir) =  abs(mean(averaged_forces_proprio(iBumpDir,large_displacement_idx)./...
        averaged_x_projection_proprio(iBumpDir,large_displacement_idx)));
    
    stiffness_x_visual(iBumpDir,:) = averaged_x_force_visual(iBumpDir,:)./...
        averaged_x_projection_visual(iBumpDir,:);
    stiffness_y_visual(iBumpDir,:) = averaged_y_force_visual(iBumpDir,:)./...
        averaged_y_projection_visual(iBumpDir,:);
end

% figure; plot(averaged_x_force_visual',averaged_y_force_visual')
%% Average maximum projection
figure;
plot(AT_struct.unique_bump_directions*180/pi,max_x_projection_visual,'.b')
hold on
plot(AT_struct.unique_bump_directions*180/pi,max_x_projection_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
if ~isempty(max_x_projection_visual) && ~isempty(max_x_projection_proprio)
    ylim([0 1.1*max(max(max_x_projection_visual),max(max_x_projection_proprio))])
end
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')

%% Maximum projection
figure
plot(AT_struct.bump_directions(AT_struct.visual_trials),max(x_projection(AT_struct.visual_trials,:),[],2),'.b')
hold on
plot(AT_struct.bump_directions(AT_struct.proprio_trials),max(x_projection(AT_struct.proprio_trials,:),[],2),'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')

%% Maximum projection by result
figure
subplot(211)
plot(180/pi*AT_struct.bump_directions(intersect(AT_struct.visual_trials,AT_struct.reward_trials)),...
    max(x_projection(intersect(AT_struct.visual_trials,AT_struct.reward_trials),:),[],2),'.b')
hold on
plot(180/pi*AT_struct.bump_directions(intersect(AT_struct.visual_trials,AT_struct.fail_trials)),...
    max(x_projection(intersect(AT_struct.visual_trials,AT_struct.fail_trials),:),[],2),'.r')
title('Visual trials')
legend('Reward','Fail')
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')
xlim([0 360])

subplot(212)
plot(180/pi*AT_struct.bump_directions(intersect(AT_struct.proprio_trials,AT_struct.reward_trials)),...
    max(x_projection(intersect(AT_struct.proprio_trials,AT_struct.reward_trials),:),[],2),'.b')
hold on
plot(180/pi*AT_struct.bump_directions(intersect(AT_struct.proprio_trials,AT_struct.fail_trials)),...
    max(x_projection(intersect(AT_struct.proprio_trials,AT_struct.fail_trials),:),[],2),'.r')
title('Proprio trials')
legend('Reward','Fail')
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')
xlim([0 360])

%% Maximum displacement
figure;
plot(AT_struct.unique_bump_directions*180/pi,max_displacement_visual,'.b')
hold on
plot(AT_struct.unique_bump_directions*180/pi,max_displacement_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max displacement (cm)')
if ~isempty(max_displacement_visual) && ~isempty(max_displacement_proprio)
    ylim([0 1.1*max(max(max_displacement_visual),max(max_displacement_proprio))])
end
xlabel('Bump direction (deg)')
ylabel('Max displacement (cm)')

%% Maximum projection polar
figure;
plot(cos(AT_struct.unique_bump_directions).*max_x_projection_visual,sin(AT_struct.unique_bump_directions).*max_x_projection_visual,'.b')
hold on
plot(cos(AT_struct.unique_bump_directions).*max_x_projection_proprio,sin(AT_struct.unique_bump_directions).*max_x_projection_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
xlabel('Max X projection (cm)')
ylabel('Max Y projection (cm)')
lim = max(max(max_x_projection_proprio),max(max_x_projection_visual));
if ~isempty(lim)
    xlim([-lim lim])
    ylim([-lim lim])
end
axis square

%% Maximum displacement polar
figure;
plot(cos(AT_struct.unique_bump_directions).*max_displacement_visual,sin(AT_struct.unique_bump_directions).*max_displacement_visual,'.b')
hold on
plot(cos(AT_struct.unique_bump_directions).*max_displacement_proprio,sin(AT_struct.unique_bump_directions).*max_displacement_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max displacement (cm)')
xlabel('Max X displacement (cm)')
ylabel('Max Y displacement (cm)')
lim = max(max(max_displacement_proprio),max(max_displacement_visual));
if ~isempty(lim)
    xlim([-lim lim])    
    ylim([-lim lim])
end
axis square

%%
% Forces and stiffness
figure;
plot(0,0,'-b',0,0,'-r')
hold on
% plot(averaged_x_force_visual(:,:)',averaged_y_force_visual(:,:)','-b')
% plot(averaged_x_force_proprio(:,:)',averaged_y_force_proprio(:,:)','-r')
plot(averaged_x_force_visual(:,:)',averaged_y_force_visual(:,:)')
plot(averaged_x_force_proprio(:,:)',averaged_y_force_proprio(:,:)')
axis equal
legend('Visual','Proprioceptive')
xlabel('X force (N)')
ylabel('Y force (N)')
title('Forces')

%% Directional stiffness
figure;
plot(cos(AT_struct.unique_bump_directions).*stiffness_visual,sin(AT_struct.unique_bump_directions).*stiffness_visual,'.b')
hold on
plot(cos(AT_struct.unique_bump_directions).*stiffness_proprio,sin(AT_struct.unique_bump_directions).*stiffness_proprio,'.r')
plot(cos(0:.05:2*pi+.05),sin(0:0.05:2*pi+.05),'k-')
axis equal
title('Stiffness')
xlabel('X stiffness (N/m)')
ylabel('Y stiffness (N/m)')
legend('Visual','Proprioceptive')

% %% Forces test
% force_magnitude = sqrt(x_force.^2+y_force.^2);
% force_direction = atan2(y_force,x_force);
% bump_directions = unique(trial_table(:,tc.bump_direction));
% mean_bump = zeros(length(bump_directions),1);
% mean_dir = zeros(length(bump_directions),1);
% for i=1:length(bump_directions)
%     mean_bump(i) = mean(mean(force_magnitude(trial_table(:,tc.bump_direction)==bump_directions(i),150:249)));
%     mean_dir(i) = mean(mean(force_direction(trial_table(:,tc.bump_direction)==bump_directions(i),150:249)))+pi;
% end
% figure; plot(bump_directions*180/pi,mean_bump,'.')
% % figure; plot(cos(bump_directions).*mean_bump,sin(bump_directions).*mean_bump,'.')
% % axis equal
% cos_fun = 'a+b*sin(2*x+c)';
% fit_bumps = fit(bump_directions,mean_bump,cos_fun);
% hold on
% plot_fit_bumps = fit_bumps(0:.1:2*pi);
% plot(180/pi*(0:.1:2*pi),plot_fit_bumps,'-')
% figure
% plot(bump_directions,mean_dir','.')
% axis equal

%% Performance as a function of time
figure; 
plot(AT_struct.trial_table((AT_struct.trial_table(:,AT_struct.table_columns.result)==32|...
    AT_struct.trial_table(:,AT_struct.table_columns.result)==34) &...
    AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==0,AT_struct.table_columns.t_trial_start),...
    100*smooth(AT_struct.trial_table((AT_struct.trial_table(:,AT_struct.table_columns.result)==32|...
    AT_struct.trial_table(:,AT_struct.table_columns.result)==34) &...
    AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==0,AT_struct.table_columns.result)==32,50),'.b')
hold on
plot(AT_struct.trial_table((AT_struct.trial_table(:,AT_struct.table_columns.result)==32|...
    AT_struct.trial_table(:,AT_struct.table_columns.result)==34) &...
    AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==1,AT_struct.table_columns.t_trial_start),...
    100*smooth(AT_struct.trial_table((AT_struct.trial_table(:,AT_struct.table_columns.result)==32|...
    AT_struct.trial_table(:,AT_struct.table_columns.result)==34) &...
    AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==1,AT_struct.table_columns.result)==32,50),'.r')
xlabel('t (s)')
ylabel('Percent correct (smoothed)')
title('Performance')
legend('Visual','Proprio')

%% Directional performance
% Visual trials
figure;
visual_response = AT_struct.trial_table(AT_struct.visual_trials,AT_struct.table_columns.result)==32;
unique_dot_dirs = unique(AT_struct.dot_directions);
visual_response_mean = zeros(size(unique_dot_dirs));
for iDir = 1:length(unique_dot_dirs)
    visual_response_mean(iDir) = mean(AT_struct.trial_table(intersect(AT_struct.visual_trials,...
        find(AT_struct.dot_directions==unique_dot_dirs(iDir))),AT_struct.table_columns.result)==32);
end
   
unique_bump_dirs = unique(AT_struct.bump_directions);
proprio_response_mean = zeros(size(unique_bump_dirs));
for iDir = 1:length(unique_bump_dirs)
    proprio_response_mean(iDir) = mean(AT_struct.trial_table(intersect(AT_struct.proprio_trials,...
        find(AT_struct.bump_directions==unique_bump_dirs(iDir))),AT_struct.table_columns.result)==32);
end

plot(180/pi*unique_dot_dirs,...
    visual_response_mean,'.b')
hold on
plot(180/pi*unique_bump_dirs,proprio_response_mean,'.r')
plot([0 360],[mean(proprio_response_mean(~isnan(proprio_response_mean))) mean(proprio_response_mean(~isnan(proprio_response_mean)))],'-r')
plot([0 360],[mean(visual_response_mean(~isnan(visual_response_mean))) mean(visual_response_mean(~isnan(visual_response_mean)))],'-b')
legend('Visual','Proprioceptive')
title('Performance as a function of direction')
xlabel('Bump/dots direction (deg)')
ylabel('Response')
ylim([0 1])
xlim([0 360])

%% Psychophysics
main_directions = AT_struct.trial_table(:,AT_struct.table_columns.main_direction);
unique_main_directions = unique(main_directions);
stim_directions = nan(size(main_directions));
stim_directions(AT_struct.visual_trials) = AT_struct.dot_directions(AT_struct.visual_trials);
stim_directions(AT_struct.proprio_trials) = AT_struct.bump_directions(AT_struct.proprio_trials);
left_stim = mod(stim_directions - main_directions,2*pi) < mod(main_directions-stim_directions,2*pi);

temp_diff = main_directions - stim_directions;
temp_diff(temp_diff>3*pi/2) = -2*pi+temp_diff(temp_diff>3*pi/2);
temp_diff(temp_diff<-pi/2) = 2*pi+temp_diff(temp_diff<-pi/2);
temp_diff = round(temp_diff*1E6)/1E6;

if length(unique(temp_diff))>=4
    result_temp = (left_stim & AT_struct.trial_table(:,AT_struct.table_columns.result)==34) |...
        (~left_stim & AT_struct.trial_table(:,AT_struct.table_columns.result)==32);

    for iMainDir = 1:length(unique_main_directions)
        dir_idx = find(main_directions==unique_main_directions(iMainDir));    
        visual_idx_temp = intersect(dir_idx,AT_struct.visual_trials);
        proprio_idx_temp = intersect(dir_idx,AT_struct.proprio_trials);

        if length(visual_idx_temp)>=4 && length(proprio_idx_temp)>=4
            [unique_visual_temp] = unique(temp_diff(visual_idx_temp));
            [unique_proprio_temp] = unique(temp_diff(proprio_idx_temp));

            response_vis = zeros(size(unique_visual_temp));
            response_pro = zeros(size(unique_proprio_temp));
            response_vis_vector = [];
            response_pro_vector = [];
            vis_dir_vector = [];
            pro_dir_vector = [];
            for iVis = 1:length(unique_visual_temp)
                response_vis_vector = [response_vis_vector; result_temp(intersect(visual_idx_temp,find(temp_diff == unique_visual_temp(iVis))))];
                vis_dir_vector = [vis_dir_vector; unique_visual_temp(iVis)*ones(size(result_temp(intersect(visual_idx_temp,find(temp_diff == unique_visual_temp(iVis))))))];
                response_vis(iVis) = mean(result_temp(intersect(visual_idx_temp,find(temp_diff == unique_visual_temp(iVis)))));
            end

            for iPro = 1:length(unique_proprio_temp)
                response_pro_vector = [response_pro_vector; result_temp(intersect(proprio_idx_temp,find(temp_diff == unique_proprio_temp(iPro))))];
                pro_dir_vector = [pro_dir_vector; unique_proprio_temp(iPro)*ones(size(result_temp(intersect(proprio_idx_temp,find(temp_diff == unique_proprio_temp(iPro))))))];
                response_pro(iPro) = mean(result_temp(intersect(proprio_idx_temp,find(temp_diff == unique_proprio_temp(iPro)))));
            end    

            figure; 
            plot(180/pi*unique_visual_temp,response_vis,'b.');
            hold on
            plot(180/pi*unique_proprio_temp,response_pro,'r.');

%             vis_fit = fit(180/pi*unique_visual_temp,response_vis,f_sigmoid,f_opts);
            vis_fit = fit(180/pi*vis_dir_vector,response_vis_vector,f_sigmoid,f_opts);
            plot(vis_fit,'b')

            pro_fit = fit(180/pi*pro_dir_vector,response_pro_vector,f_sigmoid,f_opts);
            plot(pro_fit,'r')
            legend('Visual','Proprio')
            xlabel('Relative stimulus direction (deg)')
            ylabel('Probability of moving to the right')
            title(['Main direction: ' num2str(unique_main_directions(iMainDir)*180/pi) ' (deg)'])
        end
    end
    
end

%%
figure; 
reward_difference = 180/pi*abs(AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==32)),AT_struct.table_columns.moving_dots_direction)-...
    AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==32)),AT_struct.table_columns.bump_direction));

reward_difference(reward_difference>180) = reward_difference(reward_difference>180)-180;
fail_difference = 180/pi*abs(AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==34)),AT_struct.table_columns.moving_dots_direction)-...
    AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==34)),AT_struct.table_columns.bump_direction));

fail_difference(fail_difference>180) = fail_difference(fail_difference>180)-180;
reward_difference_count = hist(reward_difference,0:15:180);
fail_difference_count = hist(fail_difference,0:15:180);
reward_ratio = reward_difference_count./(reward_difference_count+fail_difference_count);
reward_ratio(isnan(reward_ratio) | isinf(reward_ratio)) = 0;
bar(0:15:180,reward_ratio);
h = findobj(gca,'Type','patch');
% set(h,'FaceColor','r','FaceAlpha',0.5)
% hold on; 
% hist(fail_difference,0:15:180)
% disp(['Ratio of coherent bumps and dots in visual trials: ' num2str(sum(abs(trial_table(visual_trials,table_columns.moving_dots_direction)-trial_table(visual_trials,table_columns.bump_direction))<pi/2)/...
%     length(abs(trial_table(visual_trials,table_columns.moving_dots_direction)-trial_table(visual_trials,table_columns.bump_direction))<pi/2))]);
% h2 = findobj(gca,'Type','patch');
% h2 = h2(h2~=h);
xlim([-7.5 187.5])
legend('Reward ratio')
xlabel('|bump direction - dot direction| (deg)')
ylabel('Reward ratio')
title('Visual trials')
% set(h2,'FaceColor','b','FaceAlpha',0.5)