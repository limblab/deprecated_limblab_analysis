function [trains, channels] = get_sorted_units(bdf)
%
%% Returns a cell array of spike times from sorted units in 'bdf'
%
% Input: a bdf struct
% Output:
%   'trains':   [n_sorted_units x n_spikes], [iUnit timestamps]
%   'channels': [n_sorted_units x 2], [iChan iUnit]
%

min_spikes = 5000;
n_units  = length(bdf.units);

neur_ind = [];

% For each unit, check if sorted
for iUnit = 1:n_units
   channel  = bdf.units(iUnit).id(1);
   unitType = bdf.units(iUnit).id(2);
   n_spikes = length(bdf.units(iUnit).ts);
   
   if unitType > 0 && unitType < 255 && n_spikes >= min_spikes  && channel ~= 143
       % If unit is sorted
       neur_ind = [neur_ind iUnit];
   end
end

n_sorted = length(neur_ind);
trains   = cell(n_sorted,1);
channels = zeros(n_sorted,2);
% For each sorted unit, collect its timestamps, keeping track of channels
for n_unit = 1:n_sorted
    iUnit = bdf.units(neur_ind(n_unit));
    iChan = iUnit.id(1);
    iCell = iUnit.id(2);
    channels(n_unit,:) = [iChan iCell];
    trains{n_unit} = iUnit.ts;  
end

% Plot n_unit vs. channel
if 0
    figure
    plot(channels(:,1),channels(:,2),'o')
    ylim([0 max(channels(:,2))+1])
    xlim([0 100])
end
