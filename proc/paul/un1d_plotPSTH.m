function psth = un1d_plotPSTH(sortedunits,kin,alignCode)
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
time_padding = 1.5;

binSize=0.050; %50 ms
timeBins = [-4:binSize:4];
numBins = length(timeBins);

for ui=1:numUnits
    figure(ui+100)
    scount=1;
    binnedSpikes_small = zeros(numSmallTrials,numBins);
    for ti=small_trial_idx'
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        go_ts    = kin.go_ts(ti);
        cloud_ts = kin.cloud_on_ts(ti);
        end_ts   = kin.endpoint_ts(ti);
        
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'r-';
       
       
       if alignCode==0         % align to
           alignTo = go_ts;
       elseif alignCode==1
           alignTo = cloud_ts;
       elseif alignCode==2
           alignTo = end_ts;
       end
       % align the spikes to center time 0 at the go cue
       spikesAligned = sortedunits(ui).ts(spikerange)-alignTo;
       
       for bi=1:numBins-1
           binnedSpikes_small(ti,bi) = length(find(spikesAligned>=timeBins(bi) & spikesAligned <=timeBins(bi+1)));
       end
       
       scount=scount+1;
    end 
    PSTH_small(ui,:)=sum(binnedSpikes_small)/(numSmallTrials*binSize);

    
      scount=1;
    binnedSpikes_large = zeros(numLargeTrials,numBins);
    for ti=large_trial_idx'
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        go_ts    = kin.go_ts(ti);
        cloud_ts = kin.cloud_on_ts(ti);
        end_ts   = kin.endpoint_ts(ti);
        
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'r-';
       
       
       if alignCode==0         % align to
           alignTo = go_ts;
       elseif alignCode==1
           alignTo = cloud_ts;
       elseif alignCode==2
           alignTo = end_ts;
       end
       % align the spikes to center time 0 at the go cue
       spikesAligned = sortedunits(ui).ts(spikerange)-alignTo;
       
       for bi=1:numBins-1
           binnedSpikes_large(ti,bi) = length(find(spikesAligned>=timeBins(bi) & spikesAligned <=timeBins(bi+1)));
       end
       
       scount=scount+1;
    end 
    PSTH_large(ui,:)=sum(binnedSpikes_large)/(numLargeTrials*binSize);
    
    hold on;
    stairs(timeBins,PSTH_small(ui,:),'b-');
    
    stairs(timeBins,PSTH_large(ui,:),'r-');  
%         bar(timeBins,[PSTH_small(ui,:)' PSTH_large(ui,:)'],'histc');
%     bar(timeBins,PSTH_small(ui,:)','FaceColor', 'r', 'EdgeColor', 'r');
%     hold on;
%     bar(timeBins, PSTH_large(ui,:)','FaceColor', 'b', 'EdgeColor', 'b');
    legend('Small Cloud','Large Cloud');
    xlim([-2 2]);
    title(['PSTH: Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s)');
    ylabel('Spikes per second');
end