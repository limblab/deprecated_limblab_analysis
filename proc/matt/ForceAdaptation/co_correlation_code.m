%% getAdaptationMetrics
%     % if center out, use the mean movement traces to get correlation
%     if strcmpi(taskType,'CO')
%         baseCorr = zeros(length(blockTimes),2);
%         for tMove = 1:length(blockTimes)
%             % find the movements in this time block
%             relMoveInds = moveWins(:,1) >= blockTimes(tMove) & moveWins(:,1) < blockTimes(tMove) + behavWin;
%             relMoves = moveWins(relMoveInds,:);
%
%             cc = zeros(size(relMoves,1),1);
%             for iMove = 1:size(relMoves,1)
%                 idx = t >= relMoves(iMove,1) & t < relMoves(iMove,2);
%                 tempPos = pos(idx,:);
%
%                 % find the target id
%                 % for center out, movement table index should be same as tt
%                 currTarg = tt(iMove,2);
%
%                 % find correlation
%                 [x,y] = resampleTraces(tempPos(:,1),tempPos(:,2),n);
%                 bl = blTraces{currTarg+1}';
%                 ccx = corrcoef(x,bl(:,1));
%                 ccy = corrcoef(y,bl(:,2));
%
%                 cc(iMove) = mean([ccx(1,2) ccy(1,2)]);
%             end
%             baseCorr(tMove,:) = [mean(cc) std(cc)];
%         end
%     end
%
%     % do the baseline movement correlation in center out task
%     if strcmpi(taskType,'CO')
%         adaptation.(epochs{iEpoch}).baseline_correlation = baseCorr;
%     end


%% report_adaptation
% if strcmpi(taskType,'CO')
%     html = strcat(html,'</tr><tr><td>Baseline<br>Correlation</td>');
%     for iEpoch = 1:length(epochs)
%         html = strcat(html,['<td><img src="' figPath '\' epochs{iEpoch} '_adaptation_baseline_correlation.png" width="' num2str(imgWidth+200) '"></td>']);
%     end
% end

%% makeBehaviorPlots
%For center out files, plot correlation with mean baseline trajectory
% if strcmpi(taskType,'CO')
%     mC = adaptation.baseline_correlation(:,1);
%     sC = adaptation.baseline_correlation(:,2);
%
%     set(0, 'CurrentFigure', fh);
%     clf reset;
%
%     % if multiple points occur at same movement count, take average
%     repeats = moveCounts(diff(moveCounts) == 0);
%     uRepeats = unique(repeats);
%     for i = 1:length(uRepeats)
%         useInds = moveCounts==uRepeats(i);
%         mC(useInds) = mean(mC(useInds));
%         sC(useInds) = mean(sC(useInds));
%     end
%
%     nans = find(isnan(mC));
%     for i = 1:length(nans)
%         % find value of last non-nan
%         ind = find(~isnan(mC(1:nans(i))),1,'last');
%         if isempty(ind)
%             mval = 0;
%             sval = 0;
%         else
%             mval = mC(ind);
%             sval = sC(ind);
%         end
%         mC(nans(i)) = mval;
%         sC(nans(i)) = sval;
%     end
%
%     % do additional filtering
%     doFiltering = false;
%     if doFiltering
%         filtWidth = 2;
%         f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
%         mC = filter(f, 1, mC);
%     end
%
%
%     hold all;
%     % h = area(adaptation.movement_counts,[mC-sC 2*sC]);
%     % set(h(1),'FaceColor',[1 1 1]);
%     % set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
%     plot(moveCounts,mC','b','LineWidth',2);
%
%     xlabel('Movements','FontSize',fontSize);
%     ylabel('Curvature','FontSize',fontSize);
%     axis('tight');
%
%     if ~isempty(saveFilePath)
%         fn = fullfile(saveFilePath, [adaptation.meta.epoch '_adaptation_baseline_correlation.png']);
%         saveas(fh,fn,'png');
%     else
%         pause;
%     end
% end
