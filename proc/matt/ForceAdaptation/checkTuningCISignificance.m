function istuned = checkTuningCISignificance(pds,ciSig,useRad)
% assumes pds are [pd ci_low ci_high]
% useRad is for using radians

if nargin < 3
    useRad = false;
end

istuned = angleDiff( pds(1), pds(2), useRad ) + angleDiff( pds(1), pds(3), useRad ) <= ciSig;