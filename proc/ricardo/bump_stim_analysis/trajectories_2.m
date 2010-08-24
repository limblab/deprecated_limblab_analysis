% $Id: bs_trajectories.m 56 2009-03-06 18:21:55Z brian $

% Plots average trajectories on bump-stim task

clear
% load 'D:\Data\Tiki_BS_forces_002'
load 'D:\Data\bump_stim_forces_test_021'

target_angle = 0;
%
% build trial table
%%%%%%%%%%%%%%%%%%%%%
forward_start_trial_code = hex2dec('14');
reverse_start_trial_code = hex2dec('15');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
bump_code = hex2dec('50');
stim_code = hex2dec('60');
forward_trial_starts = bdf.words(bdf.words(:,2) == forward_start_trial_code, 1);
reverse_trial_starts = bdf.words(bdf.words(:,2) == reverse_start_trial_code, 1);

bdf.words = bdf.words(find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1):...
    find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('20'),1,'last'),:);

trial_starts = bdf.words(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1);
 
trial_ends = bdf.words(bitand(bdf.words(:,2), hex2dec('f0')) == hex2dec('20'), :);
trial_table = zeros(length(trial_starts),7); % will hold the [ start end direction result trial_type bump_magnitude stim_id; ... ] for each trial
% trial type = 0 (control), 1 (bump), 2 (stim)
for i=1:length(trial_starts)
    start_time = trial_starts(i);
    trial_type = 0;
    bump_or_stim = bdf.words(min(find(bdf.words(:,1)==start_time,1)+4,length(bdf.words)),2);
    bump_trial = bitand(bump_or_stim,hex2dec('F0'))==bump_code;
    if bump_trial
        bump_mag = bitand(bump_or_stim,hex2dec('07'));
        bump_mag = (-2*(bitand(bump_or_stim,hex2dec('08'))>0)+1)*bump_mag;
        trial_type = 1;
    else
        bump_mag = 0;
    end
    stim_trial = bitand(bump_or_stim,hex2dec('F0'))==stim_code;
    if stim_trial
        stim_id =  bitand(bump_or_stim,hex2dec('07'));
        trial_type = 2;
    else
        stim_id = -1;
    end        
    end_idx = find(trial_ends(:,1) > start_time, 1, 'first');
    direction = bdf.words(find(bdf.words(:,1)==start_time,1),2) == forward_start_trial_code;
    trial_table(i,:) = [start_time trial_ends(end_idx,1) direction trial_ends(end_idx,2) trial_type bump_mag stim_id];
end

% dump the ones that were aborted
trial_table = trial_table(trial_table(:,4) == hex2dec('20')|trial_table(:,4) == hex2dec('22'), : );

% replace the trial start time with the go cue start time
go_times = bdf.words(bdf.words(:,2) == hex2dec('31'), 1);
for i = 1:size(trial_table,1)
    trial_table(i,1) = go_times(find(go_times < trial_table(i,2),1,'last'));
end

trajectories = cell(size(trial_table,1),1);

% control_table = trial_table(trial_table(:,5)==0,:);
% bump_table = trial_table(trial_table(:,5)==1,:);
% stim_table = trial_table(trial_table(:,5)==2,:);

color_list = {'r','b','k'};
figure; 
for i=1:size(trial_table,1)
    start_idx = find(bdf.pos(:,1) >= trial_table(i,1), 1, 'first');
    stop_idx  = find(bdf.pos(:,1) >= trial_table(i,2), 1, 'first');
    x = bdf.pos(start_idx:stop_idx, 2);
    y = bdf.pos(start_idx:stop_idx, 3);
    if trial_table(i,3)
        subplot(211)
        hold on;
        plot(x(1),y(1),'r'); plot(x(1),y(1),'b'); plot(x(1),y(1),'k');
        title('Forward movements (raw)')
        xlabel('x pos (cm)')
        ylabel('y pos (cm)')
    else
        subplot(212)
        hold on;
        plot(x(1),y(1),'r'); plot(x(1),y(1),'b'); plot(x(1),y(1),'k');
        title('Reverse movements (raw)')
        xlabel('x pos (cm)')
        ylabel('y pos (cm)')
    end    
%     if (trial_table(i,4) == 2 || trial_table(i,4) == 0)
        plot(x,y,'Color',color_list{trial_table(i,5)+1});        
%     end
    trajectories{i} = [x y];
end
legend('Control','Bump','Stim')

total_length = 0; % used for scale at the end
trajectories_scaled = cell(size(trajectories));
[b_high_pass a_high_pass] = butter(4,.5/500,'high');
for i = 1:length(trial_table)
    offset = trajectories{i}(1,:);
    displacement = trajectories{i}(end,:) - offset;
    tmp_length = norm(displacement);
    angle = atan2(displacement(2), displacement(1));  
%     angle = target_angle;
    r = [cos(-angle) sin(-angle); -sin(-angle) cos(-angle)];
    trajectories_scaled{i} = (trajectories{i} - repmat(offset,length(trajectories{i}),1))*r;    
    total_length = total_length + tmp_length;

%     if trial_table(i,4)==1
%         offset = trajectories{i}(round(2*end/3),:);
%         displacement = trajectories{i}(end,:) - offset;
%         tmp_length = norm(displacement);
%         angle = atan2(displacement(2), displacement(1));  
%         r = [cos(-angle) sin(-angle); -sin(-angle) cos(-angle)];
% %         trajectories_temp = (trajectories{i}(round(2*end/3):end,:) -...
% %             repmat(offset,length(trajectories{i}(round(2*end/3):end,:)),1))*r; 
% %         if mean(trajectories_temp(:,2))>0
% %             trial_table(i,6) = 1;
% %         else
% %             trial_table(i,6) = -1;
% %         end
%     end
end

% get interpolateed values
avg_length = total_length / (length(trajectories_scaled));
x_ticks = 0:floor(avg_length);

trajectories_interp = zeros(length(trajectories_scaled), length(x_ticks));
for i = 1:length(trajectories)
    trajectories_interp(i,:) = interp1(trajectories_scaled{i}(:,1), trajectories_scaled{i}(:,2),x_ticks);
end

figure;
hold on
plot(trajectories_interp(trial_table(:,3)==1 & trial_table(:,5)==0,:)','r')
plot(trajectories_interp(trial_table(:,3)==1 & trial_table(:,5)==1,:)','b')
plot(trajectories_interp(trial_table(:,3)==1 & trial_table(:,5)==2,:)','k')

figure; 
mov_params = [0 0 1 1; 1 -1 1 -1];
title_i = {'Forward trial, bump left','Forward trial, bump right',...
    'Reverse trial, bump left','Reverse trial, bump right'};
for i = 1:4
    subplot(2,2,i)
    title(title_i{i})
    hold on;
    mov_dir = mov_params(1,i);
    bump_dir = mov_params(2,i);
    errorbar(x_ticks, mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==0,:)),...
        std(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==0,:)), 'ro-');
    errorbar(x_ticks, mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,6)==bump_dir & trial_table(:,5)==1,:)),...
        std(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,6)==bump_dir & trial_table(:,5)==1,:)), 'bo-');
    errorbar(x_ticks, mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==2,:)),...
        std(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==2,:)), 'ko-');
end

figure;
hold on
plot(trajectories_interp(trial_table(:,3)==1 & trial_table(:,5)==0,:)','r')
plot(trajectories_interp(trial_table(:,3)==1 & trial_table(:,5)==1,:)','b')
plot(trajectories_interp(trial_table(:,3)==1 & trial_table(:,5)==2,:)','k')
%%
figure(10);
clf
i = 2;
mov_params = [0 0 1 1; 1 -1 1 -1];
mov_dir = mov_params(1,i);
bump_dir = mov_params(2,i);

subplot(2,1,1)
hold on

dark_green = [0 .75 0];

control_to_plot = 3;
bump_to_plot = 120;
stim_to_plot = 6;
plot(.05,.05,'Color',dark_green,'LineWidth',2);
plot(.05,.05,'b','LineWidth',2);
plot(.05,.05,'k','LineWidth',2);
fill([0 0 .125 .125],[-5 5 5 -5],[.8 .8 .8],'LineStyle','none')

control_time = mean(trial_table(trial_table(:,3)==mov_dir & trial_table(:,5)==0,2) - trial_table(trial_table(:,3)==mov_dir & trial_table(:,5)==0,1));
bump_time = mean(trial_table(trial_table(:,3)==mov_dir & trial_table(:,5)==1 & trial_table(:,6)==bump_dir,2) - trial_table(trial_table(:,3)==mov_dir & trial_table(:,5)==1 & trial_table(:,6)==bump_dir,1));
stim_time = mean(trial_table(trial_table(:,3)==mov_dir & trial_table(:,5)==2,2) - trial_table(trial_table(:,3)==mov_dir & trial_table(:,5)==2,1));
mean_time = mean([control_time bump_time stim_time]);
time_axis = [0:mean_time/x_ticks(end):mean_time];

control_indices = find(trial_table(:,3)==mov_dir & trial_table(:,5)==0);
control_time = [trial_table(control_indices(control_to_plot),1):.001:trial_table(control_indices(control_to_plot),2)];
control_y = trajectories_scaled{control_indices(control_to_plot)}(:,2);
control_x = trajectories_scaled{control_indices(control_to_plot)}(:,1);
control_y = control_y(1:length(control_time));
control_crossing = control_time(find(control_x>10,1));
plot(control_time-control_crossing,control_y,'-','Color',dark_green,'LineWidth',2)

bump_indices = find(trial_table(:,3)==mov_dir & trial_table(:,5)==1 & trial_table(:,6)==bump_dir);
bump_time = [trial_table(bump_indices(bump_to_plot),1):.001:trial_table(bump_indices(bump_to_plot),2)];
bump_x = trajectories_scaled{bump_indices(bump_to_plot)}(:,1);
bump_y = trajectories_scaled{bump_indices(bump_to_plot)}(:,2);
bump_y = bump_y(1:length(bump_time));
bump_crossing = bump_time(find(bump_x>10,1));
plot(bump_time-bump_crossing,bump_y,'-','Color','b','LineWidth',2)

stim_indices = find(trial_table(:,3)==mov_dir & trial_table(:,5)==2);
stim_time = [trial_table(stim_indices(stim_to_plot),1):.001:trial_table(stim_indices(stim_to_plot),2)];
stim_y = trajectories_scaled{stim_indices(stim_to_plot)}(:,2);
stim_y = stim_y(1:length(stim_time));
stim_x = trajectories_scaled{stim_indices(stim_to_plot)}(:,1);
stim_crossing = stim_time(find(stim_x>10,1));
plot(stim_time-stim_crossing,stim_y,'-','Color','k','LineWidth',2)

xlim([-.3 .3])
ylim([-3 1])
xlabel('time (s)')
ylabel('Y position (cm)')
legend({'Control','Bump','Stim'},'Location','SouthWest')
title('Displacement perpendicular to movement. Single trials.')

subplot(2,1,2)

title('Left to right movement, bump down. Solid=hand, dashed=cursor. Averages.')
hold on;
plot(x_ticks, mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==0,:)),'-','Color',dark_green,'LineWidth',2);
plot(x_ticks, mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,6)==bump_dir & trial_table(:,5)==1,:)), 'b-','LineWidth',2);
plot(x_ticks, mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==2,:)),'k-','LineWidth',2);
bump_cursor = mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,6)==bump_dir & trial_table(:,5)==1,:));    
bump_cursor = bump_cursor + [zeros(1,10) -2*ones(1,11)];
plot(x_ticks(1:10), bump_cursor(1:10), 'b--','LineWidth',2);    
plot(x_ticks(10:end), [bump_cursor(10)-2 bump_cursor(11:end)], 'b--','LineWidth',2);
plot([x_ticks(10) x_ticks(10)],[bump_cursor(10) bump_cursor(10)-2],'b--','LineWidth',2);

stim_cursor = mean(trajectories_interp(trial_table(:,3)==mov_dir & trial_table(:,5)==2,:));
stim_cursor = stim_cursor + [zeros(1,10) -2*ones(1,11)];
plot(x_ticks(1:10), stim_cursor(1:10), 'k--','LineWidth',2);    
plot(x_ticks(10:end), [stim_cursor(10)-2 stim_cursor(11:end)], 'k--','LineWidth',2);
plot([x_ticks(10) x_ticks(10)],[stim_cursor(10) stim_cursor(10)-2],'k--','LineWidth',2);

fill([18 18 19 19],[-1.5 1.5 1.5 -1.5],'r','LineStyle','none','LineWidth',2)
xlabel('X position (cm)')
ylabel('Y position (cm)')
% end

%%
figure; 
for i = [1 3]
    subplot(2,2,i)
    title(title_i{i})
    hold on
    for j = find(trial_table(:,4)==0 & trial_table(:,3)==0)'     
        plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{1})
    end
    for j = find(trial_table(:,4)==2 & trial_table(:,3)==0)'     
        plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{3})
    end
    if i == 1
        for j = find(trial_table(:,4)==1 & trial_table(:,3)==0 & trial_table(:,6)==-1)'     
            plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{2})
        end
    else
        for j = find(trial_table(:,4)==1 & trial_table(:,3)==0 & trial_table(:,6)==1)'     
            plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{2})
        end
    end
end
for i = [2 4]
    subplot(2,2,i)
    title(title_i{i})
    hold on
    for j = find(trial_table(:,4)==0 & trial_table(:,3)==1)'     
        plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{1})
    end
    for j = find(trial_table(:,4)==2 & trial_table(:,3)==1)'     
        plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{3})
    end
    if i == 2
        for j = find(trial_table(:,4)==1 & trial_table(:,3)==1 & trial_table(:,6)==-1)'     
            plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{2})
        end
    else
        for j = find(trial_table(:,4)==1 & trial_table(:,3)==1 & trial_table(:,6)==1)'     
            plot(trajectories_scaled{j}(:,1),trajectories_scaled{j}(:,2),'Color',color_list{2})
        end
    end
end


% Rotate and scale reaches
%%%%%%%%%%%%%%%%%%%%%%%%%%

% total_length = 0; % used for scale at the end
% for i = 1:length(control_reaches)
%     offset = control_reaches{i}(1,:);
%     displacement = control_reaches{i}(end,:) - offset;
%     tmp_length = norm(displacement);
%     angle = atan2(displacement(2), displacement(1));
%     
%     r = [cos(-angle) sin(-angle); -sin(-angle) cos(-angle)];
%     control_reaches{i} = (control_reaches{i} - repmat(offset,length(control_reaches{i}),1))*r;
%     
%     total_length = total_length + tmp_length;
% end
% 
% for i = 1:length(bump_reaches)
%     offset = bump_reaches{i}(1,:);
%     displacement = bump_reaches{i}(end,:) - offset;
%     tmp_length = norm(displacement);
%     angle = atan2(displacement(2), displacement(1));
%     
%     r = [cos(-angle) sin(-angle); -sin(-angle) cos(-angle)];
%     bump_reaches{i} = (bump_reaches{i} - repmat(offset,length(bump_reaches{i}),1))*r;
%     
%     total_length = total_length + tmp_length;
% end
% 
% % get interpolateed values
% avg_length = total_length / (length(control_reaches)+length(bump_reaches));
% x_ticks = 0:floor(avg_length);
% 
% control_interp = zeros(length(control_reaches), length(x_ticks));
% for i = 1:length(control_reaches)
%     control_interp(i,:) = interp1(control_reaches{i}(:,1), control_reaches{i}(:,2),x_ticks);
% end
% 
% bump_interp = zeros(length(bump_reaches), length(x_ticks));
% for i = 1:length(bump_reaches)
%     bump_interp(i,:) = interp1(bump_reaches{i}(:,1), bump_reaches{i}(:,2),x_ticks);
% end
% 
% % Plot adjusted trajectories
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure; hold on;
% for i = 1:size(control_trials,1)
%     plot(x_ticks, control_interp(i,:), 'b-');
% end
% 
% for i = 1:size(bump_trials,1)
%     plot(x_ticks, bump_interp(i,:), 'r-');
% end
% 
% axis equal;
% 
% 
% figure; hold on;
% errorbar(x_ticks, mean(control_interp), var(control_interp), 'bo-');
% errorbar(x_ticks, mean(bump_interp), var(bump_interp), 'ro-');
% axis equal;
% 
% figure;
% plot(x_ticks, mean(bump_interp) - mean(control_interp), 'ko-')
