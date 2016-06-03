% script.
CMspikeDays

peakIndAll_x_Chewie=[]; peakIndAll_y_Chewie=[];
peakValAll_x_Chewie=[]; peakValAll_y_Chewie=[];
BDFlist_all=[];

for n=1:length(Chewie_spike_days)
    % take a day, find the kinStruct, and identifies all the
    % files of the given control type that were included.
    try
        BDFlist=findBDF_withControl('Chewie',Chewie_spike_days{n},'Spike');
        
        BDFlist_all=[BDFlist_all; BDFlist'];
        for k=1:length(BDFlist)
            load(findBDFonCitadel(BDFlist{k}))
            [fullX,sig] = buildSpikeXY(out_struct);
            [XCx,XCy,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]= ...
                spikeOutputXcorr(500,fullX,sig);
            peakIndAll_x_Chewie=[peakIndAll_x_Chewie; peakInd_x];
            peakIndAll_y_Chewie=[peakIndAll_y_Chewie; peakInd_y];
            peakValAll_x_Chewie=[peakValAll_x_Chewie; peakVal_x];
            peakValAll_y_Chewie=[peakValAll_y_Chewie; peakVal_y];
            clear peakInd_* peakVal_*
        end
        clear BDFlist
    catch ME
        if strcmp(ME.identifier,'findBDF_withControl:nokinStruct')
            fprintf('\n\nkinStruct not found for %s\n\n',Chewie_spike_days{n})
        end
        continue
    end
end

peakIndAll_x_Mini=[]; peakIndAll_y_Mini=[];
peakValAll_x_Mini=[]; peakValAll_y_Mini=[];

for n=1:length(Mini_spike_days)
    % take a day, find the kinStruct, and identifies all the
    % files of the given control type that were included.
    try
        BDFlist=findBDF_withControl('Mini',Mini_spike_days{n},'Spike');
        
        BDFlist_all=[BDFlist_all; BDFlist'];
        for k=1:length(BDFlist)
            load(findBDFonCitadel(BDFlist{k}))
            [fullX,sig] = buildSpikeXY(out_struct);
            [XCx,XCy,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]= ...
                spikeOutputXcorr(500,fullX,sig);
            
            peakIndAll_x_Mini=[peakIndAll_x_Mini; peakInd_x];
            peakIndAll_y_Mini=[peakIndAll_y_Mini; peakInd_y];
            peakValAll_x_Mini=[peakValAll_x_Mini; peakVal_x];
            peakValAll_y_Mini=[peakValAll_y_Mini; peakVal_y];
        end
        clear BDFlist
    catch ME
        if strcmp(ME.identifier,'findBDF_withControl:nokinStruct')
            fprintf('\n\nkinStruct not found for %s\n\n',Mini_spike_days{n})
        end
        continue
    end
end


