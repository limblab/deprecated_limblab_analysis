function [tStat_neuron, pVal_neuron] = find_extrinsic_stats(pol_fit_full)

    % Get t-statistic for change across conditions (max change of coefficients)
    tStat_neuron = zeros(length(pol_fit_full),1);
    pVal_neuron = zeros(length(pol_fit_full),1);
    for i = 1:length(pol_fit_full)
        tStat = pol_fit_full{i}.Coefficients.tStat(4:end);
        pVal = pol_fit_full{i}.Coefficients.pValue(4:end);
    %     estimate = pol_fit_full{i}.Coeffiecients.Estimate(4:end);
    %     [~,max_ind] = max(estimate);
        [pVal_neuron(i),max_ind] = max(pVal);
        tStat_neuron(i) = tStat(max_ind);
    end

end