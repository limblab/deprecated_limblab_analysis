clear;
clc;
close all;

save_dir = 'C:\Users\Matt Perich\Dropbox\lab\embc\Poster\figures';

arrays = {'M1','PMd'};
decoders = {'Position','Velocity','Target'};

plotTasks = {'RT'};
badCutoff = -100;
doDiff = false;
plotShift = 0.2;

if doDiff
    ymin = -0.33;
    ymax = 0.08;
else
    ymin = 0;
    ymax = 1;
end

m1Results = cell(1,length(decoders));

for iDec = 1:length(decoders)
    load('chewie_decoding_results.mat','doFiles','AllTheResults');
    excludeFiles = [1,2,3,8,11,15,16,20];
    
    fileInds = any(cell2mat(cellfun(@(x) strcmpi(doFiles(:,4),x),plotTasks,'UniformOutput',false)),2);
    fileInds(excludeFiles)=0;
    fileVAFs = AllTheResults{1,iDec};
    chewieVAFs = fileVAFs(fileInds,:);
    chewieFiles = doFiles(fileInds,:);
    
    load('mihili_decoding_results.mat','doFiles','AllTheResults');
    excludeFiles = [2,4,8,11];
    
    fileInds = any(cell2mat(cellfun(@(x) strcmpi(doFiles(:,4),x),plotTasks,'UniformOutput',false)),2);
    fileInds(excludeFiles)=0;
    fileVAFs = AllTheResults{1,iDec};
    mihiliVAFs = fileVAFs(fileInds,:);
    mihiliFiles = doFiles(fileInds,:);
    
    m1Results{1,iDec} = [mihiliVAFs; chewieVAFs];
end

arrayFiles{1} = [mihiliFiles; chewieFiles];

% now get the PMd data
load('mihili_decoding_results.mat','doFiles','AllTheResults');
excludeFiles = [2,4,8,11];
fileInds = any(cell2mat(cellfun(@(x) strcmpi(doFiles(:,4),x),plotTasks,'UniformOutput',false)),2);
fileInds(excludeFiles)=0;
pmdResults = cell(1,length(decoders));
for iDec = 1:length(decoders)
    fileVAFs = AllTheResults{2,iDec};
    mihiliVAFs = fileVAFs(fileInds,:);
    mihiliFiles = doFiles(fileInds,:);
    
    pmdResults{1,iDec} = mihiliVAFs;
end

AllTheResults(1,:) = m1Results;
AllTheResults(2,:) = pmdResults;
arrayFiles{2} = mihiliFiles;

load('mihili_decoding_results.mat','blockLabels','numBlocksAD','numBlocksWO','doAbsTime');

%% Need to restructure the results to look like old format
if doAbsTime
    numGroup = 4;
    % just use first array and decoder, they should all be same
    fileVAFs = AllTheResults{1,1};
    
    % get minimum length in AD & WO
    minL_AD = min(cell2mat(cellfun(@(x) length(x),fileVAFs(:,2),'UniformOutput',false)));
    minL_WO = min(cell2mat(cellfun(@(x) length(x),fileVAFs(:,3),'UniformOutput',false)));
    
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
    
    for iDec = 1:length(decoders)
        for iArray = 1:length(arrays)
            doFiles = arrayFiles{iArray};
            
            fileVAFs = AllTheResults{iArray,iDec};
            
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
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs,'UniformOutput',false);
        
        % now find mean/std across files for this condition
        bl_vaf(iArray,iDec) = nanmean(cellfun(@(x) nanmean(x,1),tempVAFs(:,whichBlock)),1);
        bl_vaf_std(iArray,iDec) = nanstd(cellfun(@(x) nanmean(x,1),tempVAFs(:,whichBlock)),1)./sqrt(size(doFiles,1));
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

set(gca,'XTickLabel',arrays,'YLim',[0 1],'FontSize',24);
ylabel('VAF','FontSize',24);
legend(decoders,'FontSize',24);

saveas(gcf,[save_dir '\' 'Decoding_Baseline.png'],'png');
saveas(gcf,[save_dir '\' 'Decoding_Baseline.fig'],'fig');

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
    subplot1(1,length(decoders),'Gap',[0,0],'YTickL','Margin');
    
    doFiles = arrayFiles{iArray};
    
    for iDec = 1:length(decoders)
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        % tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false);
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false);
        
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
        
        tempVAFs = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false);
        
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
    
    titleVec = decoders;
    titleVec{1} = [arrays{iArray} titleVec{1}];
    for iDec = 1:length(decoders)
        subplot1(iDec);
        if iDec == length(decoders)
            plot(0,NaN,'r','LineWidth',2);
            plot(0,NaN,'b','LineWidth',2);
            legend({'Rotation','Force'},'FontSize',24);
        end
        hold all;
        
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
        
        doFiles = arrayFiles{iArray};
        
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
