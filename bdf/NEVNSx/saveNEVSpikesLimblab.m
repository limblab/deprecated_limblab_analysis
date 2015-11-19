function saveNEVSpikesLimblab(NEV, filepath, newFileName)

%%
% Saves a .nev file from NEV data structure
% Works with File Spec 2.1 & 2.2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Use saveNEV(NEV, fname, 'report').
% 
%   NEV:          The data structure holding the NEV structure
%
% All following input arguments are optional. Input arguments can be in any order.
%
%   fname:        Name of the file to be saved.
%                 DEFAULT: input file name is used followed by '.out.nev'
%
%   'report':     Will show a summary report if user passes this argument.
%                 DEFAULT: will not show report.
%
%   'HeaderOnly': Only the NEV header will be written to disk
%                 DEFAULT: will record all NEV fields
%
%   Original Author: Ehsan Azar
%
%   Contributors: 
%   Kian Torab, Blackrock Microsystems, kianabc@kianabc.com
%
%   Version 1.0.0.1
%

fname = [filepath newFileName];
saveNEVver = '1.0.0.1';

%% Validating the input arguments. Exit with error message if error occurs.
HeaderOnly = false;
% HeaderOnly = false;
% for i=1:length(varargin)
%     inputArgument = varargin{i};
%     if strcmpi(inputArgument, 'report')
%         Report = inputArgument;
%     elseif strcmpi(inputArgument, 'HeaderOnly')
%         HeaderOnly = true;
%     else
%         temp = inputArgument;
%         if length(temp)>3 && strcmpi(temp(end-3),'.')
%             fname = inputArgument;
%         else
%             disp(['Invalid argument ''' inputArgument ''' .']);
%             clear variables;
%             return;
%         end
%     end
% end


%% Give all input arguments a default value. All input argumens are
%  optional.
if ~exist('Report', 'var');      Report = 'noreport'; end
if ~exist('fname', 'var');       fname = [fullfile(NEV.MetaTags.FilePath, NEV.MetaTags.Filename) '.out.nev']; end
if exist(fname, 'file') == 2
    disp('The file exists, it will be overwritten');
end

if strcmpi(Report, 'report')
    disp(['saveNEV version ' saveNEVver])
end

%% Writing Basic Header from NEV structure into file.
tic;

spikeLen = size(NEV.Data.Spikes.Waveform, 1);
if ~HeaderOnly
    if (spikeLen * 2 ~= NEV.MetaTags.PacketBytes - 8)
        disp('Wrong spike length');
        return;
    end
end

if isfield(NEV.Data.Comments, 'Comments')
    if (size(NEV.Data.Comments.Comments, 2) > NEV.MetaTags.PacketBytes - 12)
        disp('Comment length too long');
        return;
    end
end


FID = fopen(fname, 'w', 'ieee-le');
if (FID <= 0)
    disp('Can not access file');
    return;
end

fwrite(FID, NEV.MetaTags.FileTypeID(1:8));
fwrite(FID, [str2double(NEV.MetaTags.FileSpec(1)) str2double(NEV.MetaTags.FileSpec(3))], 'uint8');
fwrite(FID, bin2dec(NEV.MetaTags.Flags), 'uint16');
ExtHeaderCount = 0; % number of extended headers
if isfield(NEV, 'ArrayInfo')
    if (isfield(NEV.ArrayInfo, 'ElectrodeName'))
        ExtHeaderCount = ExtHeaderCount + 1;
    end
    if (isfield(NEV.ArrayInfo, 'ArrayComment'))
        ExtHeaderCount = ExtHeaderCount + 1;
    end
    if (isfield(NEV.ArrayInfo, 'ArrayCommentCont'))
        ExtHeaderCount = ExtHeaderCount + 1;
    end
    if (isfield(NEV.ArrayInfo, 'MapFile'))
        ExtHeaderCount = ExtHeaderCount + 1;
    end
end
if ~isempty(NEV.ElectrodesInfo)
    if (isfield(NEV.ElectrodesInfo(1), 'ElectrodeID'))
        ExtHeaderCount = ExtHeaderCount + length(NEV.ElectrodesInfo);
    end
    if (isfield(NEV.ElectrodesInfo(1), 'ElectrodeLabel'))
        ExtHeaderCount = ExtHeaderCount + length(NEV.ElectrodesInfo);
    end
    if (isfield(NEV.ElectrodesInfo(1), 'HighFreqCorner'))
        ExtHeaderCount = ExtHeaderCount + length(NEV.ElectrodesInfo);
    end
end
if (isfield(NEV, 'IOLabels'))
    ExtHeaderCount = ExtHeaderCount + length(NEV.IOLabels);
end
if (isfield(NEV, 'NSAS'))
    ExtHeaderCount = ExtHeaderCount + length(NEV.NSAS);
end
if (isfield(NEV, 'VideoSyncInfo'))
    ExtHeaderCount = ExtHeaderCount + length(NEV.VideoSyncInfo);
end
if (isfield(NEV, 'ObjTrackInfo'))
    ExtHeaderCount = ExtHeaderCount + length(NEV.ObjTrackInfo);
end
fExtendedHeader = 336 + ExtHeaderCount * 32;

fwrite(FID, fExtendedHeader, 'uint32');
fwrite(FID, NEV.MetaTags.PacketBytes, 'uint32');
fwrite(FID, NEV.MetaTags.TimeRes, 'uint32');
fwrite(FID, NEV.MetaTags.SampleRes, 'uint32');
fwrite(FID, NEV.MetaTags.DateTimeRaw(1:8), 'uint16');
fwrite(FID, NEV.MetaTags.Application(1:32), 'uint8');
fwrite(FID, NEV.MetaTags.Comment(1:256), 'uint8');
fwrite(FID, ExtHeaderCount, 'uint32');

%% Writing ExtendedHeader information
if isfield(NEV, 'ArrayInfo')
    if (isfield(NEV.ArrayInfo, 'ElectrodeName'))
        fwrite(FID, 'ARRAYNME');
        fwrite(FID, NEV.ArrayInfo.ElectrodeName(1:24), 'uint8');
    end
    if (isfield(NEV.ArrayInfo, 'ArrayComment'))
        fwrite(FID, 'ECOMMENT');
        fwrite(FID, NEV.ArrayInfo.ArrayComment(1:24), 'uint8');
    end
    if (isfield(NEV.ArrayInfo, 'ArrayCommentCont'))
        fwrite(FID, 'CCOMMENT');
        fwrite(FID, NEV.ArrayInfo.ArrayCommentCont(1:24), 'uint8');
    end
    if (isfield(NEV.ArrayInfo, 'MapFile'))
        fwrite(FID, 'MAPFILE');
        fwrite(FID, NEV.ArrayInfo.MapFile(1:24), 'uint8');
    end
end
for ii = 1:length(NEV.ElectrodesInfo)
    if (isfield(NEV.ElectrodesInfo(1), 'ElectrodeID'))
         fwrite(FID, 'NEUEVWAV');
         fwrite(FID, NEV.ElectrodesInfo(ii).ElectrodeID, 'uint16');
         fwrite(FID, NEV.ElectrodesInfo(ii).ConnectorBank - 'A' + 1, 'uint8');
         fwrite(FID, NEV.ElectrodesInfo(ii).ConnectorPin, 'uint8');
         fwrite(FID, NEV.ElectrodesInfo(ii).DigitalFactor, 'uint16');
         fwrite(FID, NEV.ElectrodesInfo(ii).EnergyThreshold, 'uint16');
         fwrite(FID, NEV.ElectrodesInfo(ii).HighThreshold, 'int16');
         fwrite(FID, NEV.ElectrodesInfo(ii).LowThreshold, 'int16');
         fwrite(FID, NEV.ElectrodesInfo(ii).Units, 'uint8');
         fwrite(FID, NEV.ElectrodesInfo(ii).WaveformBytes, 'uint8');
         fwrite(FID, zeros(10, 1), 'uint8');
    end
    if (isfield(NEV.ElectrodesInfo(1), 'ElectrodeLabel'))
        fwrite(FID, 'NEUEVLBL');
        fwrite(FID, NEV.ElectrodesInfo(ii).ElectrodeID, 'uint16');
        fwrite(FID, NEV.ElectrodesInfo(ii).ElectrodeLabel(1:16), 'uint8');
        fwrite(FID, zeros(6, 1), 'uint8');
    end
    if (isfield(NEV.ElectrodesInfo(1), 'HighFreqCorner'))
        fwrite(FID, 'NEUEVFLT');
        fwrite(FID, NEV.ElectrodesInfo(ii).ElectrodeID, 'uint16');
        fwrite(FID, NEV.ElectrodesInfo(ii).HighFreqCorner, 'uint32');
        fwrite(FID, NEV.ElectrodesInfo(ii).HighFreqOrder, 'uint32');
        fwrite(FID, NEV.ElectrodesInfo(ii).HighFilterType, 'uint16');
        fwrite(FID, NEV.ElectrodesInfo(ii).LowFreqCorner, 'uint32');
        fwrite(FID, NEV.ElectrodesInfo(ii).LowFreqOrder, 'uint32');
        fwrite(FID, NEV.ElectrodesInfo(ii).LowFilterType, 'uint16');
        fwrite(FID, zeros(2, 1), 'uint8');
    end
end

if isfield(NEV, 'IOLabels')
    for ii = length(NEV.IOLabels):-1:1
        fwrite(FID, 'DIGLABEL');
        fwrite(FID, NEV.IOLabels{ii}(1:16), 'uint8');
        fwrite(FID, ii - 1, 'uint8');
        fwrite(FID, zeros(7, 1), 'uint8');
    end
end

if isfield(NEV, 'NSAS')
    for ii = 1:length(NEV.NSAS)
        fwrite(FID, 'NSASEXEV');
        fwrite(FID, NEV.NSAS.Freq, 'uint16');
        fwrite(FID, NEV.NSAS.DigInputConf, 'uint8');
        fwrite(FID, NEV.NSAS.AnalCh1Conf, 'uint8');
        fwrite(FID, NEV.NSAS.AnalCh1Detect, 'uint16');
        fwrite(FID, NEV.NSAS.AnalCh2Conf, 'uint8');
        fwrite(FID, NEV.NSAS.AnalCh2Detect, 'uint16');
        fwrite(FID, NEV.NSAS.AnalCh3Conf, 'uint8');
        fwrite(FID, NEV.NSAS.AnalCh3Detect, 'uint16');
        fwrite(FID, NEV.NSAS.AnalCh4Conf, 'uint8');
        fwrite(FID, NEV.NSAS.AnalCh4Detect, 'uint16');
        fwrite(FID, NEV.NSAS.AnalCh5Conf, 'uint8');
        fwrite(FID, NEV.NSAS.AnalCh5Detect, 'uint16');
        fwrite(FID, zeros(6, 1), 'uint8');
    end
end
if isfield(NEV, 'VideoSyncInfo')
    for ii = 1:length(NEV.VideoSyncInfo)
        fwrite(FID, 'VIDEOSYN');
        fwrite(FID, NEV.VideoSyncInfo(ii).SourceID, 'uint16');
        fwrite(FID, NEV.VideoSyncInfo(ii).SourceName(1:16));
        fwrite(FID, NEV.VideoSyncInfo(ii).FrameRateFPS, 'single');
        fwrite(FID, zeros(2, 1), 'uint8');
    end
end
if isfield(NEV, 'ObjTrackInfo')
    for ii = 1:length(NEV.ObjTrackInfo)
        fwrite(FID, 'TRACKOBJ');
        fwrite(FID, NEV.ObjTrackInfo(ii).TrackableType, 'uint16');
        fwrite(FID, NEV.ObjTrackInfo(ii).TrackableID, 'uint32');
        fwrite(FID, NEV.ObjTrackInfo(ii).TrackableName(1:16));
        fwrite(FID, zeros(2, 1), 'uint8');
    end
end

if fExtendedHeader ~= ftell(FID)
    disp('Header structure corrupted!');
    fclose(FID);
    return;    
end

if HeaderOnly
    fclose(FID);
    return;
end

%% Writing data packets to NEV file

% create the index of all data
% the order here affects only for events with same timestamp, this order
% follows the way file is written currently

% ts = [NEV.Data.Spikes.TimeStamp NEV.Data.SerialDigitalIO.TimeStamp ...
%     NEV.Data.VideoSync.TimeStamp NEV.Data.Comments.TimeStamp  ...
%     NEV.Data.Tracking.TimeStamp NEV.Data.PatientTrigger.TimeStamp ...
%     NEV.Data.Reconfig.TimeStamp];

ts = [NEV.Data.Spikes.TimeStamp];

[~, idx] = sort(ts);
if strcmp(Report, 'report')
    pass = (~isempty(NEV.Data.Spikes.TimeStamp));
    disp(['start recording total of ' num2str(length(ts)) ' events of length ' ...
        num2str(NEV.MetaTags.PacketBytes) ' bytes in ' num2str(pass) ' passes']);
end

if strcmp(Report, 'report')
    disp('Initializing file ...');
end
fwrite(FID, zeros(length(ts) * NEV.MetaTags.PacketBytes, 1, 'uint8'));
clear ts;

pass = 0;
passIdx = find(idx <= length(NEV.Data.Spikes.TimeStamp));
if (~isempty(passIdx))
    pass = pass + 1;
    if strcmp(Report, 'report')
        disp(['pass ' num2str(pass) ': Recording ' num2str(length(passIdx)) ' spikes ...']);
    end
    nxtIdx = find(diff(passIdx) ~= 1);
    nxtIdx(end+1) = length(passIdx);
    start = 1;
    for ii = 1:length(nxtIdx) % for each chunk
        offset = fExtendedHeader + (passIdx(start) - 1) * NEV.MetaTags.PacketBytes;
        fseek(FID, offset - (NEV.MetaTags.PacketBytes - 4), 'bof');
        fwrite(FID, NEV.Data.Spikes.TimeStamp(start:nxtIdx(ii)), 'uint32', NEV.MetaTags.PacketBytes - 4);
        fseek(FID, offset + 4 - (NEV.MetaTags.PacketBytes - 2), 'bof');
        fwrite(FID, NEV.Data.Spikes.Electrode(start:nxtIdx(ii)), 'uint16', NEV.MetaTags.PacketBytes - 2);
        if (~isempty(NEV.Data.Spikes.Unit))
            fseek(FID, offset + 6 - (NEV.MetaTags.PacketBytes - 1), 'bof');
            fwrite(FID, NEV.Data.Spikes.Unit(start:nxtIdx(ii)), 'uint8', NEV.MetaTags.PacketBytes - 1);
        end
        fseek(FID, offset + 8 - (NEV.MetaTags.PacketBytes - spikeLen * 2), 'bof');
        fwrite(FID, NEV.Data.Spikes.Waveform(:, start:nxtIdx(ii)), [num2str(spikeLen) '*int16'], NEV.MetaTags.PacketBytes - spikeLen * 2);
        start = nxtIdx(ii) + 1;
    end
    idx = idx - length(NEV.Data.Spikes.TimeStamp);
end
%% Display how fast the function was executed.
if strcmp(Report, 'report')
    disp(['The save time for NEV file was ' num2str(toc, '%0.5f') ...
        ' seconds in ' num2str(pass) ' passes']);
end
fclose(FID);

