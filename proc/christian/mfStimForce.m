

bins = 1:60/0.05:10*60/0.05+1;

chans = [2 4];
plotflag = 0;
S = cell(1,10);
F = cell(1,10);
t = cell(1,10);
SA= cell(1,10);
Fits = cell(1,10);
CI= cell(1,10);
fo = fitoptions('poly1','Lower',[0 0],'Upper',[10000 0]);


for i = 1:length(bins)-1
    BD.timeframe = binnedData.timeframe(bins(i):bins(i+1)-1);
    BD.stim = binnedData.stim(binnedData.stim(:,1)>=binnedData.timeframe(bins(i)) & ...
                              binnedData.stim(:,1)< binnedData.timeframe(bins(i+1)-1) ,: );
    BD.forcedatabin = binnedData.forcedatabin(bins(i):bins(i+1)-1,:);
    [S{1,i},F{1,i},t{1,i}] = getStimForce(BD,chans,plotflag);
    SA{1,i}= sum(S{1,i},2);
    Fits{1,i} = fit(SA{1,i},F{1,i},'poly1',fo);
    CI{1,i} = confint(Fits{i});
end