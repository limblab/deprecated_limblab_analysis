clear all; close all;clc;

ALIGN_GO = 0;
ALIGN_FBON = 1;
ALIGN_ENDPT = 2;
ALIGN_LOCMIN = 3;
BINSIZE=0.20;
load('sortedunits/sortedunits_MrT_PMd_09242012_UN1D_001.mat');
load('kin/kin_MrT_M1sorted_09242012_UN1D_001.mat');

numtrials=size(kin.ts,1);
sm_trials=find(kin.cloudVar==0.5);
lg_trials=find(kin.cloudVar==3.5);
for ti=1:numtrials
    ts_idx_go(ti)=find(kin.ts(ti,:)<=(kin.go_ts(ti)),1,'last');
    ts_idx_cloud(ti)=find(kin.ts(ti,:)<=(kin.cloud_on_ts(ti)),1,'last');
    ts_idx_400(ti)=find(kin.ts(ti,:)<=(kin.cloud_on_ts(ti)+0.400),1,'last');
    ts_idx_end(ti)=find(kin.ts(ti,:)<=(kin.endpoint_ts(ti)),1,'last');
     
    speed_go(ti)=kin.speed(ti,ts_idx_go(ti));
    speed_cloud_on(ti)=kin.speed(ti,ts_idx_cloud(ti));
    speed_cloud_400(ti)=kin.speed(ti,ts_idx_400(ti));
    speed_cloud_end(ti)=kin.speed(ti,ts_idx_end(ti));
    
%     plot(kin.ts(ti,:),kin.speed(ti,:));
%     hold on;
%     plot(kin.ts(ti,ts_idx_go(ti)),speed_go(ti),'ko');
%     plot(kin.ts(ti,ts_idx_cloud(ti)),speed_cloud_on(ti),'bo');
%     plot(kin.ts(ti,ts_idx_400(ti)),speed_cloud_400(ti),'rx');
%     plot(kin.ts(ti,ts_idx_end(ti)),speed_cloud_end(ti),'go');
%     hold off;
%     pause;
end

tranges = [650 750 850 950 1050];
sm_postcloud_t = ts_idx_end(sm_trials)-ts_idx_cloud(sm_trials);
lg_postcloud_t = ts_idx_end(lg_trials)-ts_idx_cloud(lg_trials);
for tr=1:length(tranges)-1
    range_trials{tr}.range = [tranges(tr) tranges(tr+1)];
    range_trials{tr}.sm_trials= sm_trials(find(sm_postcloud_t<tranges(tr+1) & sm_postcloud_t>=tranges(tr)));
    range_trials{tr}.lg_trials= lg_trials(find(lg_postcloud_t<tranges(tr+1) & lg_postcloud_t>=tranges(tr)));
    
    figure(tr);

    subplot(211);    hold on;
    smm=range_trials{tr}.sm_trials;
    for si=1:length(smm)
        plot(kin.speed(smm(si),:));
        
    end
    plot(nanmean(kin.speed(smm,:)),'r');hold off;
       subplot(212);    hold on;
       lgg=range_trials{tr}.lg_trials;
    for li=1:length(lgg)
        plot(kin.speed(lgg(li),:));
    end    
        plot(nanmean(kin.speed(lgg,:)),'r');hold off;
        un1d_plotPSTH_partial_sem(sortedunits,kin,BINSIZE, ALIGN_LOCMIN, smm, lgg);
        pause;
        close all;
end


% rasters = un1d_plotRasters(sortedunits,kin,ALIGN_FBON);




% 
% [n, x]=hist([(ts_idx_end(sm_trials(1:250))-ts_idx_cloud(sm_trials(1:250)))' (ts_idx_end(lg_trials(1:250))-ts_idx_cloud(lg_trials(1:250)))'],20)

