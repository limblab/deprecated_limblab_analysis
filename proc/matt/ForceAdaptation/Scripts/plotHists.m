clear;
close all;

baseDir = 'C:\Users\Matt Perich\Desktop\lab\data\';
% baseDir = 'C:\Users\Matt Perich\Desktop\lab\data\m1_cf_paper_results\';

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
useBlocks = [1,4,7];

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

doMD = false;

if ~doMD
    binSize = 5;
    plotMax = 90;
    plotMult = 180/pi;
else
    binSize = 1;
    plotMax = 10;
    plotMult = 1;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% useArray = 'M1';
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'tunemethod',tuneMethod,'array',useArray,'binsize',binSize,'useblocks',1,'plotmax',plotMax);
%
% useArray = 'PMd';
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'tunemethod',tuneMethod,'array',useArray,'binsize',binSize,'useblocks',3,'plotmax',plotMax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Now get the data
% what are we comparing
plotLabels = {'Center Out','Random Target'};

usePeriod = 'onpeak';
tuneMethod = 'regression';
targdir = 'movement';

dateInds = strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO');
doFiles = allFiles(dateInds,:);
[targ_means, targ_diff_pds] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',doFiles,'useblocks',useBlocks,'coordinates',targdir,'period',usePeriod,'tunemethod',tuneMethod,'array',useArray,'binsize',binSize,'useblocks',useBlocks,'doMD',doMD);

dateInds = strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'RT');
doFiles = allFiles(dateInds,:);
[move_means, move_diff_pds] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',doFiles,'useblocks',useBlocks,'coordinates',targdir,'period',usePeriod,'tunemethod',tuneMethod,'array',useArray,'binsize',binSize,'useblocks',useBlocks,'doMD',doMD);


%% Now plot!
figure('Position',[200 200 1280 800]);
hold all;
plot(1,0,'bo','LineWidth',2);
plot(1.1,0,'ro','LineWidth',2);
legend(plotLabels);

for iBlock = 1:length(move_means)
    tempMove = move_means{iBlock}.*plotMult;
    tempTarg = targ_means{iBlock}.*plotMult;
    
    plot(iBlock,tempTarg(1,:),'bo','LineWidth',2);
    plot(iBlock+0.1,tempMove(1,:),'ro','LineWidth',3);
    plot([iBlock;iBlock],[tempTarg(1,:)+tempTarg(2,:);tempTarg(1,:)-tempTarg(2,:)],'b','LineWidth',2);
    plot([iBlock+0.1;iBlock+0.1],[tempMove(1,:)+tempMove(2,:);tempMove(1,:)-tempMove(2,:)],'r','LineWidth',2);
end


plot([0 length(move_means)+1],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
plot([1.5 1.5],[-plotMax plotMax],'k--','LineWidth',1);
plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);


axis([0.3 length(move_means)+0.3 -plotMax plotMax]);


set(gca,'XTick',1:length(move_means),'XTickLabel',{'Base','Early AD','Mid AD','Late AD','Early WO','Mid WO','Late WO'},'FontSize',14);
ylabel('Change in PD (deg)','FontSize',16);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
