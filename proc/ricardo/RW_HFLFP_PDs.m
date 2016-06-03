% Find PDs
plotting = 1;
datapath = 'D:\Data\Tiki_4C1\FMAs\';
filenames = {'Tiki_2011-06-21_RW_001-xcr-5-10-single_units'};

extension = '.nev';
model = 'posvel'; % 'vel' or 'posvel'
curr_dir = pwd;
cd 'E:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd 'E:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
lfp_summary_all = [];

for iFile = 1:length(filenames)
    filename = filenames{iFile};
    if ~exist([datapath 'Processed\' filename '.mat'],'file')
        if strcmp(extension,'.nev')
            bdf = get_cerebus_data([datapath 'Sorted\' filename extension],2);
        else
            bdf = get_plexon_data([datapath 'Sorted\' filename extension],2);
        end
        save([datapath 'Processed\' filename],'bdf');    
    else
        load([datapath 'Processed\' filename],'bdf')
        if ~exist('bdf','var')
            load([datapath 'Processed\' filename],'data')
            bdf = data;
        end
    end
    cd(curr_dir)
    
    fs = 10000;
    ts = 200; % time step (ms)
    new_fs = ts;
    time = bdf.vel(:,1);
    time_resampled = decimate(time,fs/new_fs);
    channel_idx = find((bdf.raw.analog.adfreq == fs)');
    channel_list = zeros(length(channel_idx),1);
    num_channels = length(channel_idx);
    
    for iChan = 1:num_channels
        temp = cell2mat(bdf.raw.analog.channels(channel_idx(iChan)));
    	channel_list(iChan) = str2double(temp(1:find(temp==' ',1,'first')-1));
    end
    
    vt = bdf.vel(:,1);
    t = decimate(vt,fs/new_fs);
    
    % Filter parameters
    low_cutoff = 150;  % Hz
    [filt_b, filt_a] = butter(4,low_cutoff/(fs/2),'high');
    low_pass_envelope = 20;  % Hz
    [low_filt_b, low_filt_a] = butter(4,low_pass_envelope/(fs/2),'low');
    
    lfps = zeros(length(channel_idx),length(time_resampled));
    for iChan = 1:num_channels
        disp(['Channel: ' num2str(iChan) ' of ' num2str(num_channels)])
        y = double(bdf.raw.analog.data{channel_idx(iChan)});
        y = y(bdf.vel(1,1)*fs:end-(bdf.meta.duration-bdf.vel(end,1))*fs);
        y_high_pass = filtfilt(filt_b,filt_a,y);
        y_rectified = abs(y_high_pass);
        y_envelope = filtfilt(low_filt_b, low_filt_a, y_rectified);
        lfps(iChan,:) = decimate(y_envelope,fs/new_fs);
    end
    lfps(lfps<0) = 0;
    clear y y_high_pass y_rectified y_envelope 
    
    % GLM parameters
    th = 1:360;
    th = th*2*pi/360;
    vel_test = [50.*cos(th') 50.*sin(th')];
    speed = sqrt(vel_test(:,1).^2 + vel_test(:,2).^2);
    pos_test = zeros(length(vel_test),2);
    if strcmp(model,'posvel')
        test_params = [pos_test vel_test speed];
    elseif strcmp(model,'vel')
        test_params = [vel_test speed];
    end
    
    clear glmv glmx
    
    glmv(:,1) = decimate(bdf.vel(:,2),fs/new_fs);
    glmv(:,2) = decimate(bdf.vel(:,3),fs/new_fs);
    glmx(:,1) = decimate(bdf.pos(:,2),fs/new_fs);
    glmx(:,2) = decimate(bdf.pos(:,3),fs/new_fs);

    offset = 0;
    pds = zeros(num_channels,1);
    confidence = zeros(num_channels,1);
    speed_comp = zeros(num_channels,1);
    task_modulation = zeros(num_channels,1);
    dm_theta = zeros(num_channels,1);
    tic
    for iChan = 1:num_channels
        et = toc;
        disp(sprintf('ET: %f (%d of %d)', et, iChan, num_channels));
        lfps_i = lfps(iChan,:);        

        if strcmp(model,'posvel')
            glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];       
            [b, dev, stats] = glmfit(glm_input, lfps_i, 'poisson');
            db = stats.se;
            bv = [b(4); b(5)];
            dbv = [db(4); db(5)];
            pd = atan2(bv(2),bv(1));

        elseif strcmp(model,'vel')
            glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];       
            [b, dev, stats] = glmfit(glm_input, lfps_i, 'poisson');
            db = stats.se;        
            bv = [b(2); b(3)];
            dbv = [db(2); db(3)];
            pd = atan2(bv(2),bv(1));
        end
        pds(iChan,:) = pd;

        J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
        seTheta = dbv'*J;
        stdTheta = 1.96*seTheta; % 95% confidence  
        confidence(iChan) = abs(stdTheta);  

        fr_50 = glmval(b, test_params, 'log');
        fr_0 = glmval(b, zeros(1,size(test_params,2)), 'log');
        speed_comp(iChan) = mean(fr_50)-fr_0;
%         dm(iChan) = max(fr_50)-fr_0; 
        if abs(max(fr_50)-fr_0) > abs(min(fr_50)-fr_0)
            task_modulation(iChan) = max(fr_50)-fr_0;
        else
            task_modulation(iChan) = min(fr_50)-fr_0;
        end
        dm_theta(iChan) = max(fr_50)-min(fr_50);  
    end
    
    pds(pds<0)=pds(pds<0)+2*pi;
    lfp_summary = [channel_list pds confidence task_modulation dm_theta speed_comp];
    lfp_summary_all = [lfp_summary_all; lfp_summary];    
    
    figure
    for iChan=1:num_channels
        subplot(6,16,channel_list(iChan))
    %     subplot(10,10,cl(iUnit))
        h = wedgePlot(pds(iChan),confidence(iChan));
        set(h,'HandleVisibility','on')
        hold on
        plot([0 cos(pds(iChan))],[0 sin(pds(iChan))])
        temp_text = findall(h,'Type','Text');
        set(temp_text,'String','');
        temp_lines = findall(h,'LineStyle',':');
        set(temp_lines,'LineStyle','none');
        title(['Chan ' num2str(channel_list(iChan))])
    end

    %% confidence for LFP
    figure;
    title(strrep(filename,'_',' '))
    hist(lfp_summary(:,3)*(180/pi),10:20:350);
    xlim([0 360])
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','b','FaceAlpha',0.5)    
    title('Multiunit confidence')

    %% PD distributions
    figure;
    title(strrep(filename,'_',' '))
    hist(lfp_summary(:,2)*(180/pi),10:20:350);
    xlim([0 360])
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','b','FaceAlpha',0.5)    
    title('Multiunit PDs')
end


%% LFP stability
lfp_summary_all_remove = lfp_summary_all;
clear chan_group;
group_count = 0;
while size(lfp_summary_all_remove,1)>0
    group_count = group_count+1;
    chan = lfp_summary_all_remove(1,1);
    chan_group{group_count}.channel = chan;
    chan_group{group_count}.PDs = lfp_summary_all_remove(1,2);
    chan_group{group_count}.conf = lfp_summary_all_remove(1,3);
    chan_group{group_count}.dm = lfp_summary_all_remove(1,4);
    chan_group{group_count}.dm_theta = lfp_summary_all_remove(1,5);
    iRemove = 2;
    while (iRemove<=size(lfp_summary_all_remove,1))
%     for iRemove = 2:size(single_units_all_remove,1)
        if (lfp_summary_all_remove(iRemove,1) == chan)
            chan_group{group_count}.PDs = [chan_group{group_count}.PDs lfp_summary_all_remove(iRemove,2)];
            chan_group{group_count}.conf = [chan_group{group_count}.conf lfp_summary_all_remove(iRemove,3)];
            chan_group{group_count}.dm = [chan_group{group_count}.dm lfp_summary_all_remove(iRemove,4)];
            chan_group{group_count}.dm_theta = [chan_group{group_count}.dm_theta lfp_summary_all_remove(iRemove,5)];
            lfp_summary_all_remove = lfp_summary_all_remove([1:iRemove-1 iRemove+1:end],:);
        end
        iRemove = iRemove+1;
    end
    lfp_summary_all_remove = lfp_summary_all_remove(2:end,:);
end

group_spread = [];
group_confidence = [];
group_mean_pd = [];
loop_count = 0;
for iGroup=1:length(chan_group)
    PDs_temp = chan_group{iGroup}.PDs;
    conf_temp = chan_group{iGroup}.conf;
    chan_temp = chan_group{iGroup}.channel;
    dm_temp = chan_group{iGroup}.dm;
    dm_theta_temp = chan_group{iGroup}.dm_theta;
    if length(PDs_temp)>1
        loop_count = loop_count+1;
        mmm = length(PDs_temp)./sqrt(sum(cos(PDs_temp')).^2 + sum(sin(PDs_temp')).^2);
        group_chan(loop_count) = chan_temp;
        group_spread(loop_count) = acos(1./mmm);
        group_confidence(loop_count) = mean(conf_temp);
        group_mean_pd(loop_count) = mean(unwrap(sort(PDs_temp)));
        group_dm(loop_count) = mean(dm_temp);
        group_dm_theta(loop_count) = mean(dm_theta_temp);
    end
end

group_chan = group_chan(group_confidence<pi);
group_spread = group_spread(group_confidence<pi);
group_mean_pd = group_mean_pd(group_confidence<pi);
group_confidence = group_confidence(group_confidence<pi);
group_dm = group_dm(group_confidence<pi);
group_dm_theta = group_dm_theta(group_confidence<pi);

% subgroup_idx = group_spread<15*pi/180;
% subgroup_idx = group_mean_pd>130/rad2deg & group_mean_pd < 170/rad2deg;
% subgroup_idx = group_confidence<40*pi/180;
% subgroup_idx = group_mean_pd>130/rad2deg & group_mean_pd < 170/rad2deg & group_confidence < 40*pi/180;
% subgroup_idx = group_chan == 14;
% subgroup_idx = group_confidence < 40/rad2deg & group_spread > 10/rad2deg;
subgroup_idx = group_dm>400 ;
subgroup_chan = group_chan(subgroup_idx);
subgroup_spread = group_spread(subgroup_idx);
subgroup_mean_pd = group_mean_pd(subgroup_idx);
subgroup_confidence = group_confidence(subgroup_idx);
subgroup_dm = group_dm(subgroup_idx);
subgroup_dm_theta = group_dm_theta(subgroup_idx);

stim_idx = group_chan == 14;
stim_chan = group_chan(stim_idx);
stim_spread = group_spread(stim_idx);
stim_mean_pd = group_mean_pd(stim_idx);
stim_confidence = group_confidence(stim_idx);
stim_dm = group_dm(stim_idx);
stim_dm_theta = group_dm_theta(stim_idx);

fit_func = 'm*x+b';
% f_opts = fitoptions('Method','NonLinearLeastSquares','StartPoint',[0 1])
f_linear = fittype(fit_func,'independent','x');
[group_spread_confidence_fit fit_stats] = fit(group_confidence',group_spread',f_linear);
group_spread_confidence_conf = confint(group_spread_confidence_fit);

rad2deg = 180/pi;
figure;
subplot(231)
hold on
plot(rad2deg*stim_confidence,rad2deg*stim_spread,'*k')
plot(rad2deg*group_confidence,rad2deg*group_spread,'.b')
plot(rad2deg*subgroup_confidence,rad2deg*subgroup_spread,'.r')

plot(rad2deg*linspace(0,pi,100),rad2deg*group_spread_confidence_fit(linspace(0,pi,100)),'-b')
if size(group_spread_confidence_conf,2)==2
    plot(rad2deg*linspace(0,pi,100),rad2deg*(group_spread_confidence_conf(1,1)+group_spread_confidence_conf(1,2)*linspace(0,pi,100)),'--b')
    plot(rad2deg*linspace(0,pi,100),rad2deg*(group_spread_confidence_conf(2,1)+group_spread_confidence_conf(2,2)*linspace(0,pi,100)),'--b')
else
    plot(rad2deg*linspace(0,pi,100),rad2deg*group_spread_confidence_conf*linspace(0,pi,100),'--b')
end
title('Multiunit PD spread vs mean confidence')
ylabel('Spread (deg)')
xlabel('Mean confidence (deg)')
xlim(rad2deg*[0 pi])
ylim(rad2deg*[0 pi/2])

subplot(232)
hold on
plot(rad2deg*stim_mean_pd,rad2deg*stim_confidence,'k*')
plot(rad2deg*group_mean_pd,rad2deg*group_confidence,'b.')
plot(rad2deg*subgroup_mean_pd,rad2deg*subgroup_confidence,'r.')
title('Mean confidence vs mean PD')
xlim(rad2deg*[0 2*pi])
ylim(rad2deg*[0 pi])
xlabel('Mean PD (deg)')
ylabel('Mean confidence (deg)')

subplot(233)
hold on
plot(rad2deg*stim_mean_pd,rad2deg*stim_spread,'k*')
plot(rad2deg*group_mean_pd,rad2deg*group_spread,'b.')
plot(rad2deg*subgroup_mean_pd,rad2deg*subgroup_spread,'r.')
title('Spread vs mean PD')
xlim(rad2deg*[0 2*pi])
ylim(rad2deg*[0 pi/2])
xlabel('Mean PD (deg)')
ylabel('Spread (deg)')

subplot(234)
hold on
hist(rad2deg*group_mean_pd(~subgroup_idx),[0:20:360])
h_hist = findobj(gca,'Type','patch');
set(h_hist,'FaceColor','b','FaceAlpha',0.5);
hist(rad2deg*subgroup_mean_pd,[0:20:360]);
h_hist2 = findobj(gca,'Type','patch');
set(setxor(h_hist2,h_hist),'FaceColor','r','FaceAlpha',0.5);

xlim([0 360])
xlabel('Mean PD (deg)')
ylabel('Count')
title('PD distribution')

subplot(235)
hold on
plot(rad2deg*group_mean_pd,group_dm,'.b')
plot(rad2deg*subgroup_mean_pd,subgroup_dm,'.r')
plot(rad2deg*stim_mean_pd,stim_dm,'*k')
xlim([0 360])
xlabel('mean PD (deg)')
ylabel('Task modulation (Hz)')
title('Task modulation (max deviation from baseline) vs mean PD')

subplot(236)
hold on
plot(rad2deg*group_mean_pd,group_dm_theta,'.b')
plot(rad2deg*subgroup_mean_pd,subgroup_dm_theta,'.r')
plot(rad2deg*stim_mean_pd,stim_dm_theta,'*k')
xlim([0 360])
xlabel('mean PD (deg)')
ylabel('Depth of tuning (Hz)')
title('Depth of tuning vs mean PD')

   