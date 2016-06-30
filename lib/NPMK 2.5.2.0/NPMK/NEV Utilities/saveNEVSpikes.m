function saveNEVSpikes(spikeStruct, newFileName, modifiedNEVFileName)

% saveNEVSpikes
% 
% Allows the user to save a modified version of the spike waveforms into a 
% NEV file. This can be very useful for those who want to save MATLAB
% sorted or rethresholded NEV data back into the NEV file. It also re-saves
% the other data in the original NEV file into the new NEV. A
%
% Use saveNEVSpikes(spikeStruct, newFileName)
%
%   spikeStruct: The structure containing the spike data needed to be
%                saved. The structure format must match the one that 
%                openNEV outputs.
%                spikeStruct.TimeStamp: contains all the timestamps
%                spikeStruct.Electrode: contains all the electrode #s
%                spikeStruct.Unit: contains all the sorted unit #s
%                spikeStruct.Waveform: Spike waveforms, containing 48 data
%                                      points
%
%   newFileName: The file name of the new NEV file.
%                DEFAULT: User will be prmpted for a file name.
%
%   Example 1:
%   saveNEVSpikes(spikeStruct, 'sortedNEV';
%
%   In the example above, the user will be prompted to select a NEV file.
%   The data stored in spikeStruct will be saved into sortedNEV alongside 
%   the data in the user-selected NEV file. The new NEV will be saved as
%   sortedNEV.nev
%
%   Kian Torab
%   ktorab@blackrockmicro.com
%   Blackrock Microsystems
%   Version 1.0.0.0
%

%% Validating the input argument
if ~exist('spikeStruct', 'var')
    disp('spikeStruct is a required input argument.');
    return;
end

if ~exist('newFileName', 'var')
    newFileName = input('What file name would you like to use to save the new NEV? ', 's');
    if isempty(newFileName)
        disp('A filename is required.');
        return;
    end
end

%% Opening the file and reading header
% [dataFilename dataFolder] = getFile('*.nev', 'Choose a NEV that you would like to modify.');
% fileFullPath = [dataFolder dataFilename];
fileFullPath = modifiedNEVFileName;
[dataFolder, ~, ~] = fileparts(modifiedNEVFileName);
FID = fopen(fileFullPath, 'r', 'ieee-le');

%% Calculating the header bytes
BasicHeader = fread(FID, 20, '*uint8');
headerBytes  = double(typecast(BasicHeader(13:16), 'uint32'));
dataPacketByteLength = double(typecast(BasicHeader(17:20), 'uint32'));

%% Calculating the data file length and eeking to the beginning of the file
fseek(FID, 0, 'eof');
endOfDataByte = ftell(FID);
dataByteLength = endOfDataByte - headerBytes;
numberOfPackets = double(dataByteLength) / double(dataPacketByteLength);

%% Reading the header binaries and saving it for future
fseek(FID, 0, 'bof');
headerBinaries = fread(FID, headerBytes, '*uint8');

%% Reading the data binaries
dataBinaries = fread(FID, [dataPacketByteLength numberOfPackets], '*uint8', 0);

%% Finding what PacketIDs have the desired channels
% PacketIDs = uint16(zeros(1,size(dataBinaries,2)));
PacketIDs = dataBinaries(5:6,:);
PacketIDs = typecast(PacketIDs(:),'uint16');

%% Only capturing all the binary lines that contain non-spike events, such
% as comments, tracking, patient trigger, etc.
newDataBinaries = dataBinaries(:, PacketIDs == 0 );

%% Extracting the timestamps of all the above non-spike events
% dataTimestamps = uint32(zeros(1,size(newDataBinaries,2)));
dataTimestamps = newDataBinaries(1:4,:);
dataTimestamps = typecast(dataTimestamps(:),'uint32')';

%% Converting all the user supplied data into binaries for saving into the
% new structure
% newSpikesBinary = uint8(zeros(dataPacketByteLength,size(spikeStruct.Electrode,2)));
timestamps = reshape(typecast(uint32(spikeStruct.TimeStamp), 'uint8'),4,[])';
electrodes = reshape(typecast(uint32(spikeStruct.Electrode), 'uint8'),4,[])';
electrodes = electrodes(:,[1 2]);
units = typecast(uint8(spikeStruct.Unit), 'uint8')';
ones_vec = uint8(ones(size(spikeStruct.Electrode,2),1));
waveforms = reshape(typecast(int16(spikeStruct.Waveform(:)), 'uint8'),...
    size(spikeStruct.Waveform(:,1),1)*2,[])';

newSpikesBinary = [timestamps electrodes units ones_vec waveforms]';
% for idx = 1:size(spikeStruct.Electrode,2)
%     newSpikesBinary(:,idx) = [typecast(uint32(spikeStruct.TimeStamp(idx)), 'uint8'),...
%                          typecast(uint16(spikeStruct.Electrode(idx)), 'uint8'),...
%                          typecast(uint8(spikeStruct.Unit(idx)), 'uint8'),...
%                          1,...
%                          typecast(uint16(spikeStruct.Waveform(:,idx))', 'uint8')]';
% end

%% Processing data
% Concatinating the user supplied data (non-spike) and the user supplied data
newDataBinaries = [newDataBinaries, newSpikesBinary];

% Ranking the spike and re-ranking the data for saving (timestamp descending)
allTimestamps = [dataTimestamps, spikeStruct.TimeStamp];
[~, ranking] = sort(allTimestamps);
newDataBinaries = newDataBinaries(:,ranking);

fclose(FID);

%% Saving the new NEV containig the desired channels
delete([dataFolder '\' newFileName])
FIDw = fopen([dataFolder '\' newFileName], 'w+', 'ieee-le');
fwrite(FIDw, headerBinaries, 'char');
fwrite(FIDw, newDataBinaries, 'char');

fclose(FIDw);