function clearTempFields(cds)
    %clearTempFields is a method of the commonDataStructure class and
    %should be saved in the @commonDataStructure folder.
    %
    %this method assigns empty matrices to the NEV,NS#,NSxInfo,enc,words
    %and databursts fields. This is inteneded to be used after NEVNSx data
    %is loaded into the cds.
    set(cds,'NEV',[])
    set(cds,'NS1',[])
    set(cds,'NS2',[])
    set(cds,'NS3',[])
    set(cds,'NS4',[])
    set(cds,'NS5',[])
    set(cds,'NSxInfo',[])
    set(cds,'enc',cell2table(cell(0,3),'VariableNames',{'t','th1','th2'}))
    set(cds,'words',cell2table(cell(0,2),'VariableNames',{'ts','word'}))
    set(cds,'databursts',cell2table(cell(0,2),'VariableNames',{'ts','word'}))
end