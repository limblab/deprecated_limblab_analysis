function crosstalk = read_crosstalk(crosstalk_file,num_electrodes)
% read .txt file from Blackrock containing crosstalk information
%
% Assumes that comments/headers and denoted with asterisks
% Assumes that crosstalk is defined as either weak, moderate, or strong
%   Gives a numerical value of 1, 2, or 3, respectively. 0 is for no
%   crosstalk, and in this case the electrode pair won't be in text file
%
% INPUTS:
%   crosstalk_file is string path to a .txt Blackrock crosstalk file
%   num_electrodes is the number of electrodes. Defaults to 96.
%
% OUTPUTS:
%   crosstalk: NxN matrix where N=num_electrodes. Each row represents a
%     reference electrode, each column represents a tested electrode. The
%     value represents the amount of crosstalk between 0 and 3 (see above).
%
%   For example, if crosstalk(3,12) = 3, then elec3 has a strong
%     crosstalk with elec12
% 
% Written by Matt Perich on 2/17/2016

% DEFINE PARAMETERS
strength_values = {'None',0; ...
    'Weak',1; ...
    'Moderate',2; ...
    'Strong',3};
% SET DEFAULTS
if nargin < 2
    num_electrodes = 96;
end

crosstalk = zeros(num_electrodes);

% open file
fid = fopen(crosstalk_file,'r');


dontstop = true;
while dontstop % loop along all lines
    line = fgetl(fid); % get the current line
    if ~isempty(line)
        if line ~= -1 % -1 means it's reached the end of the file
            parts = strsplit(strrep(line,' ',''),'\t'); % remove spaces and split on tabs
            if isempty(parts{1}) || ~strcmpi(parts{1}(1),'*') % comments are asterisks
                if ~isempty(parts{1}) % this is the beginning of a new electrode
                    ref_elec = str2double(parts{1});
                end
                test_elec = str2double(parts{2});
                if ref_elec <= num_electrodes && test_elec <= num_electrodes
                    % convert weak, strong, etc to numerical value
                    ctk_value = strength_values{strcmpi(strength_values(:,1),parts{3}),2};
                    crosstalk(ref_elec,test_elec) = ctk_value;
                end
            end
        else % end of the file
            dontstop = false;
        end
    end
end
fclose(fid);