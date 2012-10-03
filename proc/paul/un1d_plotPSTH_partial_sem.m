function psth = un1d_plotPSTH_partial(sortedunits,kin,binSize,alignCode, smtrials,lgtrials)
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

numSmallTrials = length(smtrials);
numLargeTrials = length(lgtrials);
time_padding = 1.5;

% binSize=0.05; %50 ms
timeBins = [-4:binSize:4];
numBins = length(timeBins);
% find the ts for the local minimum for hand speed following the cloud
for mi=1:numTrials
	prange = [1:find(isnan(kin.pos_x(mi,:))==1,1,'first')];
	[pks2, locs2] = findpeaks(-kin.speed(mi,prange));
	minl = locs2(find(kin.pos_y(mi,locs2)>=kin.cloudPosition,1,'first'));
	if isempty(minl)
        minloc_idx(mi) =NaN;
        locmin_ts(mi) = NaN;
    else
        minloc_idx(mi) = minl;
        locmin_ts(mi) = kin.ts(mi,minl);
	end
end

for ui=1:numUnits
     if mod(ui,4)==1
        figure(ui);
        subplot(221);
    elseif  mod(ui,4)==2
        subplot(222);
    elseif  mod(ui,4)==3
        subplot(223);
    elseif  mod(ui,4)==0
        subplot(224);
    end
    scount=1;

    binnedSpikes_small = zeros(numSmallTrials,numBins);
    for ti=smtrials'
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        go_ts    = kin.go_ts(ti);
        cloud_ts = kin.cloud_on_ts(ti);
        end_ts   = kin.endpoint_ts(ti);
                local_min_ts = locmin_ts(ti);
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'r-';
       
       
if alignCode==0         % align to
           alignTo = go_ts;
       elseif alignCode==1
           alignTo = cloud_ts;
       elseif alignCode==2
           alignTo = end_ts;
       elseif alignCode==3;
           alignTo = local_min_ts;
       end
       % align the spikes to center time 0 at the go cue
       spikesAligned = sortedunits(ui).ts(spikerange)-alignTo;
       
       for bi=1:numBins-1
           binnedSpikes_small(ti,bi) = length(find(spikesAligned>=timeBins(bi) & spikesAligned <=timeBins(bi+1)));
       end
       
       scount=scount+1;
    end 
    PSTH_small(ui,:)=sum(binnedSpikes_small)/(numSmallTrials*binSize);
    PSTH_small_sem(ui,:)=nanstd(binnedSpikes_small/binSize)/sqrt(numSmallTrials);

    
      scount=1;
      numTrials = length(lgtrials);
    binnedSpikes_large = zeros(numLargeTrials,numBins);
    for ti=lgtrials'
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        go_ts    = kin.go_ts(ti);
        cloud_ts = kin.cloud_on_ts(ti);
        end_ts   = kin.endpoint_ts(ti);
              local_min_ts = locmin_ts(ti);  
        spikerange=find(sortedunits(ui).ts>=(trange(1)-time_padding) & sortedunits(ui).ts<=(trange(end)+time_padding));
        clr = 'r-';
       
       
if alignCode==0         % align to
           alignTo = go_ts;
       elseif alignCode==1
           alignTo = cloud_ts;
       elseif alignCode==2
           alignTo = end_ts;
       elseif alignCode==3;
           alignTo = local_min_ts;
       end
       % align the spikes to center time 0 at the go cue
       spikesAligned = sortedunits(ui).ts(spikerange)-alignTo;
       
       for bi=1:numBins-1
           binnedSpikes_large(ti,bi) = length(find(spikesAligned>=timeBins(bi) & spikesAligned <=timeBins(bi+1)));
       end
       
       scount=scount+1;
    end 
    PSTH_large(ui,:)=sum(binnedSpikes_large)/(numLargeTrials*binSize);
     PSTH_large_sem(ui,:)=nanstd(binnedSpikes_large/binSize)/sqrt(numLargeTrials);
   
    hold on;
   hold on;
    alpha = 0.5;
    patch([timeBins fliplr(timeBins)],[PSTH_small(ui,:)+PSTH_small_sem(ui,:) fliplr(PSTH_small(ui,:)-PSTH_small_sem(ui,:))],[0.3 0.3 1],'EdgeColor',[0.3 0.3 1],'FaceAlpha',0.5,'EdgeAlpha',0.5);
    patch([timeBins fliplr(timeBins)],[PSTH_large(ui,:)+PSTH_large_sem(ui,:) fliplr(PSTH_large(ui,:)-PSTH_large_sem(ui,:))],[1 0.3 0.3],'EdgeColor',[1 0.3 0.3],'FaceAlpha',0.5,'EdgeAlpha',0.5);
    plot(timeBins,PSTH_small(ui,:),'b-');
    plot(timeBins,PSTH_large(ui,:),'r-');  
    legend('Small Cloud','Large Cloud');
    xlim([-2 2]);
    title(['PSTH: Channel ' num2str(sortedunits(ui).id(1)) ', Unit ' num2str(sortedunits(ui).id(2))]);
    xlabel('Time (s)');
    ylabel('Spikes per second');
end