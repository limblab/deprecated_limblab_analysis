

% options=[]; options.PredEMGs = 1;
% IsoModelAll = BuildModel(IsoBinned, options);
% WmModelAll = BuildModel(WmBinned, options);
% 
% IsoModelAllWeights = IsoModelAll.H;
% IsoModelAllWeights(1,:) = [];
% 
% WmModelAllWeights = WmModelAll.H;
% WmModelAllWeights(1,:) = [];
% 
% emgInd=10;
% meanIsoFilter = mean(reshape(IsoModelAllWeights(:,emgInd),10,[])');
% meanWmFilter = mean(reshape(WmModelAllWeights(:,emgInd),10,[])');
% 
% figure
% hold on
% plot(meanIsoFilter,'k')
% plot(meanWmFilter,'r')
% xlim([-5 15])
% title(IsoBinned.emgguide(emgInd,:))





%% Another method
options=[]; options.PredEMGs = 1;
IsoModelAll = BuildModel(IsoBinned, options);
WmModelAll = BuildModel(WmBinned, options);

IsoBinnedImpulse = IsoBinned;
IsoBinnedImpulse.spikeratedata = zeros(length(IsoBinned.spikeratedata(:,1)),length(IsoBinned.spikeratedata(1,:)));
IsoBinnedImpulse.spikeratedata(20,:) = repmat(20,1,length(IsoBinned.spikeratedata(1,:)));
[IsoBinnedImpulsePred] = predictSignals(IsoModelAll,IsoBinnedImpulse);
IsoBinnedImpulsePred.preddatabin = IsoBinnedImpulsePred.preddatabin - repmat(IsoModelAll.H(1,:),length(IsoBinnedImpulsePred.preddatabin),1);

WmBinnedImpulse = WmBinned;
WmBinnedImpulse.spikeratedata = zeros(length(WmBinned.spikeratedata(:,1)),length(WmBinned.spikeratedata(1,:)));
WmBinnedImpulse.spikeratedata(20,:) = repmat(20,1,length(WmBinned.spikeratedata(1,:)));
[WmBinnedImpulsePred] = predictSignals(WmModelAll,WmBinnedImpulse);
WmBinnedImpulsePred.preddatabin = WmBinnedImpulsePred.preddatabin - repmat(WmModelAll.H(1,:),length(WmBinnedImpulsePred.preddatabin),1);


foldername = 'Y:\User_folders\Stephanie\Data Analysis\Generalizability\Jango\EvaluateFigureDynamics\08-19-14\';
date = '08192014';
for i = 1:length(IsoBinned.emgguide)
plotImpulseResponse(IsoBinnedImpulsePred, WmBinnedImpulsePred,IsoBinned,i)

plotTitle = IsoBinned.emgguide(i,:);
saveas(gcf, strcat(foldername, date, '_FilterDynamics_', plotTitle, '.fig'))
saveas(gcf, strcat(foldername, date, '_FilterDynamics_,', plotTitle, '.pdf'))
end




