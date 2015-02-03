% pdChangeOverMovement
%   Plots change in PD of population against force or velocity of movement.
% Intended for CO task only. Requires a set of results made using the
% 'time' tuningWindow set in getFR.

colors = {'k','b','r'};
doCirc = false;

metricInfo.PD.ymin = 0;
metricInfo.PD.ymax = 120;
metricInfo.PD.binSize = 10;
metricInfo.PD.label = 'PD Change (Deg) ';

metricInfo.MD.ymin = -1;
metricInfo.MD.ymax = 5;
metricInfo.MD.binSize = 2;
metricInfo.MD.label = 'MD Change (Hz) ';

metricInfo.BO.ymin = -1;
metricInfo.BO.ymax = 5;
metricInfo.BO.binSize = 2;
metricInfo.BO.label = 'BO Change (Hz) ';

metricInfo.FR.ymin = -1;
metricInfo.FR.ymax = 5;
metricInfo.FR.binSize = 2;
metricInfo.FR.label = 'FR Change (Hz) ';

% set the bounds for the plots
if slidingParams.useVel
    ymin_f = 10;
    ymax_f = 28;
else
    ymin_f = 0;
    ymax_f = 2.8;
end

monkeys = unique(allFiles(:,1))';

h1 = figure();
subplot1(1,length(monkeys));
h2 = figure();
subplot1(1,length(monkeys));

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

%%
for iMonkey = 1:length(monkeys)
    
    doFiles = allFiles(strcmpi(allFiles(:,1),monkeys{iMonkey}),:);
    % Get the cells that are well-tuned from my normal analysis
    if useMasterTuned
        masterTunedSG = cell(size(doFiles,1),1);
        masterTuned = cell(size(doFiles,1),1);
        for iFile = 1:size(doFiles,1)
            c = loadResults(root_dir,doFiles(iFile,:),'tuning',{'classes'},useArray,paramSetName,tuneMethod,tuneWindow);
            
            masterTunedSG{iFile} = c.tuned_cells;
            masterTuned{iFile} = all(c.istuned,2);
        end
    end
    
    % currently assumes there are 3 blocks for classification
    cellPDs = cell(size(doFiles,1),3);
    meanForce = cell(size(doFiles,1),3);
    meanVel = cell(size(doFiles,1),3);
    
    for iFile = 1:size(doFiles,1)
        [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
        
        classifierBlocks = t(1).params.classes.classifierBlocks;
        
        if doWidthSeparation
            % load baseline data to get waveforms
            data = loadResults(root_dir,doFiles(iFile,:),'data',[],'BL');
            
            units = data.(useArray).units;
            wfTypes = zeros(length(units),1);
            for u = 1:length(units)
                wf = mean(units(u).wf,2);
                idx = find(abs(wf) > std(wf));
                switch doWidthSeparation
                    case 1
                        wfTypes(u) = (idx(end) - idx(1)) <= wfThresh;
                    case 2
                        wfTypes(u) = (idx(end) - idx(1)) >= wfThresh;
                end
            end
        end
        
        for iBlock = 1:size(classifierBlocks,2)
            neurons = struct();
            force = zeros(1,length(tuneWindows));
            vel = zeros(1,length(tuneWindows));
            for iWin = 1:size(classifierBlocks,1)
                tuningPeriod = tuneWindows{iWin};

                % find average force
                if useVel
                    f = t(classifierBlocks(iWin,iBlock)).vels;
                    v = t(classifierBlocks(iWin,iBlock)).vels;
                else
                    f = t(classifierBlocks(iWin,iBlock)).forces;
                    v = t(classifierBlocks(iWin,iBlock)).vels;
                end
                
                force(iWin) = mean(sqrt( f(:,1).^2 + f(:,2).^2 ));
                vel(iWin) = mean(sqrt( v(:,1).^2 + v(:,2).^2 ));
                
                sg = t(classifierBlocks(iWin,iBlock)).sg;
                
                if useMasterTuned
                    tunedCells = masterTunedSG{iFile};
                else
                    if doWidthSeparation
                        tunedCells = sg(all(c(iWin).istuned,2) & wfTypes,:);
                    else
                        tunedCells = sg(all(c(iWin).istuned,2),:);
                    end
                end
                
                [~,idx] = intersect(sg, tunedCells,'rows');
                
                inds = find(idx);
                
                for i=1:length(inds)
                    if ~doMD
                        if ~isfield(neurons,[ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ])
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds = NaN(1,length(tuneWindows));
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iWin) = t(classifierBlocks(iWin,iBlock)).pds(inds(i),1);
                        else
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iWin) = t(classifierBlocks(iWin,iBlock)).pds(inds(i),1);
                        end
                    else
                        if ~isfield(neurons,[ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ])
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds = NaN(1,length(tuneWindows));
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iWin) = t(classifierBlocks(iWin,iBlock)).mds(inds(i),1);
                        else
                            neurons.([ 'e' num2str(sg(inds(i),1)) 'u' num2str(sg(inds(i),2)) ]).pds(iWin) = t(classifierBlocks(iWin,iBlock)).mds(inds(i),1);
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
            try
                ad = ad_neurons.(fn{i}).pds;
                wo = wo_neurons.(fn{i}).pds;
                if ~any(isnan(bl)) && ~any(isnan(ad)) && ~any(isnan(wo))
                    bl_pds = [bl_pds; bl];
                    ad_pds = [ad_pds; ad];
                    wo_pds = [wo_pds; wo];
                end
            catch
                %do nothin
            end
        end
        
        % now find difference from baseline
        if ~doMD
            bl_ad = zeros(size(bl_pds));
            bl_wo = zeros(size(bl_pds));
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
    figure(h2);
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
    
    set(gca,'XLim',[0,size(periodPDs_AD,2)+1],'YLim',[ymin_pd,ymax_pd],'XTick',1:size(periodPDs_AD,2),'XTickLabel',tuneWindows,'TickDir','out','FontSize',14);
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


