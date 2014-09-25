function vaf = calc_vaf(pred,act)
    mean_act = repmat(mean(act),size(act,1),1);
    vaf = 1 - sum((pred-act).^2) ./ sum((act-mean_act).^2);
end