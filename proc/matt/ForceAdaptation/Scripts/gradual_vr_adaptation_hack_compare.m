close all;
clear;
clc;

root_dir = 'F:\';

useArray = 'M1'; % Monkey sessions are filtered by array
useMonkeys = {'Chewie'};
usePerts = {'VR'}; % which perturbations
useTasks = {'CO'}; % CO/RT here.
useControl = false;
epochs = {'BL','AD','WO'};
useMetrics = {'errors'};
flipClockwisePerts = true;

blocks = {0:0.05:1,0:0.05:1,0:0.05:1};


figure('Position',[400 400 650 550]);
hold all;
plot(-1,0,'ko','LineWidth',3);
plot(-1,0,'ro','LineWidth',3);
% plot(-1,0,'bo','LineWidth',3);
% plot(-1,0,'go','LineWidth',3);

% angles = [zeros(1,length(blocks{1})-1),30*ones(1,length(blocks{2})-1),zeros(1,length(blocks{3})-1)];
% for i = 1:3
%     plot(angles,'k--','LineWidth',1);
% end
% angles = [zeros(1,length(blocks{1})-1),[0:30/14:30 30*ones(1,length(blocks{2})-16)],zeros(1,length(blocks{3})-1)];
% for i = 1:3
%     plot(angles,'r--','LineWidth',1);
% end

% angles = [zeros(1,length(blocks{1})-1),[0:30/8:30 30*ones(1,length(blocks{2})-10)],zeros(1,length(blocks{3})-1)];
% for i = 1:3
%     plot(angles,'b--','LineWidth',1);
% end

doFiles = {'Chewie','2015-11-20','VR','CO'};
%     'Chewie','2015-07-09','VR','CO'; ... %37 S(M)
%     'Chewie','2015-07-10','VR','CO'; ... %38 S(M)
%     'Chewie','2015-07-13','VR','CO'; ... %39 S(M)
%     'Chewie','2015-07-14','VR','CO'; ... %40 S(M)
%     'Chewie','2015-07-15','VR','CO'; ... %41 S(M)
%     'Chewie','2015-07-16','VR','CO'};
%     'Chewie','2013-10-03','VR','CO'; ... %1  S(M) ?
%     'Chewie','2013-12-19','VR','CO'; ... %19 S(M)
%     'Chewie','2013-12-20','VR','CO'; ... %20 S(M)

for iTask = 1:length(useTasks)
    switch lower(useMetrics{iTask})
        case 'curvatures'
            valScale = 1;
            x_min = -0.2;
            x_max = 0.2;
        case 'errors'
            valScale = (180/pi);
            x_min = -40;
            x_max = 40;
    end
    
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
                results{iFile,iEpoch} = pertDir(iFile).*a.(epochs{iEpoch}).(useMetrics{iTask}).*valScale;
                targInfo{iFile,iEpoch} = a.(epochs{iEpoch}).movement_table(:,1);
            end
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
        
        % Take tuning blocks of trials and compute average metrics
        % deduce how many total blocks
        sResults = cell(size(results,1),sum(cellfun(@(x) length(x)-1,blocks)));
        
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
        end
        
        for iBlock = 1:size(sResults,2)
            temp = cell2mat(sResults(:,iBlock));
            plot(iBlock,mean(temp),'ko','LineWidth',2);
            plot([iBlock,iBlock],[mean(temp)-std(temp)./sqrt(length(temp)),mean(temp)+std(temp)./sqrt(length(temp))],'k-','LineWidth',2);
        end
        set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 size(sResults,2)+1]);
        title(useMonkeys{iMonkey},'FontSize',16);
        xlabel('Blocks','FontSize',16);
        ylabel(useMetrics{iTask},'FontSize',16);
    end
end


doFiles = {'Chewie','2015-11-13','VR','CO'; ... %46 S(M) - +30 degree gradual rotation in 240 trials
    'Chewie','2015-11-16','VR','CO'; ... %47 S(M) - +30 degree gradual rotation in 240 trials
    'Chewie','2015-11-17','VR','CO'};  %47 S(M) - +30 degree gradual rotation in 240 trials

for iTask = 1:length(useTasks)
    switch lower(useMetrics{iTask})
        case 'curvatures'
            valScale = 1;
            x_min = -0.2;
            x_max = 0.2;
        case 'errors'
            valScale = (180/pi);
            x_min = -40;
            x_max = 40;
    end
    
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
                results{iFile,iEpoch} = pertDir(iFile).*a.(epochs{iEpoch}).(useMetrics{iTask}).*valScale;
                targInfo{iFile,iEpoch} = a.(epochs{iEpoch}).movement_table(:,1);
            end
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
        
        % Take tuning blocks of trials and compute average metrics
        % deduce how many total blocks
        sResults = cell(size(results,1),sum(cellfun(@(x) length(x)-1,blocks)));
        
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
        end
        
        for iBlock = 1:size(sResults,2)
            temp = cell2mat(sResults(:,iBlock));
            plot(iBlock,mean(temp),'ro','LineWidth',2);
            plot([iBlock,iBlock],[mean(temp)-std(temp)./sqrt(length(temp)),mean(temp)+std(temp)./sqrt(length(temp))],'r-','LineWidth',2);
        end
        set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 size(sResults,2)+1]);
        title(useMonkeys{iMonkey},'FontSize',16);
        xlabel('Blocks','FontSize',16);
        ylabel('Takeoff Angle Error (Deg)','FontSize',16);
    end
end

%%
doFiles = {'Chewie','2015-11-09','VR','CO'; ... %43 S(M) - +30 degree gradual rotation in 120 trials
    'Chewie','2015-11-10','VR','CO'}; %44 S(M) - +30 degree gradual rotation in 120 trials
%     'Chewie','2015-11-12','VR','CO'}; %45 - -30 degree gradual rotation in 120 trials

for iTask = 1:length(useTasks)
    switch lower(useMetrics{iTask})
        case 'curvatures'
            valScale = 1;
            x_min = -0.2;
            x_max = 0.2;
        case 'errors'
            valScale = (180/pi);
            x_min = -40;
            x_max = 40;
    end
    
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
                results{iFile,iEpoch} = pertDir(iFile).*a.(epochs{iEpoch}).(useMetrics{iTask}).*valScale;
                targInfo{iFile,iEpoch} = a.(epochs{iEpoch}).movement_table(:,1);
            end
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
        
        % Take tuning blocks of trials and compute average metrics
        % deduce how many total blocks
        sResults = cell(size(results,1),sum(cellfun(@(x) length(x)-1,blocks)));
        
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
        end
        
        for iBlock = 1:size(sResults,2)
            temp = cell2mat(sResults(:,iBlock));
            plot(iBlock,mean(temp),'bo','LineWidth',2);
            plot([iBlock,iBlock],[mean(temp)-std(temp)./sqrt(length(temp)),mean(temp)+std(temp)./sqrt(length(temp))],'b-','LineWidth',2);
        end
        set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 size(sResults,2)+1]);
        title(useMonkeys{iMonkey},'FontSize',16);
        xlabel('Blocks','FontSize',16);
        ylabel('Takeoff Angle Error (Deg)','FontSize',16);
    end
end

%%

%%
legend({'Gradual 400','Gradual 240','Gradual 120'},'FontSize',14);