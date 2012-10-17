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

plotPDSummary = false;

% Specify folders in which to look for data
fileList = {'Y:\Jaco_8I1\BDFStructs\09-19-12\Jaco_IsoBC_09-19-12_003.mat'};


fHC = [];
fCT = [];
fBC = [];

fpHC = [];
fpCT = [];
fpBC = []; 

for ifile = 1:length(fileList)
    [trialTable,force] = poolCatchTrialData(fileList(ifile));

        targetData = plotForceSummaryByTarget(trialTable,force);
        
        indsHC = find(trialTable(:,11) == 0);
        indsCT = find(trialTable(:,11) == 1);
        indsBC = find(trialTable(:,11) == 2);
        
        
        for i = 1:8
            b=targetData.(['Target' num2str(i)]);
            fHC = [fHC; b(b(:,11)==0,12)];
            fCT = [fCT; b(b(:,11)==1,12)];
            fBC = [fBC; b(b(:,11)==2,12)];
            
            fpHC = [fpHC; b(b(:,11)==0,13)];
            fpCT = [fpCT; b(b(:,11)==1,13)];
            fpBC = [fpBC; b(b(:,11)==2,13)];
        end


end

A = [fHC; fCT; fBC];
B = [ones(size(fHC)); 2*ones(size(fCT)); 3*ones(size(fBC))];

% Plot boxplot summary of integrated forces for successful movements
close all;
figure;
boxplot(A,B);
title('Total force');
set(gca,'XTick',[1 2 3])
set(gca,'XTickLabel',{'HC','CT','BC'})

A = [fpHC; fpCT; fpBC];
B = [ones(size(fpHC)); 2*ones(size(fpCT)); 3*ones(size(fpBC))];
figure;
boxplot(A,B);
title('Peak force');
set(gca,'XTick',[1 2 3])
set(gca,'XTickLabel',{'HC','CT','BC'})

if plotPDSummary
    analyzeNeuronPDs(fileList);
    title('Preferred direction (degrees)');
    set(gca,'XTick',[1 2 3])
    set(gca,'XTickLabel',{'HC','CT','BC'})
end
