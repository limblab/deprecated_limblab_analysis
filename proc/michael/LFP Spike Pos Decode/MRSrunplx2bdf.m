% fnam='Thor_11-3-10_prone_iso_001'
% fnam='ChewieSpikeLFP202-final'
% bdf=get_plexon_data([fnam,'.plx'],0);
% save([fnam,'.mat'],'bdf')
% clear
% 'ChewieSpikeLFP113-final',ChewieSpikeLFP068-final-02','ChewieSpikeLFP069-
% final-03','ChewieSpikeLFP114-final-02',
% filelist={'MiniSpikeLFP046-10','MiniSpikeLFP083-08','MiniSpikeLFP108-25','MiniSpikeLFP144&145-11'}
% 'ChewieSpikeLFP270-03',
filelist={'Chewie_Spike_LFP2_105','Chewie_Spike_LFP2_115','Chewie_Spike_LFP2_116','Chewie_Spike_LFP2_117','Chewie_Spike_LFP2_118'};
for i=1:length(filelist)
fnam=filelist{i}
bdf=get_plexon_data([fnam,'.plx'],1);   %number is the LAB NUMBER!! Should be 1 for Mini
save([fnam,'.mat'],'bdf')
end
% [fparr,movetimes,words,mg,rt,eventsTable,etall] = bdf2fparr_mg(fnam,2500,2500,'rew');

