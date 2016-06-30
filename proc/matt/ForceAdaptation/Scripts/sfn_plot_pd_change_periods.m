usePerts = {'FF','VR'};

paramSetName = 'planning';
tuneMethod = 'regression';
tuneWindows = {'afton','befgo','gomove','initial'};

plotColors = {'b','r','m','g'};
errScale = 2; %scale the error by this value (2 is average of epochs)
monkeySymbols = {'o','d'};
for iPert = 1:length(usePerts)
    figure;
    hold all;
    for iMonkey = 1:length(useMonkeys)
        monkey = useMonkeys{iMonkey};
        
        useFiles = doFiles( strcmpi(doFiles(:,3),usePerts{iPert}) & strcmpi(doFiles(:,1),monkey),:);
        pertDir = zeros(1,size(useFiles,1));
        for iWin = 1:length(tuneWindows)
            tuneWindow = tuneWindows{iWin};
            for iFile = 1:size(useFiles,1)
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
                
                for iBlock = 1:length(t)
                    sg = t(iBlock).sg;
                    [~,idx] = intersect(sg, tunedCells,'rows');
                    cellPDs{iWin,iFile,iBlock} = t(iBlock).pds(idx,:);
                end
            end
        end
        
        % find all metric differences
        results = zeros(length(tuneWindows),size(cellPDs,3));
        results_err = zeros(length(tuneWindows),size(cellPDs,3));
        
                for iWin = 1:length(tuneWindows)
                    dPDs=[];
                    errPDs=[];
                    for iFile = 1:size(useFiles,1)
                        % get baseline values
                        pds = squeeze(cellPDs(iWin,iFile,:));
                        pd_bl = pds{1};
                        % now get PD diff
                        errpd = zeros(size(pds{1},1),size(cellPDs,3));
                        dpd = zeros(size(pds{1},1),size(cellPDs,3));
                        for iBlock = 1:size(cellPDs,3)
                            pd_temp = pds{iBlock};
                            errpd(:,iBlock) = angleDiff(pd_temp(:,3),pd_temp(:,2),true,false).*(180/pi)./errScale;
                            dpd(:,iBlock) = pertDir(iFile)*angleDiff(pd_bl(:,1),pd_temp(:,1),true,true).*(180/pi);
                            %                     dpd(:,iBlock) = angleDiff(pd_bl(:,1),pd_temp(:,1),true,true).*(180/pi);
                        end
                        dPDs = [dPDs; dpd];
                        errPDs = [errPDs; errpd];
                    end
                    results(iWin,:) = mean(dPDs,1);
                    results_err(iWin,:) = mean(errPDs)/errScale; %std(dPDs,1)./sqrt(length(dPDs));
        
%                     for iBlock = 1:size(cellPDs,3)-1
%                         subplot(size(cellPDs,3)-1,length(tuneWindows),iWin + length(tuneWindows)*(iBlock-1));
%                         [f,x] = hist(dPDs(:,iBlock+1),-100:5:100);
%                         bar(x,100.*f/sum(f));
%                         set(gca,'FontSize',14,'Box','off','TickDir','out','XLim',[-100 100],'YLim',[0 50]);
%                         if iWin == 1
%                             ylabel(num2str(iBlock+1),'FontSize',14);
%                         end
%                     end
%                     xlabel(tuneWindows{iWin},'FontSize',14);
                end
        
        plotColors = {[0 0 0],[1 0.6 0.6],[1 0 0],[0.6 1 0.6],[0 1 0]};
        for iWin = 1:size(results,1)
            for iBlock = [1 3]%1:size(results,2)
                x = iWin + (size(results,1)+1)*(iMonkey-1) + 0.1*(iBlock-1);
                plot( x,results(iWin,iBlock),monkeySymbols{iMonkey},'LineWidth',2,'Color',plotColors{iBlock});
                plot( [x,x],[results(iWin,iBlock)-results_err(iWin,iBlock),results(iWin,iBlock)+results_err(iWin,iBlock)],'-','LineWidth',2,'Color',plotColors{iBlock});
            end
        end
        set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',[1:length(tuneWindows),(1:length(tuneWindows))+size(results,1)+1],'XTickLabel',[tuneWindows,tuneWindows]);
        title([useArray ' ' usePerts{iPert}],'FontSize',14);
        set(gca,'YLim',[-20 40]);
        V = axis;
        text(2+(size(results,1)+1)*(iMonkey-1),0.9*V(4),monkey,'FontSize',16);
        
        % figure;
        % imagesc(results);
        % colorbar;
        % set(gca,'Box','off','TickDir','out','FontSize',14,'YTick',1:length(tuneWindows),'YTickLabel',tuneWindows);
        % xlabel('Blocks','FontSize',14);
        % title([useArray '-' usePerts(iPert)],'FontSize',14);
    end
end
