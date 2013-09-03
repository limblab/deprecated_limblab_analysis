function [cellClass,sg_bl] = classifyCells(blt,adt,wot,useArray,tuningPeriod,tuningMethod)
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
paramFile = fullfile(blt.meta.out_directory, [blt.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
ciSig = str2double(params.ci_significance{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

converterMatrix = [1 2 3;4 5 6;7 8 9];

sg_bl = blt.(useArray).(tuningMethod).(tuningPeriod).unit_guide;
sg_ad = adt.(useArray).(tuningMethod).(tuningPeriod).unit_guide;
sg_wo = wot.(useArray).(tuningMethod).(tuningPeriod).unit_guide;

badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);

if ~isempty(badUnits)
    % remove that index from each
    [sg_bl, idx_bl] = setdiff(sg_bl,badUnits,'rows');
    
    [sg_ad, idx_ad] = setdiff(sg_ad,badUnits,'rows');
    
    [sg_wo, idx_wo] = setdiff(sg_wo,badUnits,'rows');
end

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
        
        istuned = ones(size(sg_bl,1),1);
        
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
        
        % check significance
        istuned = zeros(size(sg_bl,1),1);
        for unit = 1:size(sg_bl,1)
            t_bl = checkTuningCISignificance(pds_bl(unit,:),ciSig,true);
            t_ad = checkTuningCISignificance(pds_ad(unit,:),ciSig,true);
            t_wo = checkTuningCISignificance(pds_wo(unit,:),ciSig,true);
            
            % only consider cells that are tuned in all epochs
            istuned(unit) = all([t_bl,t_ad,t_wo]);
        end
        
        out = comparePDTuning({pds_bl,pds_ad,pds_wo},sg_bl);
end

% classify each cell based on output
for unit = 1:size(sg_bl,1)
    diffMat = out.(['elec' num2str(sg_bl(unit,1))]).(['unit' num2str(sg_bl(unit,2))]);
    
    if istuned(unit)
        for k = 1:size(diffMat,3) % will be one if not nonparametric
            useDiff = squeeze(diffMat(:,:,k));
            
            val = sum(sum(useDiff.*converterMatrix));
            
            switch num2str(val)
                case '0' % Kinematic AAA
                    cellClass(unit,k) = 1;
                case '8' % Dynamic ABA
                    cellClass(unit,k) = 2;
                case '5' % Memory I ABB
                    cellClass(unit,k) = 3;
                case '9' % Memory II AAB
                    cellClass(unit,k) = 4;
                case '11' % Other ABC
                    cellClass(unit,k) = 5;
                otherwise
                    % something is funky, usually means that only one value
                    % is 1 in useDiff, e.g. significant change from BL->AD
                    % but neither BL->WO or AD->WO is not significant
                    % IGNORE FOR NOW
                    cellClass(unit,k) = 6;
            end
        end
    else
        cellClass(unit,:) = -1;
    end
    
end

