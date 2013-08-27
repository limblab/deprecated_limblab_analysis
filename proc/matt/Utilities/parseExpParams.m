function params = parseExpParams(filename)
% load parameter text file and parse it out

fid = fopen(filename,'r');

dontstop = true;
while dontstop
    line = fgetl(fid);
    if ~isempty(line)
        if line ~= -1
            line = strsplit(' ',line);
            if ~strcmpi(line{1},'%') %ignore comment lines
                params.(line{1}) = line(2:end);
            end
        else
            dontstop = false;
        end
    end
end

fclose(fid);