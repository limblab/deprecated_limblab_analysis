function rasters = un1d_plotRasters(sortedunits,kin,alignCode)
%
%this is VERY quick and dirty
%
%   align
%
%
%
%

numUnits  = length(sortedunits);
numTrials = size(kin.ts,1);
small_trial_idx = find(kin.cloudVar==0.5);
large_trial_idx = find(kin.cloudVar==3.5);

numSmallTrials = length(small_trial_idx);
numLargeTrials = length(large_trial_idx);
time_padding = 1;

for ui=1:numUnits
    figure(ui)
    scount=1;
    for ti=small_trial_idx'
        subplot(211);
        hold on;
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        go_ts    = kin.go_ts(ti);
        cloud_ts = kin.cloud_on_ts(ti);
        end_ts   = kin.endpoint_ts(ti);
        
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'r-';
        if ~isempty(spikerange)
            
            if alignCode==0         % align to 
                alignTo = go_ts;
            elseif alignCode==1
                alignTo = cloud_ts;               
            elseif alignCode==2
                alignTo = end_ts;
            end
            shifted = sortedunits(ui).ts(spikerange)-alignTo;
            plot([shifted'; shifted'],[ones(1,length(spikerange))*(scount-0.5) ;ones(1,length(spikerange))*(scount+0.5)],clr);
        
        end
            scount=scount+1;
    end 
    line([0 0],[0 numSmallTrials],'Color','m','LineWidth',1);
    ylim([-5 numSmallTrials]);
    xlim([-5 5]);
    hold off;
    title(['Raster (Small Cloud) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s)');
    ylabel('AP for each movemment');
    
    
    lcount=1;
    for ti=large_trial_idx'
        subplot(212);
        hold on;
        temp     = find(~isnan(kin.ts(ti,:)));
        trange   = kin.ts(ti,temp);
        go_ts    = kin.go_ts(ti);
        cloud_ts = kin.cloud_on_ts(ti);
        end_ts   = kin.endpoint_ts(ti);

        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'b-';
        if ~isempty(spikerange)
            if alignCode==0         % align to 
                alignTo = go_ts;
            elseif alignCode==1
                alignTo = cloud_ts;               
            elseif alignCode==2
                alignTo = end_ts;
            end
            shifted = sortedunits(ui).ts(spikerange)-alignTo;
            plot([shifted'; shifted'],[ones(1,length(spikerange))*(lcount-0.5) ;ones(1,length(spikerange))*(lcount+0.5)],clr);
        end
        lcount=lcount+1;
    end
    line([0 0],[0 numLargeTrials],'Color','m','LineWidth',1);
    ylim([-5 numLargeTrials]);
    xlim([-5 5]);
    hold off;
    title(['Raster (Large Cloud) Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s)');
    ylabel('AP for each movemment');
end