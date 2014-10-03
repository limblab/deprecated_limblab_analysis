%%
% local
for n=1:length(HbankDays)
    fprintf(1,'finding local path to %s\n',HbankDays{n});
    pathToLoad=findBDF_local(HbankDays{n});
    fprintf(1,'loading %s...',pathToLoad);
    load(pathToLoad)
    fprintf(1,'done\n');
    tsNum{n,1}=HbankDays{n};
    tsNum{n,2}=max(cellfun(@numel,out_struct.raw.analog.ts));
    tsNum{n,3}=isfield(out_struct.raw.analog,'fn');
    clear out_struct pathToLoad
end, clear n
% remote
for n=1:length(HbankDays)
    fprintf(1,'finding remote path to %s\n',HbankDays{n});
    pathToLoad=findBDFonCitadel(HbankDays{n});
    fprintf(1,'loading %s...',pathToLoad);
    load(pathToLoad)
    fprintf(1,'done\n');
    tsNum{n,4}=isfield(out_struct.raw.analog,'fn');
    clear out_struct pathToLoad
end, clear n

