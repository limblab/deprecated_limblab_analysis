filelist = Mini_MSP_DaysNames

gcp

parfor i = 1:length(filelist)
    
    [] = runPDfromspikes(filelist{i}) 
    
end