% want to ask how many trials it takes to reach reliable tuning for most neurons with the curl field and in baseline
useArray = 'M1';

trialNums = 110:5:130;
statTestParams = {'bootstrap',1000,0.95};
epochs = {'BL','AD'};

% do for all epochs
out_r = cell(length(epochs),size(doFiles,1));
out_cb = cell(length(epochs),size(doFiles,1));
out_pd = cell(length(epochs),size(doFiles,1));
out_md = cell(length(epochs),size(doFiles,1));
for iEpoch = 1:length(epochs)
    for iFile = 1:size(doFiles,1)
        disp([epochs{iEpoch} ', File ' num2str(iFile) ' of ' num2str(size(doFiles,1)) '...']);
        % load file
        data = loadResults(root_dir,doFiles(iFile,:),'data',[],epochs{iEpoch});
        params = data.params;
        params.tuning.blocks = {[0 1],[0 1],[0 1]};
        [fr,theta] = getFR(data,params,useArray,'onpeak');
        
        get_r = zeros(size(fr{1},2),length(trialNums));
        get_cb = zeros(size(fr{1},2),length(trialNums));
        get_pd = zeros(size(fr{1},2),length(trialNums));
        get_md = zeros(size(fr{1},2),length(trialNums));
        % loop along number of included trials (steps of 5?)
        for iNum = 1:length(trialNums)
            disp(['Using ' num2str(trialNums(iNum)) ' (' num2str(iNum) ' of ' num2str(length(trialNums)) ')...']);
            x = theta{1}(1:trialNums(iNum));
            y = fr{1}(1:trialNums(iNum),:);
            
            % for each neuron, fit PDs and get confidence bounds and r2
            [tcs,cbs,rs] = regressTuningCurves(y,x,statTestParams,'doplots',false,'doparallel',true);
            get_r(:,iNum) = mean(rs,2);
            get_cb(:,iNum) = angleDiff(cbs{3}(:,1),cbs{3}(:,2),true,false);
            get_pd(:,iNum) = tcs(:,3);
            get_md(:,iNum) = tcs(:,2);
        end
        
        % end up with mean/std of confidence as a function of number of trials
        out_r{iEpoch,iFile} = get_r;
        out_cb{iEpoch,iFile} = get_cb;
        out_pd{iEpoch,iFile} = get_pd;
        out_md{iEpoch,iFile} = get_md;
    end
    clear iFile data params fr theta get_r get_cb iNum x y cbs rs;
end
disp('Done!');

% Now, rearrange so that all files are pooled
all_r = cell(1,length(epochs));
all_cb = cell(1,length(epochs));
for iEpoch = 1:length(epochs)
    temp_r = [];
    temp_cb = [];
    temp_pd = [];
    temp_md = [];
    for iFile = 1:size(doFiles,1)
        temp = out_r{iEpoch,iFile};
        temp(isnan(temp)) = 0;
        temp_r = [temp_r; temp];
        temp_cb = [temp_cb; out_cb{iEpoch,iFile}];
        temp_pd = [temp_pd; out_pd{iEpoch,iFile}];
        temp_md = [temp_md; out_md{iEpoch,iFile}];
    end
    
    all_r{iEpoch} = temp_r;
    all_cb{iEpoch} = temp_cb;
    all_pd{iEpoch} = temp_pd;
    all_md{iEpoch} = temp_md;
    clear temp_r temp_cb iFile;
end

% Now, do some plotting
figure;
hold all;
plot(trialNums,mean(all_r{1},1),'bo','LineWidth',2);
plot(trialNums,mean(all_r{2},1),'ro','LineWidth',2);
set(gca,'TickDir','out','Box','off','FontSize',14);
xlabel('Number of Trials','FontSize',14);
ylabel('R-Squared','FontSize',14);
axis('tight');

figure;
hold all;
plot(trialNums,mean(all_cb{1},1).*(180/pi),'bo','LineWidth',2);
plot(trialNums,mean(all_cb{2},1).*(180/pi),'ro','LineWidth',2);
set(gca,'TickDir','out','Box','off','FontSize',14);
xlabel('Number of Trials','FontSize',14);
ylabel('Confidence Bounds','FontSize',14);
axis('tight');

% Now compute percentage of "tuned" cells and plot
figure;
hold all;
for i = 1:length(trialNums)
    plot(trialNums(i),sum(all_r{1}(:,i) > 0.5 & all_cb{1}(:,i) < 40)/size(all_r{1},1),'bo','LineWidth',2);
    plot(trialNums(i),sum(all_r{2}(:,i) > 0.5 & all_cb{2}(:,i) < 40)/size(all_r{2},1),'ro','LineWidth',2);
end
set(gca,'TickDir','out','Box','off','FontSize',14);
xlabel('Number of Trials','FontSize',14);
ylabel('Percentage "Tuned"','FontSize',14);
axis('tight');



