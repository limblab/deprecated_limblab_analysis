function array=readBrainReaderFile_function(inputPath)

if nargin
    fid=fopen(inputPath);
else
    [FileNameBR,PathNameBR]=uigetfile('*.txt','select a file');
    fid=fopen(fullfile(PathNameBR,FileNameBR));
end

array=[];
m=1;
flagCount = 0;
while ~feof(fid)
    tline=fgetl(fid);
    % if the startup tag is present, utilize it.  Otherwise, assume the
    % start of the file was the start of the recording if done pseudoOnline
    % (i.e. an LFP file).
    
    % need to account for multiple occurrences of the plexon recording
    % startup tag per file (and for the fact that we might not know which
    % section of a multi-section recording we actually want).
    
    if ~isempty(regexp(tline,'Plexon recording startup|Cerebus recording startup','once'))
        fprintf(1,'%s recording startup flag detected at line %d\n', ...
            regexp(tline,'Plexon|Cerebus','match','once'),m)
        flagCount = flagCount + 1;
        if flagCount == 1
            array=[];
        end
    end
    numbers=sscanf(tline,'%f \t%f \t%f \t%f \t%f \t%f \t%f');
    if ~isempty(numbers)
    	array=[array; numbers'];
    end
    m=m+1;
end
fclose(fid);

% through a bug in the BRcode (I assume), it is actually possible to get
% two consecutive lines with the same timestamp value.  Since this probably
% represents some kind of infarcted behavior brought on by an out-of-range
% decoded velocity, just delete the offending line.

repeaterLines=find(diff(array(:,7))==0);
if ~isempty(repeaterLines)
    array(repeaterLines+1,:)=[];
end
