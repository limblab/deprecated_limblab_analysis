% plotChangePDvsMD
%   Scatter plot of change in PD against MD

xmin = -180;
xmax = 180;
x_binSize = 10;
ymin = -30;
ymax = 30;
y_binSize = 2;
x_lab = 'PD Change (Deg)';
y_lab = 'MD Change (Hz)';

%% Get the classification for each day for tuned cells
cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
    classifierBlocks = c.params.classes.classifierBlocks;
    
    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    tunedCells = c.tuned_cells;
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    mds_bl = t(classifierBlocks(1)).mds(idx_bl,1);
    mds_ad = t(classifierBlocks(2)).mds(idx_ad,1);
    mds_wo = t(classifierBlocks(3)).mds(idx_wo,1);
    
    pds_bl = t(classifierBlocks(1)).pds(idx_bl,1);
    pds_ad = t(classifierBlocks(2)).pds(idx_ad,1);
    pds_wo = t(classifierBlocks(3)).pds(idx_wo,1);
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
    cellMDs{iFile} = {mds_bl, mds_ad, mds_wo};
end

%%
% find all dPDs
dpd_ad = [];
dpd_wo = [];
dmd_ad = [];
dmd_wo = [];
classes = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    mds = cellMDs{iFile};
    
    dpd_ad = [dpd_ad; angleDiff(pds{1},pds{2},true,true).*(180/pi)];
    dpd_wo = [dpd_wo; angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    
    dmd_ad = [dmd_ad; mds{2}-mds{1}];
    dmd_wo = [dmd_wo; mds{3}-mds{1}];
    
    c = cellClasses{iFile};
    if reassignOthers
        pds_wo = pds{3};
        pds_ad = pds{2};
        pds_bl = pds{1};
        idx = find(c==5);
        
        for i = 1:length(idx)
            % calculate the memory cell index
            bl_wo = angleDiff( pds_wo(idx(i),1),pds_bl(idx(i),1),true,true );
            bl_ad = angleDiff( pds_ad(idx(i),1), pds_bl(idx(i),1),true,true );
            ad_wo = angleDiff(pds_wo(idx(i),1),pds_ad(idx(i),1),true,true);
            
            mem_ind = abs(bl_wo) / min( abs(bl_ad) , abs(ad_wo) );
            
            % we also want both BL->WO and BL->AD to be same direction for memory
            %   otherwise it's just dynamic
            if mem_ind > 1
                if sign(bl_wo)==sign(bl_ad)
                    c(idx(i)) = 3;
                else
                    c(idx(i)) = 2;
                end
            elseif mem_ind < 1
                c(idx(i)) = 2;
            else
                disp('Hey! This one is exactly one.');
                c(idx(i)) = 3;
            end
        end
    end
    classes = [classes; c];
end

%%

classColors = {'k','b','r','m','g'};
classNames = {'Kinematic','Dynamic','Memory I','Memory II','Other'};

figure('Position',[300 50 950 950]);
subplot1(2,2,'Gap',[0 0],'Min',[0.08 0.08],'Max',[0.98 0.98]);

% make a legend here
subplot1(2);

set(gca,'XTick',[],'YTick',[],'XLim',[-0.1 4],'YLim',[-0.1 length(classColors)+1]);
V = axis(gca);
patch([V(1) V(2) V(2) V(1)],[V(3) V(3) V(4) V(4)],[0.8 0.8 0.8]);

for i=1:length(classColors)
    plot(1,i,'d','Color',classColors{i},'LineWidth',2);
    text(2,i,classNames{i},'FontSize',14);
end

box off;

% plot histogram of changes BL->AD
bins = xmin:x_binSize:xmax;
subplot1(1);
hist(dpd_ad,bins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

set(gca,'YTick',[],'XTick',[],'XLim',[xmin,xmax]);
hold all;
V = axis(gca);

m = mean(dpd_ad);
plot([m m],V(3:4),'k','LineWidth',2);

box off;

% add mean to histogram

% now plot BL->WO histogram
subplot1(4);
bins = ymin:y_binSize:ymax;
hist(dmd_ad,bins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

hold all;
V = axis(gca);
m = mean(dmd_ad);
plot([m m],V(3:4),'k','LineWidth',2);

set(gca,'XTick',[],'YTick',[],'XLim',[ymin,ymax]);
set(gca,'CameraUpVector',[-1,0,0]);
set(gca, 'Xdir', 'reverse')

box off;

% plot scatter of PD changes
subplot1(3);
hold all;
for i = 1:length(dpd_ad)
    plot(dpd_ad(i),dmd_ad(i),'d','LineWidth',2,'Color',classColors{classes(i)});
end

set(gca,'XLim',[xmin,xmax],'YLim',[ymin,ymax],'FontSize',14,'TickDir','out')

V = axis(gca);
plot([V(1) V(2)],[0 0],'k--');
plot([0 0],[V(3) V(4)],'k--');
plot([V(1) V(2)],[V(3) V(4)],'k-');

plot([mean(dpd_ad) mean(dpd_ad)],V(3:4),'k','LineWidth',2);
plot(V(1:2),[mean(dmd_ad) mean(dmd_ad)],'k','LineWidth',2);
xlabel(x_lab,'FontSize',14);
ylabel(y_lab,'FontSize',14);

box off;




