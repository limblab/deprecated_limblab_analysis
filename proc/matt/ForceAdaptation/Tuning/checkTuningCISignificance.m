function istuned = checkTuningCISignificance(pds,ciSig,useRad)
% assumes pds are [pd ci_low ci_high]
% useRad is for using radians

if nargin < 3
    useRad = false;
end

% set median to zero (Stevenson 2011)
m = median(pds(:,1));
mdiff = pds(:,1)-m;

pds = pds - repmat(mdiff,1,3);

% tuned if CI less than some value
istuned = angleDiff( pds(1), pds(2), useRad ) + angleDiff( pds(1), pds(3), useRad ) <= ciSig;