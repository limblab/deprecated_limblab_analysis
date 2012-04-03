function decoderType=decoderTypeFromLogFile(inputPath)

if nargin >= 1
    fid=fopen(inputPath);
else
    [FileNameBR,PathNameBR]=uigetfile('*.txt','select a file');
    fid=fopen(fullfile(PathNameBR,FileNameBR));
end

% modify so that it exits gracefully if called with an invalid file name
% from the command line, but if it errors when called as a sub-function, go
% ahead and throw.
% if fid < 0
%     disp('not a valid file')
%     return
% end

% preserve modelLine in case the NeuralType flag isn't present (as it isn't
% for older recordings)
modelLine=fgetl(fid);

decoderType='';
while ~feof(fid)
    decoderType=regexp(fgetl(fid), ...
        '(?<=NeuralType.*)LFP|(?<=NeuralType.*)Spike','match','once');
    if ~isempty(decoderType)
        break
    end
end
fclose(fid);

if isempty(decoderType)
    if ~isempty(regexp(modelLine,'[0-9]*(?=poly[0-9])','once'))
        decoderType='LFP';
    elseif ~isempty(regexp(modelLine,'spikedecoder','once'))
        decoderType='Spike';
    end
end


