function decoderType=decoderTypeFromLogFile(inputPath)

if nargin >= 1
    fid=fopen(inputPath);
else
    [FileNameBR,PathNameBR]=uigetfile('*.txt','select a file');
    fid=fopen(fullfile(PathNameBR,FileNameBR));
end

decoderType='';
while ~feof(fid)
    decoderType=regexp(fgetl(fid), ...
        '(?<=NeuralType.*)LFP|(?<=NeuralType.*)Spike','match','once');
    if ~isempty(decoderType)
        break
    end
end
fclose(fid);




