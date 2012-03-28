function BatchAddBRLogData(targetFiles)
    %targetFiles is a cell array with binned data, cursor data, and
    %recording order information in the format:
    %{'nameofbinneddatafile1.mat' 'nameofcursordatafile1.mat' recording order within cursordata
    % 'nameofbinneddatafile2.mat' 'nameofcursordatafile2.mat' recording order within cursordata
    %  etc.}
    %       (each row is one set of files - targetFiles is a <num_files>x3
    %       cell array

% For each binned data file...
for i = 1:size(targetFiles,1)
    
    %-initialize variables
    disp(sprintf('Beginning file "%s"...',targetFiles{i,1}));
    load(targetFiles{i,1});     % load binnedData into workspace
    load(targetFiles{i,2});     % load logData into workspace
    binnedData = var.var.binnedData; %because of something stupid in the batch binning function
    fileOrder = targetFiles{i,3};
    
    %-populate struct, save as new .mat file
    binnedData = AddBRLogData(binnedData, logData, fileOrder);
    new_name = strrep(targetFiles{i,1},'.mat','_allData.mat');
    save(new_name,'binnedData')
    disp(sprintf('File "%s" complete.',new_name));
    
end
