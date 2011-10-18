function array=readBrainReaderFile_function(inputPath)

if nargin
    fid=fopen(inputPath);
else
    [FileNameBR,PathNameBR]=uigetfile('*.txt','select a file');
    fid=fopen(fullfile(PathNameBR,FileNameBR));
end

array=[];
m=1;
while ~feof(fid)
    tline=fgetl(fid);
    % if the startup tag is present, utilize it.  Otherwise, assume the
    % start of the file was the start of the recording if done pseudoOnline
    % (i.e. an LFP file).
    
    % need to account for multiple occurrences of the plexon recording
    % startup tag per file (and for the fact that we might not know which
    % section of a multi-section recording we actually want).
    
    if ~isempty(regexp(tline,'Plexon recording startup','once'))
        fprintf(1,'Plexon recording startup flag detected at line %d\n',m)
        array=[];
    end
    numbers=sscanf(tline,'%f \t%f \t%f \t%f \t%f \t%f \t%f');
    if ~isempty(numbers)
    	array=[array; numbers'];
    end
    m=m+1;
end

fclose(fid);

