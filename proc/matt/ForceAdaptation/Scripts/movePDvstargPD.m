% plot PD with movement tuning against PD with target
%   Note could do any such comparison

clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
% root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\m1_cf_paper_results\';

allFiles = {'MrT','2013-08-19','FF','CO'; ...   % S x
    'MrT','2013-08-20','FF','RT'; ...   % S x
    'MrT','2013-08-21','FF','CO'; ...   % S x - AD is split in two so use second but don't exclude trials
    'MrT','2013-08-22','FF','RT'; ...   % S x
    'MrT','2013-08-23','FF','CO'; ...   % S x
    'MrT','2013-08-30','FF','RT'; ...   % S x
    'MrT','2013-09-03','VR','CO'; ...   % S x
    'MrT','2013-09-04','VR','RT'; ...   % S x
    'MrT','2013-09-05','VR','CO'; ...   % S x
    'MrT','2013-09-06','VR','RT'; ...   % S x
    'MrT','2013-09-09','VR','CO'; ...   % S x
    'MrT','2013-09-10','VR','RT'; ...   % S x
    'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    %'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    %'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...   % 15
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

useArray = 'M1';
classifierBlocks = 1:14;

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

% monkeys = unique(allFiles(:,1));
monkeys = {'all'};

numBL = 1;
numAD = 10;
numWO = 3;


for iMonkey = 1:length(monkeys)
    if strcmpi(monkeys{iMonkey},'all')
        doFiles = allFiles(strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);
    else
        doFiles = allFiles(strcmpi(allFiles(:,1),monkeys{iMonkey}) & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);
    end
    
    anovaVals = [];
    
    for i = 1:length(classifierBlocks)
        % load first tuning
        paramSetName = 'movementFine';
        tuneMethod = 'regression';
        tuneWindow = 'onpeak';
        
        moveSGs = cell(size(doFiles,1),1);
        movePDs = cell(size(doFiles,1),1);
        for iFile = 1:size(doFiles,1)
            % load data
            [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuningMethod,tuningWindow);
            
            sg = t(classifierBlocks(i)).sg;
            tunedCells = sg(all(c.istuned,2),:);
            
            [~,idx] = intersect(sg, tunedCells,'rows');
            
            pds = t(classifierBlocks(i)).pds(:,1);
            
            movePDs{iFile} = pds;
            moveSGs{iFile} = sg;
        end
        
        paramSetName = 'target_fine';
        tuneMethod = 'regression';
        tuneWindow = 'full';
        
        targSGs = cell(size(doFiles,1),1);
        targPDs = cell(size(doFiles,1),1);
        for iFile = 1:size(doFiles,1)
            [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuningMethod,tuningWindow);
            
            sg = t(classifierBlocks(i)).sg;
            tunedCells = sg(all(c.istuned,2),:);
            
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
        dpd = angleDiff(pds(:,1),pds(:,2),false,true);
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
    ymin = 22;
    ymax = 42;
    
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
