function cds=loadobj(S)
    %loadobj implementation for cds class. This loadobj implementation must 
    %be matched by a saveobj implementation
    if isstruct(S)
        cds=commonDataStructure;
        cds.kinFilterConfig=S.kinFilterConfig;
        cds.meta=S.meta;
        cds.kin=S.kin;
        cds.force=S.force;
        cds.lfp=S.lfp;
        cds.emg=S.emg;
        cds.analog=S.analog;
        cds.triggers=S.triggers;
        cds.units=S.units;
        cds.trials=S.trials;
    else
        cds=S;
    end
end