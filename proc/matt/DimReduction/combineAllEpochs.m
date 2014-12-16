function [allSpikes,allMT,indices] = combineAllEpochs(root_dir,doFiles,epochs,useArray,paramSetName)
% root_dir: string with the root directory
% doFile: 4 element cell with {monkey,date,perturbation,task}
% epochs: cell array with epoch names ie {'BL','AD','WO'}

filterMT = true;
excludeTrials = true;

allMT = [];
    indices = cell(length(epochs),8);
    
t_end = 0;
allSpikes = {};
for iFile = 1:size(doFiles)
    doFile = doFiles(iFile,:);
    
    % find out how many neurons are there
    fn = fullfile(root_dir,doFile{1},doFile{2},[doFile{4} '_' doFile{3} '_tracking_' doFile{2} '.mat']);
    tracking = load(fn);
    
    dataFile = fullfile(root_dir,doFile{1},doFile{2},[doFile{4} '_' doFile{3} '_BL_' doFile{2} '.mat']);
    data = load(dataFile);
    
    tuningFile = fullfile(root_dir,doFile{1},doFile{2},'movement',[doFile{4} '_' doFile{3} '_tuning_' doFile{2} '.mat']);
    tuning = load(tuningFile);
    
    [istuned, master_sg] = excludeCells(data,tuning.regression.onpeak,tracking,useArray,[1,4,7]);
    
    % don't care about tuning
    %   1) Waveform SNR
    %   2) ISI Percentage
    %   3) FR threshold
    %   4) Neuron Tracking
%     master_sg = master_sg(all(istuned(:,[1,2,3,4]),2) & ~all(istuned(:,[5,6]),2),:);
    master_sg = master_sg(all(istuned(:,[1,2,3,4]),2),:);
    
    spikes = cell(1,size(master_sg,1));

    
    
    for iEpoch = 1:length(epochs)
        epoch = epochs{iEpoch};
        
        disp(['Getting data for ' epoch '...']);
        
        % load data
        if strcmpi(epochs{iEpoch},'bl')
            e = epochs{iEpoch};
            iBlock = 1;
        else
            e = epochs{iEpoch};
            iBlock = str2num(e(3));
            e = e(1:2);
        end
        dataFile = fullfile(root_dir,doFile{1},doFile{2},[doFile{4} '_' doFile{3} '_' e '_' doFile{2} '.mat']);
        
        if filterMT
            data = load(dataFile);
            [movement_table,~] = filterMovementTable(data,paramSetName,excludeTrials,iBlock,false);
        else
            load(dataFile,'movement_table');
        end
        
        n = load(dataFile,useArray);
        
        [~,idx] = intersect(n.(useArray).sg, master_sg,'rows');
        
        % tack on the spikes
        for i = 1:length(idx)
            ts = n.(useArray).units(idx(i)).ts;
            
            spikes{i} = [spikes{i},ts+t_end];
        end
        
        
        % tack on indices for each direction
        u = unique(movement_table(:,1));
        for i = 1:length(u)
            if iFile > 1
                indices{iEpoch,i} = [indices{iEpoch,i}; find(movement_table(:,1)==u(i))+size(allMT,1)];
            else
                indices{iEpoch,i} = find(movement_table(:,1)==u(i))+size(allMT,1);
            end
        end
        
        movement_table(:,2:6) = movement_table(:,2:6)+t_end;
        
        allMT = [allMT; movement_table];
        
        % get the time of the end of this file for the next one
        t_end = movement_table(end,6);
    end
    
    allSpikes = [allSpikes, spikes];
    
    
end
