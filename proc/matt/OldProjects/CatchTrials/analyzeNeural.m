clear
close all
clc

% Potential dates: 11/16/12, 11/30/12, 12/3/12 (all of these are 0.5 hold
% for hand control and 0.2 hold for brain control)

filePre = '/Users/Matt/Desktop/lab/data/';

% Load binned data files, don't do multiple days for now
% fileList = {'09-21-12/Jaco_IsoHC_BCCatch_09-21-12_002.mat',...
%     '09-21-12/Jaco_IsoBC_09-21-12_003.mat'};
% fileList = {'09-25-12/Jaco_IsoHC_BCCatch_09-25-12_002.mat',...
%      '09-25-12/Jaco_IsoBC_09-25-12_003.mat'};
fileList = {'09-19-12/Jaco_IsoHC_BCCatch_09-19-12_002.mat',...
     '09-19-12/Jaco_IsoBC_09-19-12_003.mat'};
% fileList = {'09-20-12/Jaco_IsoHC_BCCatch_09-20-12_002.mat',...
%      '09-20-12/Jaco_IsoHC_BCCatch_09-20-12_003.mat',...
%      '09-20-12/Jaco_IsoBC_09-20-12_005.mat'};

holdTime = 0.5; % hold time in milliseconds
nBins = 20;     %hist bins

for iFile = 1:length(fileList)
    binFL{iFile} = [filePre 'BDFStructs/' fileList{iFile}];
end

[hcTC, hcPD] = fitIsoTuningCurve(binFL,holdTime,'hc');
[bcTC, bcPD] = fitIsoTuningCurve(binFL,holdTime,'bc');
[ctTC, ctPD] = fitIsoTuningCurve(binFL,holdTime,'ct');

% Compute depth of modulation (peak to peak of tuning curve)
hcMD = 2*hcTC(:,2);
bcMD = 2*bcTC(:,2);
ctMD = 2*ctTC(:,2);

hcOff = hcTC(:,1);
bcOff = bcTC(:,1);
ctOff = ctTC(:,1);

dbPD = bcPD-hcPD;
dcPD = ctPD-hcPD;

dbMD = bcMD-hcMD;
dcMD = ctMD-hcMD;

dbOff = bcOff-hcOff;
dcOff = ctOff-hcOff;


figure;
hold all
hist(hcPD,nBins);
hist(bcPD,nBins);
hist(ctPD,nBins);
h = findobj(gca,'Type','patch');
set(h(3),'FaceColor','k','EdgeColor','k')
set(h(2),'FaceColor','r','EdgeColor','k')
set(h(1),'FaceColor','b','EdgeColor','k')
legend({'HC','BC','CT'});
[~,pchange] = ttest2(hcPD,bcPD)
[~,pchange] = ttest2(hcPD,ctPD)


figure;
hold all
hist(hcOff,nBins);
hist(bcOff,nBins);
hist(ctOff,nBins);
h = findobj(gca,'Type','patch');
set(h(3),'FaceColor','k','EdgeColor','k')
set(h(2),'FaceColor','r','EdgeColor','k')
set(h(1),'FaceColor','b','EdgeColor','k')
legend({'HC','BC','CT'});
[~,pchange] = ttest2(hcOff,bcOff)
[~,pchange] = ttest2(hcOff,ctOff)

figure;
hold all
hist(hcMD,nBins);
hist(bcMD,nBins);
hist(ctMD,nBins);
h = findobj(gca,'Type','patch');
set(h(3),'FaceColor','k','EdgeColor','k')
set(h(2),'FaceColor','r','EdgeColor','k')
set(h(1),'FaceColor','b','EdgeColor','k')
legend({'HC','BC','CT'});
[~,pchange] = ttest2(hcMD,bcMD)
[~,pchange] = ttest2(hcMD,ctMD)


figure;
hold all
hist(dbPD,nBins);
hist(dcPD,nBins);
h = findobj(gca,'Type','patch');
set(h(2),'FaceColor','k','EdgeColor','k')
set(h(1),'FaceColor','r','EdgeColor','k')
[~,pchange] = ttest2(dbPD,dcPD)


figure;
hold all
hist(dbMD,nBins);
hist(dcMD,nBins);
h = findobj(gca,'Type','patch');
set(h(2),'FaceColor','k','EdgeColor','k')
set(h(1),'FaceColor','r','EdgeColor','k')
[~,pchange] = ttest2(dbMD,dcMD)


figure;
hold all
hist(dbOff,nBins);
hist(dcOff,nBins);
h = findobj(gca,'Type','patch');
set(h(2),'FaceColor','k','EdgeColor','k')
set(h(1),'FaceColor','r','EdgeColor','k')
[~,pchange] = ttest2(dbOff,dcOff)







% maxNumChans = 96;
% allPos = []; %binned
% allVel = []; %binned
% allNeur = []; %binned
% allForceBin = []; %binned
% allTunCurv = [];
% 
% c = zeros(1,8);
% 
% for iFile = 1:length(fileList)
%     
%     %%% Separate data by reaches to each target direction
%     load([filePre 'BinnedData/' fileList{iFile}]);
%     
%     t = binnedData.timeframe;
%     force = binnedData.forcedatabin;
%     vel = binnedData.velocbin;
%     frData =  binnedData.spikeratedata;
%     tempfr = -1.*ones(size(binnedData.spikeratedata,1),maxNumChans);
%     tempfr(:,str2num(binnedData.spikeguide(:,3:4))) = frData;
%     
%     % We want to know whether each trial is CT, BC, or HC, which is not
%     % built into the normal trial table by default, so I am repurposing
%     % this other piece of code that I wrote to get the trial table
%     tt = poolCatchTrialData([filePre 'BDFStructs/' fileList{iFile}]);
%     
%     uTargs = unique(tt(:,10));
%     % Only use successful trials
%     tt = tt(tt(:,9)==82,:);
%     
%     for iTarg = 1:length(uTargs)
%         useTarget = uTargs(iTarg);
%         cc = c(iTarg);
%         
%         % 6 is outer target on time, 7 is go cue, 8 is end time
%         useTT = tt(tt(:,10)==useTarget,:);
%         
%         % Get all of the reaches velocities
%         for iTrial = 1:size(useTT,1)
%             cc = cc+1;
%             allReaches.(['Target' num2str(useTarget)]).force.(['Trial' num2str(cc)]) = double(force(t >= useTT(iTrial,6) & t <= useTT(iTrial,8),:));
%             allReaches.(['Target' num2str(useTarget)]).fr.(['Trial' num2str(cc)]) = double(tempfr(t >= useTT(iTrial,6) & t <= useTT(iTrial,8),:));
%             allReaches.(['Target' num2str(useTarget)]).vel.(['Trial' num2str(cc)]) = double(vel(t >= useTT(iTrial,6) & t <= useTT(iTrial,8),:));
%         end
%         
%         if ~isfield(allReaches.(['Target' num2str(useTarget)]),'CTIndex')
%             allReaches.(['Target' num2str(useTarget)]).CTIndex = useTT(:,11);
%         else
%             allReaches.(['Target' num2str(useTarget)]).CTIndex = [allReaches.(['Target' num2str(useTarget)]).CTIndex; useTT(:,11)];
%         end
%         c(iTarg) = length(fieldnames(allReaches.(['Target' num2str(useTarget)]).fr));
%     end
%     
%     allPos = [allPos; binnedData.cursorposbin];
%     allVel = [allVel; vel];
%     allForceBin = [allForceBin; force];
%     allNeur = [allNeur; tempfr];
%     
% end
% 
% clear c cc useTT iTarg iTrial tt uTargs tempfr frData force t binFL iFile binnedData useTarget vel tunCurv maxNumChans
% 
% % Fit PDs for each of the three conditions (to movement)
% % Separate all CT/HC/BC data into three continuous variables
% % Group all together
% allHCvel = [];
% allHCfr = [];
% allCTvel = [];
% allCTfr = [];
% allBCvel = [];
% allBCfr = [];
% for i = 1:length(fieldnames(allReaches))
%     targ = allReaches.(['Target' num2str(i)]);
%     vel = targ.vel;
%     fr = targ.fr;
%     ct = targ.CTIndex;
%     
%     % Concatenate all data together
%     hcInds = find(ct==0);
%     ctInds = find(ct==1);
%     bcInds = find(ct==2);
%     
%     for ih = 1:length(hcInds)
%         hcData.(['Target' num2str(i)]).vel.(['Trial' num2str(ih)]) = vel.(['Trial' num2str(hcInds(ih))]);
%         hcData.(['Target' num2str(i)]).fr.(['Trial' num2str(ih)]) = fr.(['Trial' num2str(hcInds(ih))]);
%         allHCvel = [allHCvel; vel.(['Trial' num2str(hcInds(ih))])];
%         allHCfr = [allHCfr; fr.(['Trial' num2str(hcInds(ih))])];
%     end
%     
%     for ib = 1:length(bcInds)
%         bcData.(['Target' num2str(i)]).vel.(['Trial' num2str(ib)]) = vel.(['Trial' num2str(bcInds(ib))]);
%         bcData.(['Target' num2str(i)]).fr.(['Trial' num2str(ib)]) = fr.(['Trial' num2str(bcInds(ib))]);
%         allBCvel = [allBCvel; vel.(['Trial' num2str(bcInds(ib))])];
%         allBCfr = [allBCfr; fr.(['Trial' num2str(bcInds(ib))])];
%     end
%     
%     for ic = 1:length(ctInds)
%         ctData.(['Target' num2str(i)]).vel.(['Trial' num2str(ic)]) = vel.(['Trial' num2str(ctInds(ic))]);
%         ctData.(['Target' num2str(i)]).fr.(['Trial' num2str(ic)]) = fr.(['Trial' num2str(ctInds(ic))]);
%         allCTvel = [allCTvel; vel.(['Trial' num2str(ctInds(ic))])];
%         allCTfr = [allCTfr; fr.(['Trial' num2str(ctInds(ic))])];
%     end
% end
% 
% % Remove channels that don't have data for all (adds -1 if not)
% [~,J] = find(allHCfr == -1);
% J = unique(J);
% 
% hcTT = allTT(allTT(:,11)==0,:);
% bcTT = allTT(allTT(:,11)==2,:);
% ctTT = allTT(allTT(:,11)==1,:);
% 
% allHCfr(:,J) = [];
% allBCfr(:,J) = [];
% allCTfr(:,J) = [];
% 
% [hcTC, hcPD] = fitTuningCurveToMovement(allHCfr, allHCvel,4,true);
% [bcTC, bcPD] = fitTuningCurveToMovement(allBCfr, allBCvel,2,false);
% [ctTC, ctPD] = fitTuningCurveToMovement(allCTfr, allCTvel,2,false);