% calculate success rate
% filename = 'D:\Data\Ricardo_BC_no_spikes_001';
bootstrapping = 1;
set(0,'DefaultTextInterpreter','none')
filename = 'D:\Data\Pedro\Pedro_BC_006';
curr_dir = pwd;    
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;

if ~exist([filename '.mat'],'file')    
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
    bdf = get_plexon_data([filename '.plx'],2);
    save(filename,'bdf');
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\bump_choice_analysis';
    trial_table = build_trial_table(filename);    
end

cd(curr_dir)
load(filename,'trial_table','bdf')

trial_table = trial_table(trial_table(:,5)==0,:); % remove training trials

bump_table = trial_table(trial_table(:,4)==1,:);
bump_magnitudes = unique(bump_table(:,7));
successful = bump_table(bump_table(:,3)==32,:);
unsuccessful = bump_table(bump_table(:,3)==34,:);

stim_table = trial_table(trial_table(:,4)==2,:);
stim_codes = unique(stim_table(:,8));
no_stim_codes = length(stim_codes);
stim_success_rate = zeros(size(stim_codes));
stim_movement_times = zeros(size(stim_codes));
stim_movement_times_std = zeros(size(stim_codes));

%% psychophysics!
success_rate = histc(successful(:,7),bump_magnitudes)./...
    (histc(successful(:,7),bump_magnitudes)+histc(unsuccessful(:,7),bump_magnitudes));
figure;
bar(bump_magnitudes,success_rate)
title([filename 'Bump success rate'])
xlabel('Bump magnitude')
ylabel('Success rate')

%%
figure;
plot(bump_table(bump_table(:,3)==32,11),bump_table(bump_table(:,3)==32,12),'.b')
hold on
plot(bump_table(bump_table(:,3)==34,11),bump_table(bump_table(:,3)==34,12),'.r')
plot(stim_table(stim_table(:,3)==32,11),stim_table(stim_table(:,3)==32,12),'*b')
plot(stim_table(stim_table(:,3)==34,11),stim_table(stim_table(:,3)==34,12),'*r')
axis equal
% legend('bump succ','bump wrong','stim succ','stim wrong')
xlabel('x pos (cm)')
ylabel('y pos (cm)')
title(filename)

%%  Probability of moving to a certain target
if ~isempty(bump_magnitudes)
    
    fit_func = 'a+b/(1+exp(-x*c+d))';
    f_sigmoid = fittype(fit_func,'independent','x');
        
    bump_summary = zeros(2*length(bump_magnitudes),2);
    bump_summary_movement = zeros(2*length(bump_magnitudes),2);
    
    stim_ratio_1 = zeros(length(bump_magnitudes),1);
    stim_ratio_2 = zeros(length(bump_magnitudes),1);
    stim_summary = zeros(2*length(bump_magnitudes),2);
    stim_summary_movement = zeros(2*length(bump_magnitudes),2);
    stim_summary_new = zeros(2*length(bump_magnitudes),2);
    bump_summary_new = zeros(2*length(bump_magnitudes),2);
    
    bump_directions = unique(bump_table(:,6));
    bumps_ordered = 2*[-bump_magnitudes(end:-1:1);bump_magnitudes]; %convert bumps to forces
    
    for j = 1:length(bump_magnitudes)
        local_succ = length(bump_table(bump_table(:,6) == bump_directions(1) &...
            bump_table(:,3)==32 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(bump_table(bump_table(:,6) == bump_directions(1) &...
            bump_table(:,3)==34 &...
            bump_table(:,7)==bump_magnitudes(j),1));
%         bump_summary(end-j-4,:) = [local_succ local_unsucc];
        bump_summary_movement(end-j-4,:) = [local_succ local_unsucc];
        
        local_succ = length(stim_table(stim_table(:,6) == bump_directions(1) &...
            stim_table(:,3)==32 &...
            stim_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(stim_table(stim_table(:,6) == bump_directions(1) &...
            stim_table(:,3)==34 &...
            stim_table(:,7)==bump_magnitudes(j),1));
%         stim_summary(end-j-4,:) = [local_succ local_unsucc];
        stim_summary_movement(end-j-4,:) = [local_succ local_unsucc];

        local_succ = length(bump_table(bump_table(:,6) == bump_directions(2) &...
            bump_table(:,3)==32 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(bump_table(bump_table(:,6) == bump_directions(2) &...
            bump_table(:,3)==34 &...
            bump_table(:,7)==bump_magnitudes(j),1));
%         bump_summary(j+5,:) = [local_succ local_unsucc];
        bump_summary_movement(j+5,:) = [local_unsucc local_succ];
        
        local_succ = length(stim_table(stim_table(:,6) == bump_directions(2) &...
            stim_table(:,3)==32 &...
            stim_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(stim_table(stim_table(:,6) == bump_directions(2) &...
            stim_table(:,3)==34 &...
            stim_table(:,7)==bump_magnitudes(j),1));
%         stim_summary(j+5,:) = [local_succ local_unsucc];
        stim_summary_movement(j+5,:) = [local_unsucc local_succ];
    end
    
    bump_summary_new(bumps_ordered~=0,:) = bump_summary_movement(bumps_ordered~=0,:);
    bump_summary_new(find(bumps_ordered==0,1,'first'),:) = sum(bump_summary_movement(bumps_ordered==0,:));
    bump_summary_movement = bump_summary_new(bump_summary_new(:,1)~=0& bump_summary_new(:,2)~=0,:);
    
    stim_summary_new(bumps_ordered~=0,:) = stim_summary_movement(bumps_ordered~=0,:);
    stim_summary_new(find(bumps_ordered==0,1,'first'),:) = sum(stim_summary_movement(bumps_ordered==0,:));
    stim_summary_movement = stim_summary_new(stim_summary_new(:,1)~=0 & stim_summary_new(:,2)~=0,:);
        
    bumps_ordered = bumps_ordered([1:find(bumps_ordered==0,1,'first') find(bumps_ordered==0,1,'last')+1:end]);
    
    bump_ratios = bump_summary_movement(:,2)./(bump_summary_movement(:,1)+bump_summary_movement(:,2));
    stim_ratios = stim_summary_movement(:,2)./(stim_summary_movement(:,1)+stim_summary_movement(:,2));
    
     %bootstrapping
    if bootstrapping
        tic
        glm_fitting = 0;
        num_iter = 10000;
        confidence_level = .1;
        conf_level_stim = zeros(size(stim_summary_movement,1),2);
        conf_level_bump = zeros(size(stim_summary_movement,1),2);
        
        if glm_fitting
            resamp_stim = zeros(num_iter,size(stim_summary_movement,1));
            resamp_bump = zeros(num_iter,size(bump_summary_movement,1));

            for i = 1:size(stim_summary_movement,1)
                stim_results_i = [ones(stim_summary_movement(i,1),1);zeros(stim_summary_movement(i,2),1)];
                resamp_stim(:,i) = stim_results_i(ceil(length(stim_results_i)*rand(num_iter,1)));

                bump_results_i = [ones(bump_summary_movement(i,1),1);zeros(bump_summary_movement(i,2),1)];
                resamp_bump(:,i) = bump_results_i(ceil(length(bump_results_i)*rand(num_iter,1)));
            end

            resamp_stim_vector = resamp_stim(:);
            resamp_bump_vector = resamp_bump(:);
            bumps_ordered_vector = repmat(bumps_ordered',num_iter,1);
            bumps_ordered_vector = bumps_ordered_vector(:);

            [b_stim,dev,stats] = glmfit(bumps_ordered,[sum(resamp_bump)' repmat(num_iter,length(bumps_ordered),1)],...
                'binomial','link','probit');
            yfit = glmval(b_stim, bumps_ordered,'probit','size', repmat(num_iter,length(bumps_ordered),1));
            plot(bumps_ordered, sum(resamp_bump)'./repmat(num_iter,length(bumps_ordered),1),'o',...
                bumps_ordered,yfit./repmat(num_iter,length(bumps_ordered),1),'-','LineWidth',2)
        else
            
            mean_resamp_stim = zeros(size(stim_summary_movement,1),num_iter);
            mean_resamp_bump = zeros(size(stim_summary_movement,1),num_iter);

            for i = 1:size(stim_summary_movement,1)
                stim_results_i = [ones(stim_summary_movement(i,1),1);zeros(stim_summary_movement(i,2),1)];
                resamp_stim_i = stim_results_i(ceil(length(stim_results_i)*rand(length(stim_results_i),num_iter)));
                mean_resamp_stim(i,:) = mean(resamp_stim_i);
    %             [hist_resamp hist_bins] = hist(mean_resamp_stim(i,:),50);
    %             cum_hist_resamp = cumsum(hist_resamp)/sum(hist_resamp);
    %             conf_level_stim(i,1) = hist_bins(find(cum_hist_resamp>confidence_level,1,'first'));
    %             conf_level_stim(i,2) = hist_bins(find(cum_hist_resamp>1-confidence_level,1,'first'));

                bump_results_i = [ones(bump_summary_movement(i,1),1);zeros(bump_summary_movement(i,2),1)];
                resamp_bump_i = bump_results_i(ceil(length(bump_results_i)*rand(length(bump_results_i),num_iter)));
                mean_resamp_bump(i,:) = mean(resamp_bump_i);
    %             [hist_resamp hist_bins] = hist(mean_resamp_bump(i,:),50);
    %             cum_hist_resamp = cumsum(hist_resamp)/sum(hist_resamp);
    %             conf_level_bump(i,1) = hist_bins(find(cum_hist_resamp>confidence_level,1,'first'));
    %             conf_level_bump(i,2) =
    %             hist_bins(find(cum_hist_resamp>1-confidence_level,1,'first'));            
            end
        
            sigmoid_fit_bumps_boot = cell(num_iter,1);
            sigmoid_fit_stim_boot = cell(num_iter,1);
            bump_zero_crossing = zeros(num_iter,1);
            stim_zero_crossing = zeros(num_iter,1);
            bump_50_percent = zeros(num_iter,1);
            stim_50_percent = zeros(num_iter,1);
            for i=1:num_iter
                i
                sigmoid_fit_bumps_boot{i} = fit(bumps_ordered,mean_resamp_bump(:,i),f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);
    %             sigmoid_fit_bumps_boot{i} = fit(bumps_ordered,resamp_bump(i,:)',f_sigmoid,...
    %                 'StartPoint',[1 -1 100 0]);
                bump_zero_crossing(i) = feval(sigmoid_fit_bumps_boot{i},0);
                bump_50_percent(i) = sigmoid_fit_bumps_boot{i}.d/sigmoid_fit_bumps_boot{i}.c;
                sigmoid_fit_stim_boot{i} = fit(bumps_ordered,mean_resamp_stim(:,i),f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);
    %             sigmoid_fit_stim_boot{i} = fit(bumps_ordered,resamp_stim(i,:)',f_sigmoid,...
    %                 'StartPoint',[1 -1 100 0]);
                stim_zero_crossing(i) = feval(sigmoid_fit_stim_boot{i},0);
                stim_50_percent(i) = sigmoid_fit_stim_boot{i}.d/sigmoid_fit_stim_boot{i}.c;
            end
        end
        
        bump_zero_crossing = sort(bump_zero_crossing);
        stim_zero_crossing = sort(stim_zero_crossing);        
        bump_zero_crossing = bump_zero_crossing(round(num_iter*.01):round(num_iter*.99));
        stim_zero_crossing = stim_zero_crossing(round(num_iter*.01):round(num_iter*.99));
                
        bump_50_percent = sort(bump_50_percent);
        stim_50_percent = sort(stim_50_percent);        
        bump_50_percent = bump_50_percent(round(num_iter*.01):round(num_iter*.99));
        stim_50_percent = stim_50_percent(round(num_iter*.01):round(num_iter*.99));        
        
        zero_crossing_bins = [min(mean(bump_zero_crossing)-3*std(bump_zero_crossing),...
            mean(stim_zero_crossing)-3*std(stim_zero_crossing)),...
            max(mean(bump_zero_crossing)+3*std(bump_zero_crossing),...
            mean(stim_zero_crossing)+3*std(stim_zero_crossing))];        
        bump_zero_crossing = bump_zero_crossing(bump_zero_crossing>zero_crossing_bins(1) &...
            bump_zero_crossing<zero_crossing_bins(2));
        stim_zero_crossing = stim_zero_crossing(stim_zero_crossing>zero_crossing_bins(1) &...
            stim_zero_crossing<zero_crossing_bins(2));
        zero_crossing_bins = linspace(zero_crossing_bins(1),zero_crossing_bins(2),50);
        
        fifty_percent_bins = [min(mean(bump_50_percent)-3*std(bump_50_percent),...
            mean(stim_50_percent)-3*std(stim_50_percent)),...
            max(mean(bump_50_percent)+3*std(bump_50_percent),...
            mean(stim_50_percent)+3*std(stim_50_percent))];
        bump_50_percent = bump_50_percent(bump_50_percent>fifty_percent_bins(1) &...
            bump_50_percent<fifty_percent_bins(2));
        stim_50_percent = stim_50_percent(stim_50_percent>fifty_percent_bins(1) &...
            stim_50_percent<fifty_percent_bins(2));
        fifty_percent_bins = linspace(fifty_percent_bins(1),fifty_percent_bins(2),50);
%%
        figure;
        
        subplot(4,1,1)
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
            [-.6*target_distance+target_distance/2*cos(bump_directions(2)) target_distance+target_distance/2*sin(bump_directions(2))],...
            .1,.1,'k')
        text(-target_distance*.8, target_distance+target_distance/5,1,'PD','HorizontalAlignment','center')
        
        subplot(4,1,2)
        hold on
        plot(bumps_ordered, bump_ratios,'r.','MarkerSize',10)
        plot(bumps_ordered, stim_ratios,'b.','MarkerSize',10)

        sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios,f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);
        sigmoid_fit_stim = fit(bumps_ordered,stim_ratios,f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);

        h_temp = plot(sigmoid_fit_bumps,'r');
        set(h_temp,'LineWidth',2)

        h_temp = plot(sigmoid_fit_stim,'b');
        set(h_temp,'LineWidth',2)
        
        text(-.09,.85,'Bump','Color','r')
        text(-.09,.7,'Bump + ICMS','Color','b')
        legend off

        xlabel('Bump magnitude [N]')
        ylabel('P(moving to T1)')
        
        subplot(4,1,3)          
        hold on; 
        hist(1-bump_zero_crossing,sort(1-zero_crossing_bins));
        h1 = findobj(gca,'Type','patch');
        hist(1-stim_zero_crossing,sort(1-zero_crossing_bins));        
        h2 = findobj(gca,'Type','patch');
        h2 = h2(h2~=h1);
        set(h1,'FaceColor','r','EdgeColor','r'); 
        set(h2,'FaceColor','b','EdgeColor','b'); 
%         set(h1,'FaceColor','r','FaceAlpha',.7,'EdgeColor','r'); 
%         set(h2,'FaceColor','b','FaceAlpha',.7,'EdgeColor','b'); 
        xlim([0.25 0.75])
        ylabel('Count'); xlabel('Null bias');
        
        subplot(4,1,4)        
        hold on;        
        hist(bump_50_percent,fifty_percent_bins);
        h1 = findobj(gca,'Type','patch');
        hist(stim_50_percent,fifty_percent_bins);  
        ylabel('Count'); xlabel('PSE [N]');
        h2 = findobj(gca,'Type','patch');
        h2 = h2(h2~=h1);
        set(h1,'FaceColor','r','EdgeColor','r'); 
        set(h2,'FaceColor','b','EdgeColor','b'); 
%         set(h1,'FaceColor','r','FaceAlpha',.7,'LineStyle','none'); 
%         set(h2,'FaceColor','b','FaceAlpha',.7,'LineStyle','none'); 
        toc
        
%%
    end
end
    

%%
    figure;
    hold on
    plot(bumps_ordered, bump_ratios,'r.','MarkerSize',10)
    plot(bumps_ordered, stim_ratios,'b.','MarkerSize',10)
        
    sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios,f_sigmoid,...
                'StartPoint',[1 -1 100 0]);
    sigmoid_fit_stim = fit(bumps_ordered,stim_ratios,f_sigmoid,...
                'StartPoint',[1 -1 100 0]);
   
    plot(sigmoid_fit_bumps,'r')
        
    plot(sigmoid_fit_stim,'b')
    legend('Bumps','Bumps+Stim','Location','northwest')
    
%     errorbar_height = 0.01;
%     errorbar_width = 0.002;
    
%     plot(mean(bump_50_percent)+[-std(bump_50_percent) std(bump_50_percent)],...
%         [0.5 0.5],'r')
%     plot(mean(bump_50_percent)+[-std(bump_50_percent) -std(bump_50_percent)],...
%         0.5+[-errorbar_height errorbar_height],'r')
%     plot(mean(bump_50_percent)+[std(bump_50_percent) std(bump_50_percent)],...
%         0.5+[-errorbar_height errorbar_height],'r')
%     
%     plot([0 0],...
%         1-(mean(bump_zero_crossing)+[-std(bump_zero_crossing) std(bump_zero_crossing)]),...
%         'r')
%     plot([-errorbar_width errorbar_width],...
%         1-(mean(bump_zero_crossing)+[std(bump_zero_crossing) std(bump_zero_crossing)]),...
%         'r')
%     plot([-errorbar_width errorbar_width],...
%         1-(mean(bump_zero_crossing)-[std(bump_zero_crossing) std(bump_zero_crossing)]),...
%         'r')
    
%     plot(mean(stim_50_percent)+[-std(stim_50_percent) std(stim_50_percent)],...
%         [0.5 0.5],'b')
%     plot(mean(stim_50_percent)+[-std(stim_50_percent) -std(stim_50_percent)],...
%         0.5+[-errorbar_height errorbar_height],'b')
%     plot(mean(stim_50_percent)+[std(stim_50_percent) std(stim_50_percent)],...
%         0.5+[-errorbar_height errorbar_height],'b')
    
%     plot([0 0],...
%         1-(mean(stim_zero_crossing)+[-std(stim_zero_crossing) std(stim_zero_crossing)]),...
%         'b')
%     plot([-errorbar_width errorbar_width],...
%         1-(mean(stim_zero_crossing)+[std(stim_zero_crossing) std(stim_zero_crossing)]),...
%         'b')
%     plot([-errorbar_width errorbar_width],...
%         1-(mean(stim_zero_crossing)-[std(stim_zero_crossing) std(stim_zero_crossing)]),...
%         'b')
    
%     plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [1 1],'k--')
%     hold on
%     plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0 0],'k--')
%     plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0.5 0.5],'k--')
    
    ylim([0 1])
    xlim([-1*max(2*bump_magnitudes) 1*max(2*bump_magnitudes)])
    title([filename ' Probability of moving to target at ' num2str(bump_directions(1)*180/pi,3) '^o'])
    xlabel('Bump magnitude [N]')    


%% Success rate for 0N trials over time
bin_length = 25;
num_bins = floor(size(trial_table(trial_table(:,7)==0,:),1)/bin_length);
stim_succ_bin_dir1 = zeros(1,num_bins);
stim_succ_bin_dir2 = zeros(1,num_bins);
bump_succ_bin_dir1 = zeros(1,num_bins);
bump_succ_bin_dir2 = zeros(1,num_bins);

for i = 1:num_bins
    temp_trial_table = trial_table(trial_table(:,7)==0,:);
    temp_trial_table = temp_trial_table((i-1)*bin_length+1:i*bin_length,:);
    stim_succ_bin_dir1(i) = sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==0)/...
        sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,8)==0);
    stim_succ_bin_dir2(i) = sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==0)/...
        sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,8)==0);
    bump_succ_bin_dir1(i) = sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==-1)/...
        sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,8)==-1);
    bump_succ_bin_dir2(i) = sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==-1)/...
        sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,8)==-1);
end

stim_succ_bin = mean([stim_succ_bin_dir1;1-stim_succ_bin_dir2]);
bump_succ_bin = mean([bump_succ_bin_dir1;1-bump_succ_bin_dir2]);

figure; 
plot(bin_length/2:bin_length:num_bins*bin_length,bump_succ_bin,'r')
hold on
plot(bin_length/2:bin_length:num_bins*bin_length,stim_succ_bin,'b')
legend('Bumps','Bump+stim')
xlabel('Trial number')
title(['Probability of moving towards target at ' num2str(180*(bump_directions(1)+pi)/pi,3) 'deg with 0 magnitude bump'])


%% stim trials
for i=1:no_stim_codes
    i
    length(stim_table(stim_table(:,8)==stim_codes(i) & stim_table(:,3)==32,1))
    length(stim_table(stim_table(:,8)==stim_codes(i),1))
    stim_success_rate(i) = mean(stim_table(stim_table(:,8)==stim_codes(i),3)==32);
    stim_movement_times(i) = mean(stim_table(stim_table(:,8)==stim_codes(i),2)-...
        stim_table(stim_table(:,8)==stim_codes(i),1));
    stim_movement_times_std(i) = std(stim_table(stim_table(:,8)==stim_codes(i),2)-...
        stim_table(stim_table(:,8)==stim_codes(i),1));
end
