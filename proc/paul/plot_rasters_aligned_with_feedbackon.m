% this is still quick and dirty
%
% Script loads sorted units and kinematics and plots rasters aligned at the
% time when the feedback cloud turns on.
%
% last updated: 09/27/2012

clear all; close all;clc;
%50ms bin is standard

load('sortedunits/sortedunits_MrT_M1sorted_09252012_UN1D_001.mat');
load kin_MrT_09252012.mat;

numunits = length(sortedunits);
numtrials = size(kin.ts,1);
totsmall = length(find(kin.feedback==0.5));
movbuffer = 2;
for ui=1:numunits

        figure(ui);
   hold on;

    numsmall=0;
    numlarge=0;
    for ti=1:numtrials
        hold on;
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        fb_on = kin.mid_ts(ti);
        spikerange=find(sortedunits(ui).ts>=(trange(1)-movbuffer) & sortedunits(ui).ts<=(trange(end)+movbuffer));
        if kin.feedback(ti)==0.5
                 subplot(211);
            clr = 'b-';
            numsmall=numsmall+1;
            con=numsmall;
        elseif kin.feedback(ti)==3.5
                 subplot(212);
            clr = 'r-';
            numlarge=numlarge+1;
        	con=numlarge;
        end
        if ~isempty(spikerange)
            shifted = sortedunits(ui).ts(spikerange)-fb_on;
            plot([shifted'; shifted'],[ones(1,length(spikerange))*(con-0.5) ;ones(1,length(spikerange))*(con+0.5)],clr);
            line([trange(1)-fb_on trange(1)-fb_on],[con-0.5 con+0.5],'Color','k','LineWidth',1);
            line([trange(end)-fb_on trange(end)-fb_on],[con-0.5 con+0.5],'Color','k','LineWidth',1);
        end
    end
    subplot(211);
    line([0 0],[0 300],'Color','m','LineWidth',1);
    ylim([-5 300]);
    xlim([-3 3]);
    hold off;
    title(['Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) (aligned at feedback/cloud onset)');
    ylabel('AP for each movemment');
        subplot(212);
    line([0 0],[0 300],'Color','m','LineWidth',1);
    ylim([-5 300]);
    xlim([-3 3]);
    hold off;
    title(['Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s) (aligned at feedback/cloud onset)');
    ylabel('AP for each movemment');
end