function r2_SingleUnitsMAT=padUnits_in_r2array(r2_SingleUnits,DecNeuronIDsOUT)

r2_SingleUnitsMAT=cell((size(DecNeuronIDsOUT,1)-size(DecNeuronIDsOUT,3)), ...
    size(DecNeuronIDsOUT,2),size(DecNeuronIDsOUT,3));
for n=1:(size(DecNeuronIDsOUT,1)-size(DecNeuronIDsOUT,3))
    for k=1:size(DecNeuronIDsOUT,2)
        for m=1:size(DecNeuronIDsOUT,3)
            r2_SingleUnitsMAT{n,k,m}=zeros(96,1);
            nzDec=find(DecNeuronIDsOUT{n,k,m}(:,1));
            r2_SingleUnitsMAT{n,k,m}(DecNeuronIDsOUT{n,k,m}(nzDec,1))=r2_SingleUnits{n,k,m}(nzDec);
        end, clear m
    end, clear k
end, clear n
