% this is still quick and dirty
%
% Script loads sorted units and kinematics and plots PSTH aligned at the
% time when the feedback cloud turns on.
%
% last updated: 09/27/2012

clear all; close all;clc;
%50ms bin is standard
load sortedunits_MrT_M1_09242012.mat;
load kin_MrT_09242012.mat;

numunits = length(sortedunits);
binsize=0.05; %50 ms
time_range = [-2:binsize:2];
numtrials = size(kin.ts,1);
numbins = length(time_range);
movbuffer = 2;

% for each unit
for ui=1:numunits
     if mod(ui,4)==1
        figure(ui);
        subplot(411);
    elseif  mod(ui,4)==2
        subplot(412);
    elseif  mod(ui,4)==3
        subplot(413);
    elseif  mod(ui,4)==0
        subplot(414);
    end
    binnedSpikes = zeros(numtrials,numbins);
    %align spike sequences to the cloud appearance (4cm)
    for ti=1:numtrials
        % trim to just the timestamps for actual movement
        temp = find(~isnan(kin.ts(ti,:)));
        
        % time range of this trial
        trange = kin.ts(ti,temp);
        
        % time stamp of feedback cloud on
        fb_on = kin.mid_ts(ti);

        % extract the time stamps of each AP that falls in the trial time
        % range
        spikerange=find(sortedunits(ui).ts>=(trange(1)-movbuffer) & sortedunits(ui).ts<=(trange(end)+movbuffer));
        
        % align the spikes to center time 0 on the feedback cloud
        spikesAligned = sortedunits(ui).ts(spikerange)-fb_on;
        
        for bi=1:numbins-1
           binnedSpikes(ti,bi) = length(find(spikesAligned>=time_range(bi) & spikesAligned <=time_range(bi+1)));
        end
    end
    PSTH(ui,:)=sum(binnedSpikes)/(numtrials*binsize);
    bar(time_range+binsize/2,PSTH(ui,:),'hist');
    line([0 0],[-0.25 max(PSTH(ui,:)+0.5)],'Color','m','LineWidth',2);
    xlim([-2 2]);
    ylim([-0.25 max(PSTH(ui,:)+0.5)]);
    title(['PSTH: (Cloud) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) (50ms bins)');
    ylabel('Spikes per second');
end