function s = get_unit( data, channel, unit )
% GET_UNIT - timestamps for a particular unit
%   S = GET_UNIT( DATA, CHANNEL, UNIT) returns the list of timestamps S for
%   a particular unit contained in BDF DATA.  CHANNEL contains the channel
%   of the unit, and UNIT contains the sort code.
%
%   This will throw an exception of the specified unit cannot be found;
%   however, if the unit is defined but contains no spikes, it will return
%   a null list with no error.

% $Id$

if regexp(data.meta.filename, 'FAKE SPIKES')
    warning('BDF:fakeData', 'Using BDF with fake spike data');
end

unit_num = -1;
num_units = size(data.units, 2);

try
    for i = 1:num_units
        if all(data.units(i).id == [channel unit])
            unit_num = i;
            break
        end
    end
catch
    error('Specified unit does not exist in bdf.');
end

if unit_num == -1
    error('Specified unit does not exist in bdf.');
end

s = data.units(unit_num).ts;
