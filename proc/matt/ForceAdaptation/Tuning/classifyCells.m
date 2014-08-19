function [cellClass,master_sg] = classifyCells(t,tuningMethod,compMethod,classifierBlocks)
% cellClass is matrix, rows are units, first column is PD, second column is
% Modulation depth
% 
% first gets a matrix where ones show significant tuning between epochs
%    BL  AD  WO
% BL 0   -   -
% AD 0   0   -
% WO 0   0   0
%
%       1                   2                 3                  4                  5
% Kinematic (AAA)  |  Dynamic (ABA)  |  Memory I (ABB)  |  Memory II (AAB)  |  Other (ABC)
%     0 0 0        |      0 1 0      |      0 1 1       |      0 0 1        |     0 1 1
%     0 0 0        |      0 0 1      |      0 0 0       |      0 0 1        |     0 0 1
%     0 0 0        |      0 0 0      |      0 0 0       |      0 0 0        |     0 0 0
%       0                   8                 5                  9                  11
%
% In nonparametric case, there is one of these for every direction bin per unit
% In other cases, one of these per unit showing PD
%
% Convert these to a unique number by multiplying elementwise by the matrix
% defined below and then summing the output. The number below the matrixes
% shown above is the number that each one will be reduced to.
%
% The classification is based on the number shown above (AAA=1,ABA=2,etc)
%
% useBlocks: input to specify which tuning blocks to use. For now, must be
% three element array. For instance, if there is one baseline period, 3
% adaptation periods, and one washout, and you want to do the
% classification based on the end of adaptation, do useBlocks=[1 4 6]
%
% To compare if there is a significant difference across adaptation in the
% above case, you might do useBlocks = [2 3 4];

% if this is true, divide alpha by 2 since we are making two comparisons
doBonferroni = true;
numComparisons = 3;

meta = t(1).meta;

paramFile = fullfile(meta.out_directory, [meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
numIters = str2double(params.number_iterations{1});
clear params;

if doBonferroni
    alpha = 1-confLevel;
    confLevel = 1 - (alpha/numComparisons);
end

% load the info to classify cells
cell_classifications;

% get all of the spike guides
all_sg = {t.sg};

badUnits = checkUnitGuides(all_sg);

master_sg = setdiff(all_sg{1},badUnits,'rows');

% remove that index from each
idx = cell(size(all_sg));
for iBlock = 1:length(all_sg)
    [~, idx{iBlock}] = setdiff(all_sg{iBlock},badUnits,'rows');
end


% make the cell to pass in the checking function
switch lower(tuningMethod)
    case 'nonparametric'
        % Not supported yet
    case 'glm'
        % doing GLM stuff
        
        % this is for the t-test of empirical distributions
        all_pds = {t.pds};
        
        for iBlock = 1:length(all_pds)
            temp = all_pds{iBlock};
            temp = temp(idx{iBlock},:);
            all_pds{iBlock} = temp;
        end
        
        pd = compareTuningParameter('pd',all_pds,master_sg,{'ttest',confLevel});
        md = [];
        
        
    otherwise
        % doing regression stuff
        all_pds = {t.pds};
        
        for iBlock = 1:length(all_pds)
            temp = all_pds{iBlock};
            temp = temp(idx{iBlock},:);
            all_pds{iBlock} = temp;
        end
        
        all_mds = [];
        % Do modulation depth if it exists
        if ~isempty(t(1).mds)
            all_mds = {t.pds};
            for iBlock = 1:length(all_mds)
                temp = all_mds{iBlock};
                temp = temp(idx{iBlock},:);
                all_mds{iBlock} = temp;
            end
        end
        
        switch lower(compMethod)
            case 'overlap'
                usePDs = all_pds;
                
                if ~isempty(all_mds)
                    useMDs = all_mds;
                end
                
            case 'diff'
                all_boot_pds = {t.boot_pds};
                for iBlock = 1:length(all_mds)
                    temp = all_boot_pds{iBlock};
                    temp = temp(idx{iBlock},:);
                    all_boot_pds{iBlock} = temp;
                end
                usePDs = all_boot_pds;
                
                if ~isempty(all_mds)
                    all_boot_mds = {t.boot_mds};
                    for iBlock = 1:length(all_mds)
                        temp = all_boot_mds{iBlock};
                        temp = temp(idx{iBlock},:);
                        all_boot_mds{iBlock} = temp;
                    end
                    useMDs = all_boot_mds;
                end
        end
        
        pd = compareTuningParameter('pd',usePDs,master_sg,{compMethod,confLevel,numIters});
        
        if ~isempty(all_mds)
            md = compareTuningParameter('md',useMDs,master_sg,{compMethod,confLevel,numIters});
        else
            md = [];
        end
end


% classify each cell based on output
for unit = 1:size(master_sg,1)
    % preferred direction
    diffMat = pd.(['elec' num2str(master_sg(unit,1))]).(['unit' num2str(master_sg(unit,2))]);
        for k = 1:size(diffMat,3) % will be one if not nonparametric
            useDiff = squeeze(diffMat(classifierBlocks,classifierBlocks,k));
            
            val = sum(sum(useDiff.*converterMatrix));
            idx = classMapping(:,1)==val;
            if sum(idx) ~= 0
                cc(unit,k) = classMapping(idx,2);
            else
                warning('DANGER! Class not recognized. Something is probably fishy...');
                cc(unit,k) = NaN;
            end
        end
end
cellClass(:,1) = cc;

if ~isempty(md)
    for unit = 1:size(master_sg,1)
        % modulation depth
        diffMat = md.(['elec' num2str(master_sg(unit,1))]).(['unit' num2str(master_sg(unit,2))]);
        
            for k = 1:size(diffMat,3) % will be one if not nonparametric
                useDiff = squeeze(diffMat(classifierBlocks,classifierBlocks,k));
                
                val = sum(sum(useDiff.*converterMatrix));
                idx = classMapping(:,1)==val;
                if sum(idx) ~= 0
                    cc(unit,k) = classMapping(idx,2);
                else
                    warning('DANGER! Class not recognized. Something is probably fishy...');
                    cc(unit,k) = NaN;
                end
            end
    end
else
    cc = -1*ones(size(master_sg,1),1);
end
cellClass(:,2) = cc;

