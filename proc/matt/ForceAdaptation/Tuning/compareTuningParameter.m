function out = compareTuningParameter(doType,vals,sg,compMethod)
% compares tuning in different methods, epochs, files, days, etc
%   doType is what parameter to compare ('pd','md','bo')
%   vals is cell array of pd arrays [pd ci_low ci_high] (or md, bo)
%   sg is spike guide
%   compMethod says how to do it... can be a cell with params for diff or just a string saying to do CI overlap
%       {'diff', confLevel, numIters}: bootstrap the difference and see if zero overlaps
%
%       'overlap: see if CI of each PD estimate overlaps
%
% With diff, pds should be matrices of all of the bootstrapped pd values
% With overlap, pds should just be matrix of PD+-CI for each neuron
%
% assumes for now that the same cells are in each struct

% check to make sure doType is correct
if ~ismember(doType,{'pd','md','bo'})
    error('not sure what type of parameter to look at');
end

if nargin < 4
    compMethod = {'diff', 0.95, 1000};
end

if ~iscell(vals) || length(vals) < 2
    error('Nothing to compare!')
end

% expect a cell with parameters if doing bootstrapping of differences
switch lower(compMethod{1})
    case 'diff'
        confLevel = compMethod{2};
        numIters = compMethod{3};
        compMethod = compMethod{1};
    case 'overlap'
        confLevel = compMethod{2};
        compMethod = compMethod{1};
    case 'ttest'
        confLevel = compMethod{2};
        compMethod = compMethod{1};
end

% for each unit, compare pds and cis across three epochs
switch lower(compMethod)
    case 'ttest'
        % do a t test on two different populations of samples
        %   mostly for GLM use
        
        % get pd samples for each unit
        for unit = 1:size(vals{1},1)
            diffMat = zeros(length(vals));
            for i = 1:length(vals)
                val1 = vals{i};
                samp1 = val1(unit,:);
                
                for j = i+1:length(vals)
                    val2 = vals{j};
                    samp2 = val2(unit,:);
                    
                    % now test if samples are from same population
                    diffMat(i,j) = ttest2(samp1,samp2,'alpha',1-confLevel,'tail','both','vartype','unequal');
                end
            end
            out.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]) = diffMat;
        end
        
    case 'diff'
        % compare difference of bootstrapped PDs to see if 0 is in CI
        for unit = 1:size(vals{1},1)
            diffMat = zeros(length(vals));
            for i = 1:length(vals)
                val1 = vals{i};
                
                for j = i+1:length(vals)
                    val2 = vals{j};
                    
                    % find bootstrapped difference
                    if strcmpi(doType,'pd') % difference of angular value is a bit trickier
                        diffval = angleDiff(val1(unit,:),val2(unit,:),true,true);
                    else
                        diffval = val2(unit,:) - val1(unit,:);
                    end
                    
                    % get 95% confidence bounds
                    diffval = sort(diffval);
                    
                    ci_sig = [diffval(ceil(numIters*( (1 - confLevel)/2 ))), diffval(floor(numIters*( confLevel + (1-confLevel)/2 )))];
                    
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
        % see if CIs overlap... not ideal
        for unit = 1:size(vals{1},1)
            diffMat = zeros(length(vals));
            for i = 1:length(vals)
                val1 = vals{i};
                ci1 = val1(unit,2:3);
                ci1 = sort(ci1);
                for j = i+1:length(vals)
                    val2 = vals{j};
                    ci2 = val2(unit,2:3);
                    ci2 = sort(ci2);
                    
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