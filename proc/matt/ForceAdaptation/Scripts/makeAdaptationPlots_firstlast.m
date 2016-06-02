% Starting from scratch on the behavioral adaptation plotting code

% Do two things:
%   1) For each session, plot a trace of all trials (aligned as percentage) on top of each other
%   2) Pool across sessions in blocks to match the neural data
epochs = {'BL','AD','WO'};
useMetrics = {'errors','errors'};
numTrials = 10;
x_min = -40;
x_max = 40;
remOutliers = true;

cm = colormap;

for iTask = 1:length(useTasks)
    for iMonkey = 1:length(useMonkeys)
        if strcmpi(useMonkeys{iMonkey},'MrT')
            useArray = 'PMd';
        else
            useArray = 'M1';
        end
        % start with just CO files
        useFiles = doFiles(strcmpi(doFiles(:,4),useTasks{iTask}) & strcmpi(doFiles(:,1),useMonkeys{iMonkey}),:);
        
        pertDir = zeros(1,size(useFiles,1));
        results = cell(size(useFiles,1),length(epochs));
        targInfo = cell(size(useFiles,1),length(epochs));
        for iFile = 1:size(useFiles,1)
            a = loadResults(root_dir,useFiles(iFile,:),'adaptation');
            
            % get direction of perturbation to flip the clockwise ones to align
            if flipClockwisePerts
                % gotta hack it
                dataPath = fullfile(root_dir,useFiles{iFile,1},'Processed',useFiles{iFile,2});
                expParamFile = fullfile(dataPath,[useFiles{iFile,2} '_experiment_parameters.dat']);
                a.BL.params.exp = parseExpParams(expParamFile);
                pertDir(iFile) = a.BL.params.exp.angle_dir;
            else
                pertDir(iFile) = 1;
            end
            
            for iEpoch = 1:length(epochs)
                results{iFile,iEpoch} = pertDir(iFile).*a.(epochs{iEpoch}).(useMetrics{iTask}).*(180/pi);
                targInfo{iFile,iEpoch} = a.(epochs{iEpoch}).movement_table(:,1);
            end
        end
        
        if remOutliers
            disp('Removing outliers at 5x std of baseline...');
        end
        
        % get the baseline error for each unique target direction
        blErr = zeros(size(useFiles,1),8);
        for iFile = 1:size(useFiles,1)
            t = targInfo{iFile,1};
            r = results{iFile,1};
            utheta = unique(t);
            for i = 1:length(utheta)
                idx = t == utheta(i);
                blErr(iFile,i) = mean(r(idx));
            end
        end
        
        % load something to get the parameters used for the main tuning
%         c = loadResults(root_dir,useFiles(iFile,:),'tuning',{'classes'},useArray,paramSetName,tuneMethod,tuneWindow);
%         blocks = c(1).params.tuning.blocks; clear c;
        
        blocks = {[0 1],[0 0.33 0.66 1],[0 0.33 0.66 1]};
        
        % deduce how many total blocks
        sResults = cell(size(results,1),sum(cellfun(@(x) length(x)-1,blocks)));
        
        useColors = ceil(linspace(1,size(cm,1),size(useFiles,1)));
        
        figure('Position',[400 400 650 550]);
        hold all;
        for iFile = 1:size(results,1)
            count = 0;
            for iEpoch = 1:length(epochs)
                r = results{iFile,iEpoch};
                t = targInfo{iFile,iEpoch};
                for iBlock = 1:length(blocks{iEpoch})-1
                    count = count + 1;
                    % get relevant trials
                    idx1 = floor(blocks{iEpoch}(iBlock)*length(r))+1;
                    idx2 = floor(blocks{iEpoch}(iBlock+1)*length(r));
                    
                    temp1 = r(idx1:idx2);
                    temp2 = t(idx1:idx2);
                    for j = 1:length(temp1)
                        idx = utheta == temp2(j);
                        temp1(j) = temp1(j) - blErr(iFile,idx);
                    end
                    sResults{iFile,count} = temp1;
                end
            end
            
            for iBlock = 1:size(sResults,2)
                temp = cell2mat(sResults(:,iBlock));
                plot(iBlock,mean(temp),'o','LineWidth',2,'Color',cm(useColors(iFile),:));
                plot([iBlock,iBlock],[mean(temp)-std(temp)./sqrt(length(temp)),mean(temp)+std(temp)./sqrt(length(temp))],'-','Color',cm(useColors(iFile),:),'LineWidth',2);
            end
            set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 size(sResults,2)+1]);
            title(useMonkeys{iMonkey},'FontSize',16);
            xlabel('Blocks','FontSize',16);
            ylabel(useMetrics{iTask},'FontSize',16);
        end
    end
end
