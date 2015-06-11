% the goal is to look at any parameter over time
%   Find the population PD change for each block
%
% Will plot any two
%   - Any epoch difference (eg BL->AD, BL->WO, etc)
%   - Any metric (PD, MD, BO, FR)
%   - Any parameter set (e.g. 'movement' and 'target'
%
%   This is all mediated with the toCompare struct.

plotColors = {'b','r','m','g'};
errScale = 1; %scale the error by this value (2 is average of epochs)
widthThreshMult = 0.5; % factor multiplied by STD

%% Hardcode define axis information for plots
metricInfo.PD.min = -120;
metricInfo.PD.max = 120;
metricInfo.PD.label = 'PD Change (Deg)';

if sComp.doPercent
    metricInfo.MD.min = -1;
    metricInfo.MD.max = 1;
    metricInfo.MD.label = 'MD Change';
    
    metricInfo.BO.min = -1;
    metricInfo.BO.max = 1;
    metricInfo.BO.label = 'BO Change';
    
    metricInfo.FR.min = -1;
    metricInfo.FR.max = 1;
    metricInfo.FR.label = 'FR Change';
    
    metricInfo.VE.min = -1;
    metricInfo.VE.max = 1;
    metricInfo.VE.label = 'VE Change';
else
    metricInfo.MD.min = -30;
    metricInfo.MD.max = 30;
    metricInfo.MD.label = 'MD Change (Hz)';
    
    metricInfo.BO.min = -30;
    metricInfo.BO.max = 30;
    metricInfo.BO.label = 'BO Change (Hz)';
    
    metricInfo.FR.min = -30;
    metricInfo.FR.max = 30;
    metricInfo.FR.label = 'FR Change (Hz)';
    
    metricInfo.VE.min = -30;
    metricInfo.VE.max = 30;
    metricInfo.VE.label = 'VE Change (Hz)';
end

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
            idx = find(abs(wf) > widthThreshMult*std(wf));
            allWFWidths(count) = idx(end) - idx(1);
        end
    end
    % now, set the threshold for narrow and wide APs
    wfThresh = median(allWFWidths);
end

%% Some prelim plot setup
figure('Position',[200 200 1280 800]);
hold all;

plotMax = -Inf; plotMin = Inf;
for iRes = 1:length(sComp.titles)
    plot(1+0.1*(iRes-1),0,[plotColors{iRes} 'o'],'LineWidth',2);
    plotMax = max([plotMax metricInfo.(sComp.metrics{iRes}).max]);
    plotMin = min([plotMin metricInfo.(sComp.metrics{iRes}).min]);
end
legend(sComp.titles);

%% Get the classification for each day for tuned cells
for iRes = 1:length(sComp.titles)
    paramSetName = sComp.params{iRes};
    useArray = sComp.arrays{iRes};
    tuneMethod = sComp.methods{iRes};
    tuneWindow = sComp.windows{iRes};
    
    %     cellPDs = cell(size(doFiles,1),1);
    %     cellMDs = cell(size(doFiles,1),1);
    %     cellBOs = cell(size(doFiles,1),1);
    %     cellFRs = cell(size(doFiles,1),1);
    %     cellR2s = cell(size(doFiles,1),1);
    count = 0;
    allWidths = [];
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
        
        tunedCells = c(whichBlock).sg(all(c(whichBlock).istuned,2) & wfTypes,:);
        
        for iBlock = 1:length(t)
            sg = t(iBlock).sg;
            [~,idx] = intersect(sg, tunedCells,'rows');
            cellPDs{iFile,iBlock} = t(iBlock).pds(idx,:);
            cellMDs{iFile,iBlock} = t(iBlock).mds(idx,:);
            cellBOs{iFile,iBlock} = t(iBlock).bos(idx,:);
            cellFRs{iFile,iBlock} = mean(t(iBlock).fr(:,idx),1)';
            %cellVEs{iFile,iBlock} = sqrt( t(iBlock).vels(:,1).^2 + t(iBlock).vels(:,2).^2);
            cellVEs{iFile,iBlock} = zeros(size(mean(t(iBlock).fr(:,idx),1)'));
        end
        
        allWidths = [allWidths; fileWidths];
    end
    
    %
    % find all metric differences
    dPDs=[]; dMDs=[]; dBOs=[]; dFRs=[]; dVEs=cell(1,size(cellVEs,2));
    errPDs=[]; errMDs=[]; errBOs=[]; errFRs=[]; errVEs=cell(1,size(cellVEs,2));
    for iFile = 1:size(doFiles,1)
        % get baseline values
        pds = cellPDs(iFile,:);
        pd_bl = pds{1};
        mds = cellMDs(iFile,:);
        md_bl = mds{1};
        bos = cellBOs(iFile,:);
        bo_bl = bos{1};
        frs = cellFRs(iFile,:);
        fr_bl = frs{1};
        ves = cellVEs(iFile,:);
        ve_bl = ves{1};
        
        % find baseline firing rate for each neuron
        if sComp.doPercent
            md_mean = md_bl(:,1);
            bo_mean = bo_bl(:,1);
            fr_mean = fr_bl(:,1);
            ve_mean = mean(ve_bl(:,1));
        else
            md_mean = ones(size(md_bl,1),1);
            bo_mean = ones(size(bo_bl,1),1);
            fr_mean = ones(size(fr_bl,1),1);
            ve_mean = ones(size(ve_bl,1),1);
        end
        
        % now get PD diff
        for iBlock = 1:size(cellPDs,2)
            pd_temp = pds{iBlock};
            errpd(:,iBlock) = angleDiff(pd_temp(:,3),pd_temp(:,2),true,false).*(180/pi)./errScale;
            dpd(:,iBlock) = angleDiff(pd_bl(:,1),pd_temp(:,1),true,true).*(180/pi);
        end
        dPDs = [dPDs; dpd];
        errPDs = [errPDs; errpd];
        
        % now get MD diff
        for iBlock = 1:size(cellMDs,2)
            md_temp = mds{iBlock};
            errmd(:,iBlock) = abs( (md_temp(:,3)-md_temp(:,2))./md_mean )/errScale;
            dmd(:,iBlock) = (md_temp(:,1)-md_bl(:,1))./md_mean;
        end
        dMDs = [dMDs; dmd];
        errMDs = [errMDs; errmd];
        
        % now get BO diff
        for iBlock = 1:size(cellBOs,2)
            bo_temp = mds{iBlock};
            errbo(:,iBlock) = abs( (bo_temp(:,3)-bo_temp(:,2))./bo_mean )/errScale;
            dbo(:,iBlock) = (bo_temp(:,1)-bo_bl(:,1))./bo_mean;
        end
        dBOs = [dBOs; dbo];
        errBOs = [errBOs; errbo];
        
        % now get FR diff
        for iBlock = 1:size(cellFRs,2)
            fr_temp = frs{iBlock};
            errfr(:,iBlock) = abs( (fr_temp(:,1)-fr_temp(:,1))./fr_mean )/errScale;
            dfr(:,iBlock) = (fr_temp(:,1)-fr_bl(:,1))./fr_mean;
        end
        dFRs = [dFRs; dfr];
        errFRs = [errFRs; errfr];
        
        % now get velocity diff
        for iBlock = 1:size(cellVEs,2)
            ve_temp = ves{iBlock};
            errve = ( std(ve_temp - mean(ve_bl))./sqrt(length(ve_bl)) )/errScale;
            dve = (ve_temp - mean(ve_bl))/mean(ve_mean);
            
            errVEs{iBlock} = [errVEs{iBlock}; errve];
            dVEs{iBlock} = [dVEs{iBlock}; dve];
        end
        
        clear dpd dmd dbo dfr errpd errmd errbo errfr errvel dvel;
    end
    
    for iBlock = 1:size(cellVEs,2)
        
    end
    
    if sComp.doAbs
        dPDs = abs(dPDs);
        dMDs = abs(dMDs);
        dBOs = abs(dBOs);
        dFRs = abs(dFRs);
    end
    
    if ~strcmpi(sComp.metrics{iRes},'VE')
        eval(['plotData=mean(d' sComp.metrics{iRes} 's,1);']);
        eval(['plotErr=mean(err' sComp.metrics{iRes} 's,1);']);
    else
        for i = 1:size(cellVEs,2)
            plotData(i) = mean(dVEs{i},1);
            plotErr(i) = std(dVEs{i},1)./sqrt(length(errVEs{i}));
        end
    end
    plot((1:size(cellPDs,2))+0.1*(iRes-1),plotData,[plotColors{iRes} 'o'],'LineWidth',2);
    plot(repmat( (1:size(cellPDs,2))+0.1*(iRes-1),2,1),[plotData-plotErr; plotData+plotErr],plotColors{iRes},'LineWidth',2);
end

%% Now add some extra stuff and configure the plot
plot([0 size(cellPDs,2)+1],[0 0],'LineWidth',1,'Color',[0.6 0.6 0.6]);
plot([1.5 1.5],[plotMin plotMax],'k--','LineWidth',1);
plot([4.5 4.5],[plotMin plotMax],'k--','LineWidth',1);

axis([0.3 size(cellPDs,2)+0.3 plotMin plotMax]);

set(gca,'XTick',[1, 1+classifierBlocks(2)/2, classifierBlocks(2)+(1+classifierBlocks(3)-classifierBlocks(2))/2],'XTickLabel',{'Baseline','Adaptation','Washout'},'FontSize',14);

ylabel(metricInfo.(sComp.metrics{1}).label,'FontSize',16);


