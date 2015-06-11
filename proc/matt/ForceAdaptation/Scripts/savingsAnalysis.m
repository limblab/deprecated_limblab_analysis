root_dir = 'F:\';
monkey = 'Mihili';
usePert = 'FF';
useTasks = {'CO'};
useMetric = 'errors';
% useMetric = 'curvatures';

doAbs = false;
numAttempts = 3;
alabels = {'1','14','15','32'};

%%
allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
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

%%
dateInds = ismember(allFiles(:,1),monkey) & ismember(allFiles(:,3),usePert) & ismember(allFiles(:,4),useTasks);
doFiles = allFiles(dateInds,:);

clear err;
err = cell(1,size(doFiles,1));
blerr = cell(1,size(doFiles,1));
for iFile = 1:size(doFiles,1)
    load(fullfile(root_dir,monkey,doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_adaptation_' doFiles{iFile,2} '.mat']));
    
    utheta = unique(BL.movement_table(:,1));
    
    % get the first reaches to each target
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(AD.movement_table(:,1)==utheta(iDir),numAttempts,'first');
        temp(iDir,:) = AD.(useMetric)(idx)';
    end
    err{iFile} = temp.*(180/pi);
    
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(BL.movement_table(:,1)==utheta(iDir),numAttempts,'last');
        temp(iDir,:) = BL.(useMetric)(idx)';
    end
    
    blerr{iFile} = temp.*(180/pi);
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
for iFile = 1:size(doFiles,1)
    e = reshape(err{iFile},numAttempts*size(err{iFile},1),1);
    bl = reshape(blerr{iFile},numAttempts*size(err{iFile},1),1);
    
    m = mean(e,1) - mean(bl,1);
    if doAbs
        m = abs(m);
    end
    
    plot(iFile,m,'bo','LineWidth',2);
    plot([iFile;iFile],[m+std(e,[],1)./sqrt(numAttempts*size(e,1));m-std(e,[],1)./sqrt(numAttempts*size(e,1))],'b','LineWidth',2);
end
set(gca,'Box','off','TickDir','out','XLim',[0 size(doFiles,1)+1],'FontSize',14,'XTick',1:size(doFiles,1),'XTickLabel',alabels);
xlabel('Days Since First Exposure','FontSize',16);
ylabel('Error in early target attempts','FontSize',16);


%%
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
monkey = 'Chewie';
usePert = 'FF';
useTasks = {'CO'};
useMetric = 'errors';
% useMetric = 'curvatures';

alabels = {'1','2','9','10','42','43'};

%
allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
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

%
dateInds = ismember(allFiles(:,1),monkey) & ismember(allFiles(:,3),usePert) & ismember(allFiles(:,4),useTasks);
doFiles = allFiles(dateInds,:);

err = cell(1,size(doFiles,1));
blerr = cell(1,size(doFiles,1));
for iFile = 1:size(doFiles,1)
    load(fullfile(root_dir,monkey,doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_adaptation_' doFiles{iFile,2} '.mat']));
    
    utheta = unique(BL.movement_table(:,1));
    
    % get the first reaches to each target
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(AD.movement_table(:,1)==utheta(iDir),numAttempts,'first');
        temp(iDir,:) = AD.(useMetric)(idx)';
    end
    err{iFile} = temp.*(180/pi);
    
    temp = zeros(length(utheta),numAttempts);
    for iDir = 1:length(utheta)
        idx = find(BL.movement_table(:,1)==utheta(iDir),numAttempts,'last');
        temp(iDir,:) = BL.(useMetric)(idx)';
    end
    blerr{iFile} = temp.*(180/pi);
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
end
set(gca,'Box','off','TickDir','out','XLim',[0 size(doFiles,1)+1],'FontSize',14,'XTick',1:size(doFiles,1),'XTickLabel',alabels);
xlabel('Days Since First Exposure','FontSize',16);
ylabel('Error in early target attempts','FontSize',16);
