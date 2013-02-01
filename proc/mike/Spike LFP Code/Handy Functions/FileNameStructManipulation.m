Chewie_SpikeFileNames = {Chewie_SpikeFiles.name};

Chewie_SpikeHC_filenames = Chewie_SpikeFileNames(cellfun(@isnan,{Chewie_SpikeFiles.decoder_age})== 1)';
    
Chewie_SpikeBC_filenames = Chewie_SpikeFileNames(cellfun(@isnan,{Chewie_SpikeFiles.decoder_age})== 0)';