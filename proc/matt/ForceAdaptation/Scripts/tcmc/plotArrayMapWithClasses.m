%% Plot array maps with classes
useDate = '2013-08-22';
load(fullfile(baseDir,useDate,['RT_FF_classes_' useDate '.mat']));

inds = classes.PMd.regression.peak.tuned_cells;
cells = classes.PMd.regression.peak.unit_guide(inds);
classes = classes.PMd.regression.peak.classes(inds);

% load the array map
MrT_PMd_arraymap;

% loop along the cells
class_map = -1*ones(size(array_map));

for unit = 1:length(inds)
    currElec = cells(unit,1);
    ind = array_map==currElec;
    
    if class_map(ind) == -1
        class_map(ind) = classes(unit);
    elseif class_map(ind) == classes(unit)
        % do nothing
    elseif class_map(ind) ~= classes(unit)
        class_map(ind) = 0; % quick hack to fill in... fix it
    else
        error('something seems to be wrong here...');
    end
end

fh = figure('Position',[200 200 1200 600]);
subplot1(1,2);
subplot1(1);
% plot the array map
imagesc(-class_map,[-3 1]); colormap('hot');
ylabel(leftside,'FontSize',14);
xlabel(bottomside,'FontSize',14);
set(gca,'XTick',[],'YTick',[]);
title('Force Field','FontSize',16);

% now for a visual rotation day
useDate = '2013-09-04';
load(fullfile(baseDir,useDate,['RT_VR_classes_' useDate '.mat']));

inds = classes.PMd.regression.peak.tuned_cells;
cells = classes.PMd.regression.peak.unit_guide(inds);
classes = classes.PMd.regression.peak.classes(inds);

% load the array map
MrT_PMd_arraymap;

% loop along the cells
class_map = -1*ones(size(array_map));

for unit = 1:length(inds)
    currElec = cells(unit,1);
    ind = array_map==currElec;
    
    if class_map(ind) == -1
        class_map(ind) = classes(unit);
    elseif class_map(ind) == classes(unit)
        % do nothing
    elseif class_map(ind) ~= classes(unit)
        class_map(ind) = 0; % quick hack to fill in... fix it
    else
        error('something seems to be wrong here...');
    end
end

subplot1(2);
ax = gca;
% plot the array map
imagesc(-class_map,[-3 1]); colormap('hot');
xlabel(bottomside,'FontSize',14);
set(gca,'XTick',[],'YTick',[]);
title('Visual Rotation','FontSize',16);

c = colorbar('East');
set(c,'YTick',[-3 -2 -1 0 1],'YTickLabel',{'Memory','Adapting','Non-adapting','Mix','None'},'FontSize',14);

