function [binnedData, dropped_units] = rand_null_unit(binnedData,pct,varargin)

sd = binnedData.spikeratedata;
prevDrops = [];
if nargin>2
    prevDrops = varargin{1};
end

numprevDrops = length(prevDrops);

[numPts, numUnits] = size(sd);
numDrop = round( (numUnits-numprevDrops)*pct/100);

for i = 1:numDrop
    wrongUnit = true;
    while wrongUnit
        drop_i = round(numUnits*rand+0.5);
        if ~any(prevDrops == drop_i)
            wrongUnit = false;
            prevDrops = [prevDrops, drop_i];
        end
    end
    sd(:,drop_i) = zeros(numPts,1);
end
dropped_units = prevDrops;
binnedData.spikeratedata = sd;

end