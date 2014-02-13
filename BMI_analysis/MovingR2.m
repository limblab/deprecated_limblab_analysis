function [vaf, R2 ] = MovingR2(act,pred,window_length)

%       act,pred            : (num_bins x num_sigs) arrays of signals to be compared
%       
%       [vaf, R2]           : returns (num_bins-window_length+1 x num_sigs) arrays of vaf and R2 values 
%       window_length       : size of the moving window over which to calculate R2 amd vaf

[num_bins,num_sigs] = size(act);

vaf = zeros(num_bins-window_length+1,num_sigs);
R2  = zeros(num_bins-window_length+1,num_sigs);

if any([num_bins,num_sigs] ~= size(pred))
    error('MovingR2 input size: sig1 and sig2 have to be the same size');
end

for i = 1:num_bins-window_length+1    
    bin_start = window_length+i-1;
    bin_stop  = bin_start + window_length;
    tmp_act  = act(bin_start:bin_stop,:);
    tmp_pred  = pred(bin_start:bin_stop,:);    
    
    R2(i,:)   = CalculateR2(tmp_act,tmp_pred)';
    vaf(i,:)  = 1 - sum( (tmp_pred-tmp_act).^2 ) ./ sum( (tmp_act - repmat(mean(tmp_act),size(tmp_act,1),1)).^2 );
end
