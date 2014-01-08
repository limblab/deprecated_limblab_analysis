clear;
close all;

baseDir = 'Z:\MrT_9I4\Matt\ProcessedData';
outDir = 'C:\Users\Matt Perich\Dropbox\tcmc_talk\figure_report';
usePeriod = 'initial';
useArray = 'PMd';

binSize = 5;

plotMax = 90;

% useDates = {'2013-10-11','VR','RT','early','1VRl'; ...
%             '2013-10-11','VR','RT','middle1','2VRl'; ...
%             '2013-10-11','VR','RT','middle2','3VRl'
%             '2013-10-11','VR','RT','late','4VRl'};
% [VRm_means_bl,VRm_means_ad] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
% useDates = {'2013-10-11','VR','RT','targearly','1VRl'; ...
%             '2013-10-11','VR','RT','targmiddle1','2VRl'; ...
%             '2013-10-11','VR','RT','targmiddle2','3VRl'
%             '2013-10-11','VR','RT','targlate','4VRl'};
% [VRt_means_bl,VRt_means_ad] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
% useDates = {'2013-10-11','VR','RT','early','1early'; ...
%     '2013-10-11','VR','RT','late','5late'};
% [~, ~, VRm_means_wo] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
% useDates = {'2013-10-11','VR','RT','targearly','1early'; ...
%     '2013-10-11','VR','RT','targlate','5late'};
% [~, ~, VRt_means_wo] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
% 
% 
% figure('Position',[200 200 1280 800]);
% hold all;
% plot(0,0,'bo','LineWidth',2);
% plot(0.1,0,'ro','LineWidth',2);
% legend({'Curl Field','Visual Rotation'});
% plot(1.1:4.1,VRm_means_ad(1,:),'ro','LineWidth',3);
% plot([1.1:4.1;1.1:4.1],[VRm_means_ad(1,:)+VRm_means_ad(2,:);VRm_means_ad(1,:)-VRm_means_ad(2,:)],'r','LineWidth',2);
% 
% plot(5.1:6.1,VRm_means_wo(1,:),'ro','LineWidth',3);
% plot([5.1:6.1;5.1:6.1],[VRm_means_wo(1,:)+VRm_means_wo(2,:);VRm_means_wo(1,:)-VRm_means_wo(2,:)],'r','LineWidth',2);
% 
% plot([-1 6],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
% plot([0.5 0.5],[-plotMax plotMax],'k--','LineWidth',1);
% plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);
% 
% if doAbsMean
%     axis([-0.3 6.3 -5 plotMax]);
% else
%     axis([-0.3 6.3 -plotMax plotMax]);
% end
% 
% set(gca,'XTick',[0 1 2 3 4 5 6],'XTickLabel',{'Base','Early','Mid 1','Mid 2','Late','Early Wash', 'Late Wash'},'FontSize',14);
% 
% title('Movement','FontSize',16);
% ylabel('Change in PD (deg)','FontSize',16);
% 
% figure('Position',[200 200 1280 800]);
% hold all;
% plot(0,0,'bo','LineWidth',2);
% plot(0.1,0,'ro','LineWidth',2);
% plot(1.1:4.1,VRt_means_ad(1,:),'ro','LineWidth',3);
% plot([1.1:4.1;1.1:4.1],[VRt_means_ad(1,:)+VRt_means_ad(2,:);VRt_means_ad(1,:)-VRt_means_ad(2,:)],'r','LineWidth',2);
% 
% plot(5.1:6.1,VRt_means_wo(1,:),'ro','LineWidth',3);
% plot([5.1:6.1;5.1:6.1],[VRt_means_wo(1,:)+VRt_means_wo(2,:);VRt_means_wo(1,:)-VRt_means_wo(2,:)],'r','LineWidth',2);
% 
% plot([-1 6],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
% plot([0.5 0.5],[-plotMax plotMax],'k--','LineWidth',1);
% plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);
% 
% if doAbsMean
%     axis([-0.3 6.3 -5 plotMax]);
% else
%     axis([-0.3 6.3 -plotMax plotMax]);
% end
% 
% set(gca,'XTick',[0 1 2 3 4 5 6],'XTickLabel',{'Base','Early','Mid 1','Mid 2','Late','Early Wash', 'Late Wash'},'FontSize',14);
% title('Target','FontSize',16);
% 
% 











% make plots showing percentage of adapting cells in early vs late
useDates = {'2013-08-20','FF','RT','early','1FFe'; ...
    '2013-08-22','FF','RT','early','1FFe'; ...
    '2013-08-30','FF','RT','early','1FFe'; ...
    '2013-09-04','VR','RT','early','2VRe'; ...
    '2013-09-06','VR','RT','early','2VRe'; ...
    '2013-09-10','VR','RT','early','2VRe'; ...
    '2013-08-20','FF','RT','late','3FFl'; ...
    '2013-08-22','FF','RT','late','3FFl'; ...
    '2013-08-30','FF','RT','late','3FFl'; ...
    '2013-09-04','VR','RT','late','4VRl'; ...
    '2013-09-06','VR','RT','late','4VRl'; ...
    '2013-09-10','VR','RT','late','4VRl'};
[ap,np] = plotAdaptingCellComparison('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray);

close all;

xInds = [1, 1.1, 1.22, 1.32];
figure('Position',[200 200 800 600]);
hold all;

colors = {'b','r','b','r'};
for i = 1:length(xInds)
    temp = nan(length(xInds),2);
    temp(i,1) = ap(i);
    temp(i,2) = np(i);
    h = bar(xInds,temp,0.8,'stacked');
    
    set(get(h(1),'Children'),'FaceColor',colors{i},'EdgeColor',colors{i},'LineWidth',6);
    set(get(h(2),'Children'),'FaceColor','w','EdgeColor',colors{i},'LineWidth',6);
end

axis('tight');
set(gca,'XTick',xInds,'XTickLabel',{'CF Early','VR Early','CF Late','VR Late'},'FontSize',14);
title('Movement','FontSize',16);
ylabel('Percent of Adapting Cells','FontSize',14);


% make plots showing percentage of adapting cells in early vs late
useDates = {'2013-08-20','FF','RT','targearly','1FFe'; ...
    '2013-08-22','FF','RT','targearly','1FFe'; ...
    '2013-08-30','FF','RT','targearly','1FFe'; ...
    '2013-09-04','VR','RT','targearly','2VRe'; ...
    '2013-09-06','VR','RT','targearly','2VRe'; ...
    '2013-09-10','VR','RT','targearly','2VRe'; ...
    '2013-08-20','FF','RT','targlate','3FFl'; ...
    '2013-08-22','FF','RT','targlate','3FFl'; ...
    '2013-08-30','FF','RT','targlate','3FFl'; ...
    '2013-09-04','VR','RT','targlate','4VRl'; ...
    '2013-09-06','VR','RT','targlate','4VRl'; ...
    '2013-09-10','VR','RT','targlate','4VRl'};
[ap,np] = plotAdaptingCellComparison('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray);

close all;

xInds = [1, 1.1, 1.22, 1.32];
figure('Position',[200 200 800 600]);
hold all;

colors = {'b','r','b','r'};
for i = 1:length(xInds)
    temp = nan(length(xInds),2);
    temp(i,1) = ap(i);
    temp(i,2) = np(i);
    h = bar(xInds,temp,0.8,'stacked');
    
    set(get(h(1),'Children'),'FaceColor',colors{i},'EdgeColor',colors{i},'LineWidth',6);
    set(get(h(2),'Children'),'FaceColor','w','EdgeColor',colors{i},'LineWidth',6);
end

axis('tight');
set(gca,'XTick',xInds,'XTickLabel',{'CF Early','VR Early','CF Late','VR Late'},'FontSize',14);
title('Target','FontSize',16);
ylabel('Percent of Adapting Cells','FontSize',14);






% Mr T time change code
n = 'all_VRm';
useDates = {'2013-09-04','VR','RT','early','1early'; ...
    '2013-09-06','VR','RT','early','1early'; ...
    '2013-09-10','VR','RT','early','1early'; ...
    '2013-09-04','VR','RT','middle1','2middle1'; ...
    '2013-09-06','VR','RT','middle1','2middle1'; ...
    '2013-09-10','VR','RT','middle1','2middle1'; ...
    '2013-09-04','VR','RT','middle2','3middle2'; ...
    '2013-09-06','VR','RT','middle2','3middle2'; ...
    '2013-09-10','VR','RT','middle2','3middle2'; ...
    '2013-09-04','VR','RT','late','5late'; ...
    '2013-09-06','VR','RT','late','5late'; ...
    '2013-09-10','VR','RT','late','5late'};
[VRm_means_bl,VRm_means_ad] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);

n = 'all_FFm';
useDates = {'2013-08-20','FF','RT','early','1early'; ...
    '2013-08-22','FF','RT','early','1early'; ...
    '2013-08-30','FF','RT','early','1early'; ...
    '2013-08-20','FF','RT','middle1','2middle1'; ...
    '2013-08-22','FF','RT','middle1','2middle1'; ...
    '2013-08-30','FF','RT','middle1','2middle1'; ...
    '2013-08-20','FF','RT','middle2','3middle2'; ...
    '2013-08-22','FF','RT','middle2','3middle2'; ...
    '2013-08-30','FF','RT','middle2','3middle2'; ...
    '2013-08-20','FF','RT','late','5late'; ...
    '2013-08-22','FF','RT','late','5late'; ...
    '2013-08-30','FF','RT','late','5late'};
[FFm_means_bl,FFm_means_ad] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);


n = 'all_VRt';
useDates = {'2013-09-04','VR','RT','targearly','1early'; ...
    '2013-09-06','VR','RT','targearly','1early'; ...
    '2013-09-10','VR','RT','targearly','1early'; ...
    '2013-09-04','VR','RT','targmiddle1','2middle1'; ...
    '2013-09-06','VR','RT','targmiddle1','2middle1'; ...
    '2013-09-10','VR','RT','targmiddle1','2middle1'; ...
    '2013-09-04','VR','RT','targmiddle2','3middle2'; ...
    '2013-09-06','VR','RT','targmiddle2','3middle2'; ...
    '2013-09-10','VR','RT','targmiddle2','3middle2'; ...
    '2013-09-04','VR','RT','targlate','5late'; ...
    '2013-09-06','VR','RT','targlate','5late'; ...
    '2013-09-10','VR','RT','targlate','5late'};
[VRt_means_bl,VRt_means_ad] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);


n = 'all_FFt';
useDates = {'2013-08-20','FF','RT','targearly','1early'; ...
    '2013-08-22','FF','RT','targearly','1early'; ...
    '2013-08-30','FF','RT','targearly','1early'; ...
    '2013-08-20','FF','RT','targmiddle1','2middle1'; ...
    '2013-08-22','FF','RT','targmiddle1','2middle1'; ...
    '2013-08-30','FF','RT','targmiddle1','2middle1'; ...
    '2013-08-20','FF','RT','targmiddle2','3middle2'; ...
    '2013-08-22','FF','RT','targmiddle2','3middle2'; ...
    '2013-08-30','FF','RT','targmiddle2','3middle2'; ...
    '2013-08-20','FF','RT','targlate','5late'; ...
    '2013-08-22','FF','RT','targlate','5late'; ...
    '2013-08-30','FF','RT','targlate','5late'};
[FFt_means_bl,FFt_means_ad] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);

n = 'all_FFt_wo';
useDates = {'2013-08-20','FF','RT','targearly2','1early'; ...
    '2013-08-22','FF','RT','targearly2','1early'; ...
    '2013-08-30','FF','RT','targearly2','1early'; ...
    '2013-08-20','FF','RT','targlate2','5late'; ...
    '2013-08-22','FF','RT','targlate2','5late'; ...
    '2013-08-30','FF','RT','targlate2','5late'};
[~, ~, FFt_means_wo] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
n = 'all_FFm_wo';
useDates = {'2013-08-20','FF','RT','early2','1early'; ...
    '2013-08-22','FF','RT','early2','1early'; ...
    '2013-08-30','FF','RT','early2','1early'; ...
    '2013-08-20','FF','RT','late2','5late'; ...
    '2013-08-22','FF','RT','late2','5late'; ...
    '2013-08-30','FF','RT','late2','5late'};
[~, ~, FFm_means_wo] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
n = 'all_VRt_wo';
useDates = {'2013-09-04','VR','RT','targearly2','1early'; ...
    '2013-09-06','VR','RT','targearly2','1early'; ...
    '2013-09-10','VR','RT','targearly2','1early'; ...
    '2013-09-04','VR','RT','targlate2','5late'; ...
    '2013-09-06','VR','RT','targlate2','5late'; ...
    '2013-09-10','VR','RT','targlate2','5late'};
[~, ~, VRt_means_wo] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);
n = 'all_VRm_wo';
useDates = {'2013-09-04','VR','RT','early2','1early'; ...
    '2013-09-06','VR','RT','early2','1early'; ...
    '2013-09-10','VR','RT','early2','1early'; ...
    '2013-09-04','VR','RT','late2','5late'; ...
    '2013-09-06','VR','RT','late2','5late'; ...
    '2013-09-10','VR','RT','late2','5late'};
[~, ~, VRm_means_wo] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);





close all;


figure('Position',[200 200 1280 800]);
% subplot1(1,2);
% subplot1(1);
hold all;
plot(0,0,'bo','LineWidth',2);
plot(0.1,0,'ro','LineWidth',2);
legend({'Curl Field','Visual Rotation'});
plot([0;0],[FFm_means_bl(1,1)+FFm_means_bl(2,1);FFm_means_bl(1,1)-FFm_means_bl(2,1)],'b','LineWidth',2);
plot([0.1;0.1],[VRm_means_bl(1,1)+VRm_means_bl(2,1);VRm_means_bl(1,1)-VRm_means_bl(2,1)],'r','LineWidth',2);

plot(1:4,FFm_means_ad(1,:),'bo','LineWidth',2);
plot(1.1:4.1,VRm_means_ad(1,:),'ro','LineWidth',3);
plot([1:4;1:4],[FFm_means_ad(1,:)+FFm_means_ad(2,:);FFm_means_ad(1,:)-FFm_means_ad(2,:)],'b','LineWidth',2);
plot([1.1:4.1;1.1:4.1],[VRm_means_ad(1,:)+VRm_means_ad(2,:);VRm_means_ad(1,:)-VRm_means_ad(2,:)],'r','LineWidth',2);

plot(5:6,FFm_means_wo(1,:),'bo','LineWidth',2);
plot(5.1:6.1,VRm_means_wo(1,:),'ro','LineWidth',3);
plot([5:6;5:6],[FFm_means_wo(1,:)+FFm_means_wo(2,:);FFm_means_wo(1,:)-FFm_means_wo(2,:)],'b','LineWidth',2);
plot([5.1:6.1;5.1:6.1],[VRm_means_wo(1,:)+VRm_means_wo(2,:);VRm_means_wo(1,:)-VRm_means_wo(2,:)],'r','LineWidth',2);

plot([-1 7],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
plot([0.5 0.5],[-plotMax plotMax],'k--','LineWidth',1);
plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);


axis([-0.3 6.3 -plotMax plotMax]);


set(gca,'XTick',[0 1 2 3 4 5 6],'XTickLabel',{'Base','Early','Mid 1','Mid 2','Late','Early Wash', 'Late Wash'},'FontSize',14);

title('Movement','FontSize',16);
ylabel('Change in PD (deg)','FontSize',16);


figure('Position',[200 200 1280 800]);
% subplot1(1,2);
% subplot1(1);
hold all;
plot(0,0,'bo','LineWidth',2);
plot(0.1,0,'ro','LineWidth',2);
legend({'Curl Field','Visual Rotation'});
plot([0;0],[FFt_means_bl(1,1)+FFt_means_bl(2,1);FFt_means_bl(1,1)-FFt_means_bl(2,1)],'b','LineWidth',2);
plot([0.1;0.1],[VRt_means_bl(1,1)+VRt_means_bl(2,1);VRt_means_bl(1,1)-VRt_means_bl(2,1)],'r','LineWidth',2);

plot(1:4,FFt_means_ad(1,:),'bo','LineWidth',2);
plot(1.1:4.1,VRt_means_ad(1,:),'ro','LineWidth',3);
plot([1:4;1:4],[FFt_means_ad(1,:)+FFt_means_ad(2,:);FFt_means_ad(1,:)-FFt_means_ad(2,:)],'b','LineWidth',2);
plot([1.1:4.1;1.1:4.1],[VRt_means_ad(1,:)+VRt_means_ad(2,:);VRt_means_ad(1,:)-VRt_means_ad(2,:)],'r','LineWidth',2);

plot(5:6,FFt_means_wo(1,:),'bo','LineWidth',2);
plot(5.1:6.1,VRt_means_wo(1,:),'ro','LineWidth',3);
plot([5:6;5:6],[FFt_means_wo(1,:)+FFt_means_wo(2,:);FFt_means_wo(1,:)-FFt_means_wo(2,:)],'b','LineWidth',2);
plot([5.1:6.1;5.1:6.1],[VRt_means_wo(1,:)+VRt_means_wo(2,:);VRt_means_wo(1,:)-VRt_means_wo(2,:)],'r','LineWidth',2);

plot([-1 7],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
plot([0.5 0.5],[-plotMax plotMax],'k--','LineWidth',1);
plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);


axis([-0.3 6.3 -plotMax plotMax]);


set(gca,'XTick',[0 1 2 3 4 5 6],'XTickLabel',{'Base','Early','Mid 1','Mid 2','Late','Early Wash', 'Late Wash'},'FontSize',14);

title('Movement','FontSize',16);
ylabel('Change in PD (deg)','FontSize',16);

















% % Mr T time change code
n = 'all_VRm';
useDates = {'2013-09-04','VR','RT','early','1VRe'; ...
    '2013-09-06','VR','RT','early','1VRe'; ...
    '2013-09-10','VR','RT','early','1VRe'; ...
    '2013-08-20','FF','RT','early','2FFe'; ...
    '2013-08-22','FF','RT','early','2FFe'; ...
    '2013-08-30','FF','RT','early','2FFe'};
plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);

n = 'all_FFm';
useDates = {'2013-09-04','VR','RT','late','1VRl'; ...
    '2013-09-06','VR','RT','late','1VRl'; ...
    '2013-09-10','VR','RT','late','1VRl'; ...
    '2013-08-20','FF','RT','late','2FFl'; ...
    '2013-08-22','FF','RT','late','2FFl'; ...
    '2013-08-30','FF','RT','late','2FFl'};
plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize);




% 
% figure('Position',[200 200 1280 800]);
% hold all;
% plot(0,0,'bo','LineWidth',2);
% plot(0.1,0,'ro','LineWidth',2);
% legend({'Curl Field','Visual Rotation'});
% plot(1:4,FFm_means_ad(1,:),'bo','LineWidth',2);
% plot(1.1:4.1,VRm_means_ad(1,:),'ro','LineWidth',3);
% plot([1:4;1:4],[FFm_means_ad(1,:)+FFm_means_ad(2,:);FFm_means_ad(1,:)-FFm_means_ad(2,:)],'b','LineWidth',2);
% plot([1.1:4.1;1.1:4.1],[VRm_means_ad(1,:)+VRm_means_ad(2,:);VRm_means_ad(1,:)-VRm_means_ad(2,:)],'r','LineWidth',2);
% 
% plot(5:6,FFm_means_wo(1,:),'bo','LineWidth',2);
% plot(5.1:6.1,VRm_means_wo(1,:),'ro','LineWidth',3);
% plot([5:6;5:6],[FFm_means_wo(1,:)+FFm_means_wo(2,:);FFm_means_wo(1,:)-FFm_means_wo(2,:)],'b','LineWidth',2);
% plot([5.1:6.1;5.1:6.1],[VRm_means_wo(1,:)+VRm_means_wo(2,:);VRm_means_wo(1,:)-VRm_means_wo(2,:)],'r','LineWidth',2);
% 
% plot([-1 6],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
% plot([0.5 0.5],[-plotMax plotMax],'k--','LineWidth',1);
% plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);
% 
% if doAbsMean
%     axis([-0.3 6.3 -5 plotMax]);
% else
%     axis([-0.3 6.3 -plotMax plotMax]);
% end
% 
% set(gca,'XTick',[0 1 2 3 4 5 6],'XTickLabel',{'Base','Early','Mid 1','Mid 2','Late','Early Wash', 'Late Wash'},'FontSize',14);
% 
% title('Movement','FontSize',16);
% ylabel('Change in PD (deg)','FontSize',16);
% 
% figure('Position',[200 200 1280 800]);
% hold all;
% plot(0,0,'bo','LineWidth',2);
% plot(0.1,0,'ro','LineWidth',2);
% plot(1:4,FFt_means_ad(1,:),'bo','LineWidth',2);
% plot(1.1:4.1,VRt_means_ad(1,:),'ro','LineWidth',3);
% plot([1:4;1:4],[FFt_means_ad(1,:)+FFt_means_ad(2,:);FFt_means_ad(1,:)-FFt_means_ad(2,:)],'b','LineWidth',2);
% plot([1.1:4.1;1.1:4.1],[VRt_means_ad(1,:)+VRt_means_ad(2,:);VRt_means_ad(1,:)-VRt_means_ad(2,:)],'r','LineWidth',2);
% 
% plot(5:6,FFt_means_wo(1,:),'bo','LineWidth',2);
% plot(5.1:6.1,VRt_means_wo(1,:),'ro','LineWidth',3);
% plot([5:6;5:6],[FFt_means_wo(1,:)+FFt_means_wo(2,:);FFt_means_wo(1,:)-FFt_means_wo(2,:)],'b','LineWidth',2);
% plot([5.1:6.1;5.1:6.1],[VRt_means_wo(1,:)+VRt_means_wo(2,:);VRt_means_wo(1,:)-VRt_means_wo(2,:)],'r','LineWidth',2);
% 
% plot([-1 6],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
% plot([0.5 0.5],[-plotMax plotMax],'k--','LineWidth',1);
% plot([4.5 4.5],[-plotMax plotMax],'k--','LineWidth',1);
% 
% if doAbsMean
%     axis([-0.3 6.3 -5 plotMax]);
% else
%     axis([-0.3 6.3 -plotMax plotMax]);
% end
% 
% set(gca,'XTick',[0 1 2 3 4 5 6],'XTickLabel',{'Base','Early','Mid 1','Mid 2','Late','Early Wash', 'Late Wash'},'FontSize',14);
% title('Target','FontSize',16);
% 









% n = 'all_VRFFt';
% useDates = {'2013-09-24','VRFF','RT','early','1early'; ...
%     '2013-09-25','VRFF','RT','early','1early'; ...
%     '2013-09-27','VRFF','RT','early','1early'; ...
%     '2013-09-24','VRFF','RT','middle1','2middle1'; ...
%     '2013-09-25','VRFF','RT','middle1','2middle1'; ...
%     '2013-09-27','VRFF','RT','middle1','2middle1'; ...
%     '2013-09-24','VRFF','RT','middle2','3middle2'; ...
%     '2013-09-25','VRFF','RT','middle2','3middle2'; ...
%     '2013-09-27','VRFF','RT','middle2','3middle2'; ...
%     '2013-09-24','VRFF','RT','middle3','4middle2'; ...
%     '2013-09-25','VRFF','RT','middle3','4middle2'; ...
%     '2013-09-27','VRFF','RT','middle3','4middle2'; ...
%     '2013-09-24','VRFF','RT','late','5late'; ...
%     '2013-09-25','VRFF','RT','late','5late'; ...
%     '2013-09-27','VRFF','RT','late','5late'};
% [VRFFm_means, VRFFm_modes, VRFFm_adapt] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'doabsmean',doAbsMean);
%
%
% n = 'all_VRFFt';
% useDates = {'2013-09-24','VRFF','RT','targearly','1early'; ...
%     '2013-09-25','VRFF','RT','targearly','1early'; ...
%     '2013-09-27','VRFF','RT','targearly','1early'; ...
%     '2013-09-24','VRFF','RT','targmiddle1','2middle1'; ...
%     '2013-09-25','VRFF','RT','targmiddle1','2middle1'; ...
%     '2013-09-27','VRFF','RT','targmiddle1','2middle1'; ...
%     '2013-09-24','VRFF','RT','targmiddle2','3middle2'; ...
%     '2013-09-25','VRFF','RT','targmiddle2','3middle2'; ...
%     '2013-09-27','VRFF','RT','targmiddle2','3middle2'; ...
%     '2013-09-24','VRFF','RT','targmiddle3','4middle2'; ...
%     '2013-09-25','VRFF','RT','targmiddle3','4middle2'; ...
%     '2013-09-27','VRFF','RT','targmiddle3','4middle2'; ...
%     '2013-09-24','VRFF','RT','targlate','5late'; ...
%     '2013-09-25','VRFF','RT','targlate','5late'; ...
%     '2013-09-27','VRFF','RT','targlate','5late'};
% [VRFFt_means, VRFFt_modes, VRFFt_adapt] = plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'doabsmean',doAbsMean);








% figure;
% hold all;
% plot(1:5,VRt_means(1,:),'rd','LineWidth',2);
% plot(1.1:5.1,VRm_means(1,:),'ro','LineWidth',3);
% plot([1:5;1:5],[VRt_means(1,:)+VRt_means(2,:);VRt_means(1,:)-VRt_means(2,:)],'r:','LineWidth',2);
% plot([1.1:5.1;1.1:5.1],[VRm_means(1,:)+VRm_means(2,:);VRm_means(1,:)-VRm_means(2,:)],'r','LineWidth',2);
% plot([0 5],[0 0],'k--','LineWidth',1);
% set(gca,'XTick',[1 2 3 4 5],'XTickLabel',{'Early','Middle 1','Middle 2','Middle 3','Late'},'FontSize',14);
% axis([0.7 5.3 -20 20]);
% title('Visual Rotation','FontSize',16);
% ylabel('Change in PD (deg)','FontSize',16);
% legend({'Target','Movement'});
%
% figure;
% hold all;
% plot(1:5,FFt_means(1,:),'bd','LineWidth',2);
% plot(1.1:5.1,FFm_means(1,:),'bo','LineWidth',3);
% plot([1:5;1:5],[FFt_means(1,:)+FFt_means(2,:);FFt_means(1,:)-FFt_means(2,:)],'b:','LineWidth',2);
% plot([1.1:5.1;1.1:5.1],[FFm_means(1,:)+FFm_means(2,:);FFm_means(1,:)-FFm_means(2,:)],'b','LineWidth',2);
% plot([0 5],[0 0],'k--','LineWidth',1);
% set(gca,'XTick',[1 2 3 4 5],'XTickLabel',{'Early','Middle 1','Middle 2','Middle 3','Late'},'FontSize',14);
% axis([0.7 5.3 -20 20]);
% title('Curl Field','FontSize',16);
% ylabel('Change in PD (deg)','FontSize',16);
% legend({'Target','Movement'},'Location','SouthWest');
%
% figure;
% hold all;
% plot(1:5,VRFFt_means(1,:),'bd','LineWidth',2);
% plot(1.1:5.1,VRFFm_means(1,:),'bo','LineWidth',3);
% plot([1:5;1:5],[VRFFt_means(1,:)+VRFFt_means(2,:);VRFFt_means(1,:)-VRFFt_means(2,:)],'b:','LineWidth',2);
% plot([1.1:5.1;1.1:5.1],[VRFFm_means(1,:)+VRFFm_means(2,:);VRFFm_means(1,:)-VRFFm_means(2,:)],'b','LineWidth',2);
% plot([0 5],[0 0],'k--','LineWidth',1);
% set(gca,'XTick',[1 2 3 4 5],'XTickLabel',{'Early','Middle 1','Middle 2','Middle 3','Late'},'FontSize',14);
% axis([0.7 5.3 -20 20]);
% title('Curl Field and Visual Rotation','FontSize',16);
% ylabel('Change in PD (deg)','FontSize',16);
% legend({'Target','Movement'},'Location','SouthWest');
%
% figure;
% hold all;
% plot(1:5,100*VRt_adapt(1,:)./(VRt_adapt(1,:)+VRt_adapt(2,:)),'rd','LineWidth',2);
% plot(1.1:5.1,100*VRm_adapt(1,:)./(VRm_adapt(1,:)+VRm_adapt(2,:)),'ro','LineWidth',3);
% plot([0 5],[0 0],'k--','LineWidth',1);
% set(gca,'XTick',[1 2 3 4 5],'XTickLabel',{'Early','Middle 1','Middle 2','Middle 3','Late'},'FontSize',14);
% V = axis;
% axis([0.7 5.3 0 100]);
% title('Visual Rotation','FontSize',16);
% ylabel('Percent Adapting Cells','FontSize',16);
% legend({'Target','Movement'},'Location','NorthWest');
%
% figure;
% hold all;
% plot(1:5,100*FFt_adapt(1,:)./(FFt_adapt(1,:)+FFt_adapt(2,:)),'bd','LineWidth',2);
% plot(1.1:5.1,100*FFm_adapt(1,:)./(FFm_adapt(1,:)+FFm_adapt(2,:)),'bo','LineWidth',3);
% plot([0 5],[0 0],'k--','LineWidth',1);
% set(gca,'XTick',[1 2 3 4 5],'XTickLabel',{'Early','Middle 1','Middle 2','Middle 3','Late'},'FontSize',14);
% V = axis;
% axis([0.7 5.3 0 100]);
% title('Curl Field','FontSize',16);
% ylabel('Percent Adapting Cells','FontSize',16);
% legend({'Target','Movement'},'Location','NorthEast');
%
% figure;
% hold all;
% plot(1:5,100*VRFFt_adapt(1,:)./(VRFFt_adapt(1,:)+VRFFt_adapt(2,:)),'bd','LineWidth',2);
% plot(1.1:5.1,100*VRFFm_adapt(1,:)./(VRFFm_adapt(1,:)+VRFFm_adapt(2,:)),'bo','LineWidth',3);
% plot([0 5],[0 0],'k--','LineWidth',1);
% set(gca,'XTick',[1 2 3 4 5],'XTickLabel',{'Early','Middle 1','Middle 2','Middle 3','Late'},'FontSize',14);
% V = axis;
% axis([0.7 5.3 0 100]);
% title('Curl Field and Visual Rotation','FontSize',16);
% ylabel('Percent Adapting Cells','FontSize',16);
% legend({'Target','Movement'},'Location','NorthEast');







% % Mr T report code
% if 0
% % plotPDShiftCellClasses('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray)
% % cell matrix. each row is a file to add to plots. each column is info:
% %   {'recording_date','adaptation','task','parameter_set_name','title of file'}
% cssLoc = fullfile(outDir,'mainstyle.css');
% html = ['<html><head><title>DATA!</title><link rel="stylesheet" href="' cssLoc '" /></head><body>'];
%
% % quick table of contents
% lnks = {'VRem_VRlm', ...
%  'FFem_FFlm', ...
%  'FFlm_VRlm', ...
%  'VRlm_VRlt', ...
%  'FFlm_FFlt', ...
%  'VRFFem_VRFFlm', ...
%  'VRFFlm_VRFFlt', ...
%  'VRlm_VRFFlm', ...
%  'FFlm_VRFFlm'};
%
% for i = 1:length(lnks)
%     html = strcat(html,['<a href="#' lnks{i} '">' lnks{i} '</a><br>']);
% end
%
% html = strcat(html,'<br><br>');
%
%
% % 1) Compare VR movement early and VR movement late
% n = 'VRem_VRlm';
% useDates = {'2013-09-04','VR','RT','early','VR-early'; ...
%     '2013-09-06','VR','RT','early','VR-early'; ...
%     '2013-09-10','VR','RT','early','VR-early'; ...
%     '2013-09-04','VR','RT','late','VR-late'; ...
%     '2013-09-06','VR','RT','late','VR-late'; ...
%     '2013-09-10','VR','RT','late','VR-late'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'VR early and VR late';
% html = addReportNode(html,n,t,outDir);
%
% % 2) Compare FF movement early and FF movement late
% n = 'FFem_FFlm';
% useDates = {'2013-08-20','FF','RT','early','FF-early'; ...
%     '2013-08-22','FF','RT','early','FF-early'; ...
%     '2013-08-30','FF','RT','early','FF-early'; ...
%     '2013-08-20','FF','RT','late','FF-late'; ...
%     '2013-08-22','FF','RT','late','FF-late'; ...
%     '2013-08-30','FF','RT','late','FF-late'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'FF early and FF late';
% html = addReportNode(html,n,t,outDir);
%
% % 3) Compare FF movement and VR movement
% n = 'FFlm_VRlm';
% useDates = {'2013-08-20','FF','RT','late','FF-move'; ...
%     '2013-08-22','FF','RT','late','FF-move'; ...
%     '2013-08-30','FF','RT','late','FF-move'; ...
%     '2013-09-04','VR','RT','late','VR-move'; ...
%     '2013-09-06','VR','RT','late','VR-move'; ...
%     '2013-09-10','VR','RT','late','VR-move'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'FF and VR movement';
% html = addReportNode(html,n,t,outDir);
%
% % 4) Compare VR movement and VR target
% n = 'VRlm_VRlt';
% useDates = {'2013-09-04','VR','RT','late','VR-move'; ...
%     '2013-09-06','VR','RT','late','VR-move'; ...
%     '2013-09-10','VR','RT','late','VR-move'; ...
%     '2013-09-04','VR','RT','targlate','VR-targ'; ...
%     '2013-09-06','VR','RT','targlate','VR-targ'; ...
%     '2013-09-10','VR','RT','targlate','VR-targ'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'VR movement and VR target';
% html = addReportNode(html,n,t,outDir);
%
% % 5) Compare FF movement and FF target
% n = 'FFlm_FFlt';
% useDates = {'2013-08-20','FF','RT','late','FF-move'; ...
%     '2013-08-22','FF','RT','late','FF-move'; ...
%     '2013-08-30','FF','RT','late','FF-move'; ...
%     '2013-08-20','FF','RT','targlate','FF-targ'; ...
%     '2013-08-22','FF','RT','targlate','FF-targ'; ...
%     '2013-08-30','FF','RT','targlate','FF-targ'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'FF movement and FF target';
% html = addReportNode(html,n,t,outDir);
%
% % 6) Compare VRFF early and VRFF late
% n = 'VRFFem_VRFFlm';
% useDates = {'2013-09-24','VRFF','RT','early','VRFF-early'; ...
%     '2013-09-25','VRFF','RT','early','VRFF-early'; ...
%     '2013-09-27','VRFF','RT','early','VRFF-early'; ...
%     '2013-09-24','VRFF','RT','late','VRFF-late'; ...
%     '2013-09-25','VRFF','RT','late','VRFF-late'; ...
%     '2013-09-27','VRFF','RT','late','VRFF-late'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'VRFF early and VRFF late';
% html = addReportNode(html,n,t,outDir);
%
% % 7) Compare VRFF movement and VRFF target
% n = 'VRFFlm_VRFFlt';
% useDates = {'2013-09-24','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-25','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-27','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-24','VRFF','RT','targlate','VRFF-targ'; ...
%     '2013-09-25','VRFF','RT','targlate','VRFF-targ'; ...
%     '2013-09-27','VRFF','RT','targlate','VRFF-targ'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'VRFF movement and VRFF target';
% html = addReportNode(html,n,t,outDir);
%
% % 8) Compare VR movement and VRFF movement
% n = 'VRlm_VRFFlm';
% useDates = {'2013-09-04','VR','RT','late','VR-move'; ...
%     '2013-09-06','VR','RT','late','VR-move'; ...
%     '2013-09-10','VR','RT','late','VR-move'; ...
%     '2013-09-24','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-25','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-27','VRFF','RT','late','VRFF-move'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'VR and VRFF movement';
% html = addReportNode(html,n,t,outDir);
%
% % 9) Compare FF movement and VRFF movement
% n = 'FFlm_VRFFlm';
% useDates = {'2013-08-20','FF','RT','late','FF-move'; ...
%     '2013-08-22','FF','RT','late','FF-move'; ...
%     '2013-08-30','FF','RT','late','FF-move'; ...
%     '2013-09-24','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-25','VRFF','RT','late','VRFF-move'; ...
%     '2013-09-27','VRFF','RT','late','VRFF-move'};
% plotPDShiftComparisonHistograms('dir',baseDir,'dates',useDates,'period',usePeriod,'array',useArray,'binsize',binSize,'savepath',fullfile(outDir,n))
% t = 'FF and VRFF movement';
% html = addReportNode(html,n,t,outDir);
%
% close all;
%
% % make a quick report
% html = strcat(html,'</body></html>');
%
% fn = fullfile(outDir,'report.html');
% fid = fopen(fn,'w+');
% fprintf(fid,'%s',html);
% fclose(fid);
% end
%
% end
%
% function html = addReportNode(html,name,title,outDir)
%
% imgWidth = 600;
%
% html = strcat(html,['<div id="' name '">' title '<br><table><tr>' ...
%     '<td><img src="' fullfile(outDir,[name '_ad.png']) '" width="' num2str(imgWidth) '"></td>' ...
%     '<td><img src="' fullfile(outDir,[name '_bar.png']) '" width="' num2str(imgWidth) '"></td>' ...
%     '<td><img src="' fullfile(outDir,[name '_wo.png']) '" width="' num2str(imgWidth) '"></td>' ...
%     '</tr></table></div><br>']);
% end


