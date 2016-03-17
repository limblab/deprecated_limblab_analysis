function [sortedPDs] = PDsort(PDfile)

% This code sorts a set of PDs based on proximity to nearest neighbors. The
% outupt file matrix will rearrange units such that the top row is the
% closest to its neighbors and the bottom row is furthest.

% This does not take into account confidence intervals or depth of
% modulation. Also, it does not take into account the effects of removing
% top units on the order of subsequent units.

pi = 3.14159;
dif = zeros(size(PDfile{1,1},1),1);
totalDif = zeros(size(PDfile{1,1},1),1);

for testNeuron = 1:size(PDfile{1,1},1)
    
    for compareNeuron = 1:size(PDfile{1,1},1)
    
        dif(compareNeuron) = abs(PDfile(testNeuron,4) - PDfile(compareNeuron,4));

        if dif(compareNeuron) > pi
            dif(compareNeuron) = 2*pi - dif(compareNeuron);
        end
        
    end

    dif = sort(dif);
    totalDif(testNeuron) = sum(dif(1:3));
    
end

PDfile = [PDfile{1,1} totalDif];

sortedPDs = sortrows(PDfile, size(PDfile,2));
sortedPDs = sortedPDs(:,1:size(PDfile,2));