function [filename] = filenameFromBDF(bdf)
%FILENAMEFROMBDF Returns filename from bdf
%   Quick routine to extract just the filename from a bdf meta data
% 
filename=bdf.meta.filename;
[tok rm]=strtok(filename,'\');
while ~isempty(rm)
    [filename rm]=strtok(rm,'\');    
end

end

