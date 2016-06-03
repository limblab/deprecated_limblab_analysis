function elec_map = read_cmp(cmp_file, global_elec_num)
%read_cmp reads Blackrock .cmp files into Matlab
%
%   INPUTS:
%       cmp_file: string file path to .cmp file
%       gobal_elec_num: (Default: true) If true, elec_map is a Nx4 cell
%           array, where the third column is the numerical electrode ID
%           from 1-96. If false, the third column is a 1x2 cell with the
%           alphabetical Bank value (A,B,C) and the pin number on that bank
%   OUTPUTS:
%
%   EXAMPLES:
%   elec_map = read_cmp(cmp_file) returns a
%   cell array or array depending on whether the electrodes are named or
%   numbered.  If named, elec_map is a cell array with each element
%   corresponding to a different electrode.
% 
%   Within each cell and in the case when electrodes are numbered, 
%   the first column contains the column of the electrode on the
%   array, the second column contains the row of the electrode on the array
%   the third column contains the channel number and the last column
%   contains either the electrode name or the electrode number.
%   
%   The most common usage is with global_elec_num set to true, so it is
%   default. I added the option to return the bank and electrode as
%   separate values, rather than a single number ranging from 1-96.
%
%   Modified by Matt Perich on 2/1/16.

if nargin < 2
    global_elec_num = true;
end

fileID = fopen(cmp_file,'r');
text = char(fread(fileID,inf,'char'))';
fclose(fileID);

text = regexp(text,'\n','split');
elec_map = {};
for iText = 1:length(text)
    temp_text = text{iText};
    temp_text = temp_text(1:strfind(text{iText},char(13))-1);
    temp_text = regexp(temp_text,'\t','split');
    if length(temp_text)>4 && length(temp_text{2}>0) && ~strcmp(temp_text{1}(1),'/') && str2double(temp_text{5})~=0
        switch temp_text{3}
            case 'A'
                bank = 0;
            case 'B'
                bank = 32;
            case 'C'
                bank = 64;
        end
        if global_elec_num
            temp_elec_number = bank+str2double(temp_text{4});
        else
            temp_elec_number = {temp_text{3},str2double(temp_text{4})};
        end
        
        elec_map(end+1,:) = {str2double(temp_text{1}) str2double(temp_text{2}) temp_elec_number temp_text{5}};
    end
end
all_num = 1;
for iElec = 1:size(elec_map,1)
    if isnan(str2double(elec_map(iElec,4)))
        all_num = 0;
    end
end

if all_num
    elec_map_temp = elec_map;
    elec_map = [];
    for iElec = 1:size(elec_map_temp,1)
        elec_map(end+1,:) = [elec_map_temp(iElec,1) elec_map_temp(iElec,2)...
            elec_map_temp(iElec,3) str2double(elec_map_temp(iElec,4))];
    end
end