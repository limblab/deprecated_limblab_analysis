function out = compareNonparametricTuning(mfrs,cils,cihs,sg)
% compares 2 or more nonparametric tunings and returns diff matrix
%   mfr: mean firing rate [# units, # directions]
%   cil: low bound of confidence interval (same dimensions)
%   cih: high bound of CI
%               each of these should be a cell array with multiple tunings
%   sg: spike guide

if ~iscell(mfrs) || length(mfrs) < 2
    error('Nothing to compare!')
end

nTargs = size(mfrs{1},2);

for unit = 1:size(mfrs{1},1)
    
    diffMat = zeros(length(mfrs),length(mfrs));
    
    for iFile = 1:length(mfrs)
        fr1 = mfrs{iFile};
        cil1 = cils{iFile};
        cih1 = cihs{iFile};
        
        for j = iFile+1:length(mfrs)
            fr2 = mfrs{j};
            cil2 = cils{j};
            cih2 = cihs{j};
            
            targDiffs = zeros(nTargs,1);
            
            for iTarg = 1:nTargs
                % do the confidence intervals overlap?
                ci1 = [cil1(unit,iTarg) cih1(unit,iTarg)];
                ci2 = [cil2(unit,iTarg) cih2(unit,iTarg)];
                overlap = range_intersection(ci1,ci2);
                
                % build matrix showing how they differ
                if isempty(overlap)
                    targDiffs(iTarg) = 1;
                end
            end
            
            if any(targDiffs)==1
                diffMat(iFile,j) = 1;
            end
        end
    end
    out.(['elec' num2str(sg(unit,1))]).(['unit' num2str(sg(unit,2))]) = diffMat;
end
