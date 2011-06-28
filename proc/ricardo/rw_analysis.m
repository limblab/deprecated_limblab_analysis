% Find PDs
plotting = 1;

datapath = 'D:\Data\Tiki_4C1\FMAs\';
filenames = {'Tiki_2011-06-02_RW_001-xcr-5-5-single_units',...
    'Tiki_2011-06-07_RW_001-single_units',...
    'Tiki_2011-06-08_RW_001-xcr-5-10-single_units',...
    'Tiki_2011-06-09_RW_001-xcr-5-10-single_units',...
    'Tiki_2011-06-10_RW_001-xcr-5-10-single_units',...
    'Tiki_2011-06-13_RW_001-xcr-5-10-single_units',...
    'Tiki_2011-06-14_RW_001-xcr-5-10-single_units',...
    'Tiki_2011-06-14_RW_002-xcr-5-10-single_units',...
    'Tiki_2011-06-15_RW_001-xcr-5-10-single_units',...
    'Tiki_2011-06-15_RW_002-xcr-5-10-single_units',...
    'Tiki_2011-06-21_RW_001-xcr-5-10-single_units'};

% datapath = 'D:\Data\Pedro_4C2\S1 array\';
% filenames = {'Pedro_2011-04-29_RW_001',...
%     'Pedro_2011-04-30_RW_001',...
%     'Pedro_2011-05-01_RW_001',...
%     'Pedro_2011-05-02_RW_001',...
%     'Pedro_2011-05-04_RW_001',...
%     'Pedro_2011-05-05_RW_001',...
%     'Pedro_2011-05-06_RW_001',...
%     'Pedro_2011-05-08_RW_001',...
%     };

extension = '.nev';
model = 'posvel'; % 'vel' or 'posvel'
% filename_analyzed = [datapath 'Processed\' filename];
multiunit = 1;  % if 1, it will combine all units (except invalidated ones - 255)
curr_dir = pwd;
cd 'E:\ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd 'E:\ricardo\Miller Lab\Matlab\s1_analysis\bdf';

multi_units_all = [];
single_units_all = [];
PD_comp_all = [];
rad2deg = 180/pi;

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

    % units = unit_list(bdf);
    % units = units(units(:,2)>0 & units(:,2)<10,:);
    % monkey = 'T';

    clear out;

    tic;

    th = 1:360;
    th = th*2*pi/360;
    vel_test = [50.*cos(th') 50.*sin(th')];
    speed = sqrt(vel_test(:,1).^2 + vel_test(:,2).^2);
    pos_test = zeros(length(vel_test),2);
%     pos_test = ones(length(vel_test),2);
%     pos_test(:,1) = -10;
%     pos_test(:,2) = 10;
    if strcmp(model,'posvel')
        test_params = [pos_test vel_test speed];
    elseif strcmp(model,'vel')
        test_params = [vel_test speed];
    end

    ts = 200; % time step (ms)
    vt = bdf.vel(:,1);
    t = vt(floor(vt*ts)==vt*ts);

    glmv = bdf.vel(floor(vt*ts)==vt*ts,2:3);
    glmx = bdf.pos(floor(vt*ts)==vt*ts,2:3);

    offset = 0;

    %% Single units
    ul = unit_list(bdf);
    ul = ul(ul(:,2)~=255,:);
%     ul = ul(ul(:,2)==0,:);
    ul = ul(ul(:,2)~=0,:);
    num_pds = length(ul);
    pds = zeros(num_pds,1);
    dm = zeros(num_pds,1);
    speed_comp = zeros(num_pds,1);
    confidence = zeros(num_pds,1);

    tic;
    for i = 1:num_pds
        et = toc;
        disp(sprintf('ET: %f (%d of %d)', et, i, num_pds));    
        spike_times = get_unit(bdf,ul(i,1),ul(i,2))-offset;
        spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
        s = train2bins(spike_times, t);

        if strcmp(model,'posvel')
            glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];       
            [b, dev, stats] = glmfit(glm_input, s, 'poisson');
            db = stats.se;
            bv = [b(4); b(5)];
            dbv = [db(4); db(5)];
            pd = atan2(bv(2),bv(1));

        elseif strcmp(model,'vel')
            glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];       
            [b, dev, stats] = glmfit(glm_input, s, 'poisson');
            db = stats.se;        
            bv = [b(2); b(3)];
            dbv = [db(2); db(3)];
            pd = atan2(bv(2),bv(1));
        end
        pds(i,:) = pd;

        J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
        seTheta = dbv'*J;
        stdTheta = 1.96*seTheta; % 95% confidence  
        confidence(i) = abs(stdTheta);  

        fr_50 = glmval(b, test_params, 'log');
        fr_0 = glmval(b, zeros(1,size(test_params,2)), 'log');
        speed_comp(i) = mean(fr_50);
        dm(i) = (max(fr_50)-fr_0)/max(fr_50);  
        max(fr_50)
    end
    pds(pds<0)=pds(pds<0)+2*pi;
    single_units = [ul pds confidence dm];
    single_units_all = [single_units_all ; single_units];

%     figure
%     for iUnit=1:num_pds
%         subplot(6,16,iUnit)
%         h = wedgePlot(pds(iUnit),confidence(iUnit));
%         set(h,'HandleVisibility','on')
%         hold on
%         plot([0 cos(pds(iUnit))],[0 sin(pds(iUnit))],'r')
%         set(findobj(h,'Type','patch'),'FaceColor','r')
%         
% %         %REMOVE!!!
% %         plot([0 cos(allfilesPDs{1}(iUnit,4))],[0 sin(allfilesPDs{1}(iUnit,4))],'b')
% %         h2 = wedgePlot(allfilesPDs{1}(iUnit,4),allfilesPDs{1}(iUnit,5)-allfilesPDs{1}(iUnit,3));        
%         
%         temp_text = findall(h,'Type','Text');
%         set(temp_text,'String','');
%         temp_lines = findall(h,'LineStyle',':');
%         set(temp_lines,'LineStyle','none');
%         title(num2str(ul(iUnit,:)))
%     end

    %% Multiunit
    ul = unit_list(bdf);
    ul = ul(ul(:,2)~=255,:);
%     ul = ul(ul(:,2)==0,:);
%     ul = ul(ul(:,2)~=0,:);
    cl = unique(ul(:,1));
    num_pds = length(cl);
    pds = zeros(num_pds,1);
    pds_pos = zeros(num_pds,1);
%     dm = zeros(num_pds,1);
    dm_theta = zeros(num_pds,1);
    speed_comp = zeros(num_pds,1);
    confidence = zeros(num_pds,1);
    confidence_pos = zeros(num_pds,1);
    task_modulation = zeros(num_pds,1);
    glm_params = zeros(num_pds,6);


    tic;
    for i = 1:num_pds
        et = toc;
        disp(sprintf('ET: %f (%d of %d)', et, i, num_pds));
        this_chan_units = ul(ul(:,1)==cl(i),2);
        spike_times = [];
        for unit = 1:length(this_chan_units)
            spike_times = [spike_times; get_unit(bdf,cl(i),this_chan_units(unit))-offset];
        end
        spike_times = sort(spike_times);
        spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
        s = train2bins(spike_times, t);

        if strcmp(model,'posvel')
            glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];       
            [b, dev, stats] = glmfit(glm_input, s, 'poisson');
            db = stats.se;
            bv = [b(4); b(5)];
            dbv = [db(4); db(5)];
            pd = atan2(bv(2),bv(1));
            bv_pos = [b(2); b(3)];
            dbv_pos = [db(2); db(3)];
            pd_pos = atan2(bv_pos(2),bv_pos(1));

        elseif strcmp(model,'vel')
            glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];       
            [b, dev, stats] = glmfit(glm_input, s, 'poisson');
            db = stats.se;        
            bv = [b(2); b(3)];
            dbv = [db(2); db(3)];
            pd = atan2(bv(2),bv(1));
        end
        glm_params(i,:) = b';
        pds(i,:) = pd;
        pds_pos(i,:) = pd_pos;

        J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
        seTheta = dbv'*J;
        stdTheta = 1.96*seTheta; % 95% confidence  
        confidence(i) = abs(stdTheta);  
        
        J_pos = [-bv_pos(2)/(bv_pos(1)^2+bv_pos(2)^2);...
            bv_pos(1)/(bv_pos(1)^2+bv_pos(2)^2)];
        seTheta = dbv_pos'*J_pos;
        stdTheta = 1.96*seTheta; % 95% confidence  
        confidence_pos(i) = abs(stdTheta);  

        fr_50 = glmval(b, test_params, 'log');
        fr_0 = glmval(b, zeros(1,size(test_params,2)), 'log');
        speed_comp(i) = mean(fr_50)-fr_0;
        
        if abs(max(fr_50)-fr_0) > abs(min(fr_50)-fr_0)
            task_modulation(i) = max(fr_50)-fr_0;
        else
            task_modulation(i) = min(fr_50)-fr_0;
        end
        dm_theta(i) = max(fr_50)-min(fr_50);  
    end
    pds(pds<0)=pds(pds<0)+2*pi;
    pds_pos(pds_pos<0)=pds_pos(pds_pos<0)+2*pi;
    
    multi_units = [cl pds confidence task_modulation dm_theta speed_comp pds_pos confidence_pos];
    multi_units_all = [multi_units_all; multi_units];

%     figure
%     for iUnit=1:num_pds
%         subplot(6,16,cl(iUnit))
%     %     subplot(10,10,cl(iUnit))
%         h = wedgePlot(pds(iUnit),confidence(iUnit));
%         set(h,'HandleVisibility','on')
%         hold on
%         plot([0 cos(pds(iUnit))],[0 sin(pds(iUnit))])
%         temp_text = findall(h,'Type','Text');
%         set(temp_text,'String','');
%         temp_lines = findall(h,'LineStyle',':');
%         set(temp_lines,'LineStyle','none');
%         title(['Chan ' num2str(cl(iUnit))])
%     end

    %% Compare multi/single unit PD
    PD_comp = zeros(length(single_units),2);
    for iUnit = 1:size(single_units,1)
        PD_comp(iUnit,:) = [single_units(iUnit,3) multi_units(multi_units(:,1)==single_units(iUnit,1),2)];
    end
    PD_comp_all = [PD_comp_all ; PD_comp];
%     figure;
%     plot(PD_comp(:,1),PD_comp(:,2),'.')
%     hold on
%     plot([0 2*pi],[0 2*pi],'r')
% 
%     axis equal
%     xlim([0 2*pi])
%     ylim([0 2*pi])
% 
%     xlabel('Single unit PD (rad)')
%     ylabel('Multiunit PD (rad)')
%     title('Single-multi unit PD comparison')
% 
%     %% Compare confidence for MU and SU
%     figure;
%     title(strrep(filename,'_',' '))
%     hist(multi_units(:,3)*(180/pi),[0:20:360]);
%     xlim([0 360])
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','b','FaceAlpha',0.5)
%     hold on
%     hist(single_units(:,4)*(180/pi),[0:20:360])
%     h2 = findobj(gca,'Type','patch');
%     set(h2(1),'FaceColor','r','FaceAlpha',0.5)
%     legend('Multiunit confidence','Single unit confidence')
% 
%     %% PD distributions
%     figure;
%     title(strrep(filename,'_',' '))
%     hist(multi_units(:,2)*(180/pi),[0:20:360]);
%     xlim([0 360])
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','b','FaceAlpha',0.5)
%     hold on
%     hist(single_units(:,3)*(180/pi),[0:20:360])
%     h2 = findobj(gca,'Type','patch');
%     set(h2(1),'FaceColor','r','FaceAlpha',0.5)
%     legend('Multiunit PDs','Single unit PDs')   
    
end

% %% single unit stability
% single_units_all_remove = single_units_all;
% clear chan_unit_group;
% group_count = 0;
% while size(single_units_all_remove,1)>0
%     group_count = group_count+1;
%     chan_unit = single_units_all_remove(1,1:2);
%     chan_unit_group{group_count}.channel = chan_unit(1);
%     chan_unit_group{group_count}.unit = chan_unit(2);
%     chan_unit_group{group_count}.PDs = single_units_all_remove(1,3);
%     chan_unit_group{group_count}.conf = single_units_all_remove(1,4);
%     iRemove = 2;
%     while (iRemove<=size(single_units_all_remove,1))
% %     for iRemove = 2:size(single_units_all_remove,1)
%         if (single_units_all_remove(iRemove,1) == chan_unit(1) && single_units_all_remove(iRemove,2) == chan_unit(2))
%             chan_unit_group{group_count}.PDs = [chan_unit_group{group_count}.PDs single_units_all_remove(iRemove,3)];
%             chan_unit_group{group_count}.conf = [chan_unit_group{group_count}.conf single_units_all_remove(iRemove,4)];
%             single_units_all_remove = single_units_all_remove([1:iRemove-1 iRemove+1:end],:);
%         end
%         iRemove = iRemove+1;
%     end
%     single_units_all_remove = single_units_all_remove(2:end,:);
% end
% 
% group_spread = [];
% group_confidence = [];
% loop_count = 0;
% for iGroup=1:length(chan_unit_group)
%     PDs_temp = chan_unit_group{iGroup}.PDs;
%     conf_temp = chan_unit_group{iGroup}.conf;
%     if length(PDs_temp)>1
%         loop_count = loop_count+1;
%         mmm = length(PDs_temp)./sqrt(sum(cos(PDs_temp')).^2 + sum(sin(PDs_temp')).^2);
%         group_spread(loop_count) = acos(1./mmm);
%         group_confidence(loop_count) = mean(conf_temp);
%     end
% end
% group_spread = group_spread(group_confidence<pi);
% group_confidence =group_confidence(group_confidence<pi);
% 
% fit_func = 'm*x+b';
% f_linear = fittype(fit_func,'independent','x');
% group_spread_confidence_fit = fit(group_confidence',group_spread',f_linear);
% group_spread_confidence_conf = confint(group_spread_confidence_fit);
% 
% figure;
% plot(group_confidence*180/pi,group_spread*180/pi,'.')
% hold on
% plot(1:180,group_spread_confidence_fit(1:180),'-')
% title('Single unit PD spread vs mean confidence')
% ylabel('Spread (deg)')
% xlabel('Mean confidence (deg)')
% xlim([0 180])
% ylim([0 90])

%% multi unit stability
multi_units_all_remove = multi_units_all;
clear chan_group;
group_count = 0;
while size(multi_units_all_remove,1)>0
    group_count = group_count+1;
    chan = multi_units_all_remove(1,1);
    chan_group{group_count}.channel = chan;
    chan_group{group_count}.PDs = multi_units_all_remove(1,2);
    chan_group{group_count}.conf = multi_units_all_remove(1,3);
    chan_group{group_count}.dm = multi_units_all_remove(1,4);
    chan_group{group_count}.dm_theta = multi_units_all_remove(1,5);
    iRemove = 2;
    while (iRemove<=size(multi_units_all_remove,1))
%     for iRemove = 2:size(single_units_all_remove,1)
        if (multi_units_all_remove(iRemove,1) == chan)
            chan_group{group_count}.PDs = [chan_group{group_count}.PDs multi_units_all_remove(iRemove,2)];
            chan_group{group_count}.conf = [chan_group{group_count}.conf multi_units_all_remove(iRemove,3)];
            chan_group{group_count}.dm = [chan_group{group_count}.dm multi_units_all_remove(iRemove,4)];
            chan_group{group_count}.dm_theta = [chan_group{group_count}.dm_theta multi_units_all_remove(iRemove,5)];
            multi_units_all_remove = multi_units_all_remove([1:iRemove-1 iRemove+1:end],:);
        end
        iRemove = iRemove+1;
    end
    multi_units_all_remove = multi_units_all_remove(2:end,:);
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
subgroup_idx = group_confidence < 20/rad2deg;
% subgroup_idx = group_dm < 0 ;
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
subplot(331)
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

subplot(332)
hold on
plot(rad2deg*stim_mean_pd,rad2deg*stim_confidence,'k*')
plot(rad2deg*group_mean_pd,rad2deg*group_confidence,'b.')
plot(rad2deg*subgroup_mean_pd,rad2deg*subgroup_confidence,'r.')
title('Mean confidence vs mean PD')
xlim(rad2deg*[0 2*pi])
ylim(rad2deg*[0 pi])
xlabel('Mean PD (deg)')
ylabel('Mean confidence (deg)')

subplot(333)
hold on
plot(rad2deg*stim_mean_pd,rad2deg*stim_spread,'k*')
plot(rad2deg*group_mean_pd,rad2deg*group_spread,'b.')
plot(rad2deg*subgroup_mean_pd,rad2deg*subgroup_spread,'r.')
title('Spread vs mean PD')
xlim(rad2deg*[0 2*pi])
ylim(rad2deg*[0 pi/2])
xlabel('Mean PD (deg)')
ylabel('Spread (deg)')

subplot(334)
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

subplot(335)
hold on
plot(rad2deg*group_mean_pd,group_dm,'.b')
plot(rad2deg*subgroup_mean_pd,subgroup_dm,'.r')
plot(rad2deg*stim_mean_pd,stim_dm,'*k')
xlim([0 360])
xlabel('mean PD (deg)')
ylabel('Task modulation (Hz)')
title('Task modulation (max deviation from baseline) vs mean PD')

subplot(336)
hold on
plot(rad2deg*group_mean_pd,group_dm_theta,'.b')
plot(rad2deg*subgroup_mean_pd,subgroup_dm_theta,'.r')
plot(rad2deg*stim_mean_pd,stim_dm_theta,'*k')
xlim([0 360])
xlabel('mean PD (deg)')
ylabel('Depth of tuning (Hz)')
title('Depth of tuning vs mean PD')

subplot(337)
plot(multi_units_all(:,7)*180/pi,min(repmat(180,size(multi_units_all,1),1),multi_units_all(:,8)*180/pi),'.')
xlabel('Position PD (deg)');
ylabel('Position PD confidence (deg)');
xlim([0 360])
title('Position PD confidence vs direction')

subplot(338)
hist(multi_units_all(:,7)*180/pi)
xlabel('Position PD (deg)');
ylabel('count')
title('Position PDs')

subplot(339)
plot(multi_units_all(:,2)*180/pi,multi_units_all(:,7)*180/pi,'.')
xlabel('Velocity PD (deg)');
ylabel('Position PD (deg)');
title('Position vs Velocity PDs')

%%
% subgroup_idx = multi_units_all(:,3)*rad2deg<10;
file_separators = find(diff(multi_units_all(:,1))<0);
subgroup_idx = zeros(size(multi_units_all(:,1)));
subgroup_idx(file_separators(9):file_separators(10)) = 1;

figure;

subplot(331)
hold on
plot(rad2deg*multi_units_all(find(~subgroup_idx),2),rad2deg*multi_units_all(find(~subgroup_idx),3),'b.')
plot(rad2deg*multi_units_all(find(subgroup_idx),2),rad2deg*multi_units_all(find(subgroup_idx),3),'r.')
title('Confidence vs PD')
xlim(rad2deg*[0 2*pi])
ylim(rad2deg*[0 pi])
xlabel('PD (deg)')
ylabel('Confidence (deg)')

subplot(332)
hold on
hist(rad2deg*multi_units_all(find(~subgroup_idx),2),[10:20:350])
h_hist = findobj(gca,'Type','patch');
set(h_hist,'FaceColor','b','FaceAlpha',0.5);
hist(rad2deg*multi_units_all(find(subgroup_idx),2),[10:20:350]);
h_hist2 = findobj(gca,'Type','patch');
set(setxor(h_hist2,h_hist),'FaceColor','r','FaceAlpha',0.5);
xlim([0 360])
xlabel('Mean PD (deg)')
ylabel('Count')
title('PD distribution')

subplot(333)
hold on
plot(rad2deg*multi_units_all(find(~subgroup_idx),2),multi_units_all(find(~subgroup_idx),4),'.b')
plot(rad2deg*multi_units_all(find(subgroup_idx),2),multi_units_all(find(subgroup_idx),4),'.r')
xlim([0 360])
xlabel('PD (deg)')
ylabel('Task modulation (Hz)')
title('Task modulation (max deviation from baseline) vs mean PD')

subplot(334)
hold on
plot(rad2deg*multi_units_all(find(~subgroup_idx),2),multi_units_all(find(~subgroup_idx),5),'.b')
plot(rad2deg*multi_units_all(find(subgroup_idx),2),multi_units_all(find(subgroup_idx),5),'.r')
xlim([0 360])
xlabel('PD (deg)')
ylabel('Depth of tuning (Hz)')
title('Depth of tuning vs mean PD')

subplot(335)
hold on
plot(multi_units_all(find(~subgroup_idx),7)*180/pi,...
    min(repmat(180,sum(~subgroup_idx),1),multi_units_all(find(~subgroup_idx),8)*180/pi),'b.')
plot(multi_units_all(find(subgroup_idx),7)*180/pi,...
    min(repmat(180,sum(subgroup_idx),1),multi_units_all(find(subgroup_idx),8)*180/pi),'r.')
xlabel('Position PD (deg)');
ylabel('Position PD confidence (deg)');
xlim([0 360])
title('Position PD confidence vs direction')

subplot(336)
hold on
hist(rad2deg*multi_units_all(find(~subgroup_idx),7),10:20:350)
h_hist = findobj(gca,'Type','patch');
set(h_hist,'FaceColor','b','FaceAlpha',0.5);
hist(rad2deg*multi_units_all(find(subgroup_idx),7),10:20:350);
h_hist2 = findobj(gca,'Type','patch');
set(setxor(h_hist2,h_hist),'FaceColor','r','FaceAlpha',0.5);
xlim([0 360])
xlabel('Pos PD (deg)')
ylabel('Count')
title('Position PD distribution')

subplot(337)
hold on
plot(multi_units_all(find(~subgroup_idx),2)*180/pi,multi_units_all(find(~subgroup_idx),7)*180/pi,'b.')
plot(multi_units_all(find(subgroup_idx),2)*180/pi,multi_units_all(find(subgroup_idx),7)*180/pi,'r.')
xlabel('Velocity PD (deg)');
ylabel('Position PD (deg)');
title('Position vs Velocity PDs')

%% SU vs MU PD comparison
figure;
plot(PD_comp_all(:,1)*180/pi,PD_comp_all(:,2)*180/pi,'.')
hold on
plot([0 360],[0 360],'r')

axis equal
xlim([0 360])
ylim([0 360])

xlabel('Single unit PD (rad)')
ylabel('Multiunit PD (rad)')
title(['Single-multi unit PD comparison (' num2str(length(filenames)) ' files)'])

%% Compare confidence for MU and SU
figure;
hist(multi_units_all(:,3)*(180/pi),[0:10:180]);
xlim([0 180])
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','FaceAlpha',0.5)
hold on
hist(single_units_all(:,4)*(180/pi),[0:10:180])
h2 = findobj(gca,'Type','patch');
set(h2(1),'FaceColor','r','FaceAlpha',0.5)
legend('Multiunit confidence','Single unit confidence')
title(['Single and multiunit 95% confidence (' num2str(length(filenames)) ' files)'])
xlabel('Confidence (deg)')
ylabel('Count')

%% PD distributions
figure;
hist(multi_units_all(:,2)*(180/pi),[0:20:360]);
xlim([0 360])
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','FaceAlpha',0.5)
hold on
hist(single_units_all(:,3)*(180/pi),[0:20:360])
h2 = findobj(gca,'Type','patch');
set(h2(1),'FaceColor','r','FaceAlpha',0.5)
legend('Multiunit PDs','Single unit PDs')
title(['Single and multiunit PD distribution (' num2str(length(filenames)) ' files)'])
xlabel('PD (deg)')
ylabel('Count')

% %% Units crosscorrelation
% units_concat = [];
% for iChan = 1:length(bdf.units)
%     if bdf.units(iChan).id(2) > 0 && bdf.units(iChan).id(2)<255
%         units_concat = [units_concat; bdf.units(iChan).ts];
%     end
% end
% units_concat = sort(units_concat);
% concat_bins = train2bins(units_concat,0.001);
% [autocorr lags] = xcorr(concat_bins,100);
% % figure;
% subplot(224)
% plot(lags(end/2+1:end),autocorr(end/2+1:end))
% xlabel('t (ms)')
% ylabel('Autocorrelation')
% title('Sorted waveforms')

        