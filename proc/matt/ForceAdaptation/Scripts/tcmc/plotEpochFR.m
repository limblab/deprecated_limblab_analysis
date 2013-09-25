%% Compare firing rate of different cell classes in adaptation period
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR,I] = sort(c);
fr_VR = fr(:,I);

useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF,I] = sort(c);
fr_FF = fr(:,I);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fr_FF(:,inds);
%     [~,I] = sort(mean(fr,1));
%     fr = fr(:,I);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fr_VR(:,inds);
%     [~,I] = sort(mean(fr,1));
%     fr = fr(:,I);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-7 -7],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end

% add legend and labels
V = axis;
set(gca,'YTick',0:10:V(4),'YTickLabels',0:10:V(4),'XTick',[],'FontSize',16);
ylabel('Firing Rate (Hz)','FontSize',16);

axis([-2 V(2)+2 -20 V(4)+20]);
% add labels for cell types
text(7,-13,'Non-Adapting','FontSize',16);
text(32.5,-13,'Adapting','FontSize',16);
text(45,-13,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[105 105],'b','LineWidth',3);
plot([2 8],[97 97],'r','LineWidth',3);
text(9,105,'Force Field','FontSize',16);
text(9,97,'Visual Rotation','FontSize',16);
