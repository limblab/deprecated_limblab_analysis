%%
for n=1:length(HbankDays)
    fileToLoad=findBDFonCitadel(HbankDays{n});
    fprintf(1,'loading %s...\n',fileToLoad)
    load(fileToLoad)
    tsNum{n,1}=HbankDays{n};
    tsNum{n,2}=[length(out_struct.raw.analog.ts{1}) ...
        length(out_struct.raw.analog.ts{96})];
    if isfield(out_struct.raw.analog,'fn')
        tsNum{n,3}=[length(out_struct.raw.analog.fn{1}) ...
            length(out_struct.raw.analog.fn{96})];
    else
        tsNum{n,3}=[0,0];
    end
    tsNum{n,4}=max(max(out_struct.vel(:,2:3)))-min(min(out_struct.vel(:,2:3)));
    clear out_struct fileToLoad
end, clear n