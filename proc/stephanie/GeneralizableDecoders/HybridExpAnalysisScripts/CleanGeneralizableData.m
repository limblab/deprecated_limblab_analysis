
function finalBinned = CleanGeneralizableData(binnedData)
% This script is for going through my data and picking the 

%binnedDataCut = cutBinnedDataFile(binnedData, 18001,length(binnedData.timeframe));
% WmBinned = cutBinnedDataFile(binnedData, 18001,length(binnedData.timeframe));
% IsoBinned = cutBinnedDataFile(binnedData, 18001,length(binnedData.timeframe));
% SprBinned = cutBinnedDataFile(binnedData, 18001,length(binnedData.timeframe));

% Find the EMGs you are interested in plotting
%kevin
FCUind = strmatch('FCU',binnedData.emgguide(1,:)); FCUind = FCUind(1);
FCRind = strmatch('FCR',binnedData.emgguide(1,:)); FCRind = FCRind(1);
ECUind = strmatch('ECU',binnedData.emgguide(1,:)); ECUind = ECUind(1);
ECRind = strmatch('ECR',binnedData.emgguide(1,:)); ECRind = ECRind(1);
EDCUind = strmatch('EDCu',binnedData.emgguide(1,:)); EDCUind = EDCUind(1);
EDCRind = strmatch('EDCr',binnedData.emgguide(1,:)); EDCRind = EDCRind(1);
emg_vector = [FCUind FCRind ECUind ECRind EDCUind EDCRind];

%jango
binnedData.emgguide = cellstr(binnedData.emgguide)';
ind1 = strmatch('FCU',binnedData.emgguide(1,:)); ind1 = ind1(1);
ind2 = strmatch('FCR',binnedData.emgguide(1,:)); ind2 = ind2(1);
ind3 = strmatch('ECU',binnedData.emgguide(1,:)); ind3 = ind3(1);
ind4 = strmatch('ECR',binnedData.emgguide(1,:)); ind4 = ind4(1);
ind5 = strmatch('EDC',binnedData.emgguide(1,:)); ind5 = ind5(1);
ind6 = strmatch('EDC2',binnedData.emgguide(1,:)); ind6 = ind6(1);
emg_vector = [ind1 ind2 ind3 ind4 ind5 ind6];

binnedData.emgdatabin = binnedData.emgdatabin(:,emg_vector);
binnedData.emgguide = binnedData.emgguide(:,emg_vector);

%Fix baseline
% binnedData.emgdatabin(:,4) = binnedData.emgdatabin(:,4)-2.2;
% binnedData.emgdatabin(:,6) = binnedData.emgdatabin(:,6)-1.85;

figure;
plot(binnedData.timeframe,binnedData.emgdatabin)
% legend('FCU','FCR','ECU','ECR','EDCu','EDCr');
legend('FCU','FCR','ECU','ECR');

 finalBinned = binnedData;

end