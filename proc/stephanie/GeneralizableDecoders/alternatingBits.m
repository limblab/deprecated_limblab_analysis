% Alternating bits of a binned data file

hybridData = [];
startIndex = 1;
for i =1:floor(length(File1.timeframe)/1200) %1200 is the number of .05 bins in 30 seconds
% First put 30 seconds of the File1 data into hybridData
% Then put 30 seconds of File2 data in

% Timeframe
hybridData.timeframe(startIndex : startIndex+600-1,: ) =  File1.timeframe(startIndex:startIndex+600-1, : )  ;       
hybridData.timeframe(startIndex +600: startIndex+1200-1 ,: ) = File2.timeframe(startIndex+600:startIndex+1200-1,:);

% Emg data
hybridData.emgdatabin(startIndex : startIndex+600-1,: ) =  File1.emgdatabin(startIndex:startIndex+600-1, : )  ;         
hybridData.emgdatabin(startIndex +600: startIndex+1200-1 ,: ) = File2.emgdatabin(startIndex+600:startIndex+1200-1,:);

% Force data
hybridData.forcedatabin(startIndex : startIndex+600-1,: ) =  File1.forcedatabin(startIndex:startIndex+600-1, : )  ;         
hybridData.forcedatabin(startIndex +600: startIndex+1200-1 ,: ) = File2.forcedatabin(startIndex+600:startIndex+1200-1,:);

% Cursor position data
hybridData.cursorposbin(startIndex : startIndex+600-1,: ) =  File1.cursorposbin(startIndex:startIndex+600-1, : )  ;         
hybridData.cursorposbin(startIndex +600: startIndex+1200-1 ,: ) = File2.cursorposbin(startIndex+600:startIndex+1200-1,:);

% Veloc data
hybridData.velocbin(startIndex : startIndex+600-1,: ) =  File1.velocbin(startIndex:startIndex+600-1, : )  ;         
hybridData.velocbin(startIndex +600: startIndex+1200-1 ,: ) = File2.velocbin(startIndex+600:startIndex+1200-1,:);

% Accel data
hybridData.accelbin(startIndex : startIndex+600-1,: ) =  File1.accelbin(startIndex:startIndex+600-1, : )  ;         
hybridData.accelbin(startIndex +600: startIndex+1200-1 ,: ) = File2.accelbin(startIndex+600:startIndex+1200-1,:);

% Spike data
hybridData.spikeratedata(startIndex : startIndex+600-1,: ) =  File1.spikeratedata(startIndex:startIndex+600-1, : )  ;         
hybridData.spikeratedata(startIndex +600: startIndex+1200-1 ,: ) = File2.spikeratedata(startIndex+600:startIndex+1200-1,:);

% increment startIndex by 1200 indices = 1 minutes (since you just added 1 minute of data)
startIndex = startIndex + 1200;

end
