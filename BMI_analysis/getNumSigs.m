function numSigs = getNumSigs(binnedData,options)
numSigs = 0;

if isfield(options,'PredEMGs');
    if options.PredEMGs
        numSigs = numSigs+size(binnedData.emgdatabin,2);
    end
end

if isfield(options,'PredForce');
    if options.PredForce
        numSigs = numSigs+size(binnedData.forcedatabin,2);
    end
end

if isfield(options,'PredCursPos');
    if options.PredCursPos
        numSigs = numSigs+size(binnedData.cursorposbin,2);
    end
end
if isfield(options,'PredVeloc');
    if options.PredVeloc
        numSigs = numSigs+size(binnedData.velocbin,2);
    end
end