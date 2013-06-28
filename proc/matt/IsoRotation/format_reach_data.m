function dout = format_reach_data(din)
% Converts Anil's reach data format to Brian's Reach data format
% 
% Anil's Format: 4 column matrix where rows are reaches, column 3 is number
% of spikes, column 4 is reach direction
%
% Brian's Format: cell array where each cell represents a direction.  Each
% cell contains a vector where each element is the number of spikes for
% that particular reach

ndir = max(din(:,4));

dout = cell(1,ndir);
for i = 1:ndir
    dout{i} = din( din(:,4)==i, 3)';
end
