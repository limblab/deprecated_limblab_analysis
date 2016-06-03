%% chop bdf in half

bdf = wed1010;
division_factor = 4; % divide by? 2 -> left with first half.

% get end time of experiment from bdf
end_time = bdf.vel(end,1); % [s]

% define time to chop the file off at
chop_off_time = floor(end_time/division_factor); % [s]

% make new bdf
new_bdf = bdf;

% chop databurst
new_bdf.databursts = bdf.databursts(1:find([bdf.databursts{:,1}]>=chop_off_time,1,'first'),:);

% chop vel, pos and acc
new_bdf.pos = bdf.pos(1:find(bdf.pos(:,1)>=chop_off_time,1,'first'),:);
new_bdf.vel = bdf.vel(1:find(bdf.vel(:,1)>=chop_off_time,1,'first'),:);
new_bdf.acc = bdf.acc(1:find(bdf.acc(:,1)>=chop_off_time,1,'first'),:);

% chop the time stamps of all units
for iUnit = 1:length(new_bdf.units)
    new_bdf.units(1,iUnit).ts = bdf.units(1,iUnit).ts(1:find(bdf.units(1,iUnit).ts>=chop_off_time,1,'first'));
end

% chop the words
new_bdf.words = bdf.words(1:find(bdf.words(:,1)>=chop_off_time,1,'first'),:);

%% make histograms

[pds_full,errs_full,moddepth_full]=glm_pds(wed1010,1);
[pds_half,errs_half,moddepth_half]=glm_pds(wed1010_half,1);
[pds_quarter,errs_quarter,moddepth_quarter]=glm_pds(wed1010_quarter,1);

CI_f = abs(errs_full*1.96*2*180/pi);
CI_h = abs(errs_half*1.96*2*180/pi);
CI_q = abs(errs_quarter*1.96*2*180/pi);

CI_diff_h_f = CI_h - CI_f; % difference between confidence bounds (abs) of half and full datafile
CI_diff_q_f = CI_q - CI_f; 
CI_diff_q_h = CI_q - CI_h; % difference between confidence bounds (abs) of quarter and half datafile

%% plot confidence interval histograms
figure('name','95% CI absolute difference half - full'); 
hist(CI_diff_h_f,[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
xlim([0,360])
xlabel('degrees')
ylabel('PD counts')
title('Histogram of absolute difference between 95% CI on PDs of half and full datafile')

figure('name','95% CI absolute difference quarter - full'); 
hist(CI_diff_q_f,[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
xlim([0,360])
xlabel('degrees')
ylabel('PD counts')
title('Histogram of absolute difference between 95% CI on PDs of quarter and full datafile')

figure('name','95% CI absolute difference quarter - half'); 
hist(CI_diff_q_h,[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
xlim([0,360])
xlabel('degrees')
ylabel('PD counts')
title('Histogram of absolute difference between 95% CI on PDs of quarter and half datafile')

%% only those that have a large moddepth
figure('name','95% CI absolute difference quarter - half'); 
hist(CI_diff_q_h,[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
xlim([0,360])
xlabel('degrees')
ylabel('PD counts')
title('Histogram of absolute difference between 95% CI on PDs of quarter and half datafile')

figure('name','95% CI absolute difference quarter - half'); 
hist(CI_diff_q_h(moddepth_full>=mean(moddepth_full)),[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
xlim([0,360])
xlabel('degrees')
ylabel('PD counts')
title('Histogram of absolute difference between 95% CI on PDs of quarter and half datafile')

figure('name','95% CI absolute difference quarter - full'); 
hist(CI_diff_q_f(moddepth_full>mean(moddepth_full)),[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
xlim([0,360])
xlabel('degrees')
ylabel('PD counts')
title('Histogram of abs difference between 95% CI on PDs of quarter and full datafile (moddepth>mean(moddepths))')


%% percentually
figure('name','95% CI difference quarter - half'); 
hist(CI_diff_q_h(moddepth_full>=mean(moddepth_full))./CI_f(moddepth_full>=mean(moddepth_full))*100,20) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
% xlim([0,360])
xlabel('percent [%] that CIs from a quarter of the datafile is larger than the CI of full datafile')
ylabel('PD counts')
title('Histogram of percentual difference between 95% CI on PDs of quarter and half datafile')

figure('name','95% CI difference half - full'); 
hist(CI_diff_h_f(moddepth_full>=mean(moddepth_full))./CI_f(moddepth_full>=mean(moddepth_full))*100,20) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
% xlim([0,360])
xlabel('percent [%] of CIs from half of the datafile that is larger than the CI of full datafile')
ylabel('PD counts')
title('Histogram of percentual difference between 95% CI on PDs of half and full datafile')

