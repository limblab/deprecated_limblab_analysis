[FileNameBR,PathNameBR,FilterIndexBR]=uigetfile('*.txt','select a file');
fid=fopen(fullfile(PathNameBR,FileNameBR));

array=[];
while ~feof(fid)
    tline=fgetl(fid);
    numbers=sscanf(tline,'%f \t%f \t%f \t%f \t%f \t%f \t%f');
    if ~isempty(numbers)
    	array=[array; numbers'];
    end
end

fclose(fid);

