function S=saveobj(cds)
    %saveobj implementation for cds class. This overrides silent fail
    %behavior when attempting to save, by instead saving a structure that
    %simply contains the data from the cds without actually saving the
    %structure. This saveobj implementation must be matched by a loadobj
    %implementation
    
    S=cds;
    
%     S.kinFilterConfig=cds.kinFilterConfig;
%     S.meta=cds.meta;
%     S.kin=cds.kin;
%     S.force=cds.force;
%     S.lfp=cds.lfp;
%     S.emg=cds.emg;
%     S.analog=cds.analog;
%     S.triggers=cds.triggers;
%     S.units=cds.units;
%     S.trials=cds.trials;
%     S.operationLog=cds.operationLog;
end