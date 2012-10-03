% this is still quick and dirty
%
% Script loads sorted units and kinematics and plots PSTH aligned at the
% time when the feedback cloud turns on.
%
% last updated: 09/27/2012

clear all; close all;clc;
%50ms bin is standard
load sortedunits_MrT_PMd_09252012.mat;
load kin_MrT_09252012.mat;

numunits = length(sortedunits);
binsize=0.050; %50 ms
time_range = [-2:binsize:2];
numtrials = size(kin.feedback,1);
numbins = length(time_range);
movbuffer = 2;
smtrials = find(kin.feedback==0.5);
num_sm = length(find(kin.feedback==0.5));
lgtrials = find(kin.feedback==3.5);
num_lg = length(find(kin.feedback==3.5));

% for each unit
for ui=1:numunits
    figure(ui);
    binnedSpikes = zeros(numtrials,numbins);
    binnedSpikes_sm = zeros(num_sm,numbins);
    binnedSpikes_lg = zeros(num_lg,numbins);
    %align spike sequences to the cloud appearance (4cm)
    sm_i=1;
    lg_i=1;
    speed = zeros(numtrials,6000);
    for ti=1:numtrials
        
        % trim to just the timestamps for actual movement
        temp = find(~isnan(kin.ts(ti,:)));
        
        % time range of this trial
        trange = kin.ts(ti,temp);
        stemp = sqrt(kin.vel_x(ti,temp).^2+kin.vel_y(ti,temp).^2);
        speed(ti,1:length(stemp)) = stemp;

        [peakspeed peakspeed_idx] = max(stemp);
        figure(1000);
        plot(stemp);
        hold on;
        plot(peakspeed_idx,peakspeed,'bo');
        hold off;
        pause;
        peakspeed_ts(ti) = trange(peakspeed_idx);
        
        % time stamp of feedback cloud on
        fb_on = kin.mid_ts(ti);

        % extract the time stamps of each AP that falls in the trial time
        % range
        spikerange=find(sortedunits(ui).ts>=(trange(1)-movbuffer) & sortedunits(ui).ts<=(trange(end)+movbuffer));
        
        % align the spikes to center time 0 on the feedback cloud
        spikesAligned = sortedunits(ui).ts(spikerange)- peakspeed_ts(ti);
        
        for bi=1:numbins-1
           binnedSpikes(ti,bi) = length(find(spikesAligned>=time_range(bi) & spikesAligned <=time_range(bi+1)));
        end
        
        if ismember(ti,smtrials)
            binnedSpikes_sm(sm_i,:)=binnedSpikes(ti,:);
            sm_i=sm_i+1;
        elseif ismember(ti,lgtrials)
            binnedSpikes_lg(lg_i,:)=binnedSpikes(ti,:);            
            lg_i=lg_i+1;
        else
            printf('WHAT\n');
        end
    end
    subplot(2,1,1);
    PSTH(ui,:)=sum(binnedSpikes)/(numtrials*binsize);
    bar(time_range,PSTH(ui,:),'histc');
    line([0 0],[-0.25 max(PSTH(ui,:)+0.5)],'Color','m','LineWidth',2);
    xlim([-2 2]);
    ylim([-0.25 max(PSTH(ui,:)+0.5)]);
    title(['PSTH: (Cloud) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) (50ms bins)');
    ylabel('Spikes per second');
    subplot(2,1,2);
    hold on;
    PSTH_sm(ui,:)=sum(binnedSpikes_sm)/(num_sm*binsize);
    PSTH_lg(ui,:)=sum(binnedSpikes_lg)/(num_lg*binsize);
    bar(time_range',[PSTH_sm(ui,:); PSTH_lg(ui,:)]','histc');
    xlim([-2 2]);
    title(['PSTH: (Both Clouds) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) (50ms bins)');
    ylabel('Spikes per second');
    legend('Small Cloud','Large Cloud');
    hold on;
    line([0 0],[-0.25 max(PSTH_lg(ui,:)+0.5)],'Color','m','LineWidth',2);

end