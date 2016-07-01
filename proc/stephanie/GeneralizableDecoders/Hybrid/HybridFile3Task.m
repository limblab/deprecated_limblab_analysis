% Code to make the hybrid file
function [HybridFinal] = HybridFile3Task(File1, File2, File3)  %(iso , wm, spr)


% The purpose of this script is to take in two binned data files (i.e. iso and wrist movement data) and create
% 1. A hybrid binnedData file made from alternating segments of the two files
% 2. Two new subfile that contains the alternating segments that were not used for the hybrid file. ? do I actually need this? What will it be used for?
% Also – how do I deal with the incontinuity of the EMG data?

% Take in a file of arbitrary length, parse into alternating segments each a minute long


% If file is 20 minutes long (1200 seconds)
%divide this by 2 to get how many loops you will go through
%each time you do a loop, get one minute of data from both the iso and the wrist movement file and start concatenating them

%(there are 24000 indices in 20 minutes)
% 2400 indices in 2 minutes

%Cut files into ten minute chunks
 IsoTest = cutBinnedDataFile(File1, 1, 12000);
 WmTest = cutBinnedDataFile(File2, 1, 12000);
 SprTest = cutBinnedDataFile(File3, 1, 12000);
 File1 = cutBinnedDataFile(File1, 12001, length(File1.timeframe));
 File2 = cutBinnedDataFile(File2, 12001, length(File2.timeframe));
 File3 = cutBinnedDataFile(File3, 12001, length(File3.timeframe));
IsoTrain = File1;
WmTrain = File2;
SprTrain = File3;

hybridData = [];
newIndexA = 1; newIndexH =1; startIndex = 1; altStartIndex = 1;
altTimeIndex = 1;

for i =1:floor(length(File1.timeframe)/1200) %1200 is the number of .05 bins in 30 seconds
% First put 30 seconds of the File1 data into hybridData
% Then put 30 seconds of File2 data in

% Timeframe
hybridData.timeframe(newIndexH : newIndexH+400-1,: ) =  File1.timeframe(startIndex:startIndex+400-1, : )  ;       
hybridData.timeframe(newIndexH +400: newIndexH+800-1 ,:) = File2.timeframe(startIndex+400:startIndex+800-1,:);
hybridData.timeframe(newIndexH +800: newIndexH+1200-1 ,:) = File3.timeframe(startIndex+800:startIndex+1200-1,:);

   
alteredDataIso.timeframe(newIndexA : newIndexA+400-1,:) = File1.timeframe(altTimeIndex:altTimeIndex+400-1,:);
alteredDataWM.timeframe(newIndexA : newIndexA+400-1,:) =  File2.timeframe(altTimeIndex:altTimeIndex+400-1, : )  ;  
%% alteredDataSpr.timeframe(newIndexA : newIndexA+600-1,:) =  File3.timeframe(altTimeIndex:altTimeIndex+600-1, : )  ;    figure out which parts of the spring data arent being used

% Emg data
hybridData.emgdatabin(newIndexH : newIndexH+400-1,:) =  File1.emgdatabin(startIndex:startIndex+400-1, : )  ;         
hybridData.emgdatabin(newIndexH +400: newIndexH+800-1 ,:) = File2.emgdatabin(startIndex+400:startIndex+800-1,:);
hybridData.emgdatabin(newIndexH +800: newIndexH+1200-1 ,:) = File3.emgdatabin(startIndex+800:startIndex+1200-1,:);

alteredDataIso.emgdatabin(newIndexA : newIndexA+400-1,:) = File1.emgdatabin(altStartIndex+400:altStartIndex+800-1,:);
alteredDataWM.emgdatabin(newIndexA : newIndexA+400-1,:) =  File2.emgdatabin(altStartIndex:altStartIndex+400-1, : )  ;    
%% alteredDataSpr.emgdatabin(newIndexA : newIndexA+600-1,:) =  File3.emgdatabin(altStartIndex:altStartIndex+600-1, : )  ;    

% Force data
hybridData.forcedatabin(newIndexH : newIndexH+400-1,:) =  File1.forcedatabin(startIndex:startIndex+400-1, : )  ;         
hybridData.forcedatabin(newIndexH +400: newIndexH+800-1 ,:) = File2.forcedatabin(startIndex+400:startIndex+800-1,:);
hybridData.forcedatabin(newIndexH +800: newIndexH+1200-1 ,:) = File3.forcedatabin(startIndex+800:startIndex+1200-1,:);

alteredDataWM.forcedatabin(newIndexA : newIndexA+400-1,:) =  File2.forcedatabin(altStartIndex:altStartIndex+400-1, : )  ;       
alteredDataIso.forcedatabin(newIndexA : newIndexA+400-1,:) = File1.forcedatabin(altStartIndex+400:altStartIndex+800-1,:);

% Cursor position data
hybridData.cursorposbin(newIndexH : newIndexH+400-1,:) =  File1.cursorposbin(startIndex:startIndex+400-1, : )  ;         
hybridData.cursorposbin(newIndexH +400: newIndexH+800-1 ,:) = File2.cursorposbin(startIndex+400:startIndex+800-1,:);
hybridData.cursorposbin(newIndexH +800: newIndexH+1200-1 ,:) = File3.cursorposbin(startIndex+800:startIndex+1200-1,:);

alteredDataWM.cursorposbin(newIndexA : newIndexA+400-1,: ) =  File2.cursorposbin(altStartIndex:altStartIndex+400-1, : )  ;       
alteredDataIso.cursorposbin(newIndexA : newIndexA+400-1,:) = File1.cursorposbin(altStartIndex+400:altStartIndex+800-1,:);

% Veloc data
hybridData.velocbin(newIndexH : newIndexH+400-1,:) =  File1.velocbin(startIndex:startIndex+400-1, : )  ;         
hybridData.velocbin(newIndexH +400: newIndexH+800-1 ,:) = File2.velocbin(startIndex+400:startIndex+800-1,:);
hybridData.velocbin(newIndexH +800: newIndexH+1200-1 ,:) = File3.velocbin(startIndex+800:startIndex+1200-1,:);

alteredDataWM.velocbin(newIndexA : newIndexA+400-1,: ) =  File2.velocbin(altStartIndex:altStartIndex+400-1, : )  ;       
alteredDataIso.velocbin(newIndexA : newIndexA+400-1,:) = File1.velocbin(altStartIndex+400:altStartIndex+800-1,:);


% Accel data
hybridData.accelbin(newIndexH : newIndexH+400-1,:) =  File1.accelbin(startIndex:startIndex+400-1, : )  ;         
hybridData.accelbin(newIndexH +400: newIndexH+800-1 ,:) = File2.accelbin(startIndex+400:startIndex+800-1,:);
hybridData.accelbin(newIndexH +800: newIndexH+1200-1 ,:) = File3.accelbin(startIndex+800:startIndex+1200-1,:);

alteredDataWM.accelbin(newIndexA : newIndexA+400-1,:) =  File2.accelbin(altStartIndex:altStartIndex+400-1, : )  ;       
alteredDataIso.accelbin(newIndexA : newIndexA+400-1,:) = File1.accelbin(altStartIndex+400:altStartIndex+800-1,:);


% Spike data
hybridData.spikeratedata(newIndexH : newIndexH+400-1,:) =  File1.spikeratedata(startIndex:startIndex+400-1, : )  ;         
hybridData.spikeratedata(newIndexH +400: newIndexH+800-1 ,: ) = File2.spikeratedata(startIndex+400:startIndex+800-1,:);
hybridData.spikeratedata(newIndexH +800: newIndexH+1200-1 ,: ) = File3.spikeratedata(startIndex+800:startIndex+1200-1,:);

alteredDataWM.spikeratedata(newIndexA : newIndexA+400-1,:) =  File2.spikeratedata(altStartIndex:altStartIndex+400-1, : )  ;       
alteredDataIso.spikeratedata(newIndexA : newIndexA+400-1,:) = File1.spikeratedata(altStartIndex+400:altStartIndex+800-1,:);

%TaskFlag
hybridData.taskflag(newIndexH : newIndexH+400-1,:) = 1;
hybridData.taskflag(newIndexH +400: newIndexH+800-1 ,: ) = 0;
hybridData.taskflag(newIndexH +800: newIndexH+1200-1 ,: ) = -1;


% increment startIndex by 800 indices = 1.5 minutes (since you just added 1.5 minute of data)
startIndex = startIndex + 1200;
altStartIndex = altStartIndex + 1200;
newIndexH = newIndexH+1200;
% Only increment the Alt indices by 600 seconds (for 30 seconds)
newIndexA = newIndexA+400;
altTimeIndex = altTimeIndex+400;
end


for i=1:length(File1.emgdatabin(1,:))
   % hybridData.scale(i,1) = std(File1.emgdatabin(:,i))/(std(File2.emgdatabin(:,i)));
     hybridData.scale(i,1) = 1;
end

hybridData.meta.filename = 'Hybrid';
HybridFinal = File1;
HybridFinal.meta = hybridData.meta;
HybridFinal.timeframe = hybridData.timeframe;
HybridFinal.emgdatabin = hybridData.emgdatabin;
HybridFinal.forcedatabin = hybridData.forcedatabin;
HybridFinal.cursorposbin = hybridData.cursorposbin;
HybridFinal.accelbin = hybridData.accelbin;
HybridFinal.velocbin = hybridData.velocbin;
HybridFinal.spikeratedata=hybridData.spikeratedata;
HybridFinal.taskflag = hybridData.taskflag;
HybridFinal.scale = hybridData.scale;


alteredDataIso.meta.filename =  'AlteredIso';
AlteredIsoFinal = File1;
AlteredIsoFinal.meta = alteredDataIso.meta;
AlteredIsoFinal.timeframe = alteredDataIso.timeframe;
AlteredIsoFinal.emgdatabin = alteredDataIso.emgdatabin;
AlteredIsoFinal.forcedatabin = alteredDataIso.forcedatabin;
AlteredIsoFinal.cursorposbin = alteredDataIso.cursorposbin;
AlteredIsoFinal.accelbin = alteredDataIso.accelbin;
AlteredIsoFinal.velocbin = alteredDataIso.velocbin;
AlteredIsoFinal.spikeratedata=alteredDataIso.spikeratedata;


alteredDataWM.meta.filename =  'AlteredWM';
AlteredWMFinal = File1;
AlteredWMFinal.meta = alteredDataWM.meta;
AlteredWMFinal.timeframe = alteredDataWM.timeframe;
AlteredWMFinal.emgdatabin = alteredDataWM.emgdatabin;
AlteredWMFinal.forcedatabin = alteredDataWM.forcedatabin;
AlteredWMFinal.cursorposbin = alteredDataWM.cursorposbin;
AlteredWMFinal.accelbin = alteredDataWM.accelbin;
AlteredWMFinal.velocbin = alteredDataWM.velocbin;
AlteredWMFinal.spikeratedata=alteredDataWM.spikeratedata;

%varargout = [HybridFinal AlteredIsoFinal AlteredWMFinal];

end
