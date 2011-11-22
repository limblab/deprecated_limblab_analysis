function array=readNKfile(inputPath)

if nargin
    fid=fopen(inputPath);
else
    [FileNameNK,PathNameNK]=uigetfile('*.*','select a file');
    fid=fopen(fullfile(PathNameNK,FileNameNK));
end

% N-K files should have a header two lines long.
headLine1=fgetl(fid);
headLine2=fgetl(fid);

% after that, should be pure numbers.
array=[];
m=1;
while ~feof(fid)
    tline=fgetl(fid);
    
    numbers=sscanf(tline,'%f \t%f \t%f \t%f \t%f \t%f \t%f');
    if ~isempty(numbers)
    	array=[array; numbers'];
    end
    m=m+1;
end

fclose(fid);

