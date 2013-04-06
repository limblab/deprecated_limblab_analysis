Filelist = dir(cd)
files = {Filelist.name}


for i = 1 :length(Chewie_filenames)
    
    Nextfile = files(cellfun(@isempty,(regexp({Filelist.name},Chewie_filenames{i}(1,1:end-4))))== 0);
    
    load(Nextfile);
    
   %Insert code to look at PD stuff here 
    
end
