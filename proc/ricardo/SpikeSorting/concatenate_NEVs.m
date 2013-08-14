function NEVNSx = concatenate_NEVs(filepath,file_prefix)
% Batch combine NEVs and NSxs

    NEVlist_sorted = dir([filepath file_prefix '*-s.mat']);
    NEVlist = dir([filepath file_prefix '*.nev']);
    NS2list = dir([filepath file_prefix '*.ns2']);
    NS3list = dir([filepath file_prefix '*.ns3']);
    NS4list = dir([filepath file_prefix '*.ns4']);
    NS5list = dir([filepath file_prefix '*.ns5']);

    if isempty(NEVlist)
        disp('File(s) not found, aborting.')
        return
    end
    NEVNSxstruct = struct('NEV',[],'NS2',[],'NS3',[],'NS4',[],'NS5',[]);
    
    if length(NEVlist_sorted)==length(NEVlist)
        for iNEV = 1:length(NEVlist)
            clear NEV
            load([filepath NEVlist_sorted(iNEV).name]);
            NEVNSxstruct(iNEV).NEV = NEV;
        end
    else
        for iNEV = 1:length(NEVlist)
            NEVNSxstruct(iNEV).NEV = openNEV('read', [filepath NEVlist(iNEV).name],'nosave');
        end
    end
    for iNS2 = 1:length(NS2list)
        NEVNSxstruct(iNS2).NS2 = openNSx('read', [filepath NS2list(iNS2).name],'precision','short');
        num_zeros = fix((NEVNSxstruct(iNS2).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSxstruct(iNS2).NS2.Data,2)/1000)*1000);
        NEVNSxstruct(iNS2).NS2.Data = [zeros(size(NEVNSxstruct(iNS2).NS2.Data,1),num_zeros) NEVNSxstruct(iNS2).NS2.Data];
        NEVNSxstruct(iNS2).NS2.MetaTags.DataPoints = NEVNSxstruct(iNS2).NS2.MetaTags.DataPoints + num_zeros;
        NEVNSxstruct(iNS2).NS2.MetaTags.DataDurationSec = NEVNSxstruct(iNS2).NS2.MetaTags.DataDurationSec + num_zeros/1000;        
    end
    for iNS3 = 1:length(NS3list)
        NEVNSxstruct(iNS3).NS3 = openNSx('read', [filepath NS3list(iNS3).name],'precision','short');        
        num_zeros = fix((NEVNSxstruct(iNS3).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSxstruct(iNS3).NS3.Data,2)/2000)*2000);
        NEVNSxstruct(iNS3).NS3.Data = [zeros(size(NEVNSxstruct(iNS3).NS3.Data,1),num_zeros) NEVNSxstruct(iNS3).NS3.Data];
        NEVNSxstruct(iNS3).NS3.MetaTags.DataPoints = NEVNSxstruct(iNS3).NS3.MetaTags.DataPoints + num_zeros;
        NEVNSxstruct(iNS3).NS3.MetaTags.DataDurationSec = NEVNSxstruct(iNS3).NS3.MetaTags.DataDurationSec + num_zeros/2000;
    end
    for iNS4 = 1:length(NS4list)
        NEVNSxstruct(iNS4).NS4 = openNSx('read', [filepath NS4list(iNS4).name],'precision','short');
        num_zeros = fix((NEVNSxstruct(iNS4).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSxstruct(iNS4).NS4.Data,2)/10000)*10000);
        NEVNSxstruct(iNS4).NS4.Data = [zeros(size(NEVNSxstruct(iNS4).NS4.Data,1),num_zeros) NEVNSxstruct(iNS4).NS4.Data];
        NEVNSxstruct(iNS4).NS4.MetaTags.DataPoints = NEVNSxstruct(iNS4).NS4.MetaTags.DataPoints + num_zeros;
        NEVNSxstruct(iNS4).NS4.MetaTags.DataDurationSec = NEVNSxstruct(iNS4).NS4.MetaTags.DataDurationSec + num_zeros/10000;
    end
    for iNS5 = 1:length(NS5list)
        NEVNSxstruct(iNS5).NS5 = openNSx('read', [filepath NS5list(iNS5).name],'precision','short');
        num_zeros = fix((NEVNSxstruct(iNS5).NEV.Data.SerialDigitalIO.TimeStampSec(end)-size(NEVNSxstruct(iNS5).NS5.Data,2)/30000)*30000);
        NEVNSxstruct(iNS5).NS5.Data = [zeros(size(NEVNSxstruct(iNS5).NS5.Data,1),num_zeros) NEVNSxstruct(iNS5).NS5.Data];
        NEVNSxstruct(iNS5).NS5.MetaTags.DataPoints = NEVNSxstruct(iNS5).NS5.MetaTags.DataPoints + num_zeros;
        NEVNSxstruct(iNS5).NS5.MetaTags.DataDurationSec = NEVNSxstruct(iNS5).NS5.MetaTags.DataDurationSec + num_zeros/30000;
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

    % NEV1.Data.Tracking.TimeStamp    = [NEV1.Data.Tracking.TimeStamp, NEV2.Data.Tracking.TimeStamp];
    % NEV1.Data.Tracking.PointCount   = [NEV1.Data.Tracking.PointCount, NEV2.Data.Tracking.PointCount];
    % NEV1.Data.Tracking.X            = [NEV1.Data.Tracking.X, NEV2.Data.Tracking.X];
    % NEV1.Data.Tracking.Y            = [NEV1.Data.Tracking.Y, NEV2.Data.Tracking.Y];
    % NEV1.Data.Tracking.TimeStampSec = [NEV1.Data.Tracking.TimeStampSec, NEV2.Data.Tracking.TimeStampSec];
end