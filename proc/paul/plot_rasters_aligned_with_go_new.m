% this is VERY quick and dirty

clear all; close all;clc;
%50ms bin is standard
load sortedunits_MrT_M1_09252012.mat;
load kin_MrT_09252012.mat;

numunits = length(sortedunits);
numtrials = size(kin.ts,1);
sm_trials = find(kin.feedback==0.5);
lg_trials = find(kin.feedback==3.5);

totsmall = length(sm_trials);
totlarge = length(lg_trials)
movbuffer = 1;
for ui=1:numunits
    figure(ui)
    all_speeds = sqrt(kin.vel_x.^2+kin.vel_y.^2);
    sm_speeds = sqrt(kin.vel_x(sm_trials,:).^2+kin.vel_y(sm_trials,:).^2);
    lg_speeds = sqrt(kin.vel_x(lg_trials,:).^2+kin.vel_y(lg_trials,:).^2);

    for ti=smtrials
        subplot(211);
        hold on;
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        fb_on = kin.mid_ts(ti);
        spikerange=find(sortedunits(ui).ts>=(trange(1)-movbuffer) & sortedunits(ui).ts<=(trange(end)+movbuffer));
        clr = 'r-';
        if ~isempty(spikerange)
            shifted = sortedunits(ui).ts(spikerange)-trange(1);
            plot([shifted'; shifted'],[ones(1,length(spikerange))*(con-0.5) ;ones(1,length(spikerange))*(con+0.5)],clr);
            plot(sortedunits(ui).ts(spikerange)-trange(1),con,clr);            
            line([fb_on-trange(1) fb_on-trange(1)],[con-0.5 con+0.5],'Color','k','LineWidth',1);
            line([trange(end)-trange(1) trange(end)-trange(1)],[con-0.5 con+0.5],'Color','k','LineWidth',1);
        end
    end
    line([0 0],[0 600],'Color','m','LineWidth',1);
    ylim([-5 600]);
    xlim([-2 5]);
    hold off;
    title(['Channel ' ' Unit ']);
    xlabel('Time (s) from GO signal');
    ylabel('AP for each movemment');
end