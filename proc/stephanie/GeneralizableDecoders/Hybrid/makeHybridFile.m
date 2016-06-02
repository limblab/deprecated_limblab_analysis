% Code to make the hybrid file
function [HybridFinal AlteredIsoFinal AlteredWMFinal] = makeHybridFile(File1, File2)  %(iso , wm)

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

%Normalize the variance for each file (iso and wm) separately
SD = std(File1.emgdatabin);
for a=1:length(File1.emgdatabin(1,:))
    IsoNormEmgdatabin(:,a) = File1.emgdatabin(:,a)/SD(a);
end

SD = std(File2.emgdatabin);
for a=1:length(File2.emgdatabin(1,:))
    WmNormEmgdatabin(:,a) = File2.emgdatabin(:,a)/SD(a);
end


hybridData = [];
newIndexA = 1; newIndexH =1; startIndex = 1; altStartIndex = 1;
for i =1:floor(length(File1.timeframe)/1200) %1200 is the number of .05 bins in 30 seconds
% First put 30 seconds of the File1 data into hybridData
% Then put 30 seconds of File2 data in

% Timeframe
hybridData.timeframe(newIndexH : newIndexH+600-1,: ) =  File1.timeframe(startIndex:startIndex+600-1, : )  ;       
hybridData.timeframe(newIndexH +600: newIndexH+1200-1 ,:) = File2.timeframe(startIndex+600:startIndex+1200-1,:);

alteredDataWM.timeframe(newIndexA : newIndexA+600-1,:) =  File2.timeframe(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.timeframe(newIndexA : newIndexA+600-1,:) = File1.timeframe(altStartIndex+600:altStartIndex+1200-1,:);

% Emg data
hybridData.emgdatabin(newIndexH : newIndexH+600-1,:) =  IsoNormEmgdatabin(startIndex:startIndex+600-1, : )  ;         
hybridData.emgdatabin(newIndexH +600: newIndexH+1200-1 ,:) = WmNormEmgdatabin(startIndex+600:startIndex+1200-1,:);

alteredDataWM.emgdatabin(newIndexA : newIndexA+600-1,:) =  File2.emgdatabin(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.emgdatabin(newIndexA : newIndexA+600-1,:) = File1.emgdatabin(altStartIndex+600:altStartIndex+1200-1,:);

% Force data
hybridData.forcedatabin(newIndexH : newIndexH+600-1,:) =  File1.forcedatabin(startIndex:startIndex+600-1, : )  ;         
hybridData.forcedatabin(newIndexH +600: newIndexH+1200-1 ,:) = File2.forcedatabin(startIndex+600:startIndex+1200-1,:);

alteredDataWM.forcedatabin(newIndexA : newIndexA+600-1,:) =  File2.forcedatabin(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.forcedatabin(newIndexA : newIndexA+600-1,:) = File1.forcedatabin(altStartIndex+600:altStartIndex+1200-1,:);

% Cursor position data
hybridData.cursorposbin(newIndexH : newIndexH+600-1,:) =  File1.cursorposbin(startIndex:startIndex+600-1, : )  ;         
hybridData.cursorposbin(newIndexH +600: newIndexH+1200-1 ,:) = File2.cursorposbin(startIndex+600:startIndex+1200-1,:);

alteredDataWM.cursorposbin(newIndexA : newIndexA+600-1,: ) =  File2.cursorposbin(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.cursorposbin(newIndexA : newIndexA+600-1,:) = File1.cursorposbin(altStartIndex+600:altStartIndex+1200-1,:);

% Veloc data
hybridData.velocbin(newIndexH : newIndexH+600-1,:) =  File1.velocbin(startIndex:startIndex+600-1, : )  ;         
hybridData.velocbin(newIndexH +600: newIndexH+1200-1 ,:) = File2.velocbin(startIndex+600:startIndex+1200-1,:);

alteredDataWM.velocbin(newIndexA : newIndexA+600-1,: ) =  File2.velocbin(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.velocbin(newIndexA : newIndexA+600-1,:) = File1.velocbin(altStartIndex+600:altStartIndex+1200-1,:);


% Accel data
hybridData.accelbin(newIndexH : newIndexH+600-1,:) =  File1.accelbin(startIndex:startIndex+600-1, : )  ;         
hybridData.accelbin(newIndexH +600: newIndexH+1200-1 ,:) = File2.accelbin(startIndex+600:startIndex+1200-1,:);

alteredDataWM.accelbin(newIndexA : newIndexA+600-1,:) =  File2.accelbin(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.accelbin(newIndexA : newIndexA+600-1,:) = File1.accelbin(altStartIndex+600:altStartIndex+1200-1,:);


% Spike data
hybridData.spikeratedata(newIndexH : newIndexH+600-1,:) =  File1.spikeratedata(startIndex:startIndex+600-1, : )  ;         
hybridData.spikeratedata(newIndexH +600: newIndexH+1200-1 ,: ) = File2.spikeratedata(startIndex+600:startIndex+1200-1,:);

alteredDataWM.spikeratedata(newIndexA : newIndexA+600-1,:) =  File2.spikeratedata(altStartIndex:altStartIndex+600-1, : )  ;       
alteredDataIso.spikeratedata(newIndexA : newIndexA+600-1,:) = File1.spikeratedata(altStartIndex+600:altStartIndex+1200-1,:);


% increment startIndex by 1200 indices = 1 minutes (since you just added 1 minute of data)
startIndex = startIndex + 1200;
altStartIndex = altStartIndex + 1200;
newIndexH = newIndexH+1200;
newIndexA = newIndexA+600;

end


hybridData.meta.filename = 'Z:\Jango_12a1\ContextDependence\03-10-14\Jango_Hybrid.nev';
HybridFinal = File1;
HybridFinal.meta = hybridData.meta;
HybridFinal.timeframe = hybridData.timeframe;
HybridFinal.emgdatabin = hybridData.emgdatabin;
HybridFinal.forcedatabin = hybridData.forcedatabin;
HybridFinal.cursorposbin = hybridData.cursorposbin;
HybridFinal.accelbin = hybridData.accelbin;
HybridFinal.velocbin = hybridData.velocbin;
HybridFinal.spikeratedata=hybridData.spikeratedata;


alteredDataIso.meta.filename =  'Z:\Jango_12a1\ContextDependence\03-10-14\Jango_Hybrid.nev';
AlteredIsoFinal = File1;
AlteredIsoFinal.meta = alteredDataIso.meta;
AlteredIsoFinal.timeframe = alteredDataIso.timeframe;
AlteredIsoFinal.emgdatabin = alteredDataIso.emgdatabin;
AlteredIsoFinal.forcedatabin = alteredDataIso.forcedatabin;
AlteredIsoFinal.cursorposbin = alteredDataIso.cursorposbin;
AlteredIsoFinal.accelbin = alteredDataIso.accelbin;
AlteredIsoFinal.velocbin = alteredDataIso.velocbin;
AlteredIsoFinal.spikeratedata=alteredDataIso.spikeratedata;


alteredDataWM.meta.filename =  'Z:\Jango_12a1\ContextDependence\03-10-14\Jango_Hybrid.nev';
AlteredWMFinal = File1;
AlteredWMFinal.meta = alteredDataWM.meta;
AlteredWMFinal.timeframe = alteredDataWM.timeframe;
AlteredWMFinal.emgdatabin = alteredDataWM.emgdatabin;
AlteredWMFinal.forcedatabin = alteredDataWM.forcedatabin;
AlteredWMFinal.cursorposbin = alteredDataWM.cursorposbin;
AlteredWMFinal.accelbin = alteredDataWM.accelbin;
AlteredWMFinal.velocbin = alteredDataWM.velocbin;
AlteredWMFinal.spikeratedata=alteredDataWM.spikeratedata;

varargout = [HybridFinal AlteredIsoFinal AlteredWMFinal];
