function out = comparePDTuning(pds,sg,compMethod)
% compares tuning in different methods, epochs, files, days, etc
%   pds is cell array of pd arrays [pd ci_low ci_high]
%   sg is spike guide
%   useMethod says how to do it... can be a cell with params for diff or just a string saying to do CI overlap
%       {'diff', confLevel, numIters}: bootstrap the difference and see if zero overlaps
%           
%       'overlap: see if CI of each PD estimate overlaps
% 
% With diff, pds should be matrices of all of the bootstrapped pd values
% With overlap, pds should just be matrix of PD+-CI for each neuron
%
% assumes for now that the same cells are in each struct

if nargin < 3
    compMethod = {'diff', 0.95, 1000};
end

if ~iscell(pds) || length(pds) < 2
    error('Nothing to compare!')
end

% expect a cell with parameters if doing bootstrapping of differences
if iscell(compMethod)
    confLevel = compMethod{2};
    numIters = compMethod{3};
    compMethod = compMethod{1};
end

% for each unit, compare pds and cis across three epochs
switch lower(compMethod)
    case 'diff'
        
        for unit = 1:size(pds{1},1)
            diffMat = zeros(length(pds));
            for i = 1:length(pds)
                pd1 = pds{i};
                
                for j = i+1:length(pds)
                    pd2 = pds{j};
                    
                    % find bootstrapped difference
                    diffpd = angleDiff(pd2(unit,:),pd1(unit,:),true,true);
                    
                    % get 95% confidence bounds
                    diffpd = sort(diffpd);
                    confLevel = 0.95;
                    numIters = 1000;
                    
                    ci_sig = [diffpd(ceil(numIters - confLevel*numIters)), diffpd(floor(confLevel*numIters))];
                    
                    % is 0 in the confidence bound? if not, it is different
                    overlap = range_intersection([0 0],ci_sig);
                    
                    % build matrix showing how they differ
                    if isempty(overlap)
                        diffMat(i,j) = 1;
                    end
                end
            end
            out.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]) = diffMat;
        end
        
    %%%%%%%%%%%%%%
    case 'overlap'
        
        for unit = 1:size(pds{1},1)
            diffMat = zeros(length(pds));
            for i = 1:length(pds)
                pd1 = pds{i};
                ci1 = pd1(unit,2:3);
                for j = i+1:length(pds)
                    pd2 = pds{j};
                    ci2 = pd2(unit,2:3);
                    
                    % do the confidence intervals overlap?
                    overlap = range_intersection(ci1,ci2);
                    
                    % build matrix showing how they differ
                    if isempty(overlap)
                        diffMat(i,j) = 1;
                    end
                end
            end
            out.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]) = diffMat;
        end
        
end