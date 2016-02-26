function params = parseExpParams(filename)
% load parameter text file and parse it out
% 
% I should finish this documentation someday.

fid = fopen(filename,'r');

dontstop = true;
while dontstop
    line = fgetl(fid);
    if ~isempty(line)
        if line ~= -1
            line = strsplit(line,' ');
            if ~strcmpi(line{1},'%') %ignore comment lines and empty lines
                pname = line{1};
                vals = line(2:end);
                
                % if its all numbers, we don't want to put it in cell
                % check to see what each entry is
                getTypes = zeros(size(vals));
                for iVal = 1:length(vals)
                    % remove any decimals, since they aren't digits and
                    % then check to see if all are numbers
                    getTypes(iVal) = all(isstrprop(strrep(vals{iVal},'.',''),'digit'));
                end
                
                if all(getTypes)
                    params.(pname) = cellfun(@str2num,vals);
                else % at least one value is character
                    if length(vals) == 1
                        params.(pname) = vals{1};
                    else
                        params.(pname) = vals;
                    end
                end
            end
        else
            dontstop = false;
        end
    end
end

fclose(fid);