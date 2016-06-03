function addcursordata(targetFiles)
    %targetFiles is a cell array with binned data, cursor data, and
    %recording order information in the format:
    %{'nameofbinneddatafile1.mat' 'nameofcursordatafile1.mat' recording order within cursordata
    % 'nameofbinneddatafile2.mat' 'nameofcursordatafile2.mat' recording order within cursordata
    %  etc.}
    for i = 1:size(targetFiles,1)   %loop to go through each binned data structure
        load(targetFiles{i,1});     % load binnedData into workspace
        allcursor = importdata(targetFiles{i,2});   %load cursordata into workspace
        cursor = allcursor{targetFiles{i,3}};   %separates recording corresponding to binned data
        binnedData.cursorposbin = cursor(1:length(binnedData.timeframe),1:2);   %stores cursor position information
        binnedData.velocbin = cursor(1:length(binnedData.timeframe),3:4);   %stores cursor velocity information
        binnedData.velocbin(:,3) = sqrt(binnedData.velocbin(:,1).^2+binnedData.velocbin(:,2).^2);   %creates cursor speed information
        save(targetFiles{i,1},'binnedData') %saves binnedData
    end
end