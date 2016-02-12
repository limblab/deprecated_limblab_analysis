function d = tmi( spikes, hand, bins )
%TMI Temporal mutial information
%   d = tmi( spikes, hand, bins )
%   Peak > 0 means hand leads spikes
%

% $Id$

d = zeros(1,length(bins));
j = 1;

for i = bins
    if i == 0
        d(j) = mi(spikes', hand);
    elseif i > 0
        local_spikes = spikes(i:length(spikes));
        local_hand   = hand(1:(length(hand)-i+1),:);
        d(j) = mi(local_spikes, local_hand);
    else % bins < 0
        local_spikes = spikes( 1:(length(spikes)+i) );
        local_hand   = hand( (-i+1):length(hand),: );
        d(j) = mi(local_spikes, local_hand);
    end
    
    j = j+1;
end


