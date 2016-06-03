function target_stats = get_WF_stats(binnedData,varargin)

%totals, all targets:
successes    = find(binnedData.trialtable(:,9)==double('R'));
num_successes = length(successes);
num_trials    = size(binnedData.trialtable,1);

% for succ_per_min, only consider last minute if more than 30 sec
duration = binnedData.timeframe(end)-binnedData.timeframe(1);
num_mins = floor(duration/60);
if mod(duration,60) > 30
    %also consider last minute if more than 30 sec
    last_min_dur = mod(duration,60);
    succ_per_min = nan(num_mins+1,1);
    succ_per_min_tot = zeros(num_mins+1,1);
else
    last_min_dur = 0;
    succ_per_min = nan(num_mins,1);
    succ_per_min_tot = zeros(num_mins,1);
end


targets      = sort(unique(binnedData.trialtable(:,10)));
num_targets  = length(targets);
target_stats = [];
CT_emgs      = {};

% target specific stats
for tgt = 1:num_targets
    tgt_idx       = find(binnedData.trialtable(:,10)==targets(tgt));
    N             = length(tgt_idx);
    succ_idx      = intersect(tgt_idx,successes);
    num_succ      = length(succ_idx);
    succ_rate     = num_succ/N;
    num_reentries = nan(num_succ,1);
    path_length   = nan(num_succ,1);
    time2target   = nan(num_succ,1);
    normpath      = cell(num_succ,1);
    OT_emgs       = cell(num_succ,1);
    
    %rewards per minute
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
    succ_per_min_tot = succ_per_min_tot + succ_per_min;
    
    
    for trial = 1:num_succ
                
        %number of re-entries
        words_idx  =  binnedData.words(:,1) >= binnedData.trialtable(succ_idx(trial),1) & ...
                             binnedData.words(:,1) <= binnedData.trialtable(succ_idx(trial),8) ;
        
        num_reentries(trial) = max(0,sum(binnedData.words(words_idx,2)==161)-1);
        
        %time2target
        time2target(trial) = binnedData.trialtable(succ_idx(trial),8) - binnedData.trialtable(succ_idx(trial),7);
        
        %emgs
        
        binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),1),1,'last');
        binstop  = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),6),1,'last');
        CT_emgs = [CT_emgs;{binnedData.emgdatabin(binstart:binstop,:)}];%#ok<AGROW>
        
        binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),7),1,'last');
        binstop  = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),8),1,'last');
%         % use this to make it only until the first entry
%         firstentry_t = binnedData.words(binnedData.words(words_idx,2)==161,1);
%         binstop = find(binnedData.timeframe<=firstentry_t,1,'last');
        OT_emgs{trial} = binnedData.emgdatabin(binstart:binstop,:);
        
        %path
        rawpath  = binnedData.cursorposbin(binstart:binstop,:);      
        path_length(trial) = sum(sqrt(sum(diff(rawpath).^2,2)));
        
        numbins  = binstop-binstart;
        
        if  numbins<2 || isempty(binstart) || isempty(binstop)
            disp('something is wrong, probably extra reward word in trialtable');
            fprintf('for file : %s\n',binnedData.meta.filename);
            fprintf('trial starting at %.2f sec\n',binnedData.trialtable(succ_idx(trial),1));
        end
        
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
        {{ normpath}     ,'normpath'     },...
        {{ OT_emgs}         ,'emgs'         }...
        )];%#ok<AGROW> 
end


% totals
succ_rate = num_successes/num_trials;
pl_tot    = [];
t2t_tot   = [];
num_reent = [];
norm_path = [];
for i = 1:num_targets
    pl_tot    = [pl_tot;   target_stats.path_length{i}];%#ok<AGROW>
    t2t_tot   = [t2t_tot;  target_stats.time2target{i}];%#ok<AGROW>
    num_reent = [num_reent;target_stats.num_reentries{i}];%#ok<AGROW>
    norm_path = [norm_path; target_stats.normpath{i}]; %#ok<AGROW>
end

target_stats = [target_stats; dataset(...
    {   0                   ,'ID'           },...
    {   num_trials          ,'N'            },...
    {   succ_rate           ,'succ_rate'    },...
    {   {succ_per_min_tot}  ,'succ_per_min' },...
    {   {pl_tot}            ,'path_length'  },...
    {   {t2t_tot}           ,'time2target'  },...
    {   {num_reent}         ,'num_reentries'},...
    {   {norm_path}         ,'normpath'     },...
    {   {CT_emgs}           ,'emgs'         }...
    )];





