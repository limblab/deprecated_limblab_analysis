%% Calculate a firing rate index (change from baseline to adaptation)
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
[c_VR_AD,I] = sort(c);
fr_VR_AD = fr(:,I);

% get the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR,I] = sort(c);
fr_VR_BL = fr(:,I);

% now find an index for how firing rate changes
fri_VR = mean(fr_VR_AD,1)./mean(fr_VR_BL,1);


%%%%%%%%%%%%
% now the force field
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
[c_FF_AD,I] = sort(c);
fr_FF_AD = fr(:,I);

%%%%
% now the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_BL,I] = sort(c);
fr_FF_BL = fr(:,I);

fri_FF = mean(fr_FF_AD,1)./mean(fr_FF_BL,1);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fri_FF(:,inds);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fri_VR(:,inds);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-0.2 -0.2],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end


% add legend and labels
V = axis;
plot([V(1) V(2)],[1 1],'k--','LineWidth',1);
set(gca,'YTick',0:0.2:2,'YTickLabels',0:0.2:2,'XTick',[],'FontSize',16);
ylabel('Adaptation / Baseline','FontSize',16);

axis([-2 V(2)+2 -0.4 2]);
% add labels for cell types
text(7,-0.3,'Non-Adapting','FontSize',16);
text(32.5,-0.3,'Adapting','FontSize',16);
text(45,-0.3,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[1.9 1.9],'b','LineWidth',3);
plot([2 8],[1.8 1.8],'r','LineWidth',3);
text(9,1.9,'Force Field','FontSize',16);
text(9,1.8,'Visual Rotation','FontSize',16);

%% do same but with washout relative to baseline
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_WO,I] = sort(c);
fr_VR_WO = fr(:,I);

% get the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR,I] = sort(c);
fr_VR_BL = fr(:,I);

% now find an index for how firing rate changes
fri_VR = mean(fr_VR_WO,1)./mean(fr_VR_BL,1);


%%%%%%%%%%%%
% now the force field
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_WO,I] = sort(c);
fr_FF_WO = fr(:,I);

%%%%
% now the baseline
sg = tuning.BL.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.BL.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_BL,I] = sort(c);
fr_FF_BL = fr(:,I);

fri_FF = mean(fr_FF_WO,1)./mean(fr_FF_BL,1);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fri_FF(:,inds);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fri_VR(:,inds);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-0.2 -0.2],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end


% add legend and labels
V = axis;
plot([V(1) V(2)],[1 1],'k--','LineWidth',1);
set(gca,'YTick',0:0.2:2,'YTickLabels',0:0.2:2,'XTick',[],'FontSize',16);
ylabel('Washout / Baseline','FontSize',16);

axis([-2 V(2)+2 -0.4 2]);
% add labels for cell types
text(7,-0.3,'Non-Adapting','FontSize',16);
text(32.5,-0.3,'Adapting','FontSize',16);
text(45,-0.3,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[1.9 1.9],'b','LineWidth',3);
plot([2 8],[1.8 1.8],'r','LineWidth',3);
text(9,1.9,'Force Field','FontSize',16);
text(9,1.8,'Visual Rotation','FontSize',16);

% we want to compare with t test washout and baseline
H = ttest2(mean(fr_VR_WO,1),mean(fr_VR_BL,1))
H = ttest2(mean(fr_FF_WO,1),mean(fr_FF_BL,1))

%% do same but with washout relative to adaptation

useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_VR_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_WO,I] = sort(c);
fr_VR_WO = fr(:,I);

% get the baseline
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_VR_AD,I] = sort(c);
fr_VR_AD = fr(:,I);

% now find an index for how firing rate changes
fri_VR = mean(fr_VR_WO,1)./mean(fr_VR_AD,1);


%%%%%%%%%%%%
% now the force field
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));
load(fullfile(baseDir,useDate,['RT_FF_tuning_' useDate '.mat']));

tcs = classes.PMd.regression.peak.tuned_cells;

tunedCells = classes.PMd.regression.peak.unit_guide(tcs,:);
sg = tuning.WO.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.WO.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_WO,I] = sort(c);
fr_FF_WO = fr(:,I);

%%%%
% now the baseline
sg = tuning.AD.PMd.regression.peak.unit_guide;
[~,I] = intersect(sg,tunedCells,'rows');

fr = tuning.AD.PMd.regression.peak.fr;

% get firing rates for tuned cells
fr = fr(:,I);
c = classes.PMd.regression.peak.classes(tcs);

% order the cells by classification
[c_FF_AD,I] = sort(c);
fr_FF_AD = fr(:,I);

fri_FF = mean(fr_FF_WO,1)./mean(fr_FF_AD,1);

fh = figure('Position',[200 200 800 600]);
hold all;

uclass=unique([c_VR; c_FF]);

firstcount = 1;
count = 0;
for i = 1:length(uclass)
    inds = c_FF==uclass(i);
    fr = fri_FF(:,inds);
    
    for j = 1:size(fr,2)
        count = count + 1;
        plot(count,mean(fr(:,j)),'bd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'b','LineWidth',2);
    end
    
    inds = c_VR==uclass(i);
    fr = fri_VR(:,inds);
    
    for j = 1:size(fr,2)
        count = count+1;
        plot(count,mean(fr(:,j)),'rd','LineWidth',2);
        plot([count count],[mean(fr(:,j))-std(fr(:,j)) mean(fr(:,j))+std(fr(:,j))],'r','LineWidth',2);
    end
    
    plot([firstcount count],[-0.2 -0.2],'k','LineWidth',3);
    count = count+4;
    firstcount = count+1;
end


% add legend and labels
V = axis;
plot([V(1) V(2)],[1 1],'k--','LineWidth',1);
set(gca,'YTick',0:0.2:2,'YTickLabels',0:0.2:2,'XTick',[],'FontSize',16);
ylabel('Washout / Adaptation','FontSize',16);

axis([-2 V(2)+2 -0.4 2]);
% add labels for cell types
text(7,-0.3,'Non-Adapting','FontSize',16);
text(32.5,-0.3,'Adapting','FontSize',16);
text(45,-0.3,'Memory','FontSize',16);

% add legend for colors
plot([2 8],[1.9 1.9],'b','LineWidth',3);
plot([2 8],[1.8 1.8],'r','LineWidth',3);
text(9,1.9,'Force Field','FontSize',16);
text(9,1.8,'Visual Rotation','FontSize',16);