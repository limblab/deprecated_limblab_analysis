function istuned = checkTuningNonparametricSignificance(mfrs,cils,cihs)
% use mean firing rate +/- confidence interval
% useRad is for using radians
%
%   all of these should be 1xN where N is number of binned movement directions
% 
% if confidence interval of one movement direction is completely outside
% any other, then the cell is tuned

istuned = 0;

for iDir = 1:length(mfrs)
    for iDir2 = iDir:length(mfrs)
        ci1 = [cils(iDir), cihs(iDir)];
        ci2 = [cils(iDir2), cihs(iDir2)];
        overlap = range_intersection(ci1,ci2);
        
        if isempty(overlap)
            istuned = 1;
        end
    end
end
