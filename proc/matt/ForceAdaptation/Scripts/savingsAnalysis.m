clear all;
clc;
close all;

root_dir = 'F:\';
monkey = 'Mihili';
usePert = 'FF';
useTasks = {'CO'};
useMetric = 'errors';
% useMetric = 'curvatures';

doAbs = false;
numAttempts = 4;
flipClockwisePerts = true;

%%
dataSummary;

%%
dateInds = ismember(sessionList(:,1),monkey) & ismember(sessionList(:,3),usePert) & ismember(sessionList(:,4),useTasks);
doFiles = sessionList(dateInds,:);

clear err;
err = cell(1,size(doFiles,1));
blerr = cell(1,size(doFiles,1));
pertDir = zeros(1,size(doFiles,1));
for iFile = 1:size(doFiles,1)
    load(fullfile(root_dir,monkey,'Processed',doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_adaptation_' doFiles{iFile,2} '.mat']));
    
    if flipClockwisePerts
        % gotta hack it
        dataPath = fullfile(root_dir,doFiles{iFile,1},'Processed',doFiles{iFile,2});
        expParamFile = fullfile(dataPath,[doFiles{iFile,2} '_experiment_parameters.dat']);
        BL.params.exp = parseExpParams(expParamFile);
        pertDir(iFile) = BL.params.exp.angle_dir;
    else
        pertDir(iFile) = 1;
    end
    
    utheta = unique(BL.movement_table(:,1));
    
    % get the first reaches to each target
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(AD.movement_table(:,1)==utheta(iDir),numAttempts,'last');
        temp(iDir,:) = AD.(useMetric)(idx)';
    end
    err{iFile} = pertDir(iFile).*temp.*(180/pi);
    
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(BL.movement_table(:,1)==utheta(iDir),numAttempts,'last');
        temp(iDir,:) = BL.(useMetric)(idx)';
    end
    
    blerr{iFile} = pertDir(iFile).*temp.*(180/pi);
end

y = []; g1 = []; g2 = [];
for iFile = 1:size(doFiles,1)
    y = [y; reshape(err{iFile},numAttempts*size(err{iFile},1),1)];
    % first grouping is session
    g1 = [g1; iFile.*ones(numAttempts*size(err{1},1),1)];
    % second grouping is target
    g2 = [g2; repmat((1:length(utheta))',numAttempts,1)];
end
p = anovan(y,{g1,g2},'display','off')


close all;
figure;
hold all;
xLabls = cell(1,size(doFiles,1));
for iFile = 1:size(doFiles,1)
    e = reshape(err{iFile},numAttempts*size(err{iFile},1),1);
    bl = reshape(blerr{iFile},numAttempts*size(err{iFile},1),1);
    
    m = mean(e,1) - mean(bl,1);
    if doAbs
        m = abs(m);
    end
    
    plot(iFile,m,'bo','LineWidth',2);
    plot([iFile;iFile],[m+std(e,[],1)./sqrt(numAttempts*size(e,1));m-std(e,[],1)./sqrt(numAttempts*size(e,1))],'b','LineWidth',2);
    
    % get label as number of days from first session
    xLabls{iFile} = ceil(etime(datevec(doFiles{iFile,2}),datevec(doFiles{1,2}))/(60*60*24));
end
set(gca,'Box','off','TickDir','out','XLim',[0 size(doFiles,1)+1],'FontSize',14,'XTick',1:size(doFiles,1),'XTickLabel',xLabls);
xlabel('Days Since First Session','FontSize',16);
ylabel('Error in early target attempts','FontSize',16);
title(monkey,'FontSize',16);


%%
root_dir = 'F:/';
monkey = 'Chewie';
usePert = 'FF';
useTasks = {'CO'};
useMetric = 'errors';
% useMetric = 'curvatures';

%
dateInds = ismember(sessionList(:,1),monkey) & ismember(sessionList(:,3),usePert) & ismember(sessionList(:,4),useTasks);
doFiles = sessionList(dateInds,:);

err = cell(1,size(doFiles,1));
blerr = cell(1,size(doFiles,1));
pertDir = zeros(1,size(doFiles,1));
for iFile = 1:size(doFiles,1)
    load(fullfile(root_dir,monkey,'Processed',doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_adaptation_' doFiles{iFile,2} '.mat']));
    
    if flipClockwisePerts
        % gotta hack it
        dataPath = fullfile(root_dir,doFiles{iFile,1},'Processed',doFiles{iFile,2});
        expParamFile = fullfile(dataPath,[doFiles{iFile,2} '_experiment_parameters.dat']);
        BL.params.exp = parseExpParams(expParamFile);
        pertDir(iFile) = BL.params.exp.angle_dir;
    else
        pertDir(iFile) = 1;
    end
    
    utheta = unique(BL.movement_table(:,1));
    
    % get the first reaches to each target
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(AD.movement_table(:,1)==utheta(iDir),numAttempts,'last');
        temp(iDir,:) = AD.(useMetric)(idx)';
    end
    err{iFile} = pertDir(iFile).*temp.*(180/pi);
    
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(BL.movement_table(:,1)==utheta(iDir),numAttempts,'last');
        temp(iDir,:) = BL.(useMetric)(idx)';
    end
    blerr{iFile} = pertDir(iFile).*temp.*(180/pi);
end

y = []; g1 = []; g2 = [];
for iFile = 1:size(doFiles,1)
    e = err{iFile} - repmat(mean(blerr{iFile},2),1,numAttempts);
    y = [y; reshape(e,numAttempts*size(e,1),1)];
    % first grouping is session
    g1 = [g1; iFile.*ones(numAttempts*size(e,1),1)];
    % second grouping is target
    g2 = [g2; repmat((1:length(utheta))',numAttempts,1)];
end
p = anovan(y,{g1,g2},'display','off')

figure;
hold all;
for iFile = 1:size(doFiles,1)
    e = reshape(err{iFile},numAttempts*size(err{iFile},1),1);
    bl = reshape(blerr{iFile},numAttempts*size(err{iFile},1),1);
    
    m = mean(e,1) - mean(bl,1);
    if doAbs
        m = abs(m);
    end
    
    plot(iFile,m,'ro','LineWidth',2);
    plot([iFile;iFile],[m+std(e,[],1)./sqrt(numAttempts*size(e,1));m-std(e,[],1)./sqrt(numAttempts*size(e,1))],'r','LineWidth',2);
    xLabls{iFile} = ceil(etime(datevec(doFiles{iFile,2}),datevec(doFiles{1,2}))/(60*60*24));
end
set(gca,'Box','off','TickDir','out','XLim',[0 size(doFiles,1)+1],'FontSize',14,'XTick',1:size(doFiles,1),'XTickLabel',xLabls);
xlabel('Days Since First Session','FontSize',16);
ylabel('Error in early target attempts','FontSize',16);
title(monkey,'FontSize',16);
