usePerts = {'FF','VR'};
numBlocks = 5;

paramSetName = 'planning';
tuneMethod = 'regression';
tuneWindows = {'befgo','gomove','initial'};

plotColors = {'b','r','m','g'};
monkeySymbols = {'o','d'};

clear numTuned;
count = 0;
for iPert = 1:length(usePerts)
    for iMonkey = 1:length(useMonkeys)
        monkey = useMonkeys{iMonkey};
        
        useFiles = doFiles( strcmpi(doFiles(:,3),usePerts{iPert}) & strcmpi(doFiles(:,1),monkey),:);
        pertDir = zeros(1,size(useFiles,1));
        
        cellPDs = cell(length(tuneWindows),size(useFiles,1),numBlocks);
        cellPDBoot = cell(length(tuneWindows),size(useFiles,1),numBlocks);
        cellMDs = cell(length(tuneWindows),size(useFiles,1),numBlocks);
        cellMDBoot = cell(length(tuneWindows),size(useFiles,1),numBlocks);
        cellBOs = cell(length(tuneWindows),size(useFiles,1),numBlocks);
        cellBOBoot = cell(length(tuneWindows),size(useFiles,1),numBlocks);
        
        allDiff = cell(1,length(tuneWindows));
%         numTuned = zeros(length(tuneWindows),size(useFiles,1),2);
        
        for iWin = 1:length(tuneWindows)
            allDiff{iWin} = []; % initialize
            tuneWindow = tuneWindows{iWin};
            for iFile = 1:size(useFiles,1)
                if iWin == 1
                    count = count + 1; % allows me to pool neuron counts across monkeys and conditions
                end
                
                % load tuning and class info
                [t,c] = loadResults(root_dir,useFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
                
                % get direction of perturbation to flip the clockwise ones to align
                if flipClockwisePerts
                    % gotta hack it
                    dataPath = fullfile(root_dir,useFiles{iFile,1},'Processed',useFiles{iFile,2});
                    expParamFile = fullfile(dataPath,[useFiles{iFile,2} '_experiment_parameters.dat']);
                    t(1).params.exp = parseExpParams(expParamFile);
                    pertDir(iFile) = t(1).params.exp.angle_dir;
                else
                    pertDir(iFile) = 1;
                end
                
                classifierBlocks = c(1).params.classes.classifierBlocks;
                
                tunedCells = c(whichBlock).sg(all(c(whichBlock).istuned,2),:);
                
                numTuned(iWin,count,:) = [size(tunedCells,1) size(c(whichBlock).sg,1)];
                
                for iBlock = 1:length(t)
                    sg = t(iBlock).sg;
                    [~,idx] = intersect(sg, tunedCells,'rows');
                    cellPDs{iWin,iFile,iBlock} = t(iBlock).pds(idx,:);
                    cellPDBoot{iWin,iFile,iBlock} = t(iBlock).boot_pds(idx,:);
                    cellMDs{iWin,iFile,iBlock} = t(iBlock).mds(idx,:);
                    cellMDBoot{iWin,iFile,iBlock} = t(iBlock).boot_mds(idx,:);
                    cellBOs{iWin,iFile,iBlock} = t(iBlock).bos(idx,:);
                    cellBOBoot{iWin,iFile,iBlock} = t(iBlock).boot_bos(idx,:);
                end
                
                % compare parameters for each cell
                pdbl = cellPDBoot{iWin,iFile,1};
                pdad = cellPDBoot{iWin,iFile,3};
                mdbl = cellMDBoot{iWin,iFile,1};
                mdad = cellMDBoot{iWin,iFile,3};
                bobl = cellBOBoot{iWin,iFile,1};
                boad = cellBOBoot{iWin,iFile,3};
                isdiff = zeros(size(pdbl,1),3);
                for unit = 1:size(pdbl,1)
                    if isempty(range_intersection([0 0],prctile(angleDiff(pdbl(unit,:),pdad(unit,:),true,true),[2.5,97.5])))
                        isdiff(unit,1) = 1;
                    end
                    if isempty(range_intersection([0 0],prctile(angleDiff(mdbl(unit,:),mdad(unit,:),true,true),[2.5,97.5])))
                        isdiff(unit,2) = 1;
                    end
                    if isempty(range_intersection([0 0],prctile(angleDiff(bobl(unit,:),boad(unit,:),true,true),[2.5,97.5])))
                        isdiff(unit,3) = 1;
                    end
                end
                
                allDiff{iWin} = [allDiff{iWin}; isdiff];
            end
        end
        clear temp;
        for iWin = 1:length(allDiff)
            temp(iWin,:) = 100.*sum(allDiff{iWin},1)/size(allDiff{iWin},1);
        end
        figure;
        bar(temp);
        title([monkey usePerts{iPert} useArray]);
        set(gca,'Box','off','TickDir','out','FontSize',14,'XTickLabel',tuneWindows,'YLim',[0 100]);
        legend({'PD','MD','BO'});
        
%         clear temp;
%         for iWin = 1:length(allDiff)
%             temp(iWin) = sum(squeeze(numTuned(iWin,:,1)),1)/sum(squeeze(numTuned(iWin,:,2)),1);
%         end
%         figure;
%         bar(temp);
%         title([monkey usePerts{iPert} useArray]);
%         set(gca,'Box','off','TickDir','out','FontSize',14,'XTickLabel',tuneWindows);
        
    end
end
