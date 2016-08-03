function NEVNSx = cerebus2NEVNSx(varargin)
% cerebus2NEVNSx creates NEVNSx structure containing all Cerebus data in the
%   filepath folder that matches the file_prefix string.  NEVNSx is a
%   structure with NEV, NS2, NS3, NS4 and NS5 fields, each containing data
%   from that particular recording type.  Files of the same recording type
%   are appended to one another with 1 second of blank data in between.  If
%   spike data has been sorted (indicated by '*-s.mat' suffix), sorted files
%   will be loaded.   

    %initial setup
    opts=struct('loadanalog',1); %default to loading everything
   
    % Parse arguments
    if (nargin<2)
        error('cerebus2NEVNSx:too_few_arguments','cerebus2NEVNSx requires filepath and file_prefix as arguments');
    elseif (nargin == 2)
        filepath = varargin{1};
        file_prefix = varargin{2};
    else
        filepath = varargin{1};
        file_prefix = varargin{2};
        for i = 3:nargin
            opt_str = char(varargin{i} + ...
                (varargin{i} >= 65 & varargin{i} <= 90) * 32); % convert to lower case            
            if strcmp(opt_str, 'noanalog')
                opts.loadanalog = 0;             
            else 
                error('Unrecognized option: %s', opt_str);
            end
        end
    end

    NEVlist_sorted = dir([filepath filesep file_prefix '*-s.mat']);
    NEVlist_nodigital = dir([filepath filesep file_prefix '*-nodigital.nev']);
    NEVlist_nodigital_sorted = dir([filepath filesep file_prefix '*-nodigital-s.nev']);
    NEVlist_nospikes= dir([filepath filesep file_prefix '*-nospikes.mat']);
    NEVlist = dir([filepath filesep file_prefix '*.nev']);
    
    if(opts.loadanalog)
        NS1list = dir([filepath filesep file_prefix '*.ns1']);
        NS2list = dir([filepath filesep file_prefix '*.ns2']);
        NS3list = dir([filepath filesep file_prefix '*.ns3']);
        NS4list = dir([filepath filesep file_prefix '*.ns4']);
        NS5list = dir([filepath filesep file_prefix '*.ns5']);
    else
        NS1list = [];
        NS2list = [];
        NS3list = [];
        NS4list = [];
        NS5list = [];
    end

    NEVlist_sorted = NEVlist_sorted(cellfun('isempty',(regexp({NEVlist_sorted(:).name},'-spikes'))));
    NEVlist = NEVlist(cellfun('isempty',(regexp({NEVlist(:).name},'-spikes'))));

    if isempty(NEVlist)
        disp('File(s) not found, aborting.')
        return
    end
    NEVNSxstruct = struct('NEV',[],'NS1',[],'NS2',[],'NS3',[],'NS4',[],'NS5',[]);
    
    if (length(NEVlist_nodigital_sorted)==length(NEVlist_nospikes) && ~isempty(NEVlist_nospikes))  || (length(NEVlist_nodigital)==length(NEVlist_nospikes) && ~isempty(NEVlist_nospikes))
       for iNEV = 1:length(NEVlist_nospikes)
            disp('Found files that have been split into *.nev files with only spikes, and *.mat files with digital data only.')
            warning('cerebus2NEVNSx:FoundSplitFiles','Loading data from split files. To avoid this, do not use the *_nodigital.nev *_nospikes.mat file naming convention, or place these files in a different folder')
            clear NEV
            clear NEV_nospikes
            load([filepath filesep NEVlist_nospikes(iNEV).name]); %loads a variable NEV_nospikes
            NEVNSxstruct(iNEV).NEV = NEV_nospikes;
            if length(NEVlist_nodigital_sorted) >=length(NEVlist_nodigital) %if we have sorted data use that, otherwise use the base files
                NEV= openNEVLimblab('read', [filepath filesep NEVlist_nodigital_sorted(iNEV).name],'nosave');
            else
                NEV= openNEVLimblab('read', [filepath filesep NEVlist_nodigital(iNEV).name],'nosave');
            end
            NEVNSxstruct(iNEV).NEV.Data.Spikes= NEV.Data.Spikes;
        end
    else    
        if length(NEVlist_sorted)==length(NEVlist)
            for iNEV = 1:length(NEVlist)
                clear NEV
                load([filepath filesep NEVlist_sorted(iNEV).name]);
                NEVNSxstruct(iNEV).NEV = NEV;
            end
        else
            for iNEV = 1:length(NEVlist)
                NEVNSxstruct(iNEV).NEV = openNEVLimblab('read', [filepath filesep NEVlist(iNEV).name],'nosave');
            end
        end
    end
    fs = [500,1000,2000,10000,30000];
    for iNS = 1:5        
        for iFile = 1:length(eval(['NS' num2str(iNS) 'list']))
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]) = openNSxLimblab('read', [filepath filesep eval(['NS' num2str(iNS) 'list(iFile).name'])],'precision','short');
            if ~isempty(NEVNSxstruct(iFile).NEV.Data.SerialDigitalIO.TimeStampSec)
                digital_file_length_sec = NEVNSxstruct(iFile).NEV.Data.SerialDigitalIO.TimeStampSec(end);
                num_zeros = fix((digital_file_length_sec*fs(iNS)-size(NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data,2)));
            else %no digital data was collected
                num_zeros = 0; % no padding
            end
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data = [zeros(size(NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data,1),num_zeros) NEVNSxstruct(iFile).(['NS' num2str(iNS)]).Data];
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataPoints = NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataPoints + num_zeros;
            NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataDurationSec = NEVNSxstruct(iFile).(['NS' num2str(iNS)]).MetaTags.DataPoints/fs(iNS);
        end
    end    

    NSxfields = fieldnames(NEVNSxstruct);
    NSxfields = NSxfields(~strcmp(NSxfields,'NEV'));

    NEVNSx = NEVNSxstruct(1);
    NEVNSx.MetaTags.NumFilesConcat = 1;
    NEVNSx.MetaTags.FileStartSec = 0;
    NEVNSx.MetaTags.NEVlist = {NEVlist.name};
    NEVNSx.MetaTags.FileSepTime=[];
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
        %
        NEVNSx.MetaTags.FileSepTime(end+1,:)=[NEV1.MetaTags.DataDurationSec,NEV1.MetaTags.DataDurationSec+1];
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

    %% The following fields are not implemented
    % NEV1.Data.Tracking.TimeStamp    = [NEV1.Data.Tracking.TimeStamp, NEV2.Data.Tracking.TimeStamp];
    % NEV1.Data.Tracking.PointCount   = [NEV1.Data.Tracking.PointCount, NEV2.Data.Tracking.PointCount];
    % NEV1.Data.Tracking.X            = [NEV1.Data.Tracking.X, NEV2.Data.Tracking.X];
    % NEV1.Data.Tracking.Y            = [NEV1.Data.Tracking.Y, NEV2.Data.Tracking.Y];
    % NEV1.Data.Tracking.TimeStampSec = [NEV1.Data.Tracking.TimeStampSec, NEV2.Data.Tracking.TimeStampSec];
end
