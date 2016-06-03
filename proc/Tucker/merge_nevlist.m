function NEVNSx=merge_nevlist(NEVNSxstruct)
fs = [0,1000,2000,10000,30000];
    for iNS = 2:5        
        for iFile = 1:length(eval(['NS' num2str(iNS) 'list']))
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]) = openNSx('read', [filepath filesep eval(['NS' num2str(iNS) 'list(iFile).name'])],'precision','short');
            num_zeros = fix((NEVNSxstruct(iFile).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data,2)/fs(iNS))*1000);
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data = [zeros(size(NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data,1),num_zeros) NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data];
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataPoints = NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataPoints + num_zeros;
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataDurationSec = NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataPoints/fs(iNS) + num_zeros/1000;
        end
    end    

    NSxfields = fieldnames(NEVNSxstruct);
    NSxfields = NSxfields(~strcmp(NSxfields,'NEV'));

    NEVNSx = NEVNSxstruct(1);
    NEVNSx.MetaTags.NumFilesConcat = 1;
    NEVNSx.MetaTags.FileStartSec = 0;
    NEVNSx.MetaTags.NEVlist = {NEVlist.name};

    for iNEVNSx = 2:length(NEVNSxstruct)
        NEV1 = NEVNSx.NEV;
        NEV2 = NEVNSxstruct(iNEVNSx).NEV;
        NSx1DataLength = [];
        for iNSx = 1:length(NSxfields)
            if ~isempty(NEVNSx.(NSxfields{iNSx})) && ~isempty(NEVNSxstruct(iNEVNSx).(NSxfields{iNSx}))
                NSx1 = NEVNSx.(NSxfields{iNSx});
                NSx2 = NEVNSxstruct(iNEVNSx).(NSxfields{iNSx});       

                % Determining length of the first NSx file (adding one blank second between
                % files)
                conversionFactor = 30000/NSx1.MetaTags.SamplingFreq;
                NSx1DataLength = (NSx1.MetaTags.DataPoints + NSx1.MetaTags.SamplingFreq) * conversionFactor;

                % Combining NSx files
                NSx1.Data = [NSx1.Data, zeros(size(NSx1.Data,1),NSx1.MetaTags.SamplingFreq), NSx2.Data];
                NSx1.MetaTags.DataPoints             = NSx1.MetaTags.DataPoints + NSx2.MetaTags.DataPoints + NSx1.MetaTags.SamplingFreq;
                NSx1.MetaTags.DataDurationSec        = NSx1.MetaTags.DataDurationSec + NSx2.MetaTags.DataDurationSec + 1;

                NEVNSx.(NSxfields{iNSx}) = NSx1;
                clear NSx2;        
            end
        end

        if isempty(NSx1DataLength)
            NSx1DataLength = (NEV1.MetaTags.DataDurationSec + 1)*30000;
        end

        % Adjusting the timestamp on the second NEV file
        NEV2.Data.Comments.TimeStamp = NEV2.Data.Comments.TimeStamp + NSx1DataLength;
        NEV2.Data.Comments.TimeStampSec = NEV2.Data.Comments.TimeStampSec + double(NSx1DataLength)/30000;
        NEV2.Data.SerialDigitalIO.TimeStamp = NEV2.Data.SerialDigitalIO.TimeStamp + NSx1DataLength;
        NEV2.Data.SerialDigitalIO.TimeStampSec = NEV2.Data.SerialDigitalIO.TimeStampSec + double(NSx1DataLength)/30000;
        NEV2.Data.Spikes.TimeStamp = NEV2.Data.Spikes.TimeStamp + NSx1DataLength;

        % Combining the two NEV files
        NEVNSx.MetaTags.FileStartSec(end+1) = double(NSx1DataLength)/30000;
        NEV1.Data.Spikes.Electrode      = [NEV1.Data.Spikes.Electrode, NEV2.Data.Spikes.Electrode];
        NEV1.Data.Spikes.TimeStamp      = [NEV1.Data.Spikes.TimeStamp, NEV2.Data.Spikes.TimeStamp];
        NEV1.Data.Spikes.Unit           = [NEV1.Data.Spikes.Unit, NEV2.Data.Spikes.Unit];
        NEV1.Data.Spikes.Waveform       = [NEV1.Data.Spikes.Waveform, NEV2.Data.Spikes.Waveform];

        NEV1.Data.SerialDigitalIO.TimeStamp = [NEV1.Data.SerialDigitalIO.TimeStamp, NEV2.Data.SerialDigitalIO.TimeStamp];
        NEV1.Data.SerialDigitalIO.TimeStampSec = [NEV1.Data.SerialDigitalIO.TimeStampSec, NEV2.Data.SerialDigitalIO.TimeStampSec];
        NEV1.Data.SerialDigitalIO.InsertionReason = [NEV1.Data.SerialDigitalIO.InsertionReason, NEV2.Data.SerialDigitalIO.InsertionReason];
        NEV1.Data.SerialDigitalIO.UnparsedData = [NEV1.Data.SerialDigitalIO.UnparsedData; NEV2.Data.SerialDigitalIO.UnparsedData];

        NEV1.Data.Comments.TimeStamp    = [NEV1.Data.Comments.TimeStamp, NEV2.Data.Comments.TimeStamp];
        NEV1.Data.Comments.TimeStampSec = [NEV1.Data.Comments.TimeStampSec, NEV2.Data.Comments.TimeStampSec];
        NEV1.Data.Comments.CharSet      = [NEV1.Data.Comments.CharSet, NEV2.Data.Comments.CharSet];
        NEV1.Data.Comments.Color        = [NEV1.Data.Comments.Color, NEV2.Data.Comments.Color];

        NEV1.MetaTags.DataDuration      = NEV1.MetaTags.DataDuration + NEV2.MetaTags.DataDuration;
        NEV1.MetaTags.DataDurationSec   = NEV1.MetaTags.DataDurationSec + NEV2.MetaTags.DataDurationSec;
        NEV1.MetaTags.PacketCount       = NEV1.MetaTags.PacketCount + NEV2.MetaTags.PacketCount;
        NEV1.Data.Comments.Text         = [NEV1.Data.Comments.Text; NEV2.Data.Comments.Text];

        NEVNSx.NEV = NEV1;
        NEVNSx.MetaTags.NumFilesConcat = length(NEVNSxstruct);
        clear NEV1;
    end
end