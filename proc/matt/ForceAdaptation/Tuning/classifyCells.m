function [cellClass,sg_bl] = classifyCells(blt,adt,wot,useArray,tuningPeriod,tuningMethod,compMethod, paramSetName)
% first gets a matrix where ones show significant tuning between epochs
%    BL  AD  WO
% BL -   -   -
% AD -   -   -
% WO -   -   -
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(blt.meta.out_directory, paramSetName, [blt.meta.recording_date '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
ciSig = str2double(params.ci_significance{1});
confLevel = str2double(params.confidence_level{1});
numIters = str2double(params.number_iterations{1});
r2Min = str2double(params.r2_minimum{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load the info to classify cells
cell_classifications;

sg_bl = blt.(useArray).(tuningMethod).(tuningPeriod).unit_guide;
sg_ad = adt.(useArray).(tuningMethod).(tuningPeriod).unit_guide;
sg_wo = wot.(useArray).(tuningMethod).(tuningPeriod).unit_guide;

badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);

% remove that index from each
[sg_bl, idx_bl] = setdiff(sg_bl,badUnits,'rows');

[sg_ad, idx_ad] = setdiff(sg_ad,badUnits,'rows');

[sg_wo, idx_wo] = setdiff(sg_wo,badUnits,'rows');

% make the cell to pass in the checking function
switch lower(tuningMethod)
    case 'nonparametric'
        mfr_bl = blt.(useArray).(tuningMethod).(tuningPeriod).mfr;
        mfr_ad = adt.(useArray).(tuningMethod).(tuningPeriod).mfr;
        mfr_wo = wot.(useArray).(tuningMethod).(tuningPeriod).mfr;
        
        cil_bl = blt.(useArray).(tuningMethod).(tuningPeriod).cil;
        cil_ad = adt.(useArray).(tuningMethod).(tuningPeriod).cil;
        cil_wo = wot.(useArray).(tuningMethod).(tuningPeriod).cil;
        
        cih_bl = blt.(useArray).(tuningMethod).(tuningPeriod).cih;
        cih_ad = adt.(useArray).(tuningMethod).(tuningPeriod).cih;
        cih_wo = wot.(useArray).(tuningMethod).(tuningPeriod).cih;
        
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
        pds_bl = blt.(useArray).(tuningMethod).(tuningPeriod).pds;
        pds_ad = adt.(useArray).(tuningMethod).(tuningPeriod).pds;
        pds_wo = wot.(useArray).(tuningMethod).(tuningPeriod).pds;
        
        pds_bl = pds_bl(idx_bl,:);
        pds_ad = pds_ad(idx_ad,:);
        pds_wo = pds_wo(idx_wo,:);
        
        rs_bl = blt.(useArray).(tuningMethod).(tuningPeriod).r_squared;
        rs_ad = adt.(useArray).(tuningMethod).(tuningPeriod).r_squared;
        rs_wo = wot.(useArray).(tuningMethod).(tuningPeriod).r_squared;
        
        rs_bl = sort(rs_bl(idx_bl,:),2);
        rs_ad = sort(rs_ad(idx_ad,:),2);
        rs_wo = sort(rs_wo(idx_wo,:),2);
        
        % get 95% CI for each
        rs_bl = [rs_bl(:,ceil(numIters - confLevel*numIters)), rs_bl(:,floor(confLevel*numIters))];
        rs_ad = [rs_ad(:,ceil(numIters - confLevel*numIters)), rs_ad(:,floor(confLevel*numIters))];
        rs_wo = [rs_wo(:,ceil(numIters - confLevel*numIters)), rs_wo(:,floor(confLevel*numIters))];
         
        % check significance
        istuned = zeros(size(sg_bl,1),1);
        for unit = 1:size(sg_bl,1)
            % only consider cells that are tuned in all epochs
            t_bl = checkTuningCISignificance(pds_bl(unit,:),ciSig,true);
            t_ad = checkTuningCISignificance(pds_ad(unit,:),ciSig,true);
            t_wo = checkTuningCISignificance(pds_wo(unit,:),ciSig,true);
            
            % also only consider cells that are described by cosines
            %   have bootstrapped r2... see if 95% CI is > 0.5?
            t_r_bl = rs_bl(unit,1) > r2Min;
            t_r_ad = rs_ad(unit,1) > r2Min;
            t_r_wo = rs_wo(unit,1) > r2Min;
            
            % only consider cells that are tuned in all epochs
            istuned(unit) = all([t_bl,t_ad,t_wo]) & all([t_r_bl,t_r_ad,t_r_wo]);
        end
        
        switch lower(compMethod)
            case 'overlap'
                usePDs = {pds_bl,pds_ad,pds_wo};
            case 'diff'
                boot_pds_bl = blt.(useArray).(tuningMethod).(tuningPeriod).boot_pds;
                boot_pds_ad = adt.(useArray).(tuningMethod).(tuningPeriod).boot_pds;
                boot_pds_wo = wot.(useArray).(tuningMethod).(tuningPeriod).boot_pds;
                
                boot_pds_bl = boot_pds_bl(idx_bl,:);
                boot_pds_ad = boot_pds_ad(idx_ad,:);
                boot_pds_wo = boot_pds_wo(idx_wo,:);
                usePDs = {boot_pds_bl,boot_pds_ad,boot_pds_wo};
        end
        
        out = comparePDTuning(usePDs,sg_bl,compMethod);
end

% classify each cell based on output
for unit = 1:size(sg_bl,1)
    diffMat = out.(['elec' num2str(sg_bl(unit,1))]).(['unit' num2str(sg_bl(unit,2))]);
    
    if istuned(unit)
        for k = 1:size(diffMat,3) % will be one if not nonparametric
            useDiff = squeeze(diffMat(:,:,k));
            
            val = sum(sum(useDiff.*converterMatrix));
            idx = classMapping(:,1)==val;
            if sum(idx) ~= 0
                cellClass(unit,k) = classMapping(idx,2);
            else
                warning('DANGER! Class not recognized. Something is probably fishy...');
                cellClass(unit,k) = NaN;
            end
        end
    else
        cellClass(unit,:) = -1;
    end
    
end

