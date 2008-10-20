function list = unit_list(data)
% UNIT_LIST(DATA) - gives a list of the unit ids contained in the datafile
%   LIST = UNIT_LIST(DATA) - returns LIST, a two column matrix containing
%   the channel number (column 1) and sort code (column 2) of every unit
%   that has >0 spikes in BDF structure DATA.

% $Id$

L = size(data.units, 2);
list = [];

for i = 1:L
    if size(data.units(i).ts, 1) > 0
        list = [list; data.units(i).id];
    end
end
