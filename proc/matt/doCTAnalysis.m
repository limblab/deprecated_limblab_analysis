function doCTAnalysis()
% Can do the following things:
%   - Plot preferred directions of all channels/cells
%   - Plot forces for trials (BC, HC, CT)
%   - Plot summaries of metrics
%   - Plot metric over time (most useful for ramp)
%
% Can use the following metrics:
%   - Success percentage
%   - Success rate
%   - Path length
%   - Time to target

plotPDSummary = true;

% Specify folders in which to look for data
fileList = {'Y:\Jaco_8I1\BDFStructs\09-19-12\Jaco_IsoHC_BCCatch_09-19-12_002.mat',...
            'Y:\Jaco_8I1\BDFStructs\09-19-12\Jaco_IsoBC_09-19-12_003.mat'};



fHC = [];
fCT = [];
fBC = [];
        
for ifile = 1:length(fileList)
    [trialTable,force] = poolCatchTrialData(fileList(ifile));

        targetData = plotForceSummaryByTarget(trialTable,force);
        
        indsHC = find(trialTable(:,11) == 0);
        indsCT = find(trialTable(:,11) == 1);
        indsBC = find(trialTable(:,11) == 2);
        
        
        for i = 1:8
            b=targetData.(['Target' num2str(i)]);
            fHC = [fHC; b(b(:,11)==0,end)];
            fCT = [fCT; b(b(:,11)==1,end)];
            fBC = [fBC; b(b(:,11)==2,end)];
        end


end

A = [fHC; fCT; fBC];
B = [ones(size(fHC)); 2*ones(size(fCT)); 3*ones(size(fBC))];

close all;
figure;
boxplot(A,B);

if plotPDSummary
    analyzeNeuronPDs(fileList);
end
