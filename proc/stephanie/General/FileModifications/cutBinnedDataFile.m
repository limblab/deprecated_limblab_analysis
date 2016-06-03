function binnedDataCut = cutBinnedDataFile(binnedData, startCut, stopCut)
%Remove portion from binned data file
% The user selects portions of the data file that should be cut out, and
% the following variables are modified accordingly:
%   timeframe
%   emgdatabin
%   forcedatabin
%   spikeratedata
%   cursorposbin
%   velocbin
%   accelbin
%   trialtable
%   words

% The user inputs where to start and stop the cut
% promptStart = 'Index to start cut at: ';
% startCut = input(promptStart);
% promptStop = 'Index to stop cut at: ';
% stopCut = input(promptStop);

% Get the timestamp value for the start and stop indices
startCutTime = binnedData.timeframe(startCut);
stopCutTime = binnedData.timeframe(stopCut);
cutVectorTime = [startCutTime stopCutTime];

% Make a vecotr of selected indices to cut
cutVector = (startCut:stopCut)'; %Increments by 1 because we are talking about indices

%Loop to ask if there are other sections to cut
% promptDone = 'Keep adding cut indices? [1 for yes, 0 for no]: ';
% KeepAdding = input(promptDone);
% while KeepAdding
%     startCut2 = input(promptStart);
%     stopCut2 = input(promptStop);
%     cutVector2 = (startCut2:stopCut2)';
%     cutVector = cat(1,cutVector,cutVector2);
%     
%     % Get the timestamp values
%     startCutTime2 = binnedData.timeframe(startCut2);
%     stopCutTime2 = binnedData.timeframe(stopCut2);
%     cutVectorTime2 = [startCutTime2 stopCutTime2];
%     % Concatenate CutTimes so that you have col1: start and col2: stop
%     cutVectorTime = cat(1,cutVectorTime,cutVectorTime2);
%     
%     KeepAdding = input(promptDone);
% end
    

% Make a new binnedData variable set called binnedDataCut (this
% incorporates the cuts obviously)
binnedDataCut = binnedData;

% Remove the selected indices from the data
binnedDataCut.timeframe(cutVector) = [];
binnedDataCut.emgdatabin(cutVector,:)=[];
%binnedDataCut.forcedatabin(cutVector,:)=[];
binnedDataCut.spikeratedata(cutVector,:)=[];
binnedDataCut.cursorposbin(cutVector,:)=[];
binnedDataCut.velocbin(cutVector,:)=[];
binnedDataCut.accelbin(cutVector,:)=[];


% Cut the right indices from the 'words' variables
cutVectorForWords = []; cutVectorForWordsFull = [];
for i = 1:length(cutVectorTime(:,1))
    cutVectorForWords = find(binnedDataCut.words(:,1)>=cutVectorTime(i,1) & binnedDataCut.words(:,1)<=cutVectorTime(i,2));
    cutVectorForWordsFull = cat(1,cutVectorForWordsFull,cutVectorForWords);
end
% Remove the proper indices from the words variable
binnedDataCut.words(cutVectorForWordsFull,:) = [];


 

% 

