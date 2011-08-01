[FileName,PathName,FilterInde]=uigetfile('/home/limblab/Desktop/models','select a file');
fid=fopen(fullfile(PathName,FileName));

array=[];
while ~feof(fid)
    tline=fgetl(fid);
    numbers=sscanf(tline,'%f \t%f \t%f \t%f \t%f \t%f \t%f');
    if ~isempty(numbers)
    	array=[array; numbers'];
    end
end

fclose(fid);

