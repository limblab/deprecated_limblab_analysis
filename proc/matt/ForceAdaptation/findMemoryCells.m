clear;
close all;
clc;

% loadMat = '05272013_move_peak_bin.mat';
% loadMat = ['data\05272013_glm.mat'];
% loadMat = ['data\07022013_glm_vel.mat'];
% loadMat = ['data\CO_07-02-2013_move_peak.mat'];
loadMat = [];

ciSig = 30; %degrees

% Define locations
pmdDir = 'Z:\MrT_9I4\PMd\Matt\BDFStructs';
m1Dir = 'Z:\MrT_9I4\M1\Matt\BDFStructs';

% useDate = '2013-05-27';
% useDate2 = '05272013';
% filePreM1 = 'MrT_M1_CO_FF_';
% filePrePMd = 'MrT_PMd_CO_FF_kin_';
useDate = '2013-07-02';
useDate2 = '07022013';
filePreM1 = 'MrT_M1_CO_FF_';
filePrePMd = 'MrT_PMd_CO_FF_kin_';

if isempty(loadMat)
    tuningParams = {'doplots',false,...
                    'movetime',0.5,...
                    'sig',0.95,...
                    'numiters',1000,...
                    'glmnumsamps','all',...
                    'glmmodel','vel',...
                    'glmbin',25,...
                    'trialtable',[]};
    
    blM1File = fullfile(m1Dir,useDate,[filePreM1 'BL_' useDate2 '_001.mat']); %baseline file
    adM1File = fullfile(m1Dir,useDate,[filePreM1 'AD_' useDate2 '_002.mat']); %adaptation file
    woM1File = fullfile(m1Dir,useDate,[filePreM1 'WO_' useDate2 '_003.mat']); %washout file
    
    blPMdFile = fullfile(pmdDir,useDate,[filePrePMd 'BL_' useDate2 '_001.mat']); %baseline file
    adPMdFile = fullfile(pmdDir,useDate,[filePrePMd 'AD_' useDate2 '_002.mat']); %adaptation file
    woPMdFile = fullfile(pmdDir,useDate,[filePrePMd 'WO_' useDate2 '_003.mat']); %washout file
    
    % Get the pds for M1 cells
    disp('Baseline M1...')
    [pdsM1BL,ciM1BL,sgM1BL,ttBL] = fitTuningCurves(blM1File,tuningParams);
    disp('Adaptation M1...')
    [pdsM1AD,ciM1AD,sgM1AD,ttAD] = fitTuningCurves(adM1File,tuningParams);
    disp('Washout M1...')
    [pdsM1WO,ciM1WO,sgM1WO,ttWO] = fitTuningCurves(woM1File,tuningParams);
    
    % Get the pds for PMd cells
    disp('Baseline PMd...')
    tuningParams{end} = ttBL;
    [pdsPMdBL,ciPMdBL,sgPMdBL] = fitTuningCurves(blPMdFile,tuningParams);
    disp('Adaptation PMd...')
    tuningParams{end} = ttAD;
    [pdsPMdAD,ciPMdAD,sgPMdAD] = fitTuningCurves(adPMdFile,tuningParams);
    disp('Washout PMd...')
    tuningParams{end} = ttWO;
    [pdsPMdWO,ciPMdWO,sgPMdWO] = fitTuningCurves(woPMdFile,tuningParams);
else
    % just load data for plotting below
    load(loadMat);
    ciSig = 30; %degrees
end


%%
% Classify cells as AAA (kinematic), ABA (dynamic), or memory


%%
sigM1BL = ( angleDiff(pdsM1BL,ciM1BL(:,1)) + angleDiff(pdsM1BL,ciM1BL(:,2)) ) <= ciSig;
sigM1AD = ( angleDiff(pdsM1AD,ciM1AD(:,1)) + angleDiff(pdsM1AD,ciM1AD(:,2)) ) <= ciSig;
sigM1WO = ( angleDiff(pdsM1WO,ciM1WO(:,1)) + angleDiff(pdsM1WO,ciM1WO(:,2)) ) <= ciSig;

sigPMdBL = ( angleDiff(pdsPMdBL,ciPMdBL(:,1)) + angleDiff(pdsPMdBL,ciPMdBL(:,2)) ) <= ciSig;
sigPMdAD = ( angleDiff(pdsPMdAD,ciPMdAD(:,1)) + angleDiff(pdsPMdAD,ciPMdAD(:,2)) ) <= ciSig;
sigPMdWO = ( angleDiff(pdsPMdWO,ciPMdWO(:,1)) + angleDiff(pdsPMdWO,ciPMdWO(:,2)) ) <= ciSig;

% Find cells that are tuned in all three epochs
useM1 = find(sigM1BL & sigM1AD & sigM1WO);
usePMd = find(sigPMdBL & sigPMdAD & sigPMdWO);

useCIM1BL = ciM1BL(useM1,:);
useCIPMdBL = ciPMdBL(usePMd,:);
useCIM1AD = ciM1AD(useM1,:);
useCIPMdAD = ciPMdAD(usePMd,:);
useCIM1WO = ciM1WO(useM1,:);
useCIPMdWO = ciPMdWO(usePMd,:);

diffM1_BB = wrapAngle(pdsM1BL(useM1).*(pi/180) - pdsM1BL(useM1).*(pi/180),0).*(180/pi);
diffPMd_BB = wrapAngle(pdsPMdBL(usePMd).*(pi/180) - pdsPMdBL(usePMd).*(pi/180),0).*(180/pi);

diffM1_AB = wrapAngle(pdsM1AD(useM1).*(pi/180) - pdsM1BL(useM1).*(pi/180),0).*(180/pi);
diffPMd_AB = wrapAngle(pdsPMdAD(usePMd).*(pi/180) - pdsPMdBL(usePMd).*(pi/180),0).*(180/pi);

diffM1_WB = wrapAngle(pdsM1WO(useM1).*(pi/180) - pdsM1BL(useM1).*(pi/180),0).*(180/pi);
diffPMd_WB = wrapAngle(pdsPMdWO(usePMd).*(pi/180) - pdsPMdBL(usePMd).*(pi/180),0).*(180/pi);


% figure;
% subplot1(2,1);
% subplot1(1);
% hist(diffM1_WB,10);
% subplot1(2);
% hist(diffPMd_WB,10);
% 
% Plot raw PDs
% figure;
% hold all;
% for i = 1:length(usePMd)
%     plot([0 1 2],[pdsPMdBL(usePMd(i)), pdsPMdAD(usePMd(i)), pdsPMdWO(usePMd(i))],'k','LineWidth',2);
%     plot([0 0],[ciPMdBL(usePMd(i),1) ciPMdBL(usePMd(i),2)],'k','LineWidth',1);
%     plot([1 1],[ciPMdAD(usePMd(i),1) ciPMdAD(usePMd(i),2)],'k','LineWidth',1);
%     plot([2 2],[ciPMdWO(usePMd(i),1) ciPMdWO(usePMd(i),2)],'k','LineWidth',1);
% end
% title('PMd');
% set(gca,'XLim',[-1 3]);

% Plot differences
figure;
subplot1(2,1);
subplot1(1);
hold all;
for i = 1:length(diffM1_BB)
    % mark it as blue if it is significantly different in any epoch
    % red for every epoc
    % check for overlap of CIs
    ad_sig_diff = range_intersection(useCIM1AD(i,:),useCIM1BL(i,:));
    wo_sig_diff = range_intersection(useCIM1WO(i,:),useCIM1BL(i,:));

    if isempty(ad_sig_diff) && isempty(wo_sig_diff);
        usecolor = 'r';
    elseif isempty(ad_sig_diff) || isempty(wo_sig_diff);
        usecolor = 'b';
    else
        usecolor = 'k';
    end
    
    plot([0 1 2],[diffM1_BB(i), diffM1_AB(i), diffM1_WB(i)],'Color',usecolor,'LineWidth',2);
end
text(0.1,80,['A  M1 (N = ' num2str(length(useM1)) ')'],'FontSize',16);

subplot1(2);
hold all;
for i = 1:length(diffPMd_BB)
    % mark it as blue if it is significantly different in any epoch
    % check for overlap of CIs
    ad_sig_diff = range_intersection(useCIPMdAD(i,:),useCIPMdBL(i,:));
    wo_sig_diff = range_intersection(useCIPMdWO(i,:),useCIPMdBL(i,:));
    
    if isempty(ad_sig_diff) && isempty(wo_sig_diff);
        usecolor = 'r';
    elseif isempty(ad_sig_diff) || isempty(wo_sig_diff);
        usecolor = 'b';
    else
        usecolor = 'k';
    end
    
    plot([0 1 2],[diffPMd_BB(i), diffPMd_AB(i), diffPMd_WB(i)],'Color',usecolor,'LineWidth',2);
end
text(0.1,-60,['B  PMd (N = ' num2str(length(usePMd)) ')'],'FontSize',16);


