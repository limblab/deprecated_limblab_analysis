function [R2, vaf, err, cumerr, actvar] = pred_accuracy_per_tgt(act,pred,bd,ds,de)
% pred accuracy during each target and also between trials.
%
% act, pred : actual and predicted Ndim signals to compare
% bd        : corresponding binnedData file
% ds, de    : delay after start/end events respectively for data inclusion 
%             example [ds de] = [.2 .05], start1=10, ot1_on=10.7, rw1=11.5 start2=13.4
%             center_times = [10.2 10.75] out_times = [10.9 11.55] it_times= [11.6 13.45]
%
% R2,vaf    : Ntgt+3 x Ndim accuracy values
%             Ntgt+3 rows are for: 1 for center, 1 for each tgt, 1 for all tgts and 1 for inter-trial respectively
% err       : Ntgt+3 x Ndim array which elements indicate the percentage of
%             time points at which the error between predicted and actual values was
%             above a threshold, set to the the mean or the residual rms,
%             accross all of the predicted signals
% cumerr    : sum of error during all epochs, divided by number of bins for
%             each epoch
% actvar    : variance of the actual signals during each epoch


% find which column of trialtable is which
ct_i   = strcmp(bd.trialtablelabels,'trial start time');
ot_i   = strcmp(bd.trialtablelabels,'outer target time');
rw_i   = strcmp(bd.trialtablelabels,'trial end time');
res_i  = strcmp(bd.trialtablelabels,'Result(R,A,I,orN)');
tid_i  = strcmp(bd.trialtablelabels,'tgt_id');

tgt_list    = unique(bd.trialtable(:,tid_i)); %[ not, ct, ot]
n_tgt       = length(tgt_list);
succ_trials = bd.trialtable(:,res_i)==double('R');
num_succ    = sum(succ_trials);
n_bin       = length(bd.timeframe);
n_dim       = size(act,2);

center_t = [bd.trialtable(succ_trials,ct_i)+ds ...
                bd.trialtable(succ_trials,ot_i)+de];

out_t    = [bd.trialtable(succ_trials,ot_i)+ds ...
                bd.trialtable(succ_trials,rw_i)+de ...
                    bd.trialtable(succ_trials,tid_i)];

it_t     = [bd.trialtable([succ_trials(1:end-1);false],rw_i)+ds ...
                bd.trialtable([false;succ_trials(2:end)],ct_i)+de];

            
center_i = false(n_bin,1);
out_i    = false(n_bin,n_tgt+1);
it_i     = false(n_bin,1);

% Find bin indices for each epochs
for i = 1:num_succ
    
    center_i = center_i | bd.timeframe>=center_t(i,1) & bd.timeframe<=center_t(i,2);
    
    tgt = tgt_list == out_t(i,3);
    out_i(:,tgt) = out_i(:,tgt) | bd.timeframe>=out_t(i,1)    & bd.timeframe<=out_t(i,2);
    out_i(:,end) = out_i(:,end) | out_i(:,tgt);
    
    if i < num_succ
        it_i = it_i      | bd.timeframe>=it_t(i,1)     & bd.timeframe<=it_t(i,2);
    end
end

R2   = nan(n_tgt+3,n_dim);
vaf  = nan(n_tgt+3,n_dim);
err  = nan(n_tgt+3,n_dim);
cumerr = nan(n_tgt+3,n_dim);
res  = abs(act - pred);
trsh = mean(rms(res));
actvar = nan(n_tgt+3,n_dim);

%Calculate pred accuracy given the bin indices for each epoch
R2(1,:)  = CalculateR2(pred(center_i,:),act(center_i,:));
vaf(1,:) = calc_vaf(pred(center_i,:),act(center_i,:));
err(1,:) = sum(res(center_i,:)>trsh)/sum(center_i);
cumerr(1,:) = sum(res(center_i,:))/sum(center_i);
actvar(1,:) = var(act(center_i,:));

for t = 1:n_tgt
    R2(t+1,:)  = CalculateR2(pred(out_i(:,t),:),act(out_i(:,t),:));
    vaf(t+1,:) = calc_vaf(pred(out_i(:,t),:),   act(out_i(:,t),:));
    err(t+1,:) = sum(res(out_i(:,t),:)>trsh)/sum(out_i(:,t));
    cumerr(t+1,:) = sum(res(out_i(:,t),:))/sum(out_i(:,t));
    actvar(t+1,:) = var(act(out_i(:,t),:));
end

R2(end-1,:)  = CalculateR2(pred(out_i(:,end),:),act(out_i(:,end),:));
vaf(end-1,:) = calc_vaf(pred(out_i(:,end),:),   act(out_i(:,end),:));
err(end-1,:) = sum(res(out_i(:,end),:)>trsh)/sum(out_i(:,end));
cumerr(end-1,:)= sum(res(out_i(:,end),:))/sum(out_i(:,end));
actvar(end-1,:) = var(act(out_i(:,end),:));

R2(end,:)  = CalculateR2(pred(it_i,:),act(it_i,:));
vaf(end,:) = calc_vaf(pred(it_i,:),   act(it_i,:));
err(end,:) = sum(res(it_i,:)>trsh)/sum(it_i);
cumerr(end,:) = sum(res(it_i,:))/sum(it_i);
actvar(end,:) = var(act(it_i,:));