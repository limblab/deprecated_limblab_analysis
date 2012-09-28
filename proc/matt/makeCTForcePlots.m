function makeCTForcePlots()

% Options
plotTrialTraces = false;
plotForceSummary = true;

% Plot CT data
fileList = {'Y:\Jaco_8I1\BDFStructs\08-17-12\Jaco_IsoHC_BCCatch_08-17-12_002.mat',...
            'Y:\Jaco_8I1\BDFStructs\08-17-12\Jaco_IsoHC_BCCatch_08-17-12_003.mat',...
            'Y:\Jaco_8I1\BDFStructs\08-17-12\Jaco_IsoBC_08-17-12_004.mat',...
            'Y:\Jaco_8I1\BDFStructs\08-17-12\Jaco_IsoHC_BCCatch_08-17-12_005.mat',...
            'Y:\Jaco_8I1\BDFStructs\08-17-12\Jaco_IsoHC_BCCatch_08-17-12_006.mat'};
[trialTable,force] = poolCatchTrialData(fileList);

if plotTrialTraces
    plotIsometricForce(trialTable,force,true);
end

if plotForceSummary
    targetData = plotForceSummaryByTarget(trialTable,force);
end

end