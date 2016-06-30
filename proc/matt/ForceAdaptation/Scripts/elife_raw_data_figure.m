clear all;
clc;
close all;

root_dir = 'F:\';
monkey = 'Mihili';
pert = 'FF';
task = 'CO';
array = 'M1';

%%
allFiles = {'MrT','2013-08-19','FF','CO'; ...   % S x
    'MrT','2013-08-20','FF','RT'; ...   % S x
    %'MrT','2013-08-21','FF','CO'; ...   % S x - AD is split in two so use second but don't exclude trials
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
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
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

dateInds = ismember(allFiles(:,1),monkey);
allFiles = allFiles(dateInds,:);

%%
load(fullfile(root_dir,monkey,'Processed','multiday_tracking_wfisi_90.mat'));
tr = tracking.(array);
clear tracking;

%% Population raster
%%
close all;

iFile = 6;
tStart = 820;
tEnd = 837;
binSize = 0.05;

[neur,kin,mt] = loadResults(root_dir,allFiles(iFile,:),'data',{array,'cont','movement_table'},'BL');
[tuning,c] = loadResults(root_dir,allFiles(iFile,:),'tuning',{'tuning','classes'},array,'movement','regression','onpeak');

% find trial onset and peak times for all trials in range
os = mt(mt(:,4) >= tStart & mt(:,4) <= tEnd,4);
ps = mt(mt(:,5) >= tStart & mt(:,5) <= tEnd,5);

pds = tuning(1).pds(:,1);
goodCells = all(c.istuned(:,[1:4]),2);

t_idx = kin.t >= tStart & kin.t < tEnd;
f = kin.force(t_idx,:);
v = kin.vel(t_idx,:);

bins = tStart-binSize/2:binSize:tEnd+binSize/2;

binFR = zeros(length(neur.units),length(bins));
spikes = cell(1,length(neur.units));
for unit = 1:length(neur.units)
    ts = neur.units(unit).ts;
    s_idx = ts > tStart & ts < tEnd;
    n = hist(ts(s_idx),bins);
    
    binFR(unit,:) = n./binSize;
    
    spikes{unit} = ts(s_idx);
end

t = kin.t(t_idx);
clear allBinFR allf allv;

[~,I] = sort(pds);

I = [I(floor(length(I)/2)+6:end); I(1:floor(length(I)/2)-1+6)];

binFR = binFR(I,:);
blBinFR = binFR;
pds = pds(I);
goodCells = goodCells(I);
spikes = spikes(I);

figure;
subplot1(2,1,'Gap',[0.01,0.01]);

subplot1(2);
plot(t,v(:,1),'Color','k','LineWidth',2,'LineStyle','-');
plot(t,v(:,2),'Color','r','LineWidth',2,'LineStyle','-');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[-30,30]);
xlabel('Time (sec)','FontSize',14);
ylabel('Velocity (cm/s)','FontSize',14);
legend({'X','Y'},'FontSize',14);

% now plot neural heat maps
frMin = min(binFR,[],2);
binFR = binFR - repmat(frMin,1,size(binFR,2));

frMax = max(binFR,[],2);
badCells = frMax < 2/binSize; % we want at least one bin where more than one spike occurs, otherwise what's the point?

% frMax = blFRMax;

blBinFR = blBinFR./repmat(frMax,1,size(blBinFR,2));
blBinFR(~goodCells,:) = [];

subplot1(1);
for i = 1:length(os)
    patch([os(i) ps(i) ps(i) os(i)],[1 1 size(blBinFR,1)+1 size(blBinFR,1)+1],[0 1 0]);
end

if 0
    imagesc(bins,1:size(blBinFR,1),blBinFR,[0 1]);
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[1 size(blBinFR,1)]);
    colormap('hot');
else
    for unit = 1:length(spikes)
        plot([spikes{unit}; spikes{unit}],[unit.*ones(size(spikes{unit})); (unit+1).*ones(size(spikes{unit}))],'k-');
    end
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[1 size(blBinFR,1)+1]);
end
%     title('Baseline','FontSize',16);
ylabel('UnitID','FontSize',14);

% subplot1(3);
% plot(pds);
% axis('tight');
% set(gca,'Box','off','TickDir','out','FontSize',14);

% get target angles for each reach that is included
% tuning(1).mt( tuning(1).mt(:,2) > tStart & tuning(1).mt(:,2) <= tEnd)


%% Panel B - Representative waveforms and ISIs, across sessions
close all;

% Mihili
doFiles = [6,7];
% unit = 6;

% Chewie
% doFiles = [5,6];
% useUnits = [26,29,34];

bins = 0:0.001:1000;

allCells = tr{doFiles(1)}.chan(:,doFiles);
goodCells = allCells(all(allCells,2),:);
for unit = 6
    figure;
    subplot1(1,2);
    id = zeros(length(doFiles),2);
    for iFile = 1:length(doFiles)
        neur = loadResults(root_dir,allFiles(doFiles(iFile),:),'data',{array},'BL');

        idx = find(neur.sg(:,1)==floor(goodCells(unit,iFile)) & neur.sg(:,2)==int16(10*(goodCells(unit,iFile)-floor(goodCells(unit,iFile)))));

%         subplot(2,length(doFiles),iFile);
%         hold all;
%         plot(neur.units(idx).wf,'k');
%         set(gca,'XLim',[1,48],'YLim',[-800,800],'Box','off','TickDir','out','FontSize',14);
% 
%         subplot(2,length(doFiles),length(doFiles)+iFile);
%         hold all;
%         [N,X] = hist(diff(neur.units(idx).ts),bins);
%         bar(X,N./max(N),1);
%         set(gca,'XLim',[0,0.3],'YLim',[0 1],'Box','off','TickDir','out','FontSize',14);
        
        id = neur.units(idx).id;
        
        tuning = loadResults(root_dir,allFiles(doFiles(iFile),:),'tuning',{'tuning'},array,'movement','regression','onpeak');
        
        idx = find(tuning(1).sg(:,1)==id(1) & tuning(1).sg(:,2)==id(2));
        mean(tuning(1).r_squared(idx,:))
        % Now, plot the tuning curve for each day
        subplot1(iFile);
        hold all;
        plot(tuning(1).theta.*(180/pi),tuning(1).fr(:,idx),'k.');
        plot((-pi:0.01:pi).*(180/pi),tuning(1).bos(idx,1)+tuning(1).mds(idx,1)*cos((-pi:0.01:pi) - tuning(1).pds(idx,1)),'b','LineWidth',2);
        
        utheta = unique(tuning(1).theta);
        for iDir = 1:length(utheta)
            plot(utheta(iDir).*(180/pi),mean(tuning(1).fr(tuning(1).theta == utheta(iDir),idx)),'bd','LineWidth',3);
        end
        
        axis('tight');
        set(gca,'Box','off','FontSize',14,'TickDir','out','XLim',[-180,180],'YLim',[-2 45],'XTick',[-90,0,90]);
        xlabel('Reach Angle (Deg)','FontSize',14);
        if iFile==1
        ylabel('Firing Rate (Hz)','FontSize',14);
        end
    end
    
end

%% Panel C - Population raster for a day for reaches to all targets, with and without CF
close all;

iFile = 6;
targInds = 1:8; % which two targets to use
binSize = 0.05;
dt = 0.001;
gapSize = 0;

startInd = 3;
endInd = 6;
startOffset = 0.1;
numReaches = 1; % do one to each target

[neur,kin,mt] = loadResults(root_dir,allFiles(iFile,:),'data',{array,'cont','movement_table'},'BL');
[tuning,c] = loadResults(root_dir,allFiles(iFile,:),'tuning',{'tuning','classes'},array,'movement','regression','onpeak');
blsg = neur.sg;

utheta = unique(mt(:,1));
pds = tuning(1).pds(:,1);
goodCells = all(c.istuned(:,1:4),2);

figure;
subplot1(3,2,'Gap',[0.01,0.01]);
allBinFR = []; allf = []; allv = [];
for iTarg = 1:length(targInds)
    idx = find(mt(:,1)==utheta(targInds(iTarg)),numReaches,'last');
    
    
    for iReach = 1:numReaches
        t_idx = kin.t >= mt(idx(iReach),startInd)-startOffset & kin.t < mt(idx(iReach),endInd);
        f = kin.force(t_idx,:);
        v = kin.vel(t_idx,:);
        
        bins = mt(idx(iReach),startInd)-startOffset-binSize/2:binSize:mt(idx(iReach),endInd)+binSize/2;
        
        binFR = zeros(length(neur.units),length(bins));
        for unit = 1:length(neur.units)
            ts = neur.units(unit).ts;
            s_idx = ts > mt(idx(iReach),startInd)-startOffset & ts < mt(idx(iReach),endInd);
            n = hist(ts(s_idx),bins);
            
            binFR(unit,:) = n./binSize;
        end
        
        allBinFR = [allBinFR binFR NaN(size(binFR,1),int16(dt*gapSize/binSize))];
        allf = [allf; f; NaN(gapSize,2)];
        allv = [allv; v; NaN(gapSize,2)];
    end
end

binFR = allBinFR;
f = allf;
v = allv;
t = dt*(0:length(v)-1);
bins = t(1)-startOffset-binSize/2:binSize:t(end)+binSize/2;
clear allBinFR allf allv;

[~,I] = sort(pds);
binFR = binFR(I,:);
blBinFR = binFR;

subplot1(3);
plot(t,v(:,1),'Color','k','LineWidth',2,'LineStyle','-');
plot(t,v(:,2),'Color','k','LineWidth',2,'LineStyle','--');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[-30,30]);

ylabel('Velocity (cm/s)','FontSize',14);

subplot1(5);
plot(t,f(:,1),'Color','k','LineWidth',2,'LineStyle','-');
plot(t,f(:,2),'Color','k','LineWidth',2,'LineStyle','--');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[-3.5,3.5]);

legend({'X','Y'},'FontSize',14);

ylabel('Force (N)','FontSize',14);
xlabel('Time','FontSize',14);

[neur,kin,mt] = loadResults(root_dir,allFiles(iFile,:),'data',{array,'cont','movement_table'},'AD');


allBinFR = []; allf = []; allv = [];
for iTarg = 1:length(targInds)
    idx = find(mt(:,1)==utheta(targInds(iTarg)),numReaches,'last');
    
    
    for iReach = 1:numReaches
        t_idx = kin.t >= mt(idx(iReach),startInd)-startOffset & kin.t < mt(idx(iReach),endInd);
        f = kin.force(t_idx,:);
        v = kin.vel(t_idx,:);
        
        bins = mt(idx(iReach),startInd)-startOffset-binSize/2:binSize:mt(idx(iReach),endInd)+binSize/2;
        
        binFR = zeros(length(neur.units),length(bins));
        for unit = 1:length(blsg)
            n_idx = neur.sg(:,1)==blsg(unit,1) & neur.sg(:,2)==blsg(unit,2);
            
            ts = neur.units(n_idx).ts;
            s_idx = ts > mt(idx(iReach),startInd)-startOffset & ts < mt(idx(iReach),endInd);
            n = hist(ts(s_idx),bins);
            
            binFR(unit,:) = n./binSize;
        end
        
        allBinFR = [allBinFR binFR NaN(size(binFR,1),int16(dt*gapSize/binSize))];
        allf = [allf; f; NaN(gapSize,2)];
        allv = [allv; v; NaN(gapSize,2)];
    end
end

binFR = allBinFR;
f = allf;
v = allv;
t = dt*(0:length(v)-1);
bins = t(1)-startOffset-binSize/2:binSize:t(end)+binSize/2;
clear allBinFR allf allv;

binFR = binFR(I,:);

subplot1(4);
plot(t,v(:,1),'Color','k','LineWidth',2,'LineStyle','-');
plot(t,v(:,2),'Color','k','LineWidth',2,'LineStyle','--');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[-30,30],'YTick',[]);

subplot1(6);
plot(t,f(:,1),'Color','k','LineWidth',2,'LineStyle','-');
plot(t,f(:,2),'Color','k','LineWidth',2,'LineStyle','--');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[-3.5,3.5],'YTick',[]);

xlabel('Time (sec)','FontSize',14);


% now plot neural heat maps
blFRMin = min(blBinFR,[],2);
adFRMin = min(binFR,[],2);
frMin = min([blFRMin adFRMin],[],2);
blBinFR = blBinFR - repmat(frMin,1,size(blBinFR,2));
binFR = binFR - repmat(frMin,1,size(binFR,2));

blFRMax = max(blBinFR,[],2);
adFRMax = max(binFR,[],2);

frMax = max([blFRMax adFRMax],[],2);

% frMax = blFRMax;

blBinFR = blBinFR./repmat(frMax,1,size(blBinFR,2));
blBinFR(~goodCells,:) = [];

subplot1(1);
imagesc(bins,1:size(blBinFR,1),blBinFR,[0 1]);
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[1 size(blBinFR,1)]);
colormap('hot');
title('Baseline','FontSize',16);

% frMax = adFRMax;
binFR = binFR./repmat(frMax,1,size(binFR,2));
binFR(~goodCells,:) = [];

subplot1(2);
imagesc(bins,1:size(binFR,1),binFR,[0 1]);
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',t([1,end]),'YLim',[1 size(binFR,1)],'YTick',[]);
colormap('jet');
title('Adaptation','FontSize',16);


%% Trial by trial raster for a single neuron



%% Panel D -


