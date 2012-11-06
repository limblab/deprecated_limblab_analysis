%- PARAMETERS -------------------------------------------------------------
MAKE_PLOTS = 0;

NATURE_PLOT = 1;
Date = '10/01';

pof = -3; % Position of Feedback (Where in y the cursor appears)
yoff = -7; % Global y offset of center target
target_rad = 15; % Target radius
target_size = 3; % Target size
shift_m = 2; % Shift mean
shift_v = 3; % Shift variance

% Screen offsets
x_off = -2; 
y_off = 32.5;

%--------------------------------------------------------------------------

mid2end = target_rad - (pof - yoff) - 0.5*target_size;

BDF = bdf;
BDF.pos(:,2) = BDF.pos(:,2) + x_off;
BDF.pos(:,3) = BDF.pos(:,3) + y_off; 

tt(isnan(tt(:,5)),:) = [];
tt(tt(:,3)<0,:) = [];

comp_tt = tt(tt(:,8)==32 | tt(:,8)==34,:);

low_var = find(comp_tt(:,3)== min(comp_tt(:,3)));
high_var = find(comp_tt(:,3)== max(comp_tt(:,3)));

low_trials = comp_tt(low_var,6:7);
low_trials(isnan(low_trials),:) = [];

high_trials = comp_tt(high_var,6:7);
high_trials(isnan(high_trials),:) = [];

all_trials = [low_trials; high_trials];
%all_trials = comp_tt(:,6:7);

PC_low = zeros(length(low_trials),2);

S_M_F_low = zeros(length(low_trials),3);
S_M_F_high = zeros(length(high_trials),3);

Nature_low = zeros(length(low_trials),2);

%figure; hold on;
max_vel_low = zeros(length(low_trials),2);
max_vel_high = zeros(length(high_trials),2);

for i = 1:length(low_trials)
    % find indices
    start_v = find(BDF.pos(:,1) < low_trials(i,1),1,'last');
    last_v = find(BDF.pos(:,1) > low_trials(i,2),1,'first');         
    
    vx = BDF.vel(start_v:last_v,2);
    vy = BDF.vel(start_v:last_v,3);
    v = sqrt(vx.^2 + vy.^2);
    
    pert = comp_tt(low_var(i),2); 
    px = BDF.pos(start_v:last_v,2) + pert;
    py = BDF.pos(start_v:last_v,3);
    
    mid_p = find(py > pof , 1, 'first');
    mid_ind = mid_p + start_v;
    
    init_shift = px(mid_p);
    final_shift = px(end);
    
    nec_correction = -init_shift;
    act_correction = final_shift - init_shift;
    
    PC_low(i,:) = [nec_correction act_correction];
    Nature_low(i,:) = [init_shift final_shift];
    
    S_M_F_low(i,:) = [start_v mid_ind last_v];
    
%     %plot(BDF.vel(start_v:last_v,1)-BDF.vel(start_v,1),vy,'b'); 
%     
    max_y_vel = max(BDF.vel(start_v:mid_ind + 100,3));
    max_vel_ind = find(BDF.vel(start_v:mid_ind + 100,3)==max_y_vel);
%     
%     %plot(BDF.vel(max_vel_ind + start_v,1)-BDF.vel(start_v,1),BDF.vel(max_vel_ind + start_v,3),'ko');
%     
%     dv_y = vy(max_vel_ind+1:end) - vy(max_vel_ind:end-1);
%     low_vel_ind = find(dv_y > 0,1,'first');
%     
%     target_appr_ind = find(dv_y(low_vel_ind:end) < 0,1,'first');
%     target_appr_ind = target_appr_ind + start_v + max_vel_ind + low_vel_ind;
%      
%     max_vel_low(i,:) = BDF.vel(target_appr_ind,2:3);
%     %plot(BDF.vel(target_appr_ind,1) - BDF.vel(start_v,1),BDF.vel(target_appr_ind,3),'go');
    
%     work_range = target_appr_ind - 50:target_appr_ind + 50;
%     takeoff_fit = polyfit(BDF.pos(work_range,2),BDF.pos(work_range,3),1);
%     
%     land_zone = (yoff+target_rad - 0.5*target_size - takeoff_fit(2))/takeoff_fit(1);
%     
%     plot(BDF.pos(start_v:last_v,2),BDF.pos(start_v:last_v,3),'k'); plot(BDF.pos(work_range,2),BDF.pos(work_range,3),'c');
%     plot([-target_size/2 target_size/2],[yoff+target_rad - 0.5*target_size yoff+target_rad - 0.5*target_size],'r','LineWidth',5);
%     
%     plot([BDF.pos(work_range(1),2) land_zone],...
%         [takeoff_fit(2) + takeoff_fit(1).*BDF.pos(work_range(1),2) takeoff_fit(2) + takeoff_fit(1).*land_zone],'g--');
%     
%     drawnow; pause(0.1); cla;
    
    clear start_v last_v vx vy v px py mid_p mid_ind init_shift final_shift ...
          nec_correction act_correction perc_corr;
    
end

PC_high = zeros(length(high_trials),2);
Nature_high = zeros(length(high_trials),2);
for i = 1:length(high_trials)
    % find indices
    start_v = find(BDF.vel(:,1) < high_trials(i,1),1,'last');
    last_v = find(BDF.vel(:,1) > high_trials(i,2),1,'first');
  
    vx = BDF.vel(start_v:last_v,2);
    vy = BDF.vel(start_v:last_v,3);
    v = sqrt(vx.^2 + vy.^2);
    
    pert = comp_tt(high_var(i),2); 
    px = BDF.pos(start_v:last_v,2) + pert;
    py = BDF.pos(start_v:last_v,3);
    
    mid_p = find(py > pof , 1, 'first');
    mid_ind = mid_p + start_v;
        
    init_shift = px(mid_p);
    final_shift = px(end);
    
    nec_correction = -init_shift;
    act_correction = final_shift - init_shift;
    
    PC_high(i,:) = [nec_correction act_correction];
    Nature_high(i,:) = [init_shift final_shift];
    
    S_M_F_high(i,:) = [start_v mid_ind last_v];
    
%     %plot(BDF.vel(start_v:last_v,1)-BDF.vel(start_v,1),vy,'b'); 
%     
%     max_y_vel = max(BDF.vel(start_v:mid_ind + 100,3));
%     max_vel_ind = find(BDF.vel(start_v:mid_ind+100,3)==max_y_vel);
%     
%     %plot(BDF.vel(max_vel_ind + start_v,1)-BDF.vel(start_v,1),BDF.vel(max_vel_ind + start_v,3),'ko');
%     
%     dv_y = vy(max_vel_ind+1:end) - vy(max_vel_ind:end-1);
%     low_vel_ind = find(dv_y > 0,1,'first');
%     
%     target_appr_ind = find(dv_y(low_vel_ind:end) < 0,1,'first');
%     target_appr_ind = target_appr_ind + start_v + max_vel_ind + low_vel_ind;
%     
%     max_vel_high(i,:) = BDF.vel(target_appr_ind,2:3);
%     
%     %plot(BDF.vel(target_appr_ind,1) - BDF.vel(start_v,1),BDF.vel(target_appr_ind,3),'go');
    
%     work_range = target_appr_ind - 50:target_appr_ind + 50;
%     takeoff_fit = polyfit(BDF.pos(work_range,2),BDF.pos(work_range,3),1);
%     
%     land_zone = (yoff+target_rad - 0.5*target_size - takeoff_fit(2))/takeoff_fit(1);
%     
%     plot(BDF.pos(start_v:last_v,2),BDF.pos(start_v:last_v,3),'k'); plot(BDF.pos(work_range,2),BDF.pos(work_range,3),'c');
%     plot([-target_size/2 target_size/2],[yoff+target_rad - 0.5*target_size yoff+target_rad - 0.5*target_size],'r','LineWidth',5);
%     
%     plot([BDF.pos(work_range(1),2) land_zone],...
%         [takeoff_fit(2) + takeoff_fit(1).*BDF.pos(work_range(1),2) takeoff_fit(2) + takeoff_fit(1).*land_zone],'g--');
%     
%     drawnow; pause(0.1); cla;
    
    clear start_v last_v vx vy v px py mid_p mid_ind init_shift final_shift ...
           nec_correction act_correction perc_corr;   
end

if MAKE_PLOTS == 1

    figure; hold on;
    plot(PC_low(:,1),PC_low(:,2),'b.');
    plot(PC_high(:,1),PC_high(:,2),'r.');

    PC_all = [PC_low; PC_high];

    p_low = polyfit(PC_low(:,1),PC_low(:,2),1);
    p_high = polyfit(PC_high(:,1),PC_high(:,2),1);

    plot([min(PC_all(:,1)) max(PC_all(:,1))],...
        [p_low(1)*min(PC_all(:,1))+ p_low(2) p_low(1)*max(PC_all(:,1)) + p_low(2)],'b');

    plot([min(PC_all(:,1)) max(PC_all(:,1))],...
        [p_high(1)*min(PC_all(:,1))+ p_high(2) p_high(1)*max(PC_all(:,1)) + p_high(2)],'r');

    legend(sprintf('Fit Slope = %.3f\nCloud var = %.2f',p_low(1),min(comp_tt(:,3))),...
           sprintf('Fit Slope = %.3f\nCloud var = %.2f',p_high(1),max(comp_tt(:,3))));

    title('Use of Feedback','FontSize',18);
    xlabel('Necessary Compensatory X Movement','FontSize',12);
    ylabel('Actual Compensatory X Movement','FontSize',12);
end

feed_start = zeros(length(comp_tt),1);
for i = 1:length(all_trials)

    start_v = find(BDF.pos(:,1) < all_trials(i,1),1,'last');
    last_v = find(BDF.pos(:,1) > all_trials(i,2),1,'first');         
    
    pert = comp_tt(i,2); 
    px = BDF.pos(start_v:last_v,2) + pert;
    py = BDF.pos(start_v:last_v,3);
    
    mid_p = find(py > pof , 1, 'first');
    mid_ind = mid_p + start_v;
    
    feed_start(i) = px(mid_p);
         
    clear start_v last_v vx vy v px py mid_p mid_ind init_shift final_shift ...
          nec_correction act_correction perc_corr;
end

%------------------------------------------------------------%
%%%%%%%%%%%% Check compensation of prior %%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------------%

num_blocks = 5;

% figure; plot(feed_start,'b');
% sm_feed = smooth(feed_start,100);
% hold on; plot(sm_feed,'r');
% title('Feedback location','FontSize',18);
% xlabel('Trials');
% ylabel('Location');

shift_means = zeros(num_blocks,1);
shift_vars = zeros(num_blocks,1);
mean_sigs = zeros(num_blocks-1,1);
for i = 1:num_blocks
    shift_means(i) = mean(feed_start(round(1+(i-1)*end/num_blocks):round(i*end/num_blocks)));
    shift_vars(i) = std(feed_start(round(1+(i-1)*end/num_blocks):round(i*end/num_blocks)));
    
    if i > 1
        mean_sigs(i-1) = ttest2(feed_start(1:round(end/num_blocks)),...
                           feed_start(round(1+(i-1)*end/num_blocks):round(i*end/num_blocks)));   
    end
    
end
   
if MAKE_PLOTS == 1
    figure; hold on; 
    subplot(1,2,1); hold on;
    plot(100*(1:num_blocks)./num_blocks,shift_means,'b');
    xlabel('Percentage of Trials Complete');
    ylabel('Feedback Appearance location mean');
    axis([50/num_blocks 100+50/num_blocks ...
        1.1*min([min([shift_means;shift_m]) 0]) max([shift_means;shift_m])+0.5]);

    plot([-100 200], [shift_m shift_m],'k--','LineWidth',2);
    sigcount = 0;
    if ~isempty(find(mean_sigs,1))
        for i = find(mean_sigs)'
            sigcount = sigcount + 1;
            plot([100/num_blocks (i+1)*100/num_blocks], [max(shift_means) + sigcount*0.1 max(shift_means)+sigcount*0.1],'k+-');
            text(mean([100/num_blocks (i+1)*100/num_blocks]),max(shift_means) + sigcount*0.1 + 0.05, '*');
        end
    end
    
subplot(1,2,2);
bar(100*(1:num_blocks)./num_blocks,shift_vars,'r'); hold on;
xlabel('Percentage of Trials Complete');
ylabel('Feedback Appearance location variance');
axis([50/num_blocks 100+50/num_blocks 0 max([shift_vars;shift_v])+0.5]);
plot([-100 200], [shift_v shift_v],'k--','LineWidth',2);

set(gcf,'NextPlot','add');
axes;
h = title('Compensation for Prior','FontSize',18);
set(gca,'Visible','off');
set(h,'Visible','on');

end
%%%% Nature plot %%%%

if NATURE_PLOT == 1 || MAKE_PLOTS == 1
    Nature_all = [Nature_low;Nature_high];

    figure; plot(Nature_low(:,1),Nature_low(:,2),'b.');
    hold on; title(['Shift v. End Location' '  ' Date],'FontSize',18);
    xlabel('Y Shift'); ylabel('End Location');
    plot(Nature_high(:,1),Nature_high(:,2),'r.');

    slope_low = polyfit(Nature_low(:,1),Nature_low(:,2),1);
    slope_high = polyfit(Nature_high(:,1),Nature_high(:,2),1);

    plot([min(Nature_all(:,1)) max(Nature_all(:,1))],...
        [slope_low(1)*min(Nature_all(:,1))+ slope_low(2) slope_low(1)*max(Nature_all(:,1)) + slope_low(2)],'b');

    plot([min(Nature_all(:,1)) max(Nature_all(:,1))],...
        [slope_high(1)*min(Nature_all(:,1))+ slope_high(2) slope_high(1)*max(Nature_all(:,1)) + slope_high(2)],'r');

    legend(sprintf('Fit Slope = %.3f\nCloud var = %.2f',slope_low(1),min(comp_tt(:,3))),...
           sprintf('Fit Slope = %.3f\nCloud var = %.2f',slope_high(1),max(comp_tt(:,3))));
end