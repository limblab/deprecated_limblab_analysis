filelist= ChewieLFP2fileNames;

for i=1:length(filelist)


    filewithpath=findBDFonCitadel(filelist{i},1);
    
    load(filewithpath)
    
    UnitLists{i} = unit_list(out_struct);

end