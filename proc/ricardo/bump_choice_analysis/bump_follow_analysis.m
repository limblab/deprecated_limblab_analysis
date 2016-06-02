% calculate success rate
% filename = 'D:\Data\Ricardo_BC_no_spikes_001';
set(0,'DefaultTextInterpreter','None')
filename = 'D:\Data\TestData\Bump_follow_test_001';
if ~exist([filename '.mat'],'file')
    curr_dir = pwd;
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
    load_paths;
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
    bdf = get_plexon_data([filename '.plx'],2);
    save(filename,'bdf');
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\bump_choice_analysis';
    trial_table = build_trial_table(filename);
    cd(curr_dir)
end
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

%%
figure;
hold on;
no_ranges = 12;
colors = jet(100);
% colors = colors(1:3*end/4,:);
success_matrix = zeros(no_ranges,length(bump_magnitudes));
for i=1:no_ranges
    range = [(i-1)*2*pi/no_ranges i*2*pi/no_ranges];
    for j = 1:length(bump_magnitudes)
        if i==1
            text(j,0,num2str(2*bump_magnitudes(j),2))
        end
        local_succ = length(bump_table(bump_table(:,6)>range(1) &...
            bump_table(:,6)<range(2) &...
            bump_table(:,3)==32 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(bump_table(bump_table(:,6)>range(1) &...
            bump_table(:,6)<range(2) &...
            bump_table(:,3)==34 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        local_ratio = local_succ/(local_succ+local_unsucc);
        success_matrix(i,j) = local_ratio;
        if isnan(local_ratio)
            local_ratio = 0;
            draw_color = [1 1 1];
        else
            draw_color = colors(max(1,round(local_ratio*length(colors))),:);
        end
        plot(j*cos(mean(range)+pi),j*sin(mean(range)+pi),'.','Color',draw_color,'MarkerSize',30);
    end
end
xlim([-length(bump_magnitudes)-1 length(bump_magnitudes)+1])
ylim([-length(bump_magnitudes)-1 length(bump_magnitudes)+1])
set(gca,'XTick',[],'YTick',[])
colormap jet(100)
colorbar
title([filename ' Success rate'])
axis equal

%%  when stimulating 1 electrode (stim code 0) and using stim code 1 with
%  no stimulation
figure;
temp_succ_rate_bump = 0;
temp_succ_rate_stim = 0;
temp_succ_rate_no_stim = 0;
success_details = [];
j = 1;
bin_length = 200;
for i=1:bin_length:length(trial_table)-bin_length
    trials_temp = [trial_table(i:i+bin_length-1,4) trial_table(i:i+bin_length-1,3) trial_table(i:i+bin_length-1,8)...
        trial_table(i:i+bin_length-1,7)];
    bump_trials = trials_temp(trials_temp(:,1)==1 & trials_temp(:,4)~=0,2);
    stim_trials = trials_temp(trials_temp(:,1)==2 & trials_temp(:,3)==0,2);
    no_stim_trials = trials_temp(trials_temp(:,1)==2 & trials_temp(:,3)==1,2);
    temp_succ_rate_bump(j) = sum(bump_trials==32)/length(bump_trials);
    temp_succ_rate_stim(j) = sum(stim_trials==32)/length(stim_trials);
    temp_succ_rate_no_stim(j) = sum(no_stim_trials==32)/length(no_stim_trials);
    success_details(j,:) = [sum(stim_trials==32) length(stim_trials) sum(no_stim_trials==32) length(no_stim_trials)];
    j = j+1;
end
x_vals = bin_length/2+[1:bin_length:bin_length*(j-1)];
plot(x_vals,temp_succ_rate_bump,'b',...
    x_vals,temp_succ_rate_stim,'r',...
    x_vals,temp_succ_rate_no_stim,'k')
hold on
for i=1:size(success_details,1)
    text(x_vals(i),.2,[num2str(success_details(i,1)) '/' num2str(success_details(i,2))],'Color','r');
    text(x_vals(i),.1,[num2str(success_details(i,3)) '/' num2str(success_details(i,4))],'Color','k');
end
ylim([0 1])
% legend('bump','stim','no stim')
xlabel('Trial no.')
ylabel('Success rate')
plot([0 bin_length*(j-1)], [0.5 0.5],'--r')
title(filename)

%%
% when stimulating with more than 1 electrode
if no_stim_codes>1
    figure;
    temp_succ_rate_bump = 0;
    temp_succ_rate_stim = zeros(1,no_stim_codes);
    success_details = [];
    j = 1;
    bin_length = 50;
    for i=1:bin_length:length(trial_table)-bin_length
        trials_temp = [trial_table(i:i+bin_length-1,4) trial_table(i:i+bin_length-1,3) trial_table(i:i+bin_length-1,8)...
            trial_table(i:i+bin_length-1,7)];
        bump_trials = trials_temp(trials_temp(:,1)==1 & trials_temp(:,4)~=0,2);
        temp_succ_rate_bump(j) = sum(bump_trials==32)/length(bump_trials);
        for k=1:no_stim_codes
            stim_trials = trials_temp(trials_temp(:,1)==2 & trials_temp(:,3)==stim_codes(k),2);            
            temp_succ_rate_stim(j,k) = sum(stim_trials==32)/length(stim_trials);
            success_details(j,:,k) = [sum(stim_trials==32) length(stim_trials)];
        end
        j = j+1;
    end
    x_vals = bin_length/2+[1:bin_length:bin_length*(j-1)];
    plot(x_vals,[temp_succ_rate_bump' temp_succ_rate_stim])
    hold on
    for i=1:size(success_details,1)
        text(x_vals(i),.2,[num2str(success_details(i,1)) '/' num2str(success_details(i,2))],'Color','r');
        text(x_vals(i),.1,[num2str(success_details(i,3)) '/' num2str(success_details(i,4))],'Color','k');
    end
    ylim([0 1])
    legend_text = {'bump'};
    for i=1:no_stim_codes
        legend_text{i+1} = ['stim ' num2str(stim_codes(i))];
    end
    legend(legend_text)
    xlabel('Trial no.')
    ylabel('Success rate')
    plot([0 bin_length*(j-1)], [0.5 0.5],'--r')
    title(filename)
end

%%
if ~isempty(bump_magnitudes)
    figure;
    hold on;
    for i=1:no_ranges/2
        subplot(no_ranges/2,1,i)
        range_1 = [(i-1)*2*pi/no_ranges+pi i*2*pi/no_ranges+pi];
        range_2 = [(i-1)*2*pi/no_ranges i*2*pi/no_ranges];
        local_ratio_1 = zeros(length(bump_magnitudes),1);
        local_ratio_2 = zeros(length(bump_magnitudes),1);
        for j = 1:length(bump_magnitudes)
            local_succ = length(bump_table(bump_table(:,6)>range_1(1) &...
                bump_table(:,6)<range_1(2) &...
                bump_table(:,3)==32 &...
                bump_table(:,7)==bump_magnitudes(j),1));
            local_unsucc = length(bump_table(bump_table(:,6)>range_1(1) &...
                bump_table(:,6)<range_1(2) &...
                bump_table(:,3)==34 &...
                bump_table(:,7)==bump_magnitudes(j),1));
            %local_ratio_1(j) = 2*(local_succ/(local_succ+local_unsucc)-0.5);
            local_ratio_1(j) = local_succ/(local_succ+local_unsucc);

            local_succ = length(bump_table(bump_table(:,6)>range_2(1) &...
                bump_table(:,6)<range_2(2) &...
                bump_table(:,3)==32 &...
                bump_table(:,7)==bump_magnitudes(j),1));
            local_unsucc = length(bump_table(bump_table(:,6)>range_2(1) &...
                bump_table(:,6)<range_2(2) &...
                bump_table(:,3)==34 &...
                bump_table(:,7)==bump_magnitudes(j),1));
            %local_ratio_2(j) = -2*(local_succ/(local_succ+local_unsucc)-0.5);
            local_ratio_2(j) = 1-(local_succ/(local_succ+local_unsucc));
        end
        local_ratio_1(1) = mean([local_ratio_1(1) local_ratio_2(1)]);
        local_ratio_2(1) = local_ratio_1(1);
        plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [1 1],'k--')
        hold on
        plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0 0],'k--')
        plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0.5 0.5],'k--')
        bumps_ordered = 2*[-bump_magnitudes(end:-1:1);bump_magnitudes];
        ratios_ordered = [local_ratio_2(end:-1:1);local_ratio_1];
        max_y = max(ratios_ordered);
        min_y = min(ratios_ordered);
        fit_func = [num2str(min_y) '+' num2str((max_y-min_y)/max_y) '/(1+exp(-x*b+c))'];
        f_sigmoid = fittype(fit_func,'independent','x');
    %     f_sigmoid = fittype('a/(1+exp(-x*b)+c)','independent','x');
        sigmoid_fit = fit(bumps_ordered,ratios_ordered,f_sigmoid);
        plot(bumps_ordered, ratios_ordered,'k.')
        plot(sigmoid_fit)
        ylim([-0.2 1.2])
        xlim([-1.2*max(2*bump_magnitudes) 1.2*max(2*bump_magnitudes)])
        title([filename ' Probability of moving to target at ' num2str(mean(180*range_2/pi),3) '^o'])
    end
    xlabel('Bump magnitude [N]')
end
%%
if ~isempty(bump_magnitudes)
    figure;
    hold on;
    stim_pds = zeros(1,no_stim_codes);
    range_size = 2*pi/no_ranges;
    for i=1:no_stim_codes
        subplot(ceil(sqrt(no_stim_codes)),ceil(sqrt(no_stim_codes)),i)
        stim_pds(i) = unique(stim_table(stim_table(:,8)==stim_codes(i),6));
        range_1 = mod([stim_pds(i)-range_size/2 stim_pds(i)+range_size/2],2*pi);
        range_2 = mod([stim_pds(i)+pi-range_size/2 stim_pds(i)+pi+range_size/2],2*pi);
        range_1_flag = 0;
        range_2_flag = 0;
        if range_1(1)>range_1(2)
            range_1_flag = 1;
        end
        if range_2(1)>range_2(2)
            range_2_flag = 1;
        end
        local_ratio_1 = zeros(length(bump_magnitudes),1);
        local_ratio_2 = zeros(length(bump_magnitudes),1);
        for j = 1:length(bump_magnitudes)
            if ~range_1_flag
                local_succ = length(bump_table(bump_table(:,6)>range_1(1) &...
                    bump_table(:,6)<range_1(2) &...
                    bump_table(:,3)==32 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
                local_unsucc = length(bump_table(bump_table(:,6)>range_1(1) &...
                    bump_table(:,6)<range_1(2) &...
                    bump_table(:,3)==34 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
            else
                local_succ = length(bump_table((bump_table(:,6)>range_1(1) |...
                    bump_table(:,6)<range_1(2)) &...
                    bump_table(:,3)==32 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
                local_unsucc = length(bump_table((bump_table(:,6)>range_1(1) |...
                    bump_table(:,6)<range_1(2)) &...
                    bump_table(:,3)==34 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
            end
            %local_ratio_1(j) = 2*(local_succ/(local_succ+local_unsucc)-0.5);
            local_ratio_1(j) = local_succ/(local_succ+local_unsucc);

            if ~range_2_flag
                local_succ = length(bump_table(bump_table(:,6)>range_2(1) &...
                    bump_table(:,6)<range_2(2) &...
                    bump_table(:,3)==32 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
                local_unsucc = length(bump_table(bump_table(:,6)>range_2(1) &...
                    bump_table(:,6)<range_2(2) &...
                    bump_table(:,3)==34 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
            else
                local_succ = length(bump_table((bump_table(:,6)>range_2(1) |...
                    bump_table(:,6)<range_2(2)) &...
                    bump_table(:,3)==32 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
                local_unsucc = length(bump_table((bump_table(:,6)>range_2(1) |...
                    bump_table(:,6)<range_2(2)) &...
                    bump_table(:,3)==34 &...
                    bump_table(:,7)==bump_magnitudes(j),1));
            end
            %local_ratio_2(j) = -2*(local_succ/(local_succ+local_unsucc)-0.5);
            local_ratio_2(j) = 1-(local_succ/(local_succ+local_unsucc));
        end
        local_ratio_1(1) = mean([local_ratio_1(1) local_ratio_2(1)]);
        local_ratio_2(1) = local_ratio_1(1);
        stim_ratio = sum(stim_table(stim_table(:,6)==stim_pds(i),3)==32)/...
            length(stim_table(stim_table(:,6)==stim_pds(i),3)==32);
        plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [1 1],'k--')
        hold on
        plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0 0],'k--')
        plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0.5 0.5],'k--')
        bumps_ordered = 2*[-bump_magnitudes(end:-1:1);bump_magnitudes];
        ratios_ordered = [local_ratio_2(end:-1:1);local_ratio_1];
        max_y = max(ratios_ordered);
        min_y = min(ratios_ordered);
        fit_func = [num2str(min_y) '+' num2str((max_y-min_y)/max_y) '/(1+exp(-x*b+c))'];
        f_sigmoid = fittype(fit_func,'independent','x');
    %     f_sigmoid = fittype('a/(1+exp(-x*b)+c)','independent','x');
        sigmoid_fit = fit(bumps_ordered,ratios_ordered,f_sigmoid,'Startpoint',[1 1]);
        plot(bumps_ordered, ratios_ordered,'k.')
        plot(0,stim_ratio,'b*')
        plot(sigmoid_fit)
        legend off
        ylim([-0.2 1.2])
        xlim([-1.2*max(2*bump_magnitudes) 1.4*max(2*bump_magnitudes)])
        title(['target at ' num2str(mod(180*(stim_pds(i)+pi)/pi,360),3) '^o'])
        xlabel('Bump magnitude [N]')
        ylabel('P')
    end
end

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

%% circular statistics
figure; 
target_direction = mod(bump_table(:,6)+pi,2*pi);
response_direction = mod(atan2(bump_table(:,end),bump_table(:,end-1)),2*pi);
plot(target_direction,response_direction,'.');
title(filename);
xlabel('Target direction (rad)')
ylabel('Response direction (rad)')
mean_dot_prod = zeros(size(bump_magnitudes));

for i = 1:length(bump_magnitudes)
   mean_dot_prod(i) =  mean(cos(target_direction(bump_table(:,7)==bump_magnitudes(i))-response_direction(bump_table(:,7)==bump_magnitudes(i))));
end

figure;
plot(2*bump_magnitudes,mean_dot_prod)
title(filename);
xlabel('Bump magnitude [N]')
ylabel('Dot product(target direction,response direction)')

figure;
for i = 1:length(bump_magnitudes)
    subplot(2,4,i)
    plot(target_direction(bump_table(:,7)==bump_magnitudes(i)),response_direction(bump_table(:,7)==bump_magnitudes(i)),'.');
    hold on
    plot(target_direction(bump_table(:,7)==bump_magnitudes(i)),2*pi+response_direction(bump_table(:,7)==bump_magnitudes(i)),'.');
    plot(2*pi+target_direction(bump_table(:,7)==bump_magnitudes(i)),response_direction(bump_table(:,7)==bump_magnitudes(i)),'.');
    plot(2*pi+target_direction(bump_table(:,7)==bump_magnitudes(i)),2*pi+response_direction(bump_table(:,7)==bump_magnitudes(i)),'.');
    xlim([0 4*pi])
    ylim([0 4*pi])
    axis square
    title([num2str(2*bump_magnitudes(i)) ' N'])
end
subplot(2,4,5)
xlabel('Target direction (rad)')
ylabel('Response direction (rad)')

figure;
for i = 1:length(bump_magnitudes)
    subplot(2,4,i)
    clear histogram_data
    histogram_data = target_direction(bump_table(:,7)==bump_magnitudes(i))-response_direction(bump_table(:,7)==bump_magnitudes(i));
    histogram_data = [histogram_data target_direction(bump_table(:,7)==bump_magnitudes(i))-response_direction(bump_table(:,7)==bump_magnitudes(i))+2*pi];
    histogram_data = [histogram_data target_direction(bump_table(:,7)==bump_magnitudes(i))-response_direction(bump_table(:,7)==bump_magnitudes(i))-2*pi];
    histogram_data = min(abs(histogram_data'));
    hist(histogram_data,...
       	20);    
    hold on
	title([num2str(2*bump_magnitudes(i)) ' N'])
    ylim([0 30])
    xlim([0 pi])
end
subplot(2,4,5)
xlabel('Error (rad)')
ylabel('Count')