function [arr_map, cer_map] = get_array_mapping(filepath)

% GET_ARRAY_MAPPING Generates a matrix of channel numbers which match the 
%       channel numbers outputted by unit_list.m, in the position in which
%       the channels are displayed in Central.
%   [ARR_MAP,CER_MAP] = GET_ARRAY_MAPPING(FILEPATH) returns the 10x10 matrix
%       ARR_MAP through the information from the Blackrock array mapping
%       file *.cmp. Zeros in ARR_MAP indicate that there are no channels in
%       that position. Non-zero elements in ARR_MAP are the channel numbers
%       for each electrode as they are outputted by unit_list.m. CER_MAP
%       returns the 10x10 matrix with the electrode numbers assigned by
%       Blackrock and as they are visible in Central's Spike Panel.
%   Example:
%   [ARR,CERB]=get_array_mapping('\\citadel.physiology.northwestern.edu\limblab\lab_folder\Animal-Miscellany\_Implant Miscellany\Blackrock Array Info\Array Map Files\1025-0597.cmp')
%   returns the array mapping in ARR, and the Blackrock assigned labels in
%   CERB


fileID = fopen(filepath);
arr_map = zeros(10,10); % I assume blackrock arrays are all 10x10
cer_map = zeros(size(arr_map));

while ~feof(fileID) % while feof does not return 1 (it does when the end of the file is reached)
    tline = fgets(fileID); % move down the file, ignore headers
        if (length(tline)==28) && (strcmp(tline(1:5),'//col')) % after this line the real array info starts
        while ~feof(fileID)
            tline = fgets(fileID) ;
            temp = textscan(tline,'%s');
            temp = temp{1};
            if ~isempty(temp)
                column_ID = str2num(char(temp(1)))+1; % blackrock assigns the column left to right, zero based.
                row_ID = 10-str2num(char(temp(2))); % blackrock assigns the row bottom to top, zero based.
                bank_ID = char(temp(3)); % bank ID is A, B, C or D. each bank has 32 pins.
                pin_ID = str2num(char(temp(4))); % pin number of current electrode
                elec_ID = sscanf(char(temp(5)),'%*[elec]%f'); % elec ID that is shown in Central's 'Spike Panel'. only the number part
                if bank_ID == 'A'
                    chan_ID = pin_ID; % channel ID is what we get from the unit_list.m file
                end
                if bank_ID == 'B'
                    chan_ID = pin_ID+32;
                end
                if bank_ID == 'C'
                    chan_ID = pin_ID+64;
                end
                if bank_ID == 'D'
                    chan_ID = pin_ID+92;
                end
                arr_map(row_ID,column_ID) = chan_ID;
                cer_map(row_ID,column_ID) = elec_ID;
            end
        end
    end
end 