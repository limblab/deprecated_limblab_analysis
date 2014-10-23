function list = unit_list(varargin)
% UNIT_LIST(DATA) - gives a list of the unit ids contained in the datafile
%   LIST = UNIT_LIST(DATA) - returns LIST, a two column matrix containing
%   the channel number (column 1) and sort code (column 2) of every unit
%   that has >0 spikes in BDF structure DATA.
% UNIT_LIST(DATA,include_unsorted) - Same as above, second input includes
%   unsorted units in unit list if different from zero.

% $Id$

data = varargin{1};
include_unsorted = 0;
if length(varargin)>1
    include_unsorted = varargin{2};
end
if regexp(data.meta.filename, 'FAKE SPIKES')
    warning('BDF:fakeData', 'Using BDF with fake spike data');
end

L = size(data.units, 2);
list = [];

for i = 1:L
    if size(data.units(i).ts, 1) > 0
        list = [list; data.units(i).id];
    end
end

if ~isempty(list)
    list = list(list(:,2)~=255,:);

    if ~include_unsorted
        list = list(list(:,2)~=0,:);
    elseif include_unsorted==2
        list = list(list(:,2)==0,:);
    elseif include_unsorted==1
        %use whole list
    else
        disp('unrecognized code for including unsorted spikes')
    end
else
    warning('S1_ANALYSIS:BDF:UNIT_LIST:NoUnitsFound','No units found in the bdf')
end