% plot PD over windows of movement

clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
% root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\m1_cf_paper_results\';

allFiles = {'MrT','2013-08-19','FF','CO'; ...   % S x
    'MrT','2013-08-20','FF','RT'; ...   % S x
    'MrT','2013-08-21','FF','CO'; ...   % S x - AD is split in two so use second but don't exclude trials
    'MrT','2013-08-22','FF','RT'; ...   % S x
    'MrT','2013-08-23','FF','CO'; ...   % S x
    'MrT','2013-08-30','FF','RT'; ...   % S x
    'MrT','2013-09-03','VR','CO'; ...   % S x
    'MrT','2013-09-04','VR','RT'; ...   % S x
    'MrT','2013-09-05','VR','CO'; ...   % S x
    'MrT','2013-09-06','VR','RT'; ...   % S x
    'MrT','2013-09-09','VR','CO'; ...   % S x
    'MrT','2013-09-10','VR','RT'; ...   % S x
    'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    %'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    %'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
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


useArray = 'M1';
classifierBlocks = [1 2 3];

switch lower(useArray)
    case 'm1'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'Chewie'),:);
    case 'pmd'
        allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili') | strcmpi(allFiles(:,1),'MrT'),:);
end

paramSetName = 'move_time';
tuningMethod = 'regression';
% tuningPeriods = {'time1','time2','time3','time4','time5','time6','time7','time8'};
tuningPeriods = {'time1','time2','time3','time4','time5','time6','time7','time8','time9','time10','time11','time12','time13','time14','time15'};
% tuningPeriods = {'time1','time3','time5','time7','time9','time11','time13','time15'};
colors = {'k','b','r'};

monkeys = {'Chewie','Mihili'};

remove_predicted = false;
doMD = false;
doAvg = true;
useVel = false;
useMasterTuned = false;


if ~doMD
    doAbs = true;
    doCirc = false;
    ymin_pd = 40;
    ymax_pd = 110;
    binSize = 10;
    plotMult = 180/pi;
    y_lab = 'PD Change (Deg) ';
else
    doAbs = true;
    if doAbs
        ymin_pd = -1;
        ymax_pd = 5;
    else
        ymin_pd = -5;
        ymax_pd = 5;
    end
    binSize = 2;
    plotMult = 1;
    y_lab = 'MD Change (Hz) ';
    
end

if useVel
    ymin_f = 10;
    ymax_f = 28;
else
    ymin_f = 0;
    ymax_f = 2.8;
end


h1 = figure();
subplot1(1,length(monkeys));
% h2 = figure();
% subplot1(1,length(monkeys));
% h3 = figure();
% subplot1(1,length(monkeys));
h4 = figure();
subplot1(1,length(monkeys));
%%
for iMonkey = 1:length(monkeys)
    
    doFiles = allFiles(strcmpi(allFiles(:,1),monkeys{iMonkey}) & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);
    % Get the cells that are well-tuned from my normal analysis
    if useMasterTuned
        masterTunedSG = cell(size(doFiles,1),1);
        masterTuned = cell(size(doFiles,1),1);
        for iFile = 1:size(doFiles,1)
            classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},'Movement',[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
            classes = load(classFile);
            masterTunedSG{iFile} = classes.(tuningMethod).onpeak.(useArray).tuned_cells;
            masterTuned{iFile} = all(classes.(tuningMethod).onpeak.(useArray).istuned,2);
        end
    end
    
    %
    cellPDs = cell(size(doFiles,1),length(classifierBlocks));
    meanForce = cell(size(doFiles,1),length(classifierBlocks));
    meanVel = cell(size(doFiles,1),length(classifierBlocks));
    
    for iFile = 1:size(doFiles,1)
        classFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_classes_' doFiles{iFile,2} '.mat']);
        classes = load(classFile);
        
        tuningFile = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},paramSetName,[doFiles{iFile,4} '_' doFiles{iFile,3} '_tuning_' doFiles{iFile,2} '.mat']);
        tuning = load(tuningFile);
        
        for iBlock = 1:length(classifierBlocks)
            neurons = struct();
            force = zeros(1,length(tuningPeriods));
            vel = zeros(1,length(tuningPeriods));
            for iPeriod = 1:length(tuningPeriods)
                tuningPeriod = tuningPeriods{iPeriod};
                
                t=tuning.(tuningMethod).(tuningPeriod).(useArray).tuning;
                
                % find average force
                if useVel
                    f = t(classifierBlocks(iBlock)).vels;
                    v = t(classifierBlocks(iBlock)).vels;
                else
                    f = t(classifierBlocks(iBlock)).forces;
                    v = t(classifierBlocks(iBlock)).vels;
                end
                
                force(iPeriod) = mean(sqrt( f(:,1).^2 + f(:,2).^2 ));
                vel(iPeriod) = mean(sqrt( v(:,1).^2 + v(:,2).^2 ));
                
                c = classes.(tuningMethod).(tuningPeriod).(useArray);
                sg = t(classifierBlocks(iBlock)).sg;
                
                if useMasterTuned
                    tunedCells = masterTunedSG{iFile};
                else
                    tunedCells = sg(all(c.istuned,2),:);
                end
                
                [~,idx] = intersect(sg, tunedCells,'rows');
                
                inds = find(idx);
                
                for i=1:length(inds)
                    if ~doMD
                        if ~isfield(neurons,[ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ])
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds = NaN(1,length(tuningPeriods));
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iPeriod) = t(classifierBlocks(iBlock)).pds(inds(i),1);
                        else
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iPeriod) = t(classifierBlocks(iBlock)).pds(inds(i),1);
                        end
                    else
                        if ~isfield(neurons,[ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ])
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds = NaN(1,length(tuningPeriods));
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iPeriod) = t(classifierBlocks(iBlock)).mds(inds(i),1);
                        else
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iPeriod) = t(classifierBlocks(iBlock)).mds(inds(i),1);
                        end
                    end
                end
            end
            
            meanForce{iFile,iBlock} = force;
            meanVel{iFile,iBlock} = vel;
            cellPDs{iFile,iBlock} = neurons;
        end
    end
    
    
    % Reorganize data to get all cells together
    dPDs = cell(size(doFiles,1),2);
    bl_pds = [];
    ad_pds = [];
    wo_pds = [];
    % only adaptation period makes sense for this, since force is mostly
    % noise otherwise
    for iFile = 1:size(doFiles,1)
        bl_neurons = cellPDs{iFile,1};
        ad_neurons = cellPDs{iFile,2};
        wo_neurons = cellPDs{iFile,3};
        fn = fieldnames(bl_neurons);
        for i = 1:length(fn)
            bl = bl_neurons.(fn{i}).pds;
            ad = ad_neurons.(fn{i}).pds;
            wo = wo_neurons.(fn{i}).pds;
            if ~any(isnan(bl)) && ~any(isnan(ad)) && ~any(isnan(wo))
                bl_pds = [bl_pds; bl];
                ad_pds = [ad_pds; ad];
                wo_pds = [wo_pds; wo];
            end
        end
        
        % now find difference from baseline
        if ~doMD
            for unit = 1:size(bl_pds,1)
                bl_ad(unit,:) = angleDiff(bl_pds(unit,:),ad_pds(unit,:),true,~doAbs);
                bl_wo(unit,:) = angleDiff(bl_pds(unit,:),wo_pds(unit,:),true,~doAbs);
            end
            
            dPDs{iFile,1} = bl_ad;
            dPDs{iFile,2} = bl_wo;
        else
            dPDs{iFile,1} = ad_pds - bl_pds;
            dPDs{iFile,2} = wo_pds - bl_pds;
        end
    end
    
    % Now, plot mean change in PD against force
    figure(h1);
    subplot1(iMonkey);
    hold all;
    allForce = [];
    allVel = [];
    alldPDs = [];
    periodPDs_AD = [];
    periodPDs_WO = [];
    periodForce = [];
    periodVel = [];
    % now plot the means
    for iFile = 1:size(doFiles,1)
        dpd = dPDs{iFile,1};
        force = meanForce{iFile,2}-meanForce{iFile,1};
        vel = meanVel{iFile,2};
        
        % plot them
        if doAbs
            minnum = 0;
        else
            minnum = 2;
        end
        if size(dpd,1) > minnum
            for i = 1:size(dpd,2)
                temp = force(i);
                tempv = vel(i);
                if ~doMD
                    if doCirc
                        plot(temp,circular_mean(dpd(:,i)).*(180/pi),'o','Color',colors{2},'LineWidth',2);
                    else
                        plot(temp,mean(dpd(:,i)).*(180/pi),'o','Color',colors{2},'LineWidth',2);
                    end
                else
                    plot(temp,mean(dpd(:,i)),'o','Color',colors{2},'LineWidth',2);
                end
                
                
                
                if doAvg
                    allForce = [allForce; temp];
                    allVel = [allVel; tempv];
                    if ~doMD
                        if doCirc
                            alldPDs = [alldPDs; circ_mean(dpd(:,i))];
                        else
                            alldPDs = [alldPDs; mean(dpd(:,i))];
                        end
                    else
                        if doAbs
                            alldPDs = [alldPDs; mean(abs(dpd(:,i)))];
                        else
                            alldPDs = [alldPDs; mean(dpd(:,i))];
                        end
                    end
                else
                    alldPDs = [alldPDs; dpd(:,i)];
                    allForce = [allForce; repmat(temp,length(dpd(:,i)),1)];
                end
            end
            
            if doAvg
                if ~doMD
                    if doCirc
                        periodPDs_AD = [periodPDs_AD; circular_mean(dPDs{iFile,1}).*(180/pi)];
                        periodPDs_WO = [periodPDs_WO; circular_mean(dPDs{iFile,2}).*(180/pi)];
                    else
                        periodPDs_AD = [periodPDs_AD; mean(dPDs{iFile,1}).*(180/pi)];
                        periodPDs_WO = [periodPDs_WO; mean(dPDs{iFile,2}).*(180/pi)];
                    end
                else
                    if doAbs
                        periodPDs_AD = [periodPDs_AD; mean(abs(dPDs{iFile,1}))];
                        periodPDs_WO = [periodPDs_WO; mean(abs(dPDs{iFile,2}))];
                    else
                        periodPDs_AD = [periodPDs_AD; mean(dPDs{iFile,1})];
                        periodPDs_WO = [periodPDs_WO; mean(dPDs{iFile,2})];
                    end
                end
            else
                periodPDs_AD = [periodPDs_AD; dPDs{iFile,1}.*(180/pi)];
                periodPDs_WO = [periodPDs_WO; dPDs{iFile,2}.*(180/pi)];
            end
            
            periodForce = [periodForce; force];
            periodVel = [periodVel; vel];
        end
    end
    
    
    % fit a regression line
    [b,bint,~,~,stats] = regress(alldPDs,[ones(length(allForce),1) allForce]);
    stats
    plot(allForce,(b(1)+b(2)*allForce).*plotMult,'r');
    set(gca,'YLim',[-40,120],'TickDir','out','FontSize',14);
    xlabel('Force','FontSize',14);
    if iMonkey == 1
        ylabel('Mean dPD','FontSize',14);
    end
    title(['p = ' num2str(stats(3))],'FontSize',14);
    
    allMonkeydPDs{iMonkey} = alldPDs;
    allMonkeyForce{iMonkey} = allForce;
    allMonkeyVel{iMonkey} = allVel;
    allMonkeyFits{iMonkey,1} = b;
    allMonkeyFits{iMonkey,2} = bint;
    
%     clear npf npa
%     for i = 2:2:size(periodForce,2)
%         npf(:,i/2) = [periodForce(:,i); periodForce(:,i+1)];
%         npa(:,i/2) = [periodPDs_AD(:,i); periodPDs_AD(:,i+1)];
%     end
%     periodForce = npf;
%     periodPDs_AD = npa;
    
    % NOW FUN STUFF!
    % plot on dual axes PD change and RMS force
    figure(h4);
    subplot1(iMonkey);
    ax1 = gca;
    hold all;
    plot(1:size(periodPDs_AD,2),mean(periodPDs_AD,1),'-','LineWidth',2,'Color','r','Parent',ax1);
    %     plot(1:size(periodPDs_WO,2),mean(periodPDs_WO,1),'-','LineWidth',2,'Color','b','Parent',ax1);
    %     if iMonkey == 2
    %         legend({'Adaptation','Washout'},'FontSize',14);
    %     end
    
    plot(1:size(periodPDs_AD,2),mean(periodPDs_AD,1),'o','LineWidth',2,'Color','r','Parent',ax1);
    plot([1:size(periodPDs_AD,2);1:size(periodPDs_AD,2)],[mean(periodPDs_AD,1)+std(periodPDs_AD,1)/sqrt(size(periodPDs_AD,1));mean(periodPDs_AD,1)-std(periodPDs_AD,1)/sqrt(size(periodPDs_AD,1))],'LineWidth',2,'Color','r','Parent',ax1)
    %     plot(1:size(periodPDs_WO,2),mean(periodPDs_WO,1),'o','LineWidth',2,'Color','b','Parent',ax1);
    %     plot([1:size(periodPDs_WO,2);1:size(periodPDs_WO,2)],[mean(periodPDs_WO,1)+std(periodPDs_WO,1)/sqrt(size(periodPDs_WO,1));mean(periodPDs_WO,1)-std(periodPDs_WO,1)/sqrt(size(periodPDs_WO,1))],'LineWidth',2,'Color','b','Parent',ax1)
    
    % plot individual points
    %     for iBin = 1:size(periodPDs_AD,2)
    %         plot(repmat(iBin,1,size(periodPDs_AD,1)),periodPDs_AD(:,iBin),'o','LineWidth',2,'Color','r','Parent',ax1);
    %         plot(repmat(iBin,1,size(periodPDs_WO,1)),periodPDs_WO(:,iBin),'o','LineWidth',2,'Color','b','Parent',ax1)
    %     end
    
    
    plot([0 size(periodPDs_AD,2)+1],[0 0],'k--','Parent',ax1);
    
    set(gca,'XLim',[0,size(periodPDs_AD,2)+1],'YLim',[ymin_pd,ymax_pd],'XTick',1:size(periodPDs_AD,2),'XTickLabel',tuningPeriods,'TickDir','out','FontSize',14);
    if iMonkey == 1
        if ~doMD
            ylabel('Change in PD (Deg) Relative to Baseline','FontSize',14);
        else
            ylabel('Abs(Change in MD)','FontSize',14);
        end
    end
    xlabel('Time Periods over the course of movement','FontSize',14);
    box off;
    
    ax1_pos = get(ax1,'Position'); % store position of first axes
    ax2 = axes('Position',ax1_pos,...
        'YAxisLocation','right',...
        'Color','none', ...
        'TickDir','out');
  
    hold all;
    plot(1:size(periodForce,2),mean(periodForce,1),'o','LineWidth',2,'Color',[0.6 0.6 0.6],'Parent',ax2);
    plot(1:size(periodForce,2),mean(periodForce,1),'-','LineWidth',2,'Color',[0.6 0.6 0.6],'Parent',ax2);
    plot([1:size(periodForce,2);1:size(periodForce,2)],[mean(periodForce,1)+std(periodForce,1)/sqrt(size(periodForce,1));mean(periodForce,1)-std(periodForce,1)/sqrt(size(periodForce,1))],'LineWidth',2,'Color',[0.6 0.6 0.6],'Parent',ax2)
    
    set(gca,'XLim',[0,size(periodForce,2)+1],'YLim',[ymin_f,ymax_f],'XTick',[],'YColor',[0.4 0.4 0.4],'FontSize',14);
    if iMonkey == length(monkeys)
        if useVel
            ylabel('Velocity (cm/s)','FontSize',14);
        else
            ylabel('Force (N)','FontSize',14);
        end
        set(gca,'TickDir','out');
    else
        set(gca,'YTick',[],'TickDir','out');
    end
    title(monkeys{iMonkey},'FontSize',16);
    box off;
    
end

%% now, fit one line for all monkeys if necessary
if length(monkeys) > 1
    allForce = [];
    allVel = [];
    alldPDs = [];
    colors = {'r','b'};
    figure;
    hold all;
    for iMonkey = 1:length(monkeys)
        allForce = [allForce; allMonkeyForce{iMonkey}];
        allVel = [allVel; allMonkeyVel{iMonkey}];
        alldPDs = [alldPDs; allMonkeydPDs{iMonkey}];
        plot(allMonkeyForce{iMonkey},allMonkeydPDs{iMonkey}.*plotMult,'o','LineWidth',2,'Color',colors{iMonkey});
    end
    
    
    
    % remove some outliers
    m = mean(alldPDs);
    s = std(alldPDs);
    outliers = alldPDs > m+60*s;
    [b,bint,~,~,stats] = regress(alldPDs(~outliers),[ones(length(allForce(~outliers)),1) allForce(~outliers)]);
    plot(allForce,(b(1)+b(2)*allForce).*plotMult,'k-','LineWidth',3);
    
    legend({['dPD = ' num2str(b(1).*plotMult) ' + ' num2str(b(2).*plotMult) ' * F, p=' num2str(stats(3))]},'FontSize',14);
    
    % now, compare fits for total data to whole monkey
    %   do CIs overlap?
    %     b2 = allMonkeyFits{1,1};
    %     plot(allForce,(b2(1)+b2(2)*allForce).*(180/pi),'r');
    %     bint2 = allMonkeyFits{1,2};
    %     out1 = range_intersection(bint(2,:),bint2(2,:));
    
    %     b2 = allMonkeyFits{2,1};
    %     plot(allForce,(b2(1)+b2(2)*allForce).*(180/pi),'m');
    %     bint2 = allMonkeyFits{2,2};
    %     out2 = range_intersection(bint(2,:),bint2(2,:));
    
    set(gca,'YLim',[ymin_pd,ymax_pd],'TickDir','out','FontSize',14);
    if useVel
        xlabel('Velocity','FontSize',14);
    else
        xlabel('Force','FontSize',14);
    end
    
    if doMD
        ylabel('Mean Magnitude of dDOM (Hz)','FontSize',14);
    else
        ylabel('Mean dPD (Deg)','FontSize',14);
    end
    box off;
    
    %     plot(allForce,alldPDs.*plotMult,'o','LineWidth',2,'Color',colors{iMonkey});
end


