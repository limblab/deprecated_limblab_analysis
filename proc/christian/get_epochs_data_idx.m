function [center_i, out_i, it_i] = get_epochs_data_idx(bd,varargin)
% [ct_i, ot_i, it_i] = get_epochs_data_idx(bd,ds,de)
% 
%   This function returns the bin indices for a center-out WF binnedData file (bd),
%   corresponding to the times:
%   center_i  : the center target was on (n_bin x 1 logical)
%   out_i     : the outer target was on  (n_bin x ntgt logical)
%   it_i      : time in-between trials   (n_bin x 1 logical)
%
%  Note: this function currently returns indices only for SUCCESSFUL TRIALS!
%
% optionally, in addition to the binnedData file bd, you can specify delay parameters: 
% varargin = {ds,de}
% ds, de    : delay after start/end events respectively for data inclusion 
%             example [ds de] = [.2 .05], start1=10, ot1_on=10.7, rw1=11.5 start2=13.4
%             center_times = [10.2 10.75] out_times = [10.9 11.55] it_times= [11.6 13.45]
ds=0; de=0;
if nargin>1
    ds = varargin{1};
    if nargin>2
        de = varargin{2};
    end
end

% find which column of trialtable is which
ct_i   = strcmp(bd.trialtablelabels,'trial start time');
ot_i   = strcmp(bd.trialtablelabels,'outer target time');
rw_i   = strcmp(bd.trialtablelabels,'trial end time');
res_i  = strcmp(bd.trialtablelabels,'Result(R,A,I,orN)');
tid_i  = strcmp(bd.trialtablelabels,'tgt_id');

tgt_list    = unique(bd.trialtable(:,tid_i)); %[ not, ct, ot]
n_tgt       = length(tgt_list);
succ_trials = find(bd.trialtable(:,res_i)==double('R'));
num_succ    = length(succ_trials);
n_bin       = length(bd.timeframe);

center_t = [bd.trialtable(succ_trials,ct_i)+ds ...
                bd.trialtable(succ_trials,ot_i)+de];

out_t    = [bd.trialtable(succ_trials,ot_i)+ds ...
                bd.trialtable(succ_trials,rw_i)+de ...
                    bd.trialtable(succ_trials,tid_i)];

it_t     = [bd.trialtable(succ_trials(1:end-1),rw_i)+ds ...
                bd.trialtable(succ_trials(2:end),ct_i)+de];

            
center_i = false(n_bin,1);
out_i    = false(n_bin,n_tgt+1);
it_i     = false(n_bin,1);

% Find bin indices for each epochs
for i = 1:num_succ
    
    center_i = center_i | bd.timeframe>=center_t(i,1) & bd.timeframe<=center_t(i,2);
    
    tgt = tgt_list == out_t(i,3);
    out_i(:,tgt) = out_i(:,tgt) | bd.timeframe>=out_t(i,1)    & bd.timeframe<=out_t(i,2);
    
    if i < num_succ
        it_i = it_i      | bd.timeframe>=it_t(i,1)     & bd.timeframe<=it_t(i,2);
    end
end