function target_stats = get_WF_stats(binnedData,varargin)

if nargin>1
    plotflag = varargin{1};
else
    plotflag=0;
end

successes    = find(binnedData.trialtable(:,9)==double('R'));
numsuccesses = length(successes);
numtrials    = size(binnedData.trialtable,1);

targets      = sort(unique(binnedData.trialtable(:,10)));
numtargets   = length(targets);

target_stats = [];
for tgt = 1:numtargets
    
    tgt_idx       = find(binnedData.trialtable(:,10)==targets(tgt));
    N             = length(tgt_idx);
    succ_idx      = intersect(tgt_idx,successes);
    num_succ      = length(succ_idx);
    succ_rate     = num_succ/N;
    num_reentries = nan(num_succ,1);
    path_length   = nan(num_succ,1);
    time2target   = nan(num_succ,1);
    normpath      = cell(num_succ,1);
    
    %rewards per minute
    duration = binnedData.timeframe(end)-binnedData.timeframe(1);
    num_mins = floor(duration/60);
    if mod(duration,60) > 30
        %also consider last minute if more than 30 sec
        last_min_dur = mod(duration,60);
        succ_per_min  = nan(num_mins+1,1);
    else
        last_min_dur = 0;
        succ_per_min  = nan(num_mins,1);
    end
    for i = 1:num_mins
        min_start = binnedData.timeframe(1)+(i-1)*60;
        min_idx = find(binnedData.trialtable(:,8)>min_start & binnedData.trialtable(:,8)<=(min_start+60));
        min_idx_tgt = intersect(min_idx,tgt_idx);
        if ~isempty(min_idx_tgt)
            succ_per_min(i) = sum(binnedData.trialtable(min_idx_tgt,9)==double('R'));
        else
            succ_per_min(i) = 0;
        end
    end
    %last min
    if last_min_dur
        min_idx = find(binnedData.trialtable(:,8)>num_mins*60);
        min_idx_tgt = intersect(min_idx,tgt_idx);
        if ~isempty(min_idx_tgt)
            succ_per_min(end) = sum(binnedData.trialtable(min_idx_tgt,9)==double('R'))*60/last_min_dur;
        else
            succ_per_min(end) = 0;
        end
    end
    
    
    for trial = 1:num_succ
                
        %number of re-entries
        words_idx  =  binnedData.words(:,1) >= binnedData.trialtable(succ_idx(trial),1) & ...
                             binnedData.words(:,1) <= binnedData.trialtable(succ_idx(trial),8) ;
        
        num_reentries(trial) = sum(binnedData.words(words_idx,2)==161)-1;
        
        %time2target
        time2target(trial) = binnedData.trialtable(succ_idx(trial),8) - binnedData.trialtable(succ_idx(trial),7);
        
        %path
        binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),7),1,'last');
        binstop  = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),8),1,'last');
        rawpath  = binnedData.cursorposbin(binstart:binstop,:);

        path_length(trial) = sum(sqrt(sum(diff(rawpath).^2,2)));
        
        numbins  = binstop-binstart;
        binpct   = 0:100/numbins:100;
        normpath{trial} = interp1(binpct,rawpath,0:100);
    end
        
    target_stats = [target_stats; dataset(...
        {  targets(tgt)  ,'ID'           },...
        {  N             ,'N'            },...
        {  succ_rate     ,'succ_rate'    },...
        {{ succ_per_min} ,'succ_per_min' },...
        {{ path_length}  ,'path_length'  },...
        {{ time2target}  ,'time2target'  },...
        {{ num_reentries},'num_reentries'},...
        {{ normpath},'normpath'} ...
        )];%#ok<AGROW> 
end






