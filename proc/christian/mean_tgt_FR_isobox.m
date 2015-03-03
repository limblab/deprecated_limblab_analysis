function [MTF] = mean_tgt_FR_isobox(binnedData,varargin)
% varargin = {t_start_wrt_GO, X, t_stop_wrt_X}
% define the time window over which to look at FR.
% t_start_wrt_GO is beginning of window wrt GO_CUE
% X is either 'GO' or 'Reward'
% t_stop_wrt_X is the end of window wrt to X

% default options:
t_start_wrt_GO = 0;
t_stop_wrt_X   = 0;
X = 'Reward';

if nargin > 1 t_start_wrt_GO = varargin{1}; end
if nargin > 2 X = varargin{2}; end
if nargin > 3 t_stop_wrt_X = varargin{3}; end

% sizes, counters and indexes:
n_tgt     = 8;
trial_list= find(binnedData.trialtable(:,9)=='R'); % only successful trials
n_trials  = length(trial_list);
tgt_list  = binnedData.trialtable(trial_list,10);
tgt_ctr   = zeros(1,n_tgt);
n_chan    = size(binnedData.spikeratedata,2);
start_ts  = binnedData.trialtable(trial_list,7)+t_start_wrt_GO;
if strcmp(X,'Reward')
    stop_ts = binnedData.trialtable(trial_list,8)+t_stop_wrt_X;
else
    stop_ts = start_ts + t_start_wrt_X;
end

% pre-allocation
MTF = zeros(n_tgt,n_chan);

% compute FR
for t = 1:n_trials
    
    bin_start = find(binnedData.timeframe <= start_ts(t),1,'last');
    bin_stop  = find(binnedData.timeframe <= stop_ts(t),1,'last');
    tgt_ctr(tgt_list(t)) = tgt_ctr(tgt_list(t)) + 1;
    nt = tgt_ctr(tgt_list(t));
    
    mfr = mean(binnedData.spikeratedata(bin_start:bin_stop,:));
    
    MTF(tgt_list(t),:) = MTF(tgt_list(t),:)*(nt-1)/nt + mfr/nt;
end


