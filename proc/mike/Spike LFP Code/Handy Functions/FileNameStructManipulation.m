Mini_SpikeFileNames = {Mini_SpikeControlDaysNames.name; Mini_SpikeControlDaysNames.datename; Mini_SpikeControlDaysNames.decoder_age};

Mini_SpikeHC_filenames = Mini_SpikeFileNames(:,cellfun(@isnan,{Mini_SpikeControlDaysNames.decoder_age})== 1)';
    
Mini_SpikeBC_filenames = Mini_SpikeFileNames(:,cellfun(@isnan,{Mini_SpikeControlDaysNames.decoder_age})== 0)';