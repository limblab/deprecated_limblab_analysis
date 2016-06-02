% use binned position and trial table to build a continuous vector of
% target angle relative to hand
clear
clc
close all;

%%
root_dirs = {'Mihili','Z:\Mihili_12A3\Matt\';
    'Chewie','Z:\Chewie_8I2\Matt\';
    'MrT','Z:\MrT_9I4\Matt\'};
tt_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

monkey = 'Mihili';

redoAnalysis = false;
rewriteFiles = false;
retrimFiles = true;

doAbsTime = true;

dupShift = false;

numLags = 10; %number of lags for decoder
itiCutoff = 0;
numBlocksAD = 5; % number of chunks to break AD and WO into
numBlocksWO = 6;
foldLength = 60;
binSize = 0.05;

kin_array = 'M1'; % only needed for PMd

allFiles = { ...
    'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
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

dateInds = strcmpi(allFiles(:,1),monkey);
doFiles = allFiles(dateInds,:);

epochs = {'BL','AD','WO'};

switch lower(monkey)
    case 'chewie'
        arrays = {'M1'};
    case 'mihili'
        arrays = {'M1','PMd'};
end

decoders = {'Position','Velocity','Target'};

symbols = {'o','s','^','d','v','+','p','>','h','.','<','o','s','^','d','v','+','p','>','h','.','<'};

if redoAnalysis
    
    if ~doAbsTime
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
    end
    
    %% Do decoding
    for iArray = 1:length(arrays)
        use_array = arrays{iArray};
        
        % checks directories and files to make sure they exist
        checkDecodingFiles(root_dirs,use_array,doFiles,epochs,kin_array,rewriteFiles)
        
        % now, bin the three data files
        binDataFiles(root_dirs,use_array,doFiles,epochs,rewriteFiles)
        
        % now, make target direction vector and save is new binned data file
        trimBinnedData(root_dirs,tt_dir,use_array,doFiles,epochs,itiCutoff,binSize,numLags,dupShift,retrimFiles);
        
        if dupShift
            numLags = 1;
        end
        % Do Decoding
        for iDec = 1:length(decoders)
            
            if doAbsTime
                fileVAFs = cell(size(doFiles,1),length(epochs));
                fileR2s = cell(size(doFiles,1),length(epochs));
                fileFRs = cell(size(doFiles,1),length(epochs));
                
                % now, build decoder for baseline
                [fileVAFs(:,1),fileR2s(:,1),fileFRs(:,1)] = doBaselineDecoding(root_dirs,use_array,doFiles,decoders{iDec},foldLength,numLags);
                % AD predictions
                [fileVAFs(:,2), fileR2s(:,2), fileFRs(:,2)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',20,decoders{iDec});
                % Now, make predictions for WO and calculate VAF
                [fileVAFs(:,3), fileR2s(:,3)] = doEpochDecoding(root_dirs,use_array,doFiles,'WO',20,decoders{iDec});
                
            else
                if length(sdAD) == minL_AD+1 && length(sdWO) == minL_WO+1
                    for iBlock = 1:minL_AD
                        % AD predictions
                        [fileVAFs(:,1+iBlock), fileR2s(:,1+iBlock), fileFRs(:,1+iBlock)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',[sdAD(iBlock) sdAD(iBlock+1)],decoders{iDec});
                    end
                    for iBlock = 1:3 %numBlocksWO
                        % Now, make predictions for WO and calculate VAF
                        [fileVAFs(:,1+minL_AD+iBlock), fileR2s(:,1+minL_AD+iBlock), fileFRs(:,1+minL_AD+iBlock)] = doEpochDecoding(root_dirs,use_array,doFiles,'WO',[sdWO(iBlock) sdWO(iBlock+1)],decoders{iDec});
                    end
                else
                    error('Things are not lining up here...');
                end
            end
            AllTheResults{iArray,iDec} = fileVAFs;
            AllTheResultsR2{iArray,iDec} = fileR2s;
            AllTheFR{iArray,iDec} = fileFRs;
        end
    end
    
    save([lower(monkey) '_decoding_results.mat']);
else
    load([lower(monkey) '_decoding_results.mat']);
end

% AllTheResults = AllTheResultsR2;
%%
save_dir = 'C:\Users\Matt Perich\Dropbox\lab\embc\Poster\figures';
% worst files: M1,Vel: 5,9
%            PMd, Vel: 4,12
% ORIGINAL: excludeFiles = [4,5,11];
% NEW: excludeFiles = [2,8,11,12];
switch lower(monkey)
    case 'mihili'
        excludeFiles = [2,4,8,11];
    case 'chewie'
        % 1,2,20 are just short
        excludeFiles = [1,2,3,8,11,15,16,20];
end

plotDecoders = [1,2,3];
plotTasks = {'CO'};
badCutoff = -100;
doDiff = false;
plotShift = 0.2;

if doDiff
    ymin = -0.35;
    ymax = 0.1;
else
    ymin = 0.3;
    ymax = 0.8;
end

%Now that I have ALL THE RESULTS
fileInds = any(cell2mat(cellfun(@(x) strcmpi(doFiles(:,4),x),plotTasks,'UniformOutput',false)),2);
% now exclude some files
fileInds(excludeFiles)=0;

%% Need to restructure the results to look like old format
if 0%doAbsTime
    numGroup = 5;
    % just use first array and decoder, they should all be same
    fileVAFs = AllTheResults{1,1};
    
    % get minimum length in AD & WO
    minL_AD = min(cell2mat(cellfun(@(x) length(x),fileVAFs(fileInds,2),'UniformOutput',false)));
    minL_WO = min(cell2mat(cellfun(@(x) length(x),fileVAFs(fileInds,3),'UniformOutput',false)));
    
    numBlocksAD = floor(minL_AD/numGroup);
    numBlocksWO = floor(minL_WO/numGroup);
    
    blockLabels = cell(1,1+numBlocksAD+numBlocksWO);
    blockLabels{1} = 'B';
    for iBlock = 1:numBlocksAD
        blockLabels{1+iBlock} = ['A' num2str(iBlock)];
    end
    for iBlock = 1:numBlocksWO
        blockLabels{1+numBlocksAD+iBlock} = ['W' num2str(iBlock)];
    end
    
    doFiles = doFiles(fileInds,:);
    
    for iDec = 1:length(decoders)
        for iArray = 1:length(arrays)
            fileVAFs = AllTheResults{iArray,iDec};
            fileVAFs = fileVAFs(fileInds,:);
            
            outVAFs = cell(size(fileVAFs,1),2);
            % cycle through files and find the minimum length for AD
            for iFile = 1:size(fileVAFs,1)
                getVAFs = fileVAFs{iFile,2};
                getVAFs = getVAFs(1:minL_AD,:);
                
                newVAFs_AD = cell(1,size(getVAFs,1));
                for j = 1:size(getVAFs,1)
                    newVAFs_AD{j} = getVAFs(j,:);
                end
                
                getVAFs = fileVAFs{iFile,3};
                getVAFs = getVAFs(1:minL_WO,:);
                
                newVAFs_WO = cell(1,size(getVAFs,1));
                for j = 1:size(getVAFs,1)
                    newVAFs_WO{j} = getVAFs(j,:);
                end
                
                outVAFs{iFile,1} = newVAFs_AD;
                outVAFs{iFile,2} = newVAFs_WO;
            end
            
            finalVAFs = cell(size(fileVAFs,1)*numGroup,1+numBlocksWO+numBlocksAD);
            
            count = 0;
            for iFile = 1:size(fileVAFs,1)
                for j = 1:numGroup
                    count = count + 1;
                    finalVAFs(count,1) = fileVAFs(iFile,1);
                end
            end
            finalFiles = cell(size(fileVAFs,1)*numGroup,4);
            
            for iBlock = 1:numBlocksAD
                clear newVAFs;
                count = 0;
                for iFile = 1:size(fileVAFs,1)
                    temp = outVAFs{iFile,1};
                    for j = 1:numGroup
                        count = count + 1;
                        newVAFs(count,1) = temp((iBlock-1)*numGroup+j);
                        finalFiles(count,:) = doFiles(iFile,:);
                    end
                end
                finalVAFs(:,iBlock+1) = newVAFs;
            end
            
            for iBlock = 1:numBlocksWO
                clear newVAFs;
                count = 0;
                for iFile = 1:size(fileVAFs,1)
                    temp = outVAFs{iFile,2};
                    for j = 1:numGroup
                        count = count + 1;
                        newVAFs(count,1) = temp((iBlock-1)*numGroup+j);
                    end
                end
                finalVAFs(:,1+iBlock+numBlocksAD) = newVAFs;
            end
            
            AllTheResults{iArray,iDec} = finalVAFs;
        end
    end
    
    fileInds = ones(size(finalVAFs,1),1);
    doFiles = finalFiles;
else
    numGroup = 1;
end

%%
% Find average VAF in baseline of all days for both areas and all decoders
whichBlock = 1;

for iDec = 1:length(decoders)
    for iArray = 1:length(arrays)
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(fileInds,:),'UniformOutput',false);
        idx = 1:numGroup:size(tempVAFs,1);
        % now find mean/std across files for this condition
        bl_vaf(iArray,iDec) = nanmean(cellfun(@(x) nanmean(x,1),tempVAFs(idx,whichBlock)),1);
        bl_vaf_std(iArray,iDec) = nanstd(cellfun(@(x) nanmean(x,1),tempVAFs(idx,whichBlock)),1)./sqrt(size(doFiles,1)/numGroup);
    end
end

figure('Position',[200 200 800 600]);
h = barwitherr(bl_vaf_std,bl_vaf,'BarWidth',1);
c=get(h,'Children');
if ~iscell(c)
    c = {c};
end
for i = 1:length(c)
    set(c{i},'CDataMapping','scaled');
end

colormap([0.8 0.25 0.25;0.25 0.8 0.25;0.25 0.25 1])

set(gca,'XTickLabel',arrays,'YLim',[0 1],'FontSize',24,'TickDir','out');
box off;
ylabel('VAF','FontSize',24);
legend(decoders,'FontSize',24);

saveas(gcf,[save_dir '\' 'Decoding_Baseline.png'],'png');
saveas(gcf,[save_dir '\' 'Decoding_Baseline.fig'],'fig');

%%
figure('Position',[200 200 800 600]);
h = barwitherr([bl_co_std;bl_rt_std],[bl_co;bl_rt],'BarWidth',1);
c=get(h,'Children');
if ~iscell(c)
    c = {c};
end
for i = 1:length(c)
    set(c{i},'CDataMapping','scaled');
end

colormap([0.8 0.25 0.25;0.25 0.8 0.25;0.25 0.25 1])

set(gca,'XTickLabel',{'CO','RT'},'YLim',[0 1],'FontSize',24,'TickDir','out');
box off;
ylabel('VAF','FontSize',24);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT THE DECODERS FOR EACH AREA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vaf_ff = zeros(length(decoders),length(blockLabels));
vaf_ff_std = zeros(length(decoders),length(blockLabels));
vaf_vr = zeros(length(decoders),length(blockLabels));
vaf_vr_std = zeros(length(decoders),length(blockLabels));

all_vaf_ff = zeros(length(decoders),length(blockLabels),length(arrays));
all_vaf_ff_std = zeros(length(decoders),length(blockLabels),length(arrays));
all_vaf_vr = zeros(length(decoders),length(blockLabels),length(arrays));
all_vaf_vr_std = zeros(length(decoders),length(blockLabels),length(arrays));

for iArray = 1:length(arrays)
    figure('Position',[0 0 1600 1200]);
    subplot1(1,length(plotDecoders),'Gap',[0,0],'YTickL','Margin');
    
    for iDec = 1:length(decoders)
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        % tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false);
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff') & fileInds,:),'UniformOutput',false);
        
        % now find mean/std across files for this condition
        allM = cellfun(@(x) nanmean(x,1),tempVAFs);
        if doDiff
            allM(:,2:end) = allM(:,2:end) - repmat(allM(:,1),1,size(allM,2)-1);
        else
            allM(allM < badCutoff) = NaN;
            %allM(any(isnan(allM),2),:) = [];
        end
        
        m = nanmean(allM,1);
        s = nanstd(allM,1)./sqrt(size(allM,1));
        
        if doDiff
            m(1) = 0;
        end
        
        vaf_ff(iDec,:) = m;
        vaf_ff_std(iDec,:) = s;
        %         vaf_ff(iDec,:) = [m(1) fliplr(m(2:6)) fliplr(m(7:8))];
        %         vaf_ff_std(iDec,:) = [s(1) fliplr(s(2:6)) fliplr(s(7:8))];
        
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'vr') & fileInds,:),'UniformOutput',false);
        
        % now find mean/std across files for this condition
        allM = cellfun(@(x) nanmean(x,1),tempVAFs);
        if doDiff
            allM(:,2:end) = allM(:,2:end) - repmat(allM(:,1),1,size(allM,2)-1);
        else
            allM(allM < badCutoff) = NaN;
            %allM(any(isnan(allM),2),:) = [];
        end
        
        m = nanmean(allM,1);
        s = nanstd(allM,1)./sqrt(size(allM,1));
        
        if doDiff
            m(1) = 0;
        end
        
        vaf_vr(iDec,:) = m;
        vaf_vr_std(iDec,:) = s;
        % vaf_vr(iDec,:) = [m(1) fliplr(m(2:6)) fliplr(m(7:8))];
        % vaf_vr_std(iDec,:) = [s(1) fliplr(s(2:6)) fliplr(s(7:8))];
    end
    
    titleVec = decoders(plotDecoders);
    titleVec{1} = [arrays{iArray} titleVec{1}];
    for iDec = 1:length(plotDecoders)
        subplot1(iDec);
        if iDec == length(plotDecoders)
            plot(0,NaN,'r','LineWidth',2);
            plot(0,NaN,'b','LineWidth',2);
            legend({'Rotation','Force'},'FontSize',24);
        end
        hold all;
        
        for iBlock = 1:length(blockLabels)
            plot(iBlock-1,vaf_vr(plotDecoders(iDec),iBlock),'d','LineWidth',2,'Color','r');
            vals = [vaf_vr(plotDecoders(iDec),:)-vaf_vr_std(plotDecoders(iDec),:); ...
                vaf_vr(plotDecoders(iDec),:)+vaf_vr_std(plotDecoders(iDec),:)];
            plot([0:length(blockLabels)-1;0:length(blockLabels)-1],vals,'LineWidth',2,'Color','r');
            
            plot(plotShift+iBlock-1,vaf_ff(plotDecoders(iDec),iBlock),'d','LineWidth',2,'Color','b');
            vals = [vaf_ff(plotDecoders(iDec),:)-vaf_ff_std(plotDecoders(iDec),:); ...
                vaf_ff(plotDecoders(iDec),:)+vaf_ff_std(plotDecoders(iDec),:)];
            plot([plotShift+(0:length(blockLabels)-1);plotShift+(0:length(blockLabels)-1)],vals,'LineWidth',2,'Color','b');
        end
        
        axis('tight');
        set(gca,'XTick',[0,(numBlocksAD+1)/2,numBlocksAD+(numBlocksWO+1)/2],'XTickLabels',{'Baseline','Adaptation','Washout'},'YLim',[ymin ymax],'XLim',[-0.5 length(blockLabels)-0.5],'FontSize',24,'TickDir','out');
        title(titleVec{iDec},'FontSize',24);
        if iDec==1
            ylabel('VAF','FontSize',24);
        end
        box off;
        V=axis;
        plot([0.5,0.5],V(3:4),'k--','LineWidth',1);
        plot([0.5+numBlocksAD,0.5+numBlocksAD],V(3:4),'k--','LineWidth',1);
    end
    
    all_vaf_vr(:,:,iArray) = vaf_vr;
    all_vaf_ff(:,:,iArray) = vaf_ff;
    all_vaf_vr_std(:,:,iArray) = vaf_vr_std;
    all_vaf_ff_std(:,:,iArray) = vaf_ff_std;
    
    
    if doDiff
        fn = ['Decoding_' arrays{iArray} '_diff'];
    else
        fn = ['Decoding_' arrays{iArray}];
    end
    saveas(gcf,[save_dir '\' fn '.png'],'png');
    saveas(gcf,[save_dir '\' fn '.fig'],'fig');
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT THE DECODERS BY AREA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iDec = 1:length(decoders)
    figure('Position',[0 0 1300 1200]);
    subplot1(1,length(arrays),'Gap',[0,0],'YTickL','Margin');
    
    titleVec = arrays;
    titleVec{1} = [decoders{iDec} titleVec{1}];
    
    for iArray = 1:length(arrays)
        subplot1(iArray);
        hold all;
        
        if iArray == length(arrays)
            plot(0,NaN,'r','LineWidth',2);
            plot(0,NaN,'b','LineWidth',2);
            legend({'Rotation','Force'},'FontSize',24);
        end
        
        vaf_vr = squeeze(all_vaf_vr(:,:,iArray));
        vaf_vr_std = squeeze(all_vaf_vr_std(:,:,iArray));
        vaf_ff = squeeze(all_vaf_ff(:,:,iArray));
        vaf_ff_std = squeeze(all_vaf_ff_std(:,:,iArray));
        
        for iBlock = 1:length(blockLabels)
            plot(iBlock-1,vaf_vr(iDec,iBlock),'d','LineWidth',2,'Color','r');
            vals = [vaf_vr(iDec,:)-vaf_vr_std(iDec,:); ...
                vaf_vr(iDec,:)+vaf_vr_std(iDec,:)];
            plot([0:length(blockLabels)-1;0:length(blockLabels)-1],vals,'LineWidth',2,'Color','r');
            
            plot(plotShift+iBlock-1,vaf_ff(iDec,iBlock),'d','LineWidth',2,'Color','b');
            vals = [vaf_ff(iDec,:)-vaf_ff_std(iDec,:); ...
                vaf_ff(iDec,:)+vaf_ff_std(iDec,:)];
            plot([plotShift+(0:length(blockLabels)-1);plotShift+(0:length(blockLabels)-1)],vals,'LineWidth',2,'Color','b');
        end
        
        axis('tight');
        set(gca,'XTick',[0,(numBlocksAD+1)/2,numBlocksAD+(numBlocksWO+1)/2],'XTickLabels',{'Baseline','Adaptation','Washout'},'YLim',[ymin ymax],'XLim',[-0.5 length(blockLabels)-0.5],'FontSize',24,'TickDir','out');
        title(titleVec{iArray},'FontSize',24);
        if iArray==1
            ylabel('VAF','FontSize',24);
        end
        box off;
        V=axis;
        plot([0.5,0.5],V(3:4),'k--','LineWidth',1);
        plot([0.5+numBlocksAD,0.5+numBlocksAD],V(3:4),'k--','LineWidth',1);
    end
    
    all_vaf_vr(:,:,iArray) = vaf_vr;
    all_vaf_ff(:,:,iArray) = vaf_ff;
    all_vaf_vr_std(:,:,iArray) = vaf_vr_std;
    all_vaf_ff_std(:,:,iArray) = vaf_ff_std;
    
    
    if doDiff
        fn = ['Decoding_' decoders{iDec} '_diff'];
    else
        fn = ['Decoding_' decoders{iDec}];
    end
    saveas(gcf,[save_dir '\' fn '.png'],'png');
    saveas(gcf,[save_dir '\' fn '.fig'],'fig');
end


% %%
% % Plot change in VAF in WO as a function of change in FR of population
% woBlocks = [7,8,9];
% iDec = 2;
%
% figure('Position',[0 0 1300 1200]);
% subplot1(1,length(arrays),'Gap',[0,0],'YTickL','Margin');
%
% titleVec = arrays;
% titleVec{1} = [decoders{iDec} titleVec{1}];
%
% for iArray = 1:length(arrays)
%     subplot1(iArray);
%     hold all;
%
%     vaf_vr = squeeze(all_vaf_vr(:,:,iArray));
%     vaf_vr_std = squeeze(all_vaf_vr_std(:,:,iArray));
%     vaf_ff = squeeze(all_vaf_ff(:,:,iArray));
%     vaf_ff_std = squeeze(all_vaf_ff_std(:,:,iArray));
%
%     fileFRs = AllTheFR{iArray,iDec};
%     for iFile = 1:size(fileFRs,1)
%         for iBlock = 1:size(fileFRs,2)
%             temp = fileFRs{iFile,1};
%             bl_sg = temp{1};
%             bl_fr = temp{2};
%             temp = fileFRs{iFile,iBlock};
%             wo_sg = temp{1};
%             wo_fr = temp{2};
%
%             [~,Iwo,Ibl] = intersect(wo_sg,bl_sg,'rows');
%
%             dfr{iFile,iBlock} = abs(wo_fr(Iwo)-bl_fr(Ibl));
%         end
%     end
%
%
%     tempFRs = cell2mat(cellfun(@(x) nanmean(x,2),dfr(fileInds,:),'UniformOutput',false));
%
%     tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(fileInds,:),'UniformOutput',false);
%     allM = cellfun(@(x) nanmean(x,1),tempVAFs);
%     allM(:,2:end) = abs(allM(:,2:end) - repmat(allM(:,1),1,size(allM,2)-1));
%
%     temp=[];
%     for iBlock = 1:length(woBlocks)
%         plot(tempFRs(:,woBlocks(iBlock)),allM(:,woBlocks(iBlock)),'d');
%         temp = [temp;tempFRs(:,woBlocks(iBlock)),allM(:,woBlocks(iBlock))];
%     end
%
% end

