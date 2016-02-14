j = 1;
k = 1;

for i = 1:length(Mini_SpikeFiles)
    
    if isnan(Mini_SpikeFiles(1,i).decoder_age) == 1
        
        MiniSpikeHCFileNames{k} = Mini_SpikeFiles(1,i).name;
        k = k+1;
        
    else
        
        MiniSpikeBCFileNames{j} = Mini_SpikeFiles(1,i).name;
        j = j+1;
    end
end
