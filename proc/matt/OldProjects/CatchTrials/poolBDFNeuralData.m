function neuralData = poolBDFNeuralData(varargin)
% This function is a hack. It combines unit data from BDFs

% Initialize some number of potential units
neuralData = initializeNeuralData(200);

% add the data for the BDFs
maxt = 0;
for iBDF = 1:length(varargin)
    bdf = varargin{iBDF};
    [neuralData, maxt] = addBDFToNeuralData(neuralData,bdf,maxt);
end

% Now trim units that have no data
% DO THIS

end

function neuralData = initializeNeuralData(nUnits)

for i = 1:nUnits
    neuralData(i) = struct('id', [ceil((i)/2) mod(i+1,2)], 'ts', []);
end

end

function [neuralData, maxt] = addBDFToNeuralData(neuralData,bdf,maxt)
    
nUnits = length(bdf.units);
for iUnit = 1:nUnits
    id = bdf.units(iUnit).id;
    ts = bdf.units(iUnit).ts;
    
    % I got some weird thing where the id was [72 255] so... weird.
    if id(2)==255
        id(2) = 1;
    end
    
    findID = arrayfun(@(x) x.id==id, neuralData, 'UniformOutput', false);
    findID = cellfun(@(x) sum(x)==2, findID);

    neuralData(findID).ts = [neuralData(findID).ts; ts+maxt];


end

maxt = bdf.force.data(end,1);
end