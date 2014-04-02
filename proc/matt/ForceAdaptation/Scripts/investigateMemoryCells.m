clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

doFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
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
    'Mihili','2014-03-07','FF','CO'};       %15 S(M-P)

useArray = 'M1';
paramSetName = 'movement';
tuningMethod = 'regression';
tuningPeriod = 'initial';

classifierBlocks = [1 4 5];

%% Get the classification for each day for tuned cells
cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
    classes = load(classFile);
    
    tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
    tuning = load(tuningFile);
    
    c = classes.(tuningMethod).(tuningPeriod).(useArray);
    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    
    tunedCells = c.tuned_cells;
    
    t=tuning.(tuningMethod).(tuningPeriod).(useArray).tuning;
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    pds_bl = t(classifierBlocks(1)).pds(idx_bl,:);
    pds_ad = t(classifierBlocks(2)).pds(idx_ad,:);
    pds_wo = t(classifierBlocks(3)).pds(idx_wo,:);
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
end

%% now that I have the classes, plot it!

numClasses = 5;
ymin = 0;
ymax = 100;
classLabels = {'Non-Adapt','Adapt','Mem I','Mem II','Other'};

% % plot the percent of each cell type for the two perturbations
% vr_counts = zeros(sum(strcmpi(doFiles(:,3),'vr')),numClasses);
% ff_counts = zeros(sum(strcmpi(doFiles(:,3),'ff')),numClasses);
% for j = 1:numClasses % loop along the classes
%     vr_counts(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,3),'vr'),:));
%     ff_counts(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,3),'ff'),:));
% end
%
% figure;
% hold all;
% h = barwitherr([(std(ff_counts,1)/size(ff_counts,1))' (std(vr_counts,1)/size(vr_counts,1))'],[mean(ff_counts,1)' mean(vr_counts,1)'],'BarWidth',1);
% set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
% ylabel('Percent','FontSize',14);
% legend({'Curl Field','Visual Rotation'},'FontSize',14);


% same as before but break down by file type
vr_counts_co = zeros(sum(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co')),numClasses);
ff_counts_co = zeros(sum(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co')),numClasses);
vr_counts_rt = zeros(sum(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt')),numClasses);
ff_counts_rt = zeros(sum(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt')),numClasses);

for j = 1:numClasses % loop along the classes
    vr_counts_co(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:));
    ff_counts_co(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:));
    vr_counts_rt(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:));
    ff_counts_rt(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:));
end

figure;
subplot1(1,2,'Gap',[0,0],'YTickL','Margin');
subplot1(1);
hold all;
h = barwitherr([(std(ff_counts_co,1)/sqrt(size(ff_counts_co,1)))' (std(vr_counts_co,1)/sqrt(size(vr_counts_co,1)))'],[mean(ff_counts_co,1)' mean(vr_counts_co,1)'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
ylabel('Percent','FontSize',14);
title('Center Out','FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);

subplot1(2);
hold all;
h = barwitherr([(std(ff_counts_rt,1)/sqrt(size(ff_counts_rt,1)))' (std(vr_counts_rt,1)/sqrt(size(vr_counts_rt,1)))'],[mean(ff_counts_rt,1)' mean(vr_counts_rt,1)'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);
title('Random Target','FontSize',14);



%% Plot magnitude of PD change for each cell type
ymin = -45;
ymax = 45;

epoch1 = 1;
epoch2 = 2;

% % get the size of PD change based on file type
% vr_classes = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false));
% ff_classes = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false));
%
% all_vr_pds = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false));
% all_ff_pds = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false));
%
% vr_pds = zeros(1,numClasses);
% ff_pds = zeros(1,numClasses);
% vr_pds_se = zeros(1,numClasses);
% ff_pds_se = zeros(1,numClasses);
% for j = 1:numClasses
%     vr_pds(j) = mean(all_vr_pds(vr_classes==j)).*180/pi;
%     vr_pds_se(j) = std(all_vr_pds(vr_classes==j))/sqrt(sum(vr_classes==j)).*180/pi;
%
%     ff_pds(j) = mean(all_ff_pds(ff_classes==j)).*180/pi;
%     ff_pds_se(j) = std(all_ff_pds(ff_classes==j))/sqrt(sum(ff_classes==j)).*180/pi;
% end
%
% figure;
% hold all;
% h = barwitherr([ff_pds_se' vr_pds_se'],[ff_pds' vr_pds'],'BarWidth',1);
% set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
% ylabel('PD Change','FontSize',14);
% legend({'Curl Field','Visual Rotation'},'FontSize',14);



% Now make same plot but broken down by task
vr_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
ff_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
all_vr_pds_co = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
all_ff_pds_co = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));

vr_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
ff_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
all_vr_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
all_ff_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));

vr_pds_co = zeros(1,numClasses);
ff_pds_co = zeros(1,numClasses);
vr_pds_se_co = zeros(1,numClasses);
ff_pds_se_co = zeros(1,numClasses);

vr_pds_rt = zeros(1,numClasses);
ff_pds_rt = zeros(1,numClasses);
vr_pds_se_rt = zeros(1,numClasses);
ff_pds_se_rt = zeros(1,numClasses);
for j = 1:numClasses
    vr_pds_co(j) = mean(all_vr_pds_co(vr_classes_co==j)).*180/pi;
    vr_pds_se_co(j) = std(all_vr_pds_co(vr_classes_co==j))/sqrt(sum(vr_classes_co==j)).*180/pi;
    
    ff_pds_co(j) = mean(all_ff_pds_co(ff_classes_co==j)).*180/pi;
    ff_pds_se_co(j) = std(all_ff_pds_co(ff_classes_co==j))/sqrt(sum(ff_classes_co==j)).*180/pi;
    
    vr_pds_rt(j) = mean(all_vr_pds_rt(vr_classes_rt==j)).*180/pi;
    vr_pds_se_rt(j) = std(all_vr_pds_rt(vr_classes_rt==j))/sqrt(sum(vr_classes_rt==j)).*180/pi;
    
    ff_pds_rt(j) = mean(all_ff_pds_rt(ff_classes_rt==j)).*180/pi;
    ff_pds_se_rt(j) = std(all_ff_pds_rt(ff_classes_rt==j))/sqrt(sum(ff_classes_rt==j)).*180/pi;
end

figure;
subplot1(1,2,'Gap',[0,0],'YTickL','Margin');
subplot1(1);
hold all;
h = barwitherr([ff_pds_se_co' vr_pds_se_co'],[ff_pds_co' vr_pds_co'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
ylabel('PD Change','FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);
title('Center Out','FontSize',14);

subplot1(2);
hold all;
h = barwitherr([ff_pds_se_rt' vr_pds_se_rt'],[ff_pds_rt' vr_pds_rt'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);
title('Random Target','FontSize',14);


%% Plot magnitude of PD change for each cell type
ymin = -45;
ymax = 45;

epoch1 = 1;
epoch2 = 3;

% % get the size of PD change based on file type
% vr_classes = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false));
% ff_classes = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false));
%
% all_vr_pds = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false));
% all_ff_pds = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false));
%
% vr_pds = zeros(1,numClasses);
% ff_pds = zeros(1,numClasses);
% vr_pds_se = zeros(1,numClasses);
% ff_pds_se = zeros(1,numClasses);
% for j = 1:numClasses
%     vr_pds(j) = mean(all_vr_pds(vr_classes==j)).*180/pi;
%     vr_pds_se(j) = std(all_vr_pds(vr_classes==j))/sum(vr_classes==j).*180/pi;
%
%     ff_pds(j) = mean(all_ff_pds(ff_classes==j)).*180/pi;
%     ff_pds_se(j) = std(all_ff_pds(ff_classes==j))/sum(ff_classes==j).*180/pi;
% end
%
% figure;
% hold all;
% h = barwitherr([ff_pds_se' vr_pds_se'],[ff_pds' vr_pds'],'BarWidth',1);
% set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
% ylabel('PD Change','FontSize',14);
% legend({'Curl Field','Visual Rotation'},'FontSize',14);

% Now make same plot but broken down by task
vr_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
ff_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
all_vr_pds_co = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
all_ff_pds_co = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));

vr_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
ff_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
all_vr_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
all_ff_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));

vr_pds_co = zeros(1,numClasses);
ff_pds_co = zeros(1,numClasses);
vr_pds_se_co = zeros(1,numClasses);
ff_pds_se_co = zeros(1,numClasses);

vr_pds_rt = zeros(1,numClasses);
ff_pds_rt = zeros(1,numClasses);
vr_pds_se_rt = zeros(1,numClasses);
ff_pds_se_rt = zeros(1,numClasses);
for j = 1:numClasses
    vr_pds_co(j) = mean(all_vr_pds_co(vr_classes_co==j)).*180/pi;
    vr_pds_se_co(j) = std(all_vr_pds_co(vr_classes_co==j))/sqrt(sum(vr_classes_co==j)).*180/pi;
    
    ff_pds_co(j) = mean(all_ff_pds_co(ff_classes_co==j)).*180/pi;
    ff_pds_se_co(j) = std(all_ff_pds_co(ff_classes_co==j))/sqrt(sum(ff_classes_co==j)).*180/pi;
    
    vr_pds_rt(j) = mean(all_vr_pds_rt(vr_classes_rt==j)).*180/pi;
    vr_pds_se_rt(j) = std(all_vr_pds_rt(vr_classes_rt==j))/sqrt(sum(vr_classes_rt==j)).*180/pi;
    
    ff_pds_rt(j) = mean(all_ff_pds_rt(ff_classes_rt==j)).*180/pi;
    ff_pds_se_rt(j) = std(all_ff_pds_rt(ff_classes_rt==j))/sqrt(sum(ff_classes_rt==j)).*180/pi;
end

figure;
subplot1(1,2,'Gap',[0,0],'YTickL','Margin');
subplot1(1);
hold all;
h = barwitherr([ff_pds_se_co' vr_pds_se_co'],[ff_pds_co' vr_pds_co'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
ylabel('PD Change','FontSize',14);
legend({'Curl Field','Visual Rotation'},'FontSize',14);
title('Center Out','FontSize',14);

subplot1(2);
hold all;
h = barwitherr([ff_pds_se_rt' vr_pds_se_rt'],[ff_pds_rt' vr_pds_rt'],'BarWidth',1);
set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
title('Random Target','FontSize',14);



%% Compare % of "other" cells in each task and perturbation along with size of change
%
% for j = 1:numClasses
%     epoch1 = 1;
%     epoch2 = 3;
%     vr_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
%     ff_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
%     all_vr_pds_co = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
%     all_ff_pds_co = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
%     
%     vr_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     ff_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     all_vr_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     all_ff_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     
%     % get indices of "other" class
%     vr_idx_co = vr_classes_co==j;
%     ff_idx_co = ff_classes_co==j;
%     vr_idx_rt = vr_classes_rt==j;
%     ff_idx_rt = ff_classes_rt==j;
%     
%     % get percent of cells
%     vr_counts_co = 100*sum(vr_idx_co)/length(vr_idx_co);
%     ff_counts_co = 100*sum(ff_idx_co)/length(ff_idx_co);
%     vr_counts_rt = 100*sum(vr_idx_rt)/length(vr_idx_rt);
%     ff_counts_rt = 100*sum(ff_idx_rt)/length(ff_idx_rt);
%     
%     % get PD change
%     vr_pds_co = mean(all_vr_pds_co(vr_idx_co));
%     ff_pds_co = mean(all_ff_pds_co(ff_idx_co));
%     vr_pds_rt = mean(all_vr_pds_rt(vr_idx_rt));
%     ff_pds_rt = mean(all_ff_pds_rt(ff_idx_rt));
%     
%     vr_pds_se_co = std(all_vr_pds_co(vr_idx_co))/sqrt(sum(vr_idx_co));
%     ff_pds_se_co = std(all_ff_pds_co(ff_idx_co))/sqrt(sum(ff_idx_co));
%     vr_pds_se_rt = std(all_vr_pds_rt(vr_idx_rt))/sqrt(sum(vr_idx_rt));
%     ff_pds_se_rt = std(all_ff_pds_rt(ff_idx_rt))/sqrt(sum(ff_idx_rt));
%     
%     figure;
%     subplot1(1,3,'Gap',[0.1,0],'YTickL','All');
%     subplot1(1);
%     hold all;
%     bar([ff_counts_co vr_counts_co; ff_counts_rt vr_counts_rt],'BarWidth',1);
%     set(gca,'YLim',[0 50],'XTick',1:2,'XTickLabel',{'Center Out','Random Target'},'FontSize',14);
%     legend({'Curl Field','Visual Rotation'},'FontSize',14);
%     ylabel('Percent of Cells','FontSize',14);
%     title(['Classified as ' classLabels{j}],'FontSize',14);
%     
%     subplot1(2);
%     hold all;
%     h = barwitherr([ff_pds_se_co vr_pds_se_co; ff_pds_se_rt vr_pds_se_rt].*(180/pi),[ff_pds_co vr_pds_co; ff_pds_rt vr_pds_rt].*(180/pi),'BarWidth',1);
%     set(gca,'YLim',[-45 45],'XTick',1:2,'XTickLabel',{'Center Out','Random Target'},'FontSize',14);
%     ylabel('Change in PD (deg)','FontSize',14);
%     title('Washout - Baseline','FontSize',14);
%     
%     
%     
%     % get PD change
%     epoch1 = 2;
%     epoch2 = 3;
%     vr_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     ff_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     all_vr_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     all_ff_pds_rt = cell2mat(cellfun(@(x) angleDiff(x{epoch1}(:,1),x{epoch2}(:,1),true,true),cellPDs(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%     
%     vr_pds_co = mean(all_vr_pds_co(vr_idx_co));
%     ff_pds_co = mean(all_ff_pds_co(ff_idx_co));
%     vr_pds_rt = mean(all_vr_pds_rt(vr_idx_rt));
%     ff_pds_rt = mean(all_ff_pds_rt(ff_idx_rt));
%     
%     vr_pds_se_co = std(all_vr_pds_co(vr_idx_co))/sqrt(sum(vr_idx_co));
%     ff_pds_se_co = std(all_ff_pds_co(ff_idx_co))/sqrt(sum(ff_idx_co));
%     vr_pds_se_rt = std(all_vr_pds_rt(vr_idx_rt))/sqrt(sum(vr_idx_rt));
%     ff_pds_se_rt = std(all_ff_pds_rt(ff_idx_rt))/sqrt(sum(ff_idx_rt));
%     
%     
%     subplot1(3);
%     hold all;
%     h = barwitherr([ff_pds_se_co vr_pds_se_co; ff_pds_se_rt vr_pds_se_rt].*(180/pi),[ff_pds_co vr_pds_co; ff_pds_rt vr_pds_rt].*(180/pi),'BarWidth',1);
%     set(gca,'YLim',[-45 45],'XTick',1:2,'XTickLabel',{'Center Out','Random Target'},'FontSize',14);
%     ylabel('Change in PD (deg)','FontSize',14);
%     title('Washout - Adaptation','FontSize',14);
%     
% end


%% Plot total percentage (not average across days)
%
% numClasses = 5;
% ymin = 0;
% ymax = 100;
% classLabels = {'Non-Adapt','Adapt','Mem I','Mem II','Other'};
%
% % plot the percent of each cell type for the two perturbations
% vr_classes = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false));
% ff_classes = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false));
%
% vr_counts = zeros(1,numClasses);
% ff_counts = zeros(1,numClasses);
% for j = 1:numClasses % loop along the classes
%     vr_counts(j) = 100*sum(vr_classes==j)/length(vr_classes);
%     ff_counts(j) = 100*sum(ff_classes==j)/length(ff_classes);
% end
%
% figure;
% hold all;
% h = bar([ff_counts' vr_counts'],'BarWidth',1);
% set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
% ylabel('Percent','FontSize',14);
% legend({'Curl Field','Visual Rotation'},'FontSize',14);
%
%
%
%
% % plot the percent of each cell type for the two perturbations
% vr_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
% ff_classes_co = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'co'),:),'UniformOutput',false));
% vr_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'vr') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
% ff_classes_rt = cell2mat(cellfun(@(x) x,cellClasses(strcmpi(doFiles(:,3),'ff') & strcmpi(doFiles(:,4),'rt'),:),'UniformOutput',false));
%
% vr_counts_co = zeros(1,numClasses);
% ff_counts_co = zeros(1,numClasses);
% vr_counts_rt = zeros(1,numClasses);
% ff_counts_rt = zeros(1,numClasses);
% for j = 1:numClasses % loop along the classes
%     vr_counts_co(j) = 100*sum(vr_classes_co==j)/length(vr_classes_co);
%     ff_counts_co(j) = 100*sum(ff_classes_co==j)/length(ff_classes_co);
%     vr_counts_rt(j) = 100*sum(vr_classes_rt==j)/length(vr_classes_rt);
%     ff_counts_rt(j) = 100*sum(ff_classes_rt==j)/length(ff_classes_rt);
% end
%
% figure;
% subplot1(1,2,'Gap',[0,0],'YTickL','Margin');
% subplot1(1);
% hold all;
% h = bar([ff_counts_co' vr_counts_co'],'BarWidth',1);
% set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
% ylabel('Percent','FontSize',14);
% legend({'Curl Field','Visual Rotation'},'FontSize',14);
%
% subplot1(2);
% hold all;
% h = bar([ff_counts_rt' vr_counts_rt'],'BarWidth',1);
% set(gca,'YLim',[ymin ymax],'XTick',1:numClasses,'XTickLabel',classLabels,'FontSize',14);
