% use binned position and trial table to build a continuous vector of
% target angle relative to hand

% problem files:
% 4  2014-02-03
% 8  2014-02-18-VR
clear
clc
close all;

%%
root_dirs = {'Mihili','Z:\Mihili_12A3\Matt\';
    'Chewie','Z:\Chewie_8I2\Matt\';
    'MrT','Z:\MrT_9I4\Matt\'};
tt_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

redoAnalysis = true;
rewriteFiles = false;
retrimFiles = false;

numbins = 50; %number of lags for decoder
itiCutoff = 4;
numBlocksAD = 10; % number of chunks to break AD and WO into
numBlocksWO = 6;
foldLength = 90;

kin_array = 'M1'; % only needed for PMd

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...    % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S

dateInds = strcmpi(allFiles(:,1),'Mihili');
doFiles = allFiles(dateInds,:);

epochs = {'BL','AD','WO'};
arrays = {'M1','PMd'};

decoders = {'Position','Velocity','Target'};

symbols = {'o','s','^','d','v','+','p','>','h','.','<','o','s','^','d','v','+','p','>','h','.','<'};

if redoAnalysis
    blockLabels = cell(1,1+numBlocksAD+numBlocksWO);
    blockLabels{1} = 'B';
    sdAD = 0:1/numBlocksAD:1;
    sdWO = 0:1/numBlocksWO:1;
    for iBlock = 1:numBlocksAD
        blockLabels{1+iBlock} = ['A' num2str(iBlock)];
    end
    for iBlock = 1:numBlocksWO
        blockLabels{1+numBlocksAD+iBlock} = ['W' num2str(iBlock)];
    end
    %% Do decoding
    for iArray = 1:length(arrays)
        use_array = arrays{iArray};
        
        % checks directories and files to make sure they exist
        checkDecodingFiles(root_dirs,use_array,doFiles,epochs,kin_array,rewriteFiles)
        
        % now, bin the three data files
        binDataFiles(root_dirs,use_array,doFiles,epochs,rewriteFiles)
        
        % now, make target direction vector and save is new binned data file
        trimBinnedData(root_dirs,tt_dir,use_array,doFiles,epochs,itiCutoff,0.05,retrimFiles);
        
        % Do Decoding
        for iDec = 1:length(decoders)
            
            fileVAFs = cell(size(doFiles,1),length(blockLabels));
            fileR2s = cell(size(doFiles,1),length(blockLabels));
            numTrials = cell(1,length(blockLabels));
            
            % now, build decoder for baseline
            [fileVAFs(:,1),fileR2s(:,1)] = doBaselineDecoding(root_dirs,use_array,doFiles,decoders{iDec},foldLength,numbins);
            % Now, make predictions for AD and calculate VAF
            
            if length(sdAD) == numBlocksAD+1 && length(sdWO) == numBlocksWO+1
                for iBlock = 1:numBlocksAD
                    % AD predictions
                    [fileVAFs(:,1+iBlock), fileR2s(:,1+iBlock)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',[sdAD(iBlock) sdAD(iBlock+1)],decoders{iDec});
                end
                for iBlock = 1:numBlocksWO
                    % Now, make predictions for WO and calculate VAF
                    [fileVAFs(:,1+numBlocksAD+iBlock), fileR2s(:,1+numBlocksAD+iBlock)] = doEpochDecoding(root_dirs,use_array,doFiles,'WO',[sdWO(iBlock) sdWO(iBlock+1)],decoders{iDec});
                end
            else
                error('Things are not lining up here...');
            end
            
            AllTheResults{iArray,iDec} = fileVAFs;
            AllTrialCounts{iArray,iDec} = numTrials;
        end
    end
    
    save('mihili_decoding_results.mat');
else
    load('mihili_decoding_results.mat');
end

%%
save_dir = 'C:\Users\Matt Perich\Dropbox\lab\embc\Poster\figures';
excludeFiles = [];
plotTasks = {'CO'};
badCutoff = -0.2;

%Now that I have ALL THE RESULTS
fileInds = any(cell2mat(cellfun(@(x) strcmpi(doFiles(:,4),x),plotTasks,'UniformOutput',false)),2);
% now exclude some files
fileInds(excludeFiles)=0;

%  Plot, for PMd, the three conditions
ymin = 0;
ymax = 1;

vaf_ff = zeros(length(decoders),length(blockLabels));
vaf_ff_std = zeros(length(decoders),length(blockLabels));
vaf_vr = zeros(length(decoders),length(blockLabels));
vaf_vr_std = zeros(length(decoders),length(blockLabels));

all_vaf_ff = zeros(length(decoders),length(blockLabels),length(arrays));
all_vaf_ff_std = zeros(length(decoders),length(blockLabels),length(arrays));
all_vaf_vr = zeros(length(decoders),length(blockLabels),length(arrays));
all_vaf_vr_std = zeros(length(decoders),length(blockLabels),length(arrays));

for iArray = 1:length(arrays)
    figure;
    subplot1(1,length(decoders),'Gap',[0,0],'YTickL','Margin');
    
    for iDec = 1:length(decoders)
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        % tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false);
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff') & fileInds,:),'UniformOutput',false);
        
        % now find mean/std across files for this condition
        allM = cellfun(@(x) nanmean(x,1),tempVAFs);
        allS = cellfun(@(x) nanmean(x,1),tempVAFs);
        
        allS(allM < badCutoff) = NaN;
        allM(allM < badCutoff) = NaN;
        %allM(any(isnan(allM),2),:) = [];
        
        m = nanmean(allM,1);
        s = nanstd(allS,1)./sqrt(size(allS,1));
        vaf_ff(iDec,:) = m;
        vaf_ff_std(iDec,:) = s;
        
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'vr') & fileInds,:),'UniformOutput',false);
        
        % now find mean/std across files for this condition
        allM = cellfun(@(x) nanmean(x,1),tempVAFs);
        allS = cellfun(@(x) nanmean(x,1),tempVAFs);
        
        allS(allM < badCutoff) = NaN;
        allM(allM < badCutoff) = NaN;
        %allM(any(isnan(allM),2),:) = [];
        
        m = nanmean(allM,1);
        s = nanstd(allS,1)./sqrt(size(allS,1));
        vaf_vr(iDec,:) = m;
        vaf_vr_std(iDec,:) = s;
    end
    
    titleVec = decoders;
    titleVec{1} = [arrays{iArray} titleVec{1}];
    for iDec = 1:length(decoders)
        subplot1(iDec);
        hold all;
        
        for iBlock = 1:length(blockLabels)
            plot(iBlock-1,vaf_vr(iDec,iBlock),'d','LineWidth',2,'Color','r');
            %         plot([0:length(blockLabels)-1;0:length(blockLabels)-1],[vaf_vr(iDec,:)-vaf_vr_std(iDec,:);vaf_vr(iDec,:)+vaf_vr_std(iDec,:)],'LineWidth',2,'Color','r');
            plot(iBlock-1,vaf_ff(iDec,iBlock),'d','LineWidth',2,'Color','b');
            %         plot([0:length(blockLabels)-1;0:length(blockLabels)-1],[vaf_ff(iDec,:)-vaf_ff_std(iDec,:);vaf_ff(iDec,:)+vaf_ff_std(iDec,:)],'LineWidth',2,'Color','b');
        end
        
        axis('tight');
        set(gca,'XTick',0:length(blockLabels)-1,'XTickLabels',blockLabels,'YLim',[ymin ymax],'XLim',[-0.5 length(blockLabels)-0.5],'FontSize',14);
        title(titleVec{iDec},'FontSize',14);
        if iDec==1
            ylabel('VAF','FontSize',14);
        end
    end
    
    all_vaf_vr(:,:,iArray) = vaf_vr;
    all_vaf_ff(:,:,iArray) = vaf_ff;
    all_vaf_vr_std(:,:,iArray) = vaf_vr_std;
    all_vaf_ff_std(:,:,iArray) = vaf_ff_std;
    
    saveas(gcf,[save_dir '\' 'Decoding_' arrays{iArray} '.png'],'png');
    saveas(gcf,[save_dir '\' 'Decoding_' arrays{iArray} '.fig'],'fig');
end

%%
% Find average VAF in baseline of all days for both areas and all decoders
whichBlock = 1;

for iDec = 1:length(decoders)
    for iArray = 1:length(arrays)
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(fileInds,:),'UniformOutput',false);
        
        % now find mean/std across files for this condition
        bl_vaf(iArray,iDec) = nanmean(cellfun(@(x) nanmean(x,1),tempVAFs(:,whichBlock)),1);
        bl_vaf_std(iArray,iDec) = nanstd(cellfun(@(x) nanmean(x,1),tempVAFs(:,whichBlock)),1)./sqrt(size(doFiles,1));
    end
end

figure;
h = barwitherr(bl_vaf_std,bl_vaf,'BarWidth',1);
c=get(h,'Children');
if ~iscell(c)
    c = {c};
end
for i = 1:length(c)
    set(c{i},'CDataMapping','scaled');
end

colormap([0.8 0.25 0.25;0.25 0.8 0.25;0.25 0.25 1])

set(gca,'XTickLabel',arrays,'YLim',[0 1],'FontSize',14);
ylabel('VAF','FontSize',14);
legend(decoders,'FontSize',12);

saveas(gcf,[save_dir '\' 'Decoding_Baseline.png'],'png');
saveas(gcf,[save_dir '\' 'Decoding_Baseline.fig'],'fig');

