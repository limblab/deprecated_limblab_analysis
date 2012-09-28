function analyzeNeuronPDs(fileList)

% This is a temporary hack
bcfileList = fileList(2);
fileList = fileList(1);
        
% Pool together all of the data
%  HC, CT, and BC all get their own pds array
[trialTable, pdsHC, pdsCT, pdsBC] = poolNeuronPDs(fileList);
load(bcfileList{1});
pdsBC = computeNeuronPDs(out_struct,false);
clear out_struct;

% Get indices for HC, CT, BC
indsHC = trialTable(:,11)==0;
indsCT = trialTable(:,11)==1;
indsBC = trialTable(:,11)==2;

% % Check to ensure the units are present across all conditions
% %  If not, exclude them
% badUnits = checkUnits(pdsHC,pdsCT,pdsBC);
% pdsHC(pdsHC(:,1)==badUnits,:) = [];
% pdsCT(pdsCT(:,1)==badUnits,:) = [];
% pdsBC(pdsBC(:,1)==badUnits,:) = [];

% Turn the x,y PD into an angular PD
pdsHC = convertPDsToAngles(pdsHC,'deg');
pdsCT = convertPDsToAngles(pdsCT,'deg');
pdsBC = convertPDsToAngles(pdsBC,'deg');

% For each unit, compute a change in PD between HC and CT and HC and BC
pdChanges = computeNeuronPDChanges(pdsHC,pdsCT,pdsBC);

meanPDChanges = mean(abs(pdChanges(:,2:end)));
meanPDs = [mean(pdsHC(:,2)), mean(pdsCT(:,2)), mean(pdsBC(:,2))];

% Make summary box plot
figure;
plotPDBox(pdsHC, pdsCT, pdsBC);
