function [cellClass,sg_bl] = classifyCells(blt,adt,wot,meta,tuningMethod,compMethod,paramSetName)
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

paramFile = fullfile(meta.out_directory, [meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
ciSig = str2double(params.ci_significance{1});
confLevel = str2double(params.confidence_level{1});
numIters = str2double(params.number_iterations{1});
r2Min = str2double(params.r2_minimum{1});
clear params;


% load the info to classify cells
cell_classifications;

sg_bl = blt.sg;
sg_ad = adt.sg;
sg_wo = wot.sg;

badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);

% remove that index from each
[sg_bl, idx_bl] = setdiff(sg_bl,badUnits,'rows');

[sg_ad, idx_ad] = setdiff(sg_ad,badUnits,'rows');

[sg_wo, idx_wo] = setdiff(sg_wo,badUnits,'rows');

% make the cell to pass in the checking function
switch lower(tuningMethod)
    case 'nonparametric'
        disp('Skipping nonparametric tuning for now...');
        mfr_bl = blt.mfr;
        mfr_ad = adt.mfr;
        mfr_wo = wot.mfr;
        
        cil_bl = blt.cil;
        cil_ad = adt.cil;
        cil_wo = wot.cil;
        
        cih_bl = blt.cih;
        cih_ad = adt.cih;
        cih_wo = wot.cih;
        
        mfr_bl = mfr_bl(idx_bl,:);
        cil_bl = cil_bl(idx_bl,:);
        cih_bl = cih_bl(idx_bl,:);
        
        mfr_ad = mfr_ad(idx_ad,:);
        cil_ad = cil_ad(idx_ad,:);
        cih_ad = cih_ad(idx_ad,:);
        
        mfr_wo = mfr_wo(idx_wo,:);
        cil_wo = cil_wo(idx_wo,:);
        cih_wo = cih_wo(idx_wo,:);
        
        istuned = zeros(size(sg_bl,1),1);
        for unit = 1:size(sg_bl,1)
            istuned(unit) = checkTuningNonparametricSignificance(mfr_bl(unit,:),cil_bl(unit,:),cih_bl(unit,:));
        end
        
        % Call the cell tuned if the confidence bounds of any 2 or more
        % points have confidence bounds that do no overlap
        out = compareNonparametricTuning({mfr_bl,mfr_ad,mfr_wo},{cil_bl,cil_ad,cil_wo},{cih_bl,cih_ad,cih_wo},sg_bl);
        
    otherwise
        pds_bl = blt.pds;
        pds_ad = adt.pds;
        pds_wo = wot.pds;
        
        pds_bl = pds_bl(idx_bl,:);
        pds_ad = pds_ad(idx_ad,:);
        pds_wo = pds_wo(idx_wo,:);
        
        if ~isempty(blt.mds)
            mds_bl = blt.mds;
            mds_ad = adt.mds;
            mds_wo = wot.mds;
            
            mds_bl = mds_bl(idx_bl,:);
            mds_ad = mds_ad(idx_ad,:);
            mds_wo = mds_wo(idx_wo,:);
        end
        
%         if ~isempty(blt.bos)
%             bos_bl = blt.bos;
%             bos_ad = adt.bos;
%             bos_wo = wot.bos;
%             
%             bos_bl = bos_bl(idx_bl,:);
%             bos_ad = bos_ad(idx_ad,:);
%             bos_wo = bos_wo(idx_wo,:);
%         end
        
        
        if isfield(blt,'r_squared') && ~isempty(blt.r_squared)
            rs_bl = blt.r_squared;
            rs_ad = adt.r_squared;
            rs_wo = wot.r_squared;
            
            rs_bl = sort(rs_bl(idx_bl,:),2);
            rs_ad = sort(rs_ad(idx_ad,:),2);
            rs_wo = sort(rs_wo(idx_wo,:),2);
            
            % get 95% CI for each
            rs_bl = [rs_bl(:,ceil(numIters - confLevel*numIters)), rs_bl(:,floor(confLevel*numIters))];
            rs_ad = [rs_ad(:,ceil(numIters - confLevel*numIters)), rs_ad(:,floor(confLevel*numIters))];
            rs_wo = [rs_wo(:,ceil(numIters - confLevel*numIters)), rs_wo(:,floor(confLevel*numIters))];
            
        else
            % glm etc won't have r-squared
            rs_bl = ones(size(sg_bl,1),1);
            rs_ad = ones(size(sg_bl,1),1);
            rs_wo = ones(size(sg_bl,1),1);
        end
        
        % check significance
        istuned = zeros(size(sg_bl,1),2);
        for unit = 1:size(sg_bl,1)
            % only consider cells that are tuned in all epochs
            t_bl = checkTuningCISignificance(pds_bl(unit,:),ciSig,true);
            t_ad = checkTuningCISignificance(pds_ad(unit,:),ciSig,true);
            t_wo = checkTuningCISignificance(pds_wo(unit,:),ciSig,true);
            
            % also only consider cells that are described by cosines
            %   have bootstrapped r2... see if 95% CI is > threshold?
            t_r_bl = rs_bl(unit,1) > r2Min;
            t_r_ad = rs_ad(unit,1) > r2Min;
            t_r_wo = rs_wo(unit,1) > r2Min;
            
            % only consider cells that are tuned in all epochs
            %   first column is CI bound, second is r-squared
            istuned(unit,:) = [all([t_bl,t_ad,t_wo]), all([t_r_bl,t_r_ad,t_r_wo])];
        end
        
        switch lower(compMethod)
            case 'overlap'
                usePDs = {pds_bl,pds_ad,pds_wo};
                
                if ~isempty(blt.mds)
                    useMDs = {mds_bl,mds_ad,mds_wo};
                end
%                 if ~isempty(blt.bos)
%                     useBOs = {pds_bl,pds_ad,pds_wo};
%                 end
            case 'diff'
                boot_pds_bl = blt.boot_pds;
                boot_pds_ad = adt.boot_pds;
                boot_pds_wo = wot.boot_pds;
                
                boot_pds_bl = boot_pds_bl(idx_bl,:);
                boot_pds_ad = boot_pds_ad(idx_ad,:);
                boot_pds_wo = boot_pds_wo(idx_wo,:);
                usePDs = {boot_pds_bl,boot_pds_ad,boot_pds_wo};
                
                if ~isempty(blt.mds)
                    boot_mds_bl = blt.boot_mds;
                    boot_mds_ad = adt.boot_mds;
                    boot_mds_wo = wot.boot_mds;
                    
                    boot_mds_bl = boot_mds_bl(idx_bl,:);
                    boot_mds_ad = boot_mds_ad(idx_ad,:);
                    boot_mds_wo = boot_mds_wo(idx_wo,:);
                    useMDs = {boot_mds_bl,boot_mds_ad,boot_mds_wo};
                end
                
%                 if ~isempty(blt.bos)
%                     boot_bos_bl = blt.boot_bos;
%                     boot_bos_ad = adt.boot_bos;
%                     boot_bos_wo = wot.boot_bos;
%                     
%                     boot_bos_bl = boot_bos_bl(idx_bl,:);
%                     boot_bos_ad = boot_bos_ad(idx_ad,:);
%                     boot_bos_wo = boot_bos_wo(idx_wo,:);
%                     useBOs = {boot_bos_bl,boot_bos_ad,boot_bos_wo};
%                 end
        end
        
        pd = compareTuningParameter('pd',usePDs,sg_bl,{compMethod,confLevel,numIters});
        
        if ~isempty(blt.mds)
            md = compareTuningParameter('md',useMDs,sg_bl,{compMethod,confLevel,numIters});
        else
            md = [];
        end
        
%         if ~isempty(blt.bos)
%             bo = compareTuningParameter('bo',useBOs,sg_bl,{compMethod,confLevel,numIters});
%         else
%             bo = [];
%         end
end




% classify each cell based on output
for unit = 1:size(sg_bl,1)
    % preferred direction
    diffMat = pd.(['elec' num2str(sg_bl(unit,1))]).(['unit' num2str(sg_bl(unit,2))]);
    
    if all(istuned(unit,:))
        for k = 1:size(diffMat,3) % will be one if not nonparametric
            useDiff = squeeze(diffMat(:,:,k));
            
            val = sum(sum(useDiff.*converterMatrix));
            idx = classMapping(:,1)==val;
            if sum(idx) ~= 0
                cc(unit,k) = classMapping(idx,2);
            else
                warning('DANGER! Class not recognized. Something is probably fishy...');
                cc(unit,k) = NaN;
            end
        end
    else
        cc(unit,:) = -1;
    end
end

cellClass(:,1) = cc;

if ~isempty(blt.mds)
    for unit = 1:size(sg_bl,1)
        % modulation depth
        diffMat = md.(['elec' num2str(sg_bl(unit,1))]).(['unit' num2str(sg_bl(unit,2))]);
        
        if all(istuned(unit,:))
            for k = 1:size(diffMat,3) % will be one if not nonparametric
                useDiff = squeeze(diffMat(:,:,k));
                
                val = sum(sum(useDiff.*converterMatrix));
                idx = classMapping(:,1)==val;
                if sum(idx) ~= 0
                    cc(unit,k) = classMapping(idx,2);
                else
                    warning('DANGER! Class not recognized. Something is probably fishy...');
                    cc(unit,k) = NaN;
                end
            end
        else
            cc(unit,:) = -1;
        end
    end
else
    cc = -1*ones(size(sg_bl,1),1);
end

cellClass(:,2) = cc;

% if ~isempty(blt.bos)
%     for unit = 1:size(sg_bl,1)
%         % baseline offset
%         diffMat = bo.(['elec' num2str(sg_bl(unit,1))]).(['unit' num2str(sg_bl(unit,2))]);
%         
%         if istuned(unit)
%             for k = 1:size(diffMat,3) % will be one if not nonparametric
%                 useDiff = squeeze(diffMat(:,:,k));
%                 
%                 val = sum(sum(useDiff.*converterMatrix));
%                 idx = classMapping(:,1)==val;
%                 if sum(idx) ~= 0
%                     cc(unit,k) = classMapping(idx,2);
%                 else
%                     warning('DANGER! Class not recognized. Something is probably fishy...');
%                     cc(unit,k) = NaN;
%                 end
%             end
%         else
%             cc(unit,:) = -1;
%         end
%         
%     end
% else
%     cc = -1*ones(size(sg_bl,1),1);
% end
% 
% cellClass(:,1) = cc;
