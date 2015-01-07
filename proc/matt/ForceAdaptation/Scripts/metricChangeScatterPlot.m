% This is for a general "population PD change scatter plot". Horizontal and
% vertical axis can be specified independently to be:
%   - Any epoch difference (eg BL->AD, BL->WO, etc)
%   - Any metric (PD, MD, BO, FR)
%   - Any parameter set (e.g. 'movement' and 'target'
%
% The scatterAxes variable is important here. It is a two-element cell
% array, where each element is a string with 6 characters. The first three
% are the 3-letter abbreviations for the metric (PD, MD, BO, FR... add a 
% 'd' after for difference and an 's' after for the exact epoch) and the
% last two are the two-letter abbreviations for the epochs for PD changes
% (AD, WO). A dash separates. . In the case of difference, 'AD' actually
% means 'AD minus BL', and 'WO' means 'WO minus BL'.
% Example: scatterAxes = {'dPD-AD','dMD-WO'};
%           or scatterAxes = {'dPD-AD','FRs-BL'};

classColors = {'k','b','r','m','g'};
classNames = {'Kinematic','Dynamic','Memory I','Memory II','Other'};

%% Hardcode define axis information for plots
axisInfo.PDs.min = -180;
axisInfo.PDs.max = 180;
axisInfo.PDs.binSize = 10;
axisInfo.PDs.label = 'Preferred Direction (Deg) ';

axisInfo.PDd.min = -180;
axisInfo.PDd.max = 180;
axisInfo.PDd.binSize = 10;
axisInfo.PDd.label = 'PD Change (Deg) ';

axisInfo.MDs.min = 0;
axisInfo.MDs.max = 50;
axisInfo.MDs.binSize = 2;
axisInfo.MDs.label = 'Modulation Depth (Hz) ';

axisInfo.MDd.min = -30;
axisInfo.MDd.max = 30;
axisInfo.MDd.binSize = 2;
axisInfo.MDd.label = 'MD Change (Hz) ';

axisInfo.BOs.min = 0;
axisInfo.BOs.max = 50;
axisInfo.BOs.binSize = 2;
axisInfo.BOs.label = 'Offset (Hz) ';

axisInfo.BOd.min = -30;
axisInfo.BOd.max = 30;
axisInfo.BOd.binSize = 2;
axisInfo.BOd.label = 'BO Change (Hz) ';

axisInfo.FRs.min = 0;
axisInfo.FRs.max = 50;
axisInfo.FRs.binSize = 2;
axisInfo.FRs.label = 'Mean Firing Rate (Hz) ';

axisInfo.FRd.min = -30;
axisInfo.FRd.max = 30;
axisInfo.FRd.binSize = 2;
axisInfo.FRd.label = 'FR Change (Hz) ';

%%
% If we want to separate by waveform width...
if doWidthSeparation
    count = 0;
    clear allWFWidths;
    for iFile = 1:size(doFiles,1)
        % load baseline data to get width of all spike waveforms
        data = loadResults(root_dir,doFiles(iFile,:),'data',[],'BL');

        units = data.(useArray).units;
        for u = 1:length(units)
            count = count + 1;
            wf = mean(units(u).wf,2);
            idx = find(abs(wf) > std(wf));
            allWFWidths(count) = idx(end) - idx(1);
        end
    end
    % now, set the threshold for narrow and wide APs
    wfThresh = median(allWFWidths);
end

%% Get the classification for each day for tuned cells
cellClasses = cell(size(doFiles,1),1);
cellWidths = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
cellMDs = cell(size(doFiles,1),1);
cellBOs = cell(size(doFiles,1),1);
cellFRs = cell(size(doFiles,1),1);
cellR2 = cell(size(doFiles,1),1);
count = 0;
for iFile = 1:size(doFiles,1)
    % load tuning and class info
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    
    classifierBlocks = c.params.classes.classifierBlocks;
    
    if doWidthSeparation
        % load baseline data to get waveforms
        data = loadResults(root_dir,doFiles(iFile,:),'data',[],'BL');
        
        units = data.(useArray).units;
        fileWidths = zeros(length(units),1);
        wfTypes = zeros(length(units),1);
        for u = 1:length(units)
            wf = mean(units(u).wf,2);
            idx = find(abs(wf) > std(wf));
            switch doWidthSeparation
                case 1
                    wfTypes(u) = (idx(end) - idx(1)) <= wfThresh;
                case 2
                    wfTypes(u) = (idx(end) - idx(1)) > wfThresh;
                case 3
                    wfTypes(u) = 1;
            end
            fileWidths(u) = idx(end) - idx(1);
        end
    else
        wfTypes = ones(size(c(whichBlock).istuned,1),1);
        fileWidths = ones(size(c(whichBlock).istuned,1),1);
    end
    
    % first column is PD, second column is MD
    cellClasses{iFile} = c(whichBlock).classes(all(c(whichBlock).istuned,2) & wfTypes,1);
    
    tunedCells = c(whichBlock).sg(all(c(whichBlock).istuned,2) & wfTypes,:);
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    pds_bl = t(classifierBlocks(1)).pds(idx_bl,1);
    pds_ad = t(classifierBlocks(2)).pds(idx_ad,1);
    pds_wo = t(classifierBlocks(3)).pds(idx_wo,1);
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
    
    mds_bl = t(classifierBlocks(1)).mds(idx_bl,1);
    mds_ad = t(classifierBlocks(2)).mds(idx_ad,1);
    mds_wo = t(classifierBlocks(3)).mds(idx_wo,1);
    
    cellMDs{iFile} = {mds_bl, mds_ad, mds_wo};
    
    bos_bl = t(classifierBlocks(1)).bos(idx_bl,1);
    bos_ad = t(classifierBlocks(2)).bos(idx_ad,1);
    bos_wo = t(classifierBlocks(3)).bos(idx_wo,1);
    
    cellBOs{iFile} = {bos_bl, bos_ad, bos_wo};
    
    fr_bl = mean(t(classifierBlocks(1)).fr(:,idx_bl),1)';
    fr_ad = mean(t(classifierBlocks(2)).fr(:,idx_ad),1)';
    fr_wo = mean(t(classifierBlocks(3)).fr(:,idx_wo),1)';
    
    cellFRs{iFile} = {fr_bl, fr_ad, fr_wo};
    
    r2_bl = mean(t(classifierBlocks(1)).r_squared,2);
    r2_ad = mean(t(classifierBlocks(2)).r_squared,2);
    r2_wo = mean(t(classifierBlocks(3)).r_squared,2);
    
    cellWidths{iFile} = fileWidths(all(c(whichBlock).istuned,2) & wfTypes);
    cellR2{iFile} = {r2_bl(idx_bl), r2_ad(idx_ad), r2_wo(idx_wo)};
end

%%
% find all dPDs
pds_bl = []; pds_ad = []; pds_wo = [];
pdd_ad = []; pdd_wo = [];
mds_bl = []; mds_ad = []; mds_wo = [];
mdd_ad = []; mdd_wo = [];
bos_bl = []; bos_ad = []; bos_wo = [];
bod_ad = []; bod_wo = [];
frs_bl = []; frs_ad = []; frs_wo = [];
frd_ad = []; frd_wo = [];
classes = [];
r2s = [];
widths = [];
for iFile = 1:size(doFiles,1)
    pds = cellPDs{iFile};
    pds_bl = [pds_bl; pds{1}.*(180/pi)];
    pds_ad = [pds_ad; pds{2}.*(180/pi)];
    pds_wo = [pds_wo; pds{3}.*(180/pi)];
    pdd_ad = [pdd_ad; angleDiff(pds{1},pds{2},true,true).*(180/pi)];
    pdd_wo = [pdd_wo; angleDiff(pds{1},pds{3},true,true).*(180/pi)];
    
    mds = cellMDs{iFile};
    mds_bl = [mds_bl; mds{1}];
    mds_ad = [mds_ad; mds{2}];
    mds_wo = [mds_wo; mds{3}];
    mdd_ad = [mdd_ad; mds{2}-mds{1}];
    mdd_wo = [mdd_wo; mds{3}-mds{1}];
    
    bos = cellBOs{iFile};
    bos_bl = [bos_bl; bos{1}];
    bos_ad = [bos_ad; bos{2}];
    bos_wo = [bos_wo; bos{3}];
    bod_ad = [bod_ad; bos{2}-bos{1}];
    bod_wo = [bod_wo; bos{3}-bos{1}];
    
    frs = cellFRs{iFile};
    frs_bl = [frs_bl; frs{1}];
    frs_ad = [frs_ad; frs{2}];
    frs_wo = [frs_wo; frs{3}];
    frd_ad = [frd_ad; frs{2}-frs{1}];
    frd_wo = [frd_wo; frs{3}-frs{1}];
    
    c = cellClasses{iFile};
    w = cellWidths{iFile};
    
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
    widths = [widths; w];
    r2 = cellR2{iFile};
    r2s = [r2s; r2{1}];
end

%
% see if class correlates with R2
% plot(r2s,classes,'o');

%%
% decide what data to plot on two axes based on scatterAxes variable
x = scatterAxes{1};
eval(['x_data = ' lower(x(1:3)) '_' lower(x(5:6)) ';']);
xmin = axisInfo.(x(1:3)).min;
xmax = axisInfo.(x(1:3)).max;
xBinSize = axisInfo.(x(1:3)).binSize;
x_lab = [axisInfo.(x(1:3)).label 'BL->' x(1:2)];

y = scatterAxes{2};
eval(['y_data = ' lower(y(1:3)) '_' lower(y(5:6)) ';']);
ymin = axisInfo.(y(1:3)).min;
ymax = axisInfo.(y(1:3)).max;
yBinSize = axisInfo.(y(1:3)).binSize;
y_lab = [axisInfo.(y(1:3)).label 'BL->' y(1:2)];


if reassignOthers
    classColors = classColors(1:end-1);
    classNames = classNames(1:end-1);
end

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

xbins = xmin:xBinSize:xmax;
ybins = ymin:yBinSize:ymax;

% plot histogram of changes BL->AD
subplot1(1);
hist(x_data,xbins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

set(gca,'YTick',[],'XTick',[],'XLim',[xmin,xmax]);
hold all;
V = axis(gca);

m = mean(x_data);
plot([m m],V(3:4),'k','LineWidth',2);

box off;

% add mean to histogram

% now plot BL->WO histogram
subplot1(4);
hist(y_data,ybins);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','facealpha',1,'edgealpha',1);

hold all;
V = axis(gca);
m = mean(y_data);
plot([m m],V(3:4),'k','LineWidth',2);

set(gca,'XTick',[],'YTick',[],'XLim',[ymin,ymax]);
set(gca,'CameraUpVector',[-1,0,0]);
set(gca, 'Xdir', 'reverse')

box off;

% plot scatter of PD changes
subplot1(3);
hold all;
for i = 1:length(x_data)
    plot(x_data(i),y_data(i),'d','LineWidth',2,'Color',classColors{classes(i)});
end

set(gca,'XLim',[xmin,xmax],'YLim',[ymin,ymax],'FontSize',14,'TickDir','out')

V = axis(gca);
plot([V(1) V(2)],[0 0],'k--');
plot([0 0],[V(3) V(4)],'k--');
plot([V(1) V(2)],[V(3) V(4)],'k-');

plot([mean(x_data) mean(x_data)],V(3:4),'k','LineWidth',2);
plot(V(1:2),[mean(y_data) mean(y_data)],'k','LineWidth',2);
xlabel([x_lab 'BL->AD'],'FontSize',14);
ylabel(y_lab,'FontSize',14);

box off;




