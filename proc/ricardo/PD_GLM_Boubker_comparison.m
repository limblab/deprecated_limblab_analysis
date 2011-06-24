% Find PDs
% for iPause = 1:20000
%     clc
%     disp(['Wait for ' num2str(round((20000-iPause)/60)) ' more minutes'])
%     pause(1)
% end
PD_folder = 'D:\Ricardo\Miller Lab\Results\PD comparison\';    
plotting = 1;
% datapath = 'D:\Data\Tiki_4C1\FMAs\';
% datapath = 'D:\Data\Pedro_4C2\S1 array\';
datapath = 'D:\Data\Pedro_4C2\S1 array\';
filenames = {'Pedro_2011-04-29_RW_001',...
    'Pedro_2011-04-30_RW_001',...
    'Pedro_2011-05-01_RW_001',...
    'Pedro_2011-05-02_RW_001',...
    'Pedro_2011-05-04_RW_001',...
    'Pedro_2011-05-05_RW_001',...
    'Pedro_2011-05-06_RW_001',...
    'Pedro_2011-05-08_RW_001',...
    };


%     'Pedro_2011-05-07_RW_001',...
%     'Pedro_2011-05-09_RW_001',...
%     'Pedro_2011-05-10_RW_001',...
%     'Pedro_2011-05-11_RW_001',...
%     'Pedro_2011-05-13_RW_001',...
%     'Pedro_2011-05-14_RW_001',...
%     'Pedro_2011-05-15_RW_001'};
%     'Pedro_2011-05-16_RW_001',...
%     'Pedro_2011-05-18_RW_001';};

extension = '.nev';
model = 'posvel'; % 'vel' or 'posvel'
% filename_analyzed = [datapath 'Processed\' filename];
multiunit = 1;  % if 1, it will combine all units (except invalidated ones - 255)
curr_dir = pwd;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';

multi_units_all = [];
single_units_all = [];
PD_comp_all = [];
boubker_pds_all = [];

for iFile = 1:length(filenames)
    filename = filenames{iFile};
    if ~exist([datapath 'Processed\' filename '.mat'],'file')
        if strcmp(extension,'.nev')
            bdf = get_cerebus_data([datapath 'Sorted\' filename extension],2);
        else
            bdf = get_plexon_data([datapath 'Sorted\' filename extension],2);
        end
        save([datapath 'Processed\' filename],'bdf');   
        
    end
end

for iFile = 1:length(filenames)
    filename = filenames{iFile};
    clear bdf
    if exist([PD_folder filename '_PDs.mat'],'file')
        load([PD_folder filename '_PDs'])
    else
        load([datapath 'Processed\' filename],'bdf')
        if ~exist('bdf','var')
            load([datapath 'Processed\' filename],'data')
            bdf = data;
        end

        cd(curr_dir)
        clear out;

        tic;

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

        ts = 200; % new sampling frequency (Hz)
        vt = bdf.vel(:,1);
        t = vt(floor(vt*ts)==vt*ts);

        glmv = bdf.vel(floor(vt*ts)==vt*ts,2:3);
        glmx = bdf.pos(floor(vt*ts)==vt*ts,2:3);

        offset = 0;

        %% Multiunit
        ul = unit_list(bdf);
        ul = ul(ul(:,2)~=255,:);
    %     ul = ul(ul(:,2)==0,:);
    %     ul = ul(ul(:,2)~=0,:);
        cl = unique(ul(:,1));
        num_pds = length(cl);
        pds = zeros(num_pds,1);
        dm_theta = zeros(num_pds,1);
        speed_comp = zeros(num_pds,1);
        confidence = zeros(num_pds,1);
        task_modulation = zeros(num_pds,1);

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
            speed_comp(i) = mean(fr_50)-fr_0;
    %         dm(i) = max(fr_50)-fr_0; 
            if abs(max(fr_50)-fr_0) > abs(min(fr_50)-fr_0)
                task_modulation(i) = max(fr_50)-fr_0;
            else
                task_modulation(i) = min(fr_50)-fr_0;
            end
            dm_theta(i) = max(fr_50)-min(fr_50);  
        end
        pds(pds<0)=pds(pds<0)+2*pi;
        multi_units = [cl pds confidence task_modulation dm_theta speed_comp];
        save([PD_folder filename '_PDs'],'multi_units')
    end
    
    multi_units_all = [multi_units_all; multi_units];
    
    boubker_pd_file = ['Y:\user_folders\Boubker\PDs\' filenames{iFile} '_multi3'];
    load(boubker_pd_file);
    boubker_pds_all = [boubker_pds_all; allfilesPDs{1}];
end


%%
channels = multi_units_all(:,1);
glm_pds = multi_units_all(:,2)*180/pi;
glm_confidence = min(multi_units_all(:,3)*180/pi,180);
glm_tm = multi_units_all(:,4);
glm_tuning = multi_units_all(:,5);
glm_speed_comp = multi_units_all(:,6);

boubker_pds = boubker_pds_all(:,4)*180/pi;
boubker_confidence = ((boubker_pds_all(:,5)-boubker_pds_all(:,3))/2)*180/pi;

subgroup_idx = glm_confidence<10;

figure; 
plot(glm_pds(~subgroup_idx),boubker_pds(~subgroup_idx),'b.')
hold on
plot(glm_pds(subgroup_idx),boubker_pds(subgroup_idx),'r.')
xlabel('GLM PDs (deg)')
ylabel('Boubker PDs (deg)')

figure; 
plot(glm_confidence(~subgroup_idx),boubker_confidence(~subgroup_idx),'.')
hold on
plot(glm_confidence(subgroup_idx),boubker_confidence(subgroup_idx),'r.')
axis equal
xlim([0 180])
ylim([0 180])
xlabel('GLM confidence (deg)')
ylabel('Boubker confidence (deg)')

figure;
hold on
for i=1:size(multi_units_all,1)
    plot(glm_pds(i),boubker_pds(i),'.','Color',[boubker_confidence(i)/180 0 glm_confidence(i)/180]);
    hold on
end
xlabel('GLM PDs (deg)')
ylabel('Boubker PDs (deg)')

figure;
hold on
for i=1:size(multi_units_all,1)
    plot(glm_pds(i),boubker_pds(i),'.','Color',(glm_confidence(i))/180*[1 1 1]);
    hold on
end
xlabel('GLM PDs (deg)')
ylabel('Boubker PDs (deg)')

figure;
subplot(121)
hist(glm_pds(~subgroup_idx),30)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','FaceAlpha',0.5,'LineStyle','none')
hold on
hist(glm_pds(subgroup_idx),30)
h2 = findobj(gca,'Type','patch');
set(h2(1),'FaceColor','r','FaceAlpha',0.5,'LineStyle','none')
title('GLM PDs')
xlabel('GLM PDs (deg)')

subplot(122)
hist(boubker_pds(~subgroup_idx),30)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','FaceAlpha',0.5,'LineStyle','none')
hold on
hist(boubker_pds(subgroup_idx),30)
h2 = findobj(gca,'Type','patch');
set(h2(1),'FaceColor','r','FaceAlpha',0.5,'LineStyle','none')
title('Boubker PDs')
xlabel('Boubker PDs (deg)')

figure;
hist(glm_pds - boubker_pds,30)
title('GLM PD - Boubker PD')

figure;
subplot(121)
plot(boubker_pds,boubker_confidence,'.')
xlabel('Boubker PDs (deg)')
ylabel('Boubker confidence (deg)')
subplot(122)
plot(glm_pds,glm_confidence,'.')
xlabel('GLM PDs (deg)')
ylabel('GLM confidence (deg)')

figure;
subplot(241)
plot(glm_pds(~subgroup_idx),glm_confidence(~subgroup_idx),'.')
hold on
plot(glm_pds(subgroup_idx),glm_confidence(subgroup_idx),'r.')
xlabel('GLM PDs (deg)')
ylabel('GLM confidence (deg)')
subplot(242)
plot(glm_pds(~subgroup_idx),glm_tm(~subgroup_idx),'.')
hold on
plot(glm_pds(subgroup_idx),glm_tm(subgroup_idx),'r.')
ylabel('GLM Task modulation')
xlabel('GLM PDs (deg)')
subplot(243)
plot(glm_pds(~subgroup_idx),glm_tuning(~subgroup_idx),'.')
hold on
plot(glm_pds(subgroup_idx),glm_tuning(subgroup_idx),'r.')
ylabel('GLM Tuning')
xlabel('GLM PDs (deg)')
subplot(244)
plot(glm_pds(~subgroup_idx),glm_speed_comp(~subgroup_idx),'.')
hold on
plot(glm_pds(subgroup_idx),glm_speed_comp(subgroup_idx),'r.')
ylabel('GLM speed component')
xlabel('GLM PDs (deg)')
subplot(245)
hist(glm_pds(~subgroup_idx),50)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','FaceAlpha',0.5,'LineStyle','none')
hold on
hist(glm_pds(subgroup_idx),50)
h2 = findobj(gca,'Type','patch');
set(h2(1),'FaceColor','r','FaceAlpha',0.5,'LineStyle','none')



% figure; hist((single_units(:,3)-allfilesPDs{1}(:,4)))
