clear;
clc;
close all;

doFiles = { ...
            'Chewie','2013-10-22','FF','CO'; ... %5  S(M) ?
            'Chewie','2013-10-23','FF','CO'; ... %6  S(M) ?
            'Chewie','2013-10-31','FF','CO'; ... %9  S(M) ?
            'Chewie','2013-11-01','FF','CO'; ... %10 S(M) ?
            'Chewie','2013-12-03','FF','CO'; ... %11 S(M)
            'Chewie','2013-12-04','FF','CO'; ... %12 S(M)
            'Chewie','2015-06-29','FF','CO'; ... %30 S(M) - SHORT WASHOUT
            'Chewie','2015-06-30','FF','CO'; ... %31 S(M)
            'Chewie','2015-07-01','FF','CO'; ... %32 S(M)
            'Chewie','2015-07-03','FF','CO'; ... %33 S(M)
            'Chewie','2015-07-06','FF','CO'; ... %34 S(M)
            'Chewie','2015-07-07','FF','CO'; ... %35 S(M)
            'Chewie','2015-07-08','FF','CO'; ...
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-03-07','FF','CO'; ...    %15 S(M-P)
    'Mihili','2015-06-10','FF','CO'; ...    %23 S(M-P) - SHORT WASHOUT
    'Mihili','2015-06-11','FF','CO'; ...    %24 S(M-P) - SHORT WASHOUT
    'Mihili','2015-06-15','FF','CO'; ...    %26 S(M-P) - SOMETHING SEEMED WEIRD IN PMd POPULATION SO I'M SKIPPING FOR NOW
    'Mihili','2015-06-16','FF','CO'; ...
    };

for iFile = 1:size(doFiles,1)
    % load baseline data file
    data = load(['F:\' doFiles{iFile,1} '\Processed\' doFiles{iFile,2} '\CO_FF_AD_' doFiles{iFile,2} '.mat']);
    
    params = data.params;
    params = setParamValues(params,'paramSetName','movement2');
    params = parameterSets(params,'movement2');
    
    %
    [outFR, outTheta, blockMT] = getFR(data,params,'M1','onpeak');
    t = data.cont.t; pos = data.cont.pos; mt = blockMT{2}; fr = outFR{2}; th = outTheta{2}; clear outFR outTheta blockMT;
    
    utheta = unique(th);
    % utheta = unique(mt(:,1));
    c = distinguishable_colors(length(utheta));
    
    % find the number of successful reaches to each target direction
    numReaches = zeros(1,length(utheta));
    for iDir = 1:length(utheta)
        numReaches(iDir) = sum(th==utheta(iDir));
        %     numReaches(iDir) = sum(mt(:,1)==utheta(iDir));
    end
    minReaches = min(numReaches);
    
    % figure;
    % bar(utheta,numReaches,1);
    % set(gca,'Box','off','TickDir','out','FontSize',14);
    % xlabel('Target Direction','FontSize',16);
    % ylabel('Number of Rewards','FontSize',16);
    % axis('tight');
    
    % now, pick minReaches number of reaches to each target randomly
    ogFR = fr;
    ogTH = th;
    ogMT = mt;
    newMT = [];
    newFR = [];
    newTH = [];
    for iDir = 1:length(utheta)
        idx = find(th==utheta(iDir));
        %     idx = find(mt(:,1)==utheta(iDir));
        temp = randperm(length(idx));
        idx = idx(temp(1:minReaches));
        
        newMT = [newMT; mt(idx,:)];
        newFR = [newFR; fr(idx,:)];
        newTH = [newTH; th(idx)];
    end
    
    % randomly sample from original data to match trial counts
    temp = randperm(size(mt,1));
    mt = mt(temp(1:size(newMT,1)),:);
    th = th(temp(1:size(newMT,1)));
    fr = fr(temp(1:size(newMT,1)),:);
    
    % Fit cosine models with new data and old data
    [tc1,cb1,r1,bpd1] = regressTuningCurves(fr,th,{'bootstrap',1000,0.95},'doplots',false,'domeanfr',true,'doparallel',true);
    [tc2,cb2,r2,bpd2] = regressTuningCurves(newFR,newTH,{'bootstrap',1000,0.95},'doplots',false,'domeanfr',true,'doparallel',true);
    
    % Determine if significantly different
    confLevel = 0.95;
    numIters = 1000;
    
    o = zeros(1,size(bpd1,1));
    for unit = 1:size(bpd1,1)
        d = angleDiff(bpd1(unit,:),bpd2(unit,:),true,true);
        d = sort(d);
        
        ci_sig = [d(ceil(numIters*( (1 - confLevel)/2 ))), d(floor(numIters*( confLevel + (1-confLevel)/2 )))];
        
        % is 0 in the confidence bound? if not, it is different
        o(unit) = isempty(range_intersection([0 0],ci_sig));
    end
    allO{iFile} = o;
    allTC1{iFile} = tc1;
    allTC2{iFile} = tc2;
    allCB1{iFile} = cb1;
    allCB2{iFile} = cb2;
    allR1{iFile} = r1;
    allR2{iFile} = r2;
    allBPD1{iFile} = bpd1;
    allBPD2{iFile} = bpd2;
end
clear unit iFile o tc1 tc2 cb1 cb2 r1 r2 bpd1 bpd2 ci_sig d fr th data mt temp idx minReaches numReaches c t pos iDir;

%% plot
clear;
clc;
close all;
% a=cell2mat(cellfun(@(x) x',allO,'UniformOutput',false)');

doAbs = false;
useInds = 1:6;
nBins = 0:1:40;
xRange = [0 40];
yRange = [0 40];

figure;
subplot1(3,1);
subplot1(1);
load('uniform_pd_comparison_bl_matched.mat')

for iFile = 1:size(doFiles,1)
    c = loadResults('F:\',doFiles(iFile,:),'tuning',{'classes'},'M1','movement','regression','onpeak');
    allO{iFile} = allO{iFile}(all(c.istuned(:,useInds),2));
    allTC1{iFile} = allTC1{iFile}(all(c.istuned(:,useInds),2),:);
    allTC2{iFile} = allTC2{iFile}(all(c.istuned(:,useInds),2),:);
    allCB1{iFile}{3} = allCB1{iFile}{3}(all(c.istuned(:,useInds),2),:);
    allCB2{iFile}{3} = allCB2{iFile}{3}(all(c.istuned(:,useInds),2),:);
end

a=angleDiff(cell2mat(cellfun(@(x) x(:,3),allTC1,'UniformOutput',false)'),cell2mat(cellfun(@(x) x(:,3),allTC2,'UniformOutput',false)'),true,~doAbs);
hist(a.*(180/pi),nBins);
axis('tight');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',xRange,'YLim',yRange);
xlabel('Change in PD with uniformity','FontSize',14);
ylabel('Baseline','FontSize',16);

subplot1(2);
% load('uniform_pd_comparison_ad1.mat')
load('uniform_pd_comparison_ad1_matched.mat')

for iFile = 1:size(doFiles,1)
    c = loadResults('F:\',doFiles(iFile,:),'tuning',{'classes'},'M1','movement','regression','onpeak');
    allO{iFile} = allO{iFile}(all(c.istuned(:,useInds),2));
    allTC1{iFile} = allTC1{iFile}(all(c.istuned(:,useInds),2),:);
    allTC2{iFile} = allTC2{iFile}(all(c.istuned(:,useInds),2),:);
end

a2=angleDiff(cell2mat(cellfun(@(x) x(:,3),allTC1,'UniformOutput',false)'),cell2mat(cellfun(@(x) x(:,3),allTC2,'UniformOutput',false)'),true,~doAbs);
hist(a2.*(180/pi),nBins);
axis('tight');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',xRange,'YLim',yRange);
xlabel('Change in PD with uniformity','FontSize',14);
ylabel('Early Adaptation','FontSize',16);

% figure;
% boxplot([a a2].*(180/pi));
% set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',[1 2],'XTickLabel',{'Base','Force'});
% ylabel('PD Change with Uniformity (Deg)','FontSize',14);

load('uniform_pd_comparison_bl.mat')
for iFile = 1:size(doFiles,1)
    c = loadResults('F:\',doFiles(iFile,:),'tuning',{'classes'},'M1','movement','regression','onpeak');
    allO{iFile} = allO{iFile}(all(c.istuned(:,useInds),2));
    allTC1{iFile} = allTC1{iFile}(all(c.istuned(:,useInds),2),:);
    allTC2{iFile} = allTC2{iFile}(all(c.istuned(:,useInds),2),:);
    allCB1{iFile}{3} = allCB1{iFile}{3}(all(c.istuned(:,useInds),2),:);
    allCB2{iFile}{3} = allCB2{iFile}{3}(all(c.istuned(:,useInds),2),:);
end
a3 = cell2mat(cellfun(@(x) angleDiff(x{3}(:,1),x{3}(:,2),true,false),allCB1,'UniformOutput',false)');
subplot1(3);
hist(a3.*(180/pi),nBins);
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',xRange,'YLim',yRange);
xlabel('Degrees','FontSize',14);
ylabel('BL Confidence Bounds','FontSize',16);

figure;
hold all;
plot(a3.*(180/pi),a.*(180/pi),'ko');
plot(a3.*(180/pi),a2.*(180/pi),'bd');
axis('tight');
set(gca,'Box','off','TickDir','out','FontSize',14);

%%
close all;

figure;
subplot1(1,2);
subplot1(1);
hist(tc1(:,3).*(180/pi),22);
subplot1(2);
hist(tc2(:,3).*(180/pi),22);

figure;
hist(angleDiff(tc1(:,3),tc2(:,3),true,true).*(180/pi),50);
set(gca,'Box','off','TickDir','out','FontSize',14);
xlabel('Change in PD Non-Uniform to Uniform (Deg)','FontSize',14);
ylabel('Count','FontSize',14);

%%
figure;
hist(oldMT(:,1),utheta)
set(gca,'Box','off','TickDir','out','FontSize',14);
xlabel('Target Direction','FontSize',16);
ylabel('Number of Rewards','FontSize',16);
axis('tight');

figure;
hist(th,8)
set(gca,'Box','off','TickDir','out','FontSize',14);
xlabel('Hand Direction','FontSize',16);
ylabel('Number of Rewards','FontSize',16);
axis('tight');

figure;
hist(th,80)
set(gca,'Box','off','TickDir','out','FontSize',14);
xlabel('Hand Direction','FontSize',16);
ylabel('Number of Rewards','FontSize',16);
axis('tight');

%%
% now, loop along trials in table and align all positions to 0 degree target
figure;
subplot1(1,2,'YTickL','All','Gap',[0.05 0.05]);
subplot1(1); hold all;
subplot1(2); hold all;
for iTrial = 1:size(mt,1)
    idx = t >= mt(iTrial,3) & t <= mt(iTrial,6)-0.3;
    usePos = pos(idx,:);
    usePos(:,1) = usePos(:,1)-usePos(1,1);
    usePos(:,2) = usePos(:,2)-usePos(1,2);
    subplot1(1);
    plot(usePos(:,1),usePos(:,2),'Color',c(utheta == mt(iTrial,1),:));
    
    rotationAngle = -mt(iTrial,1);
    R = [cos(rotationAngle) -sin(rotationAngle); sin(rotationAngle) cos(rotationAngle)];
    newPos = zeros(size(usePos));
    for j = 1:length(usePos)
        newPos(j,:) = R*(usePos(j,:)');
    end
    subplot1(2);
    plot(newPos(:,1),newPos(:,2),'Color',c(utheta == mt(iTrial,1),:));
end
subplot1(1);
axis('tight');
set(gca,'Box','off','TickDir','out','FontSize',14);
subplot1(2);
axis('tight');
set(gca,'Box','off','TickDir','out','FontSize',14);

%%
doFiles = { ...
    %         'Chewie','2013-10-22','FF','CO'; ... %5  S(M) ?
    %         'Chewie','2013-10-23','FF','CO'; ... %6  S(M) ?
    %         'Chewie','2013-10-31','FF','CO'; ... %9  S(M) ?
    %         'Chewie','2013-11-01','FF','CO'; ... %10 S(M) ?
    %         'Chewie','2013-12-03','FF','CO'; ... %11 S(M)
    %         'Chewie','2013-12-04','FF','CO'; ... %12 S(M)
    %         'Chewie','2015-06-29','FF','CO'; ... %30 S(M) - SHORT WASHOUT
    %         'Chewie','2015-06-30','FF','CO'; ... %31 S(M)
    %         'Chewie','2015-07-01','FF','CO'; ... %32 S(M)
    %         'Chewie','2015-07-03','FF','CO'; ... %33 S(M)
    %         'Chewie','2015-07-06','FF','CO'; ... %34 S(M)
    %         'Chewie','2015-07-07','FF','CO'; ... %35 S(M)
    %         'Chewie','2015-07-08','FF','CO'; ...
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-03-07','FF','CO'; ...    %15 S(M-P)
    'Mihili','2015-06-10','FF','CO'; ...    %23 S(M-P) - SHORT WASHOUT
    'Mihili','2015-06-11','FF','CO'; ...    %24 S(M-P) - SHORT WASHOUT
    'Mihili','2015-06-15','FF','CO'; ...    %26 S(M-P) - SOMETHING SEEMED WEIRD IN PMd POPULATION SO I'M SKIPPING FOR NOW
    'Mihili','2015-06-16','FF','CO'};

figure;
hold all;
count = 1;

epochs = {'BL','AD','WO'};

allM = zeros(size(doFiles,1),4);
for iFile = 1:size(doFiles,1)
    m = zeros(1,4);
    count = 1;
    for iEpoch = 1:length(epochs)
        data = load(['F:\' doFiles{iFile,1} '\Processed\' doFiles{iFile,2} '\CO_FF_' epochs{iEpoch} '_' doFiles{iFile,2} '.mat']);
        params = data.params;
        params = setParamValues(params,'paramSetName','movement2');
        params = parameterSets(params,'movement2');
        
        [outFR, outTheta, blockMT] = getFR(data,params,'M1','onpeak');
        
        for i = 1:length(blockMT)
            th = outTheta{i};
            mt = blockMT{i};
            
            % calculate non-uniformity metric for each block
            utheta = unique(th);
            
            % find the number of successful reaches to each target direction
            numReaches = zeros(1,length(utheta));
            for iDir = 1:length(utheta)
                numReaches(iDir) = sum(th==utheta(iDir));
            end
            m(count) = mean(sqrt((numReaches - mean(numReaches)).^2));
            
            %         plot(count,mean(m),'ko');
            %         plot([count count],[mean(m)+std(m)./sqrt(length(m)) mean(m)-std(m)./sqrt(length(m))],'k-');
            
            count = count + 1;
        end
    end
    
    allM(iFile,:) = m;
end

plot(1:4,mean(allM,1),'ko');
plot([1:4; 1:4],[mean(allM,1)+std(allM,[],1)./sqrt(size(allM,1)); mean(allM,1)-std(allM,[],1)./sqrt(size(allM,1))],'k-');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 5],'XTick',[1 2 3 4],'XTickLabel',{'BL','Force1','Force2','Wash'});
ylabel('Average Non-uniformity (# reaches)','FontSize',14);
