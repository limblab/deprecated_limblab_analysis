% calculate success rate
% filename = 'D:\Data\Ricardo_BC_no_spikes_001';
set(0,'DefaultTextInterpreter','Tex')
filename = 'D:\Data\TestData\Test_newsome_nospikes_004';
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

%%  Probability of moving to a certain target
if ~isempty(bump_magnitudes)
    figure;
    hold on;       
    bump_ratio_1 = zeros(length(bump_magnitudes),1);
    bump_ratio_2 = zeros(length(bump_magnitudes),1);
    stim_ratio_1 = zeros(length(bump_magnitudes),1);
    stim_ratio_2 = zeros(length(bump_magnitudes),1);
    bump_directions = unique(bump_table(:,6));
    
    for j = 1:length(bump_magnitudes)
        local_succ = length(bump_table(bump_table(:,6) == bump_directions(1) &...
            bump_table(:,3)==32 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(bump_table(bump_table(:,6) == bump_directions(1) &...
            bump_table(:,3)==34 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        %bump_ratio_1(j) = 2*(local_succ/(local_succ+local_unsucc)-0.5);
        bump_ratio_1(j) = local_succ/(local_succ+local_unsucc);
        
        local_succ = length(stim_table(stim_table(:,6) == bump_directions(1) &...
            stim_table(:,3)==32 &...
            stim_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(stim_table(stim_table(:,6) == bump_directions(1) &...
            stim_table(:,3)==34 &...
            stim_table(:,7)==bump_magnitudes(j),1));
        %bump_ratio_1(j) = 2*(local_succ/(local_succ+local_unsucc)-0.5);
        stim_ratio_1(j) = local_succ/(local_succ+local_unsucc);

        local_succ = length(bump_table(bump_table(:,6) == bump_directions(2) &...
            bump_table(:,3)==32 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(bump_table(bump_table(:,6) == bump_directions(2) &...
            bump_table(:,3)==34 &...
            bump_table(:,7)==bump_magnitudes(j),1));
        %bump_ratio_2(j) = -2*(local_succ/(local_succ+local_unsucc)-0.5);
        bump_ratio_2(j) = 1-(local_succ/(local_succ+local_unsucc));
        
        local_succ = length(stim_table(stim_table(:,6) == bump_directions(2) &...
            stim_table(:,3)==32 &...
            stim_table(:,7)==bump_magnitudes(j),1));
        local_unsucc = length(stim_table(stim_table(:,6) == bump_directions(2) &...
            stim_table(:,3)==34 &...
            stim_table(:,7)==bump_magnitudes(j),1));
        %bump_ratio_2(j) = -2*(local_succ/(local_succ+local_unsucc)-0.5);
        stim_ratio_2(j) = 1-(local_succ/(local_succ+local_unsucc));
    end
    bump_ratio_1(1) = mean([bump_ratio_1(1) bump_ratio_2(1)]);
    bump_ratio_2(1) = bump_ratio_1(1);
    stim_ratio_1(1) = mean([stim_ratio_1(1) stim_ratio_2(1)]);
    stim_ratio_2(1) = stim_ratio_1(1);
    
    plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [1 1],'k--')
    hold on
    plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0 0],'k--')
    plot(2.5*[-bump_magnitudes(end) bump_magnitudes(end)], [0.5 0.5],'k--')
    bumps_ordered = 2*[-bump_magnitudes(end:-1:1);bump_magnitudes]; %convert bumps to forces
    
    bump_ratios_ordered = [bump_ratio_2(end:-1:1);bump_ratio_1];
    max_y = max(bump_ratios_ordered);
    min_y = min(bump_ratios_ordered);
    fit_func = [num2str(min_y) '+' num2str((max_y-min_y)/max_y) '/(1+exp(-x*b+c))'];
    f_sigmoid = fittype(fit_func,'independent','x');
%     f_sigmoid = fittype('a/(1+exp(-x*b)+c)','independent','x');
    sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios_ordered,f_sigmoid);
    plot(bumps_ordered, bump_ratios_ordered,'r.')
    plot(sigmoid_fit_bumps,'r')
    
    stim_ratios_ordered = [stim_ratio_2(end:-1:1);stim_ratio_1];
    stim_ratios_ordered(isnan(stim_ratios_ordered)) = 0;
    max_y = max(stim_ratios_ordered);
    min_y = min(stim_ratios_ordered);
    fit_func = [num2str(min_y) '+' num2str((max_y-min_y)/max_y) '/(1+exp(-x*b+c))'];
    f_sigmoid = fittype(fit_func,'independent','x');
%     f_sigmoid = fittype('a/(1+exp(-x*b)+c)','independent','x');
    sigmoid_fit_stim = fit(bumps_ordered,stim_ratios_ordered,f_sigmoid);
    plot(bumps_ordered, stim_ratios_ordered,'b.')
    plot(sigmoid_fit_stim,'b')
    
    ylim([-0.2 1.2])
    xlim([-1.2*max(2*bump_magnitudes) 1.2*max(2*bump_magnitudes)])
    title([filename ' Probability of moving to target at ' num2str(bump_directions(2)*180/pi,3) '^o'])
    xlabel('Bump magnitude [N]')
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
