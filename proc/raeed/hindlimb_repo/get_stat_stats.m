function [num_neurons,num_same,median_t,median_cos] = get_stat_stats
leg;foo2

num_neurons = sum(VAF_unc>0.4 & VAF_con>0.4);
num_same = sum(VAF_unc>0.4 & VAF_con>0.4 & pVal_neuron'>0.01);
median_t = median(abs(tStat_neuron(VAF_unc>0.4 & VAF_con>0.4)));
median_cos = median(cosdthetay(VAF_unc>0.4 & VAF_con>0.4));
end