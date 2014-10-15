% plot average velocity profile in BL, AD, WO for each monkey for each CO

% plot PD over windows of movement

clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
save_file = 'velocity_results.mat';

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
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
    'Mihili','2014-03-07','FF','CO'; ...    % 15
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


doFiles = allFiles(strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);

epochs = {'BL','AD','WO'};
colors = {'b','r','g'};
monkeys = {'Mihili','Chewie'};

timeDelay = 0.1;
holdTime = 0.5;

%%
load(fullfile(root_dir,save_file));

%%
allMoves = cell(size(doFiles,1),length(epochs));
for iEpoch = 2
    for iFile = 1:size(doFiles,1)
        
        if strcmpi(doFiles{iFile,1},'Chewie')
            ind = 2;
        else
            ind = 3;
        end
        
        fn = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' doFiles{iFile,2} '.mat']);
        data = load(fn);
        c = data.cont;
        
        [mt,~] = filterMovementTable(data,'movement',true,3,false);
        
        getMoves = zeros(size(mt,1),1000);
        for iMove = 1:size(mt,1)
            % get velocity between target presentation and trial end
            idx = c.t > mt(iMove,ind)-timeDelay & c.t < mt(iMove,6)-holdTime+timeDelay;
            v = sqrt(c.vel(idx,1).^2 + c.vel(idx,2).^2);
            
            % stretch out v to be 1000 samples
            v = interp1(1:length(v),v,1:length(v)/1000:length(v));
            getMoves(iMove,1:length(v)) = v;
            
            % if length(v) >= 1200
            %    getMoves(iMove,:) = v(1:1200);
            % else
            %    getMoves(iMove,:) = nan(1,1200);
            % end
            
            
        end
        
        allMoves{iFile,iEpoch} = getMoves;
        
    end
end

clear getMoves iFile iEpoch iMove v idx mt c data fn ind

%%
 save(fullfile(root_dir,save_file));

%%
close all;
figure;
subplot1(1,length(monkeys));
for iMonkey = 1:length(monkeys)
    subplot1(iMonkey);
    hold all;
    monkeyInds = strcmpi(doFiles(:,1),monkeys{iMonkey});
    
    for iEpoch = 1:length(epochs)
        temp = cellfun(@(x) nanmean(x),allMoves(monkeyInds,iEpoch),'UniformOutput',false);
        for iFile = 1:length(temp)
            if iMonkey == 2 && iFile == 1
                plot(temp{iFile},'--','Color',colors{iEpoch},'LineWidth',2);
            else
            plot(temp{iFile},'Color',colors{iEpoch},'LineWidth',2);
            end
        end
    end
    
    set(gca,'YLim',[0 30],'FontSize',14,'TickDir','out');
    xlabel('Samples','FontSize',14);
    if iMonkey==1
        ylabel('Velocity (cm/s)','FontSize',14);
    end
    title(monkeys{iMonkey},'FontSize',16);
end

%%
% find the difference from BL->AD and BL->WO in each bin for dPD vs Force
bins = [0.00000001 0.3;
        0.1 0.4;
        0.2 0.5;
        0.3 0.6;
        0.4 0.7;
        0.5 0.8;
        0.6 0.9;
        0.7 1.0];

allMeanVel = cell(length(monkeys),length(epochs));
for iMonkey = 1:length(monkeys)
    monkeyInds = strcmpi(doFiles(:,1),monkeys{iMonkey});
    
    for iEpoch = 1:length(epochs)
        temp = cellfun(@(x) nanmean(x),allMoves(monkeyInds,iEpoch),'UniformOutput',false);
        meanVel = zeros(length(temp),size(bins,1));
        for iFile = 1:length(temp)
            v=temp{iFile};
            for iBin = 1:size(bins,1)
                idx = ceil(1000*bins(iBin,1)):ceil(1000*bins(iBin,2));
                meanVel(iFile,iBin) = mean(v(idx));
            end
        end
        
        allMeanVel{iMonkey,iEpoch} = meanVel;
    end
end

% now plot differences for each monkey
figure;
subplot1(1,2);
for iMonkey = 1:length(monkeys)
    subplot1(iMonkey);
    hold all;
    
    meanVel = allMeanVel(iMonkey,:);
    
    ad_diff = meanVel{2}-meanVel{1};
    wo_diff = meanVel{3}-meanVel{1};
    
    m_ad = mean(ad_diff,1);
    s_ad = std(ad_diff,1)/sqrt(size(ad_diff,1));
    m_wo = mean(wo_diff,1);
    s_wo = std(wo_diff,1)/sqrt(size(wo_diff,1));
    
    plot(m_ad,'ro','LineWidth',3);
    plot(m_wo,'bo','LineWidth',3);
    for i=1:size(bins,1)
        plot([i,i],[m_ad(i)+s_ad(i),m_ad(i)-s_ad(i)],'r-','LineWidth',2);
    end
    for i=1:size(bins,1)
        plot([i,i],[m_wo(i)+s_wo(i),m_wo(i)-s_wo(i)],'b-','LineWidth',2);
    end
    
    if iMonkey==1
        ylabel('Change in Speed (cm/s)','FontSize',14);
    end
    set(gca,'FontSize',14,'TickDir','out');
    xlabel('Time Periods over the course of movement','FontSize',14);
    title(monkeys{iMonkey},'FontSize',16);
end
legend({'Force','Washout'},'FontSize',14);

%%
load(fullfile(root_dir,'force_results.mat'));
close all;
figure;
subplot1(1,length(monkeys));
for iMonkey = 1:length(monkeys)
    subplot1(iMonkey);
    hold all;
    monkeyInds = strcmpi(doFiles(:,1),monkeys{iMonkey});
    
    for iEpoch = 2:2 %:length(epochs)
        temp = cellfun(@(x) nanmean(x),allMoves(monkeyInds,iEpoch),'UniformOutput',false);
        for iFile = 1:length(temp)
                plot(temp{iFile}./max(temp{iFile}),'-','Color','b','LineWidth',2);
        end
    end
end

load(fullfile(root_dir,'velocity_results.mat'));
for iMonkey = 1:length(monkeys)
    subplot1(iMonkey);
    hold all;
    monkeyInds = strcmpi(doFiles(:,1),monkeys{iMonkey});
    
    for iEpoch = 2:2 %:length(epochs)
        temp = cellfun(@(x) nanmean(x),allMoves(monkeyInds,iEpoch),'UniformOutput',false);
        for iFile = 1:length(temp)
                plot(temp{iFile}./max(temp{iFile}),'-','Color','k','LineWidth',2);
        end
    end
    
    set(gca,'YLim',[0 1],'FontSize',14,'TickDir','out');
    xlabel('Samples','FontSize',14);
    if iMonkey==1
        ylabel('Velocity (cm/s)','FontSize',14);
    end
    title(monkeys{iMonkey},'FontSize',16);
end

