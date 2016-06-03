function binnedData = concatBinnedData(struct1,struct2,varargin)

if nargin > 2
    neuronIDs = varargin{1};
else
    neuronIDs = [];
end

%% Concat timeframe
if round(1000*(struct1.timeframe(2)-struct1.timeframe(1)))~=round(1000*(struct2.timeframe(2)-struct2.timeframe(1)));
    warning('incompatible sampling rate - data concatenation aborted');
    binnedData = [];
    return;
else
    binnedData = struct1;
    
    binsize = round(1000*(struct1.timeframe(2)-struct1.timeframe(1)))/1000;

    t_offset = struct1.timeframe(end)+binsize;
    tf2 = struct2.timeframe-struct2.timeframe(1)+t_offset;
  %     tf2 = (0:size(struct2.timeframe,1)-1)*(binsize) + t_offset;
    binnedData.timeframe = [struct1.timeframe; tf2]; 
    clear tf2;
end

%% Concat EMGs
if isfield(struct1, 'emgguide') && isfield(struct2, 'emgguide')

    for i = 1:size(struct1.emgguide,1)
        if ~strcmp(deblank(struct1.emgguide(i,:)),deblank(struct2.emgguide(i,:)))
            warning('incompatible EMG labels - concatenation aborted');
            binnedData = [];
            return;           
        end
    end

    if ~isfield(struct1, 'emgdatabin') || ~isfield(struct2, 'emgdatabin') || (size(struct1.emgguide,1)~=size(struct2.emgguide,1))
        warning('incompatible EMG data - concatenation aborted');
        binnedData = [];
        return;
    else
        binnedData.emgdatabin = [struct1.emgdatabin; struct2.emgdatabin];
    end
end            
%% Concat Spikes
if isfield(struct1, 'spikeratedata') && isfield(struct2, 'spikeratedata')
    %NeuronIDs file provided?
    if isempty(neuronIDs) %no -
        % find common units
        [neuronIDs,idx1,idx2] = intersect(struct1.neuronIDs,struct2.neuronIDs,'rows','stable');
    else 
        %check if any channels are provided in neuronIDs, but missing from structures
        if ~isempty(setdiff(neuronIDs,struct1.neuronIDs)) || ~isempty(setdiff(neuronIDs,struct2.neuronIDs))
                warning('incompatible spike data - concatenation aborted');
                binnedData = [];
                return;
        end
        
        [~,idx1,~] = intersect(struct1.neuronIDs,neuronIDs,'rows','stable');
        [~,idx2,~] = intersect(struct2.neuronIDs,neuronIDs,'rows','stable');
    end
    binnedData.spikeratedata = [struct1.spikeratedata(:,idx1); struct2.spikeratedata(:,idx2)];
    binnedData.neuronIDs = neuronIDs;
end
    
%% Concat Force
if isfield(struct1, 'forcelabels') && isfield(struct2, 'forcelabels')
    for i = 1:size(struct1.forcelabels,1)
        if ~strcmp(deblank(struct1.forcelabels(i,:)),deblank(struct2.forcelabels(i,:)))
            warning('incompatible force labels - concatenation aborted');
            binnedData = [];
            return;
        end
    end

    if ~isfield(struct1, 'forcedatabin') || ~isfield(struct2, 'forcedatabin') || (size(struct1.forcelabels,1)~=size(struct2.forcelabels,1))
        warning('incompatible force data - concatenation aborted');
        binnedData = [];
        return;
    else
        binnedData.forcedatabin = [struct1.forcedatabin; struct2.forcedatabin];
    end
end

%% Concat Pos
if isfield(struct1, 'cursorposlabels') && isfield(struct2, 'cursorposlabels')
    for i = 1:size(struct1.cursorposlabels,1)
        if ~strcmp(deblank(struct1.cursorposlabels(i,:)),deblank(struct2.cursorposlabels(i,:)))
            warning('incompatible position labels - concatenation aborted');
            binnedData = [];
            return;
        end
    end

    if ~isfield(struct1, 'cursorposbin') || ~isfield(struct2, 'cursorposbin') || (size(struct1.cursorposlabels,1)~=size(struct2.cursorposlabels,1))
        warning('incompatible position data - concatenation aborted');
        binnedData = [];
        return;
    else
        binnedData.cursorposbin = [struct1.cursorposbin; struct2.cursorposbin];
    end
end
%% Concat Vel
if isfield(struct1, 'veloclabels') && isfield(struct2, 'veloclabels')
    for i = 1:size(struct1.veloclabels,1)
        if ~strcmp(deblank(struct1.veloclabels(i,:)),deblank(struct2.veloclabels(i,:)))
            warning('incompatible velocity labels - concatenation aborted');
            binnedData = [];
            return;
        end
    end

    if ~isfield(struct1, 'velocbin') || ~isfield(struct2, 'velocbin') || (size(struct1.veloclabels,1)~=size(struct2.veloclabels,1))
        warning('incompatible velocity data - concatenation aborted');
        binnedData = [];
        return;
    else
        binnedData.velocbin = [struct1.velocbin; struct2.velocbin];
    end
end
%% Concat Acceleration
if isfield(struct1, 'acclabels') && isfield(struct2, 'acclabels')
    for i = 1:size(struct1.acclabels,1)
        if ~strcmp(deblank(struct1.acclabels(i,:)),deblank(struct2.acclabels(i,:)))
            warning('incompatible acceleration labels - concatenation aborted');
            binnedData = [];
            return;
        end
    end

    if ~isfield(struct1, 'accelbin') || ~isfield(struct2, 'accelbin') || (size(struct1.acclabels,1)~=size(struct2.acclabels,1))
        warning('incompatible acceleration data - concatenation aborted');
        binnedData = [];
        return;
    else
        binnedData.accelbin = [struct1.accelbin; struct2.accelbin];
    end
end

%% Concat States
if isfield(struct1, 'statemethods') && isfield(struct2, 'statemethods')
    for i = 1:size(struct1.statemethods,1)
        if ~strcmp(deblank(struct1.statemethods(i,:)),deblank(struct2.statemethods(i,:)))
            warning('incompatible state methods - concatenation aborted');
            binnedData = [];
            return;
        end
    end

    if ~isfield(struct1, 'states') || ~isfield(struct2, 'states') || (size(struct1.statemethods,1)~=size(struct2.statemethods,1))
        warning('incompatible state data - concatenation aborted');
        binnedData = [];
        return;
    else
        binnedData.states = [struct1.states; struct2.states];
    end
end

%% Concat trialtable
if isfield(struct1, 'trialtable') && isfield(struct2, 'trialtable')
    if (size(struct1.trialtable,2)~=size(struct2.trialtable,2))
        warning('incompatible trial tables - concatenation aborted');
        binnedData = [];
        return;
    else
        %time stamps have to be updated in struct 2. Columns containing ts depend on the task.
        time_col_idx = false(1,size(struct1.trialtable,2));
        
        if isfield(struct1,'words')
            if any(struct1.words(:,2) == hex2dec('16'))
                %Multi-Gadget:    
                %   tt = [1-Start_ts 2-TP_ts 3-Go_ts 4_TrialType 5-Gdt_ID 6-Tgt_ID
                %   7:10-Tgt_Corners 11-End_ts 12-End_code]
                time_col_idx = [1 2 3 11];
                
            elseif any(struct1.words(:,2) == hex2dec('17'))
                % Wrist Flexion
                %   tt = [1-Start_ts 2:5-Target[ULx ULy LRx LRy] 6-OT_on_ts
                %   7-Go_ts 8-End_ts 9-End_code 10-Tgt_Id]
                time_col_idx =[1 6 7 8];
                
            %Figure out time column index for other tasks here                
            % elseif any(struct1.words(:,2) == hex2dec('xx'))
            
            end
        end
        
        for i=1:length(time_col_idx)
            %find only ts > 0, others should be left at -1
            valid_idx = struct2.trialtable(:,time_col_idx(i))>0;
            struct2.trialtable(valid_idx,time_col_idx(i)) = struct2.trialtable(valid_idx,time_col_idx(i))+t_offset;
        end
        binnedData.trialtable = [struct1.trialtable; struct2.trialtable];                
    end
end

%% Concat Words
if isfield(struct1, 'words') && isfield(struct2, 'words')
        if (~isempty(struct1.words) && ~isempty(struct2.words))
        w2 = [struct2.words(:,1)+t_offset struct2.words(:,2)];
        binnedData.words = [struct1.words; w2];
        clear w2;
    end
end

%% Concat Targets
if isfield(struct1, 'targets') && isfield(struct2, 'targets')
    if isfield(struct1.targets, 'corners') && isfield(struct2.targets, 'corners')
        if ~isempty(struct1.targets.corners) && ~isempty(struct2.targets.corners)
            c2 = [struct2.targets.corners(:,1)+t_offset struct2.targets.corners(:,2:end)];
            binnedData.targets.corners = [struct1.targets.corners; c2];
            clear c2;
        end
    end
end

if isfield(struct1, 'targets') && isfield(struct2, 'targets')
    if isfield(struct1.targets, 'rotation') && isfield(struct2.targets, 'rotation')
        if ~isempty(struct1.targets.rotation) && ~isempty(struct2.targets.rotation)
            c2 = [struct2.targets.rotation(:,1)+t_offset struct2.targets.rotation(:,2:end)];
            binnedData.targets.rotation = [struct1.targets.rotation; c2];
            clear c2;
        end
    end
end
%% Concat Stim
if isfield(struct1, 'stim') && isfield(struct2, 'stim')
    
    if ~isempty(struct1.stim) && ~isempty(struct2.stim)

        if round(1000*(struct1.stim(2,1)-struct1.stim(1,1)))~=round(1000*(struct2.stim(2,1)-struct2.stim(1,1)));
            warning('incompatible stimulation rate - data concatenation aborted');
            binnedData = [];
            return;
        else

            stimbinsize = round(1000*(struct1.stim(2,1)-struct1.stim(1,1)))/1000;

            stim_t_offset = struct1.stim(end,1)+stimbinsize;
            stim_tf2 = struct2.stim(:,1)-struct2.stim(1,1)+stim_t_offset;

            binnedData.stim = [struct1.stim; [stim_tf2 struct2.stim(:,2:end)]];
        end
    end

end
