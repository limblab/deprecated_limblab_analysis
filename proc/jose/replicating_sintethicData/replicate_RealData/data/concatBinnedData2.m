function binnedData = concatBinnedData2(struct1,struct2,varargin)

if nargin > 2
    neuronIDs = varargin{1};
else
    neuronIDs = [];
end

%% Concat timeframe
if round(1000*(struct1.timeframe(2)-struct1.timeframe(1)))~=round(1000*(struct2.timeframe(2)-struct2.timeframe(1)));
    disp('incompatible sampling rate - data concatenation aborted');
    binnedData = struct1;
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
    
    % Taking the first 9 muscles which have not changed over muscle reorder
    % Should improve this algorithm
    struct1.emgguide = struct1.emgguide(1:9,:);
    struct1.emgdatabin = struct1.emgdatabin(:,1:9);
    struct2.emgguide = struct2.emgguide(1:9,:);
    struct2.emgdatabin = struct2.emgdatabin(:,1:9);
    
    EMG_FLAG = 0;
    for i = 1:size(struct1.emgguide,1)
        if ~strcmp(deblank(struct1.emgguide(i,:)),deblank(struct2.emgguide(i,:)))
            disp('incompatible EMG labels - concatenation aborted');
            binnedData = struct1;
            return;           
        end
    end

    if ~isfield(struct1, 'emgdatabin') || ~isfield(struct2, 'emgdatabin') || (size(struct1.emgguide,1)~=size(struct2.emgguide,1))
        disp('incompatible EMG data - concatenation aborted');
        binnedData = struct1;
        return;
    else
        binnedData.emgdatabin = [struct1.emgdatabin; struct2.emgdatabin];
        binnedData.emgguide   =  struct1.emgguide;
    end
end            
%% Concat Spikes
if isfield(struct1, 'spikeguide') && isfield(struct2, 'spikeguide')
    %NeuronIDs file provided?
    if isempty(neuronIDs) %no -
        SPIKE_FLAG = 0;
        for i = 1:size(struct1.spikeguide,1)
            if ~strcmp(deblank(struct1.spikeguide(i,:)),deblank(struct2.spikeguide(i,:)))
                disp(sprintf('incompatible spike labels index %d - concatenation aborted',i));
                binnedData = struct1;
                return;
            end
        end
        if ~isfield(struct1, 'spikeratedata') || ~isfield(struct2, 'spikeratedata') || (size(struct1.spikeguide,1)~=size(struct2.spikeguide,1))
            disp('incompatible spike data - concatenation aborted');
            binnedData = struct1;
            return;
        else
            binnedData.spikeratedata = [struct1.spikeratedata; struct2.spikeratedata];
        end
    
    else % use neuronIDs to concat only some of the units and discard others
        num_units = size(neuronIDs,1);
        Neurons1 = spikeguide2neuronIDs(struct1.spikeguide);
        Neurons2 = spikeguide2neuronIDs(struct2.spikeguide);
        
        s1_i = zeros(1,num_units);
        s2_i = zeros(1,num_units);
        for i = 1:num_units
            spot1 = find( Neurons1(:,1)==neuronIDs(i,1) & Neurons1(:,2)==neuronIDs(i,2),1,'first');
            spot2 = find( Neurons2(:,1)==neuronIDs(i,1) & Neurons2(:,2)==neuronIDs(i,2),1,'first');
            if isempty(spot1) || isempty(spot2)
                disp('incompatible spike data - concatenation aborted');
                binnedData = struct1;
                return;
            else
                s1_i(i) = spot1;
                s2_i(i) = spot2;
            end
        end
        binnedData.spikeguide = neuronIDs2spikeguide(neuronIDs);
        binnedData.spikeratedata = [struct1.spikeratedata(:,s1_i); struct2.spikeratedata(:,s2_i)];
        clear Neurons1 Neurons2 num_units s1_i s2_i spot1 spot2;
    end
    
end
    
%% Concat Force
if isfield(struct1, 'forcelabels') && isfield(struct2, 'forcelabels')
    if  ~isempty(struct1.forcelabels) && ~isempty(struct2.forcelabels)
        for i = 1:size(struct1.forcelabels,1)
            if ~strcmp(deblank(struct1.forcelabels(i,:)),deblank(struct2.forcelabels(i,:)))
                disp('incompatible force labels - concatenation aborted');
                binnedData = struct1;
                return;
            end
        end

        if ~isfield(struct1, 'forcedatabin') || ~isfield(struct2, 'forcedatabin') || (size(struct1.forcelabels,1)~=size(struct2.forcelabels,1))
            disp('incompatible force data - concatenation aborted');
            binnedData = struct1;
            return;
        else
            binnedData.forcedatabin = [struct1.forcedatabin; struct2.forcedatabin];
        end
    end
end

%% Concat Pos
if isfield(struct1, 'cursorposlabels') && isfield(struct2, 'cursorposlabels')
    for i = 1:size(struct1.cursorposlabels,1)
        if ~strcmp(deblank(struct1.cursorposlabels(i,:)),deblank(struct2.cursorposlabels(i,:)))
            disp('incompatible position labels - concatenation aborted');
            binnedData = struct1;
            return;
        end
    end

    if ~isfield(struct1, 'cursorposbin') || ~isfield(struct2, 'cursorposbin') || (size(struct1.cursorposlabels,1)~=size(struct2.cursorposlabels,1))
        disp('incompatible position data - concatenation aborted');
        binnedData = struct1;
        return;
    else
        binnedData.cursorposbin = [struct1.cursorposbin; struct2.cursorposbin];
    end
end
%% Concat Vel
if isfield(struct1, 'veloclabels') && isfield(struct2, 'veloclabels')
    for i = 1:size(struct1.veloclabels,1)
        if ~strcmp(deblank(struct1.veloclabels(i,:)),deblank(struct2.veloclabels(i,:)))
            disp('incompatible velocity labels - concatenation aborted');
            binnedData = struct1;
            return;
        end
    end

    if ~isfield(struct1, 'velocbin') || ~isfield(struct2, 'velocbin') || (size(struct1.veloclabels,1)~=size(struct2.veloclabels,1))
        disp('incompatible velocity data - concatenation aborted');
        binnedData = struct1;
        return;
    else
        binnedData.velocbin = [struct1.velocbin; struct2.velocbin];
    end
end

%% Concat States
if isfield(struct1, 'statemethods') && isfield(struct2, 'statemethods')
    for i = 1:size(struct1.statemethods,1)
        if ~strcmp(deblank(struct1.statemethods(i,:)),deblank(struct2.statemethods(i,:)))
            disp('incompatible state methods - concatenation aborted');
            binnedData = struct1;
            return;
        end
    end

    if ~isfield(struct1, 'states') || ~isfield(struct2, 'states') || (size(struct1.statemethods,1)~=size(struct2.statemethods,1))
        disp('incompatible state data - concatenation aborted');
        binnedData = struct1;
        return;
    else
        binnedData.states = [struct1.states; struct2.states];
    end
end

%% Concat trialtable
if isfield(struct1, 'trialtable') && isfield(struct2, 'trialtable')
    if (size(struct1.trialtable,2)~=size(struct2.trialtable,2))
        disp('incompatible trial tables - concatenation aborted');
        binnedData = struct1;
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
            disp('incompatible stimulation rate - data concatenation aborted');
            binnedData = struct1;
            return;
        else

            stimbinsize = round(1000*(struct1.stim(2,1)-struct1.stim(1,1)))/1000;

            stim_t_offset = struct1.stim(end,1)+stimbinsize;
            stim_tf2 = struct2.stim(:,1)-struct2.stim(1,1)+stim_t_offset;

            binnedData.stim = [struct1.stim; [stim_tf2 struct2.stim(:,2:end)]];
        end
    end

end
