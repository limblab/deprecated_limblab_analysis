function unit_list = parse_units(spikeguide)
% Quick and dirty replacement for 'unit_list.m' when using 'SD_glm_pds.m'
% with a 'binnedData' struct (classified/binned data for Nick's SD
% analysis) instead of a 'bdf' for input
%
% Should work with files that output 'binnedData.spikeguide' in the form
% 'ee[xx]u[y]'
% ...Or maybe I'll just make it super dumb and make it the unit index so it
% can count the column from 'binnedData.spikeratedata'

unit_list = zeros(length(spikeguide),1);

for i=1:length(spikeguide)
    
    unit_list(i) = i;
%     unit_list(i,1) = str2double(spikeguide(i,3:4));
%     unit_list(i,2) = str2double(spikeguide(i,6));
    
end

