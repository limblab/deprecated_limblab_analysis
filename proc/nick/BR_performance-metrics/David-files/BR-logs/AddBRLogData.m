function allData = AddBRLogData(binnedData, logData, fileOrder)
% Concatenates processed variables containing binned spike data and BR log
% data loaded from .mat files by adding the cursor position data from
% 'logData' into the 'binnedData' struct

%allcursor = importdata(targetFiles{i,2});   %load cursordata into workspace
%cursor = allcursor{targetFiles{i,3}};   %separates recording corresponding to binned data

%VERIFY THAT logData IS POPULATED
if isempty(logData)
    disp('No BR log data available.');
    allData = binnedData;
    return;
end
cursor = logData{fileOrder};
disp('Concatenating BR data into binned spike struct');

%GET TIME ENDPOINT... AVOIDS 'INDEX OUT OF BOUNDS' ERRORS
log_length    = size(cursor,1);
binned_length = size(binnedData.timeframe,1);
if (log_length < binned_length)
    end_time = log_length;
else
    end_time = binned_length;
end

%FILL binnedData FIELDS
binnedData.cursorposbin  = cursor(1:end_time,1:2);   %store cursor position
binnedData.velocbin      = cursor(1:end_time,3:4);   %store cursor velocity
binnedData.velocbin(:,3) = sqrt( binnedData.velocbin(:,1).^2 + binnedData.velocbin(:,2).^2 );   %calculate cursor speed
allData = binnedData;








