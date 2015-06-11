function [cellClasses,cellPDs,cellMDs,cellBOs] = getClassesAndPDs(root_dir,doFiles,paramSetName,useArray,classifierBlocks,tuningMethod,tuningWindow,doMD)
% load in classes for each cell
%   tied to investigateMemoryCells

cellClasses = cell(size(doFiles,1),1);
cellPDs = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    % load tuning and classification data
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuningMethod,tuningWindow);

    cellClasses{iFile} = c.classes(all(c.istuned,2),1);
    
    tunedCells = c.tuned_cells;

    disp([length(t(1).theta),length(t(2).theta),length(t(3).theta)])
    
    sg_bl = t(classifierBlocks(1)).sg;
    sg_ad = t(classifierBlocks(2)).sg;
    sg_wo = t(classifierBlocks(3)).sg;
    
    [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
    [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
    [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
    
    if ~doMD
        pds_bl = t(classifierBlocks(1)).pds(idx_bl,:);
        pds_ad = t(classifierBlocks(2)).pds(idx_ad,:);
        pds_wo = t(classifierBlocks(3)).pds(idx_wo,:);
        mds_bl = t(classifierBlocks(1)).mds(idx_bl,:);
        mds_ad = t(classifierBlocks(2)).mds(idx_ad,:);
        mds_wo = t(classifierBlocks(3)).mds(idx_wo,:);
        bos_bl = mean(t(classifierBlocks(1)).fr(:,idx_bl),1);
        bos_ad = mean(t(classifierBlocks(2)).fr(:,idx_ad),1);
        bos_wo = mean(t(classifierBlocks(3)).fr(:,idx_wo),1);
    else
        pds_bl = t(classifierBlocks(1)).mds(idx_bl,:);
        pds_ad = t(classifierBlocks(2)).mds(idx_ad,:);
        pds_wo = t(classifierBlocks(3)).mds(idx_wo,:);
    end
    
    cellPDs{iFile} = {pds_bl, pds_ad, pds_wo};
    cellMDs{iFile} = {mds_bl, mds_ad, mds_wo};
    cellBOs{iFile} = {bos_bl, bos_ad, bos_wo};
end