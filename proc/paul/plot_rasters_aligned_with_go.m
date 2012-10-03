% this is VERY quick and dirty

clear all;

load('sortedunits/sortedunits_MrT_M1sorted_09252012_UN1D_001.mat');
load('kin_MrT_09252012.mat');

numunits  = length(sortedunits);
numtrials = size(kin.ts,1);
sm_trials = find(kin.feedback==0.5);
lg_trials = find(kin.feedback==3.5);

numsmall = length(sm_trials);
numlarge = length(lg_trials);
time_padding = 1;

for ui=1:5
    figure(ui*100)

    sm_idx=1;

    for ti=sm_trials'
        subplot(211);
        hold on;
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        fb_on = kin.mid_ts(ti);
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'r-';
        if ~isempty(spikerange)
            shifted = sortedunits(ui).ts(spikerange)-trange(1);
            plot([shifted'; shifted'],[ones(1,length(spikerange))*(sm_idx-0.5) ;ones(1,length(spikerange))*(sm_idx+0.5)],clr);
            sm_idx=sm_idx+1;
        end
    end
    line([0 0],[0 numsmall],'Color','m','LineWidth',1);
    ylim([-5 numsmall]);
    xlim([-2 5]);
    hold off;
    title(['Raster (Small Cloud) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) from GO signal');
    ylabel('AP for each movemment');
    
        lg_idx=1;
    
    for ti=lg_trials'
        subplot(212);
        hold on;
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        fb_on = kin.mid_ts(ti);
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'b-';
        if ~isempty(spikerange)
            shifted = sortedunits(ui).ts(spikerange)-trange(1);
            plot([shifted'; shifted'],[ones(1,length(spikerange))*(lg_idx-0.5) ;ones(1,length(spikerange))*(lg_idx+0.5)],clr);
        lg_idx=lg_idx+1;
        end
        
    end
    line([0 0],[0 numlarge],'Color','m','LineWidth',1);
    ylim([-5 numlarge]);
    xlim([-2 5]);
    hold off;
    title(['Raster (Large Cloud) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) from GO signal');
    ylabel('AP for each movemment');
end