%% 
bad_neurons = neurons(VAF_cart_unc<0.4 & VAF_cart_con<0.4,:);
norm_bad_factor = sqrt(sum(bad_neurons.^2,2));
norm_bad = bad_neurons./repmat(norm_bad_factor,1,size(bad_neurons,2));
figure
for i = 1:8
    subplot(8,1,i)
    ksdensity(norm_bad(:,i))
end

%% 
good_neurons = neurons(VAF_cart_unc>0.4 & VAF_cart_con>0.4,:);
norm_good_factor = sqrt(sum(good_neurons.^2,2));
norm_good = good_neurons./repmat(norm_good_factor,1,size(good_neurons,2));
figure
for i = 1:8
    subplot(8,1,i)
    ksdensity(norm_good(:,i))
end

%% 
norm_all_factor = sqrt(sum(neurons.^2,2));
norm_all = neurons./repmat(norm_all_factor,1,size(neurons,2));
figure
for i = 1:8
    subplot(8,1,i)
    ksdensity(norm_all(:,i))
end