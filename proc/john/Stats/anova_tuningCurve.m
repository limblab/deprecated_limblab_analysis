function [pValues, goodNeurons] = anova_tuningCurve(FRandGroups,signif)
% ANOVA_TUNINGCURVE Perform anova2 test on multiple neuron FRs from
%'tuningCurve.m'
%
% INPUT: 'FRandGroups' - Output from 'tuningCurveStats' function
%
% OUTPUT: 'probGreatF' - cell array, 2 columns. 'prob>F' value from anova2
% table for firing rates and standard deviations from 'tuningCurve.m'

%%


% g1 = direction; g2 = stim. block


n_neurons = length(FRandGroups);
pValues = zeros(n_neurons,2);
goodNeurons = [];

% Perform anovan for each neuron
for iNeuron = 1:n_neurons-1

    FRs = FRandGroups{iNeuron+1,1};
    g1 = FRandGroups{iNeuron+1,2};
    g2 = FRandGroups{iNeuron+1,3};
    
%     cutZeros = find(FRs~=0);
%     FRs = FRs(cutZeros);
%     g1  = g1(cutZeros);
%     g2  = g2(cutZeros);
        
    
    p = anovan(FRs,{g1 g2},'display','off');
    pValues(iNeuron,:) = p;
    
%     [N,BINS] = count(FRs); [BINS N]
%     N(1)/length(FRs)
    
    if p(2) < signif
        goodNeurons = [goodNeurons iNeuron];
    end
     
end