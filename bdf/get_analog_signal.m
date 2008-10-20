function analog_data = get_analog_signal(data, name)
% GET_ANALOG_SIGNAL     Extracts analog signal from datastructure
%   ANALOG_DATA = GET_ANALOG_SIGNAL(DATA, NAME) finds the analog signal
%   from DATA.raw.analog with the name NAME and returns its values.
%   ANALOG_DATA is two columns where the first column is the timestamps and
%   the second column is the datapoints
%

% $Id$

achan_index = find(strcmp(data.raw.analog.channels, name));

a = data.raw.analog.data{achan_index};
t = (0:length(a)-1)' / data.raw.analog.adfreq + data.raw.analog.ts{achan_index};

analog_data = [t a];