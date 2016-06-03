% plot PD with movement tuning against PD with target
%   Note could do any such comparison

clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...    % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S

useArray = 'M1';
numSamples = 100;

reassignOthers = true;
paramSetNames = {'target_noisy'};
paramSetName = 'target_noisy';
tuneWindow = 'full';
tuneMethod = 'regression';

doFiles = allFiles(strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);

%%
% Get the cells that are well-tuned from my normal analysis
masterTunedSG = cell(size(doFiles,1),1);
masterTuned = cell(size(doFiles,1),1);
for iFile = 1:size(doFiles,1)
    c = loadResults(root_dir,doFiles(iFile,:),'tuning','classes',useArray,paramSetName,tuneMethod,tuneWindow);
    masterTunedSG{iFile} = c.tuned_cells;
    masterTuned{iFile} = all(c.istuned,2);
end

%%
%

for i = 1:numSamples
    classifierBlocks = [i,numSamples+i,2*numSamples+i];
    
    processFFData2;
    
    for iFile = 1:size(doFiles,1)
        [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
        
        allC(iFile).c{i} = c.classes(masterTuned{iFile},1);
        %allC(iFile).c{i} =  c.classes(all(c.istuned,2));
        
        tunedCells = masterTunedSG{iFile};
        %tunedCells = c.tuned_cells;
        
        sg_bl = t(classifierBlocks(1)).sg;
        sg_ad = t(classifierBlocks(2)).sg;
        sg_wo = t(classifierBlocks(3)).sg;
        
        [~,idx_bl] = intersect(sg_bl, tunedCells,'rows');
        [~,idx_ad] = intersect(sg_ad, tunedCells,'rows');
        [~,idx_wo] = intersect(sg_wo, tunedCells,'rows');
        
        pds_bl = t(classifierBlocks(1)).pds(idx_bl,1);
        pds_ad = t(classifierBlocks(2)).pds(idx_ad,1);
        pds_wo = t(classifierBlocks(3)).pds(idx_wo,1);
        
        
        allC(iFile).pds{i} = {pds_bl, pds_ad, pds_wo};
    end
end

save('classesAcrossBlocks.mat');

%%
clear;
load('classesAcrossBlocks.mat')

%%
for i = 1:numSamples
    for iFile = 1:size(doFiles,1)
        
        c=allC(iFile).c{i};
        pds = allC(iFile).pds{i};
        
        % now reassign the others class
        pds_bl = pds{1};
        pds_ad = pds{2};
        pds_wo = pds{3};
        
        % find "other" type cells
        idx = find(c==5);
        
        if reassignOthers
            for m = 1:length(idx)
                % calculate the memory cell index
                bl_wo = angleDiff( pds_wo(idx(m),1),pds_bl(idx(m),1),true,true );
                bl_ad = angleDiff( pds_ad(idx(m),1), pds_bl(idx(m),1),true,true );
                ad_wo = angleDiff(pds_wo(idx(m),1),pds_ad(idx(m),1),true,true);
                
                mem_ind = abs(bl_wo) / min( abs(bl_ad) , abs(ad_wo) );
                
                % we also want both BL->WO and BL->AD to be same direction for memory
                %   otherwise it's just dynamic
                if mem_ind > 1
                    if sign(bl_wo)==sign(bl_ad)
                        c(idx(m)) = 3;
                    else
                        c(idx(m)) = 2;
                    end
                elseif mem_ind < 1
                    c(idx(m)) = 2;
                else
                    disp('Hey! This one is exactly one.');
                    c(idx(m)) = 3;
                end
            end
        end
        
        gc(iFile,1) = sum(c==1);
        gc(iFile,2) = sum(c==2);
        gc(iFile,3) = sum(c==3);
        gc(iFile,4) = sum(c==4);
    end
    getClasses{i} = gc;
end

%%
% assume the order of cells is unchanged and get the percent chance for
% each cell of being a memory cell


%%
close all
data = [];
for i = 1:numSamples
    c = getClasses{i};
    count = sum(c,1);
    tot = sum(count,2);
    p = count./repmat(tot,1,size(count,2));
    
    data = [data; count];
end

pie(sum(data,1),{'K','D','M1','M2'})

%%
close all
data = [];
for i = 1:numSamples
    c = getClasses{i};
    count = sum(c,1);
    tot = sum(count,2);
    p = count./repmat(tot,1,size(count,2));
    
    data = [data; p];
end

pie(mean(data,1),{'K','D','M1','M2'})