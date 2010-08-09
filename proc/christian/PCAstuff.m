

desiredInputs = get_desired_inputs(binnedData.spikeguide, NeuronIDs);

spikes = binnedData.spikeratedata(:,desiredInputs);

[pc,score,variances,tsquare] = princomp(spikes);

% prop_of_var = cumsum(variances)./sum(variances);
percent_explained = 100*variances/sum(variances);

figure;
pareto(percent_explained);
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Before Standardisation');

figure;
biplot(pc(:,1:2)); title('Coeffs, before Standardisation');

%You can standardize the data by dividing each column by its standard
%deviation.
stdSpikes = std(spikes);
stdSpikes = spikes./repmat(stdSpikes, size(spikes,1),1);

[pc,score,variances,tsquare] = princomp(stdSpikes);

% prop_of_var = cumsum(variances)./sum(variances);
percent_explained = 100*variances/sum(variances);

figure;
pareto(percent_explained);
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('After Standardisation');

figure;
biplot(pc(:,1:2)); title('Coeffs, with Standardisation');