function  [bothSigNames pSS pMean] = computeAnovaForEpochs(out_struct,sorted)


% Create trial table
trialtable = GetFixTrialTable(out_struct,'contextdep');

% Get the indices for the sorted cells------------------------------------
if sorted == 1;
    UnitIndices = []; ind=1;
    for a = 1:length(out_struct.units)
        if out_struct.units(1,a).id(2)~=0 && out_struct.units(1,a).id(2)~=255
            UnitIndices(ind) = a;
            ind = ind+1;
        end
    end
else
    UnitIndices = 1:1:length(out_struct.units);
end
%--------------------------------------------------------------------------

OTon = trialtable(:,6); 
TargetAcq = trialtable(:,8)-0.5;
EndofTrial = trialtable(:,8);

for i = 1:length(UnitIndices)
    unit = UnitIndices(i);
    
    % Get means for OTon->TargetAcquired epoch
    epochMeansPerTrial(:,1) = getFRmeansPerEpoch(out_struct,unit,OTon,TargetAcq);
    epochSSPerTrial(:,1) = getSSPerEpoch(out_struct,unit,OTon,TargetAcq);
    
    
    % Get means for Hold Time (TargetAcquired->End of Trial) epoch
    epochMeansPerTrial(:,2) = getFRmeansPerEpoch(out_struct,unit,TargetAcq,EndofTrial);
    epochSSPerTrial(:,2) = getSSPerEpoch(out_struct, unit,TargetAcq,EndofTrial);
    
    pSS(i,1) = anova1(epochSSPerTrial,[],'off');
    pMean(i,1) = anova1(epochMeansPerTrial,[],'off');
    
    names(i,:) =  out_struct.units(1,unit).id;
end

 bothSignificant =find(pSS<=0.05 & pMean<=0.05);
 bothSigNames =names(bothSignificant,:);

