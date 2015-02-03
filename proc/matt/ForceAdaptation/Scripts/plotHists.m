clear;
close all;

baseDir = 'C:\Users\Matt Perich\Desktop\lab\data\';

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
classifierBlocks = [1,4,7];

% switch lower(useArray)
%     case 'm1'
%         allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
%     case 'pmd'
%         allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
% end

doMD = true;
if ~doMD
    binSize = 5;
    plotMax = 90;
    plotMult = 180/pi;
else
    binSize = 1;
    plotMax = 20;
    plotMult = 1;
end

usePeriod = 'onpeak';
tuneMethod = 'regression';
coordinates = 'movement';

% separate by waveform width
%   0: don't do
%   1: use cells below median
%   2: use cells above median
doWidthSeparation = 0;

%%
% build parameter struct
params.blocks = classifierBlocks;
params.coordinates = coordinates;
params.period = usePeriod;
params.tunemethod = tuneMethod;
params.array = useArray;
params.binsize = binSize;
params.domd = doMD;
params.dows = doWidthSeparation;


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% useArray = 'M1';
% dateInds = strcmpi(allFiles(:,3),'FF') & (strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie')); % & strcmpi(allFiles(:,4),'CO');
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',allFiles(dateInds,:),'period',usePeriod,'tunemethod',tuneMethod,'array',useArray,'binsize',binSize,'useblocks',4,'plotmax',plotMax);
% 
% set(gca,'YLim',[0 0.3]);
% %
% useArray = 'PMd';
% dateInds = strcmpi(allFiles(:,3),'FF') & (strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT')); % & strcmpi(allFiles(:,4),'CO');
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',allFiles(dateInds,:),'period',usePeriod,'tunemethod',tuneMethod,'array',useArray,'binsize',binSize,'useblocks',4,'plotmax',plotMax);
% set(gca,'YLim',[0 0.3]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Now get the data
% what are we comparing
plotLabels = {'CO','RT'};

useArray = 'M1';

switch lower(useArray)
    case 'm1'
        doFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        doFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

dateInds = strcmpi(doFiles(:,3),'FF') & strcmpi(doFiles(:,4),'CO');
[means1, diff_pds1] = plotPDShiftComparisonHistograms(baseDir,doFiles(dateInds,:),params);

dateInds = strcmpi(doFiles(:,3),'FF') & strcmpi(doFiles(:,4),'RT');
[means2, diff_pds2] = plotPDShiftComparisonHistograms(baseDir,doFiles(dateInds,:),params);


%% Now plot!
figure('Position',[200 200 1280 800]);
hold all;
plot(1,0,'bo','LineWidth',2);
plot(1.1,0,'ro','LineWidth',2);
legend(plotLabels);

for iBlock = 1:length(means2)
    temp2 = means2{iBlock}.*plotMult;
    temp1 = means1{iBlock}.*plotMult;
    
    plot(iBlock,temp1(1,:),'bo','LineWidth',2);
    plot(iBlock+0.1,temp2(1,:),'ro','LineWidth',3);
    plot([iBlock;iBlock],[temp1(1,:)+temp1(2,:);temp1(1,:)-temp1(2,:)],'b','LineWidth',2);
    plot([iBlock+0.1;iBlock+0.1],[temp2(1,:)+temp2(2,:);temp2(1,:)-temp2(2,:)],'r','LineWidth',2);
end


plot([0 length(means2)+1],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
plot([1.5 1.5],[-plotMax plotMax],'k--','LineWidth',1);
plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);


axis([0.3 length(means2)+0.3 -plotMax plotMax]);


set(gca,'XTick',1:length(means2),'XTickLabel',{'Base','Early AD','Mid AD','Late AD','Early WO','Mid WO','Late WO'},'FontSize',14);
if ~doMD
ylabel('Change in PD (deg)','FontSize',16);
else
    ylabel('Change in DOT (deg)','FontSize',16);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
