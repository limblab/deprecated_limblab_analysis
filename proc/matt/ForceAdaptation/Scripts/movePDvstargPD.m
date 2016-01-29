% plot PD with movement tuning against PD with target
%   Note could do any such comparison

clear
clc
close all;

% load each file and get cell classifications
root_dir = 'F:\';

dataSummary;

useArray = 'M1';
classifierBlocks = 1:12;

switch lower(useArray)
    case 'm1'
        sessionList = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'Chewie'),:);
    case 'pmd'
        sessionList = sessionList(strcmpi(sessionList(:,1),'Mihili') | strcmpi(sessionList(:,1),'MrT'),:);
end

% monkeys = unique(allFiles(:,1));
monkeys = {'all'};
doAbs = true;

numBL = 1;
numAD = 10;
numWO = 1;

for iMonkey = 1:length(monkeys)
    if strcmpi(monkeys{iMonkey},'all')
        doFiles = sessionList(strcmpi(sessionList(:,3),'FF') & strcmpi(sessionList(:,4),'CO'),:);
    else
        doFiles = sessionList(strcmpi(sessionList(:,1),monkeys{iMonkey}) & strcmpi(sessionList(:,3),'FF') & strcmpi(sessionList(:,4),'CO'),:);
    end
    
    anovaVals = [];
    
    for i = 1:length(classifierBlocks)
        % load first tuning
        paramSetName = 'moveFine';
        tuneMethod = 'regression';
        tuneWindow = 'onpeak';
        
        moveSGs = cell(size(doFiles,1),1);
        movePDs = cell(size(doFiles,1),1);
        for iFile = 1:size(doFiles,1)
            % load data
            [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
            
            sg = t(classifierBlocks(i)).sg;
            tunedCells = sg(all(c(end).istuned,2),:);
            
            [~,idx] = intersect(sg, tunedCells,'rows');
            
            pds = t(classifierBlocks(i)).pds(:,1);
            
            movePDs{iFile} = pds;
            moveSGs{iFile} = sg;
        end
        
        paramSetName = 'targFine';
        tuneMethod = 'regression';
        tuneWindow = 'onpeak';
        
        targSGs = cell(size(doFiles,1),1);
        targPDs = cell(size(doFiles,1),1);
        for iFile = 1:size(doFiles,1)
            [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
            
            sg = t(classifierBlocks(i)).sg;
            tunedCells = sg(all(c(end).istuned,2),:);
            
            [~,idx] = intersect(sg, tunedCells,'rows');
            
            pds = t(classifierBlocks(i)).pds(:,1);
            
            targPDs{iFile} = pds;
            targSGs{iFile} = sg;
        end
        
        
        %% combine movement and target
        pds = [];
        for iFile = 1:size(doFiles,1)
            move_pds = movePDs{iFile};
            targ_pds = targPDs{iFile};
            
            [~,idx,idx2] = intersect(moveSGs{iFile},targSGs{iFile},'rows');
            
            pds = [pds; move_pds(idx).*(180/pi) targ_pds(idx2).*(180/pi)];
        end
        
        %%
        
        % fit line relating movement PD to target PD
        [b,~,~,~,stats] = regress(pds(:,2),[ones(size(pds(:,1))) pds(:,1)]);
        
        
        %     plot(pds(:,1),pds(:,2),'b+','LineWidth',2);
        %     plot(pds(:,1),b(1) + b(2)*pds(:,1),'r','LineWidth',3);
        %     set(gca,'FontSize',14,'XLim',[-180 180],'YLim',[-180 180]);
        %     xlabel('Movement Tuning PD','FontSize',14);
        %     if i==1
        %         ylabel('Target Tuning PD','FontSize',14);
        %     end
        %     axis('square');
        %     plot([-180 180],[0 0],'k--','LineWidth',1);
        %     plot([0 0],[-180 180],'k--','LineWidth',1);
        %     plot([-180 180],[-180 180],'b--','LineWidth',1);
        
        %% compute some sort of "difference index"
        dpd = angleDiff(pds(:,1),pds(:,2),false,~doAbs);
        diffInd(i,:) = [mean(dpd) std(dpd)./sqrt(length(dpd))];
        
        % not during BL or WO
        if i > numBL && i <= numBL+numAD
            anovaVals = [anovaVals; dpd, i*ones(size(dpd,1),1)];
        end
        
    end
    
    %%
    % fit a line to the diffInds
    [b,~,~,~,stats] = regress(diffInd(numBL+1:numBL+numAD,1),[ones(numAD,1) (1:numAD)']);
    p = anovan(anovaVals(:,1),anovaVals(:,2));
    ymin = 0;
    ymax = 11;
    
    figure;
    hold all;
    
    plot(numBL+1:numBL+numAD,b(1)+(1:numAD)*b(2),'k--','LineWidth',3);
    legend({['PD=' num2str(b(1)) ' + ' num2str(b(2)) 'F, p=' num2str(stats(3))]});
    
    plot(1:length(diffInd),diffInd(:,1),'bo','LineWidth',2);
    plot(1:length(diffInd),diffInd(:,1),'b-','LineWidth',1);
    for i=1:length(diffInd)
        plot([i,i],[diffInd(i,1)+diffInd(i,2),diffInd(i,1)-diffInd(i,2)],'b-','LineWidth',2);
    end
    
    plot([numBL+0.5,numBL+0.5],[ymin,ymax],'k--','LineWidth',1);
    plot([numBL+numAD+0.5,numBL+numAD+0.5],[ymin,ymax],'k--','LineWidth',1);
    
    set(gca,'XLim',[0 length(diffInd)+1],'XTick',[1,1+numAD/2,1+numAD+numWO/2],'XTickLabel',{'Baseline','Adaptation','Washout'},'YLim',[ymin ymax],'FontSize',14,'TickDir','out');
    ylabel('abs(Diff PD), Degrees','FontSize',14);
    
    % plot the line
    title(['PD Diff Move vs Targ, ANOVA p= ' num2str(p)],'FontSize',14);
    box off;
    
    
end
