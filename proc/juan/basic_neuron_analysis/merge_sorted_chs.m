% 
% remove sorted units and channels with only one threshold crossing (seem
% to happen in old data files)
%
%   function bdf = merge_sorted_chs( bdf )
%
%

function bdf = merge_sorted_chs( bdf )


new_units                   = struct();

% do for all channels in the array
for i = 1:(bdf.units(end).id(1))
    
    % find the neurons that belong to this channel
    neurons_this_ch         = find(cell2mat(arrayfun(@(x) (x.id(1)==i),bdf.units,...
                                'uniformoutput',false)));
    
    % combine all threshold crossings 
    if ~isempty(neurons_this_ch)
        new_units(i).id     = [i 0];
        new_units(i).ts     = [];
        new_units(i).waveforms = [];
        for ii = 1:numel(neurons_this_ch)
            new_units(i).ts = [new_units(i).ts; bdf.units(neurons_this_ch(ii)).ts];
            new_units(i).waveforms = [new_units(i).waveforms; ...
                                        bdf.units(neurons_this_ch(ii)).waveforms];
        end
        % resort so the time stamps are ordered 
        [new_units(i).ts, indx] = sort(new_units(i).ts);
        new_units(i).waveforms = new_units(i).waveforms(indx,:);
    end
end


% update the units field
bdf.units                   = new_units;

% check if there's any empty channel and remove it
bdf.units( arrayfun(@(x) isempty(x.id),bdf.units) ) = [];
