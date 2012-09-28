function [trialTable, pdsHC, pdsCT, pdsBC] = poolNeuronPDs(fileList)

[trialTable,~] = poolCatchTrialData(fileList);

pdsHC = [];
pdsCT = [];
pdsBC = [];

maxIDHC = 0;
maxIDCT = 0;
maxIDBC = 0;

for iFile = 1:length(fileList)
    
    if strfind(lower(fileList{iFile}),'isobc')
        BCTrial = true;
    else
        BCTrial = false;
    end
    
    load(fileList{iFile});
    
    temptable = getCatchTrialTable(out_struct,BCTrial);
    temptable = temptable(temptable(:,9)==82,:);
    
    indsHC = temptable(:,11)==0;
    indsCT = temptable(:,11)==1;
    indsBC = temptable(:,11)==2;
end

    if any(indsHC)
        pds = computeNeuronPDs(out_struct,false,indsHC);
        pdsHC = combinePDs(pdsHC, pds);
    end
    
    if any(indsCT)
        pds = computeNeuronPDs(out_struct,false,indsCT);
        pdsCT = combinePDs(pdsCT, pds);
    end
    
    if any(indsBC)
        pds = computeNeuronPDs(out_struct,false,indsBC);
        pdsBC = combinePDs(pdsBC, pds);
    end

end

function pd1 = combinePDs(pd1,pd2)

if length(pd2) > length(pd1)
    temp = pd1;
    pd1 = pd2;
    pd2 = temp;
    clear temp;
end

% if one of them is empty, it will become pd2 and then the non-empty one
% will be passed out
if ~isempty(pd2)
    for i = 1:length(pd2)
        ind = pd1(:,1) == pd2(i,1);
        pd1(ind,2:end) = pd1(ind,2:end) + pd2(i,2:end);
    end
end

end

