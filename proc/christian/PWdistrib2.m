function [bin_bottom, binnedPW] = PWdistrib2(stim_array)

%stim_array = [ts ch I PW]

numbin      = 11;
binsize     = round(220/numbin);
bin_bottom  = 0:binsize:(numbin-1)*binsize;

chans     = unique(stim_array(:,2));
numchans = length(chans);

binnedPW = zeros(numbin,numchans);

for ch = 1:numchans
    
    ch_idx = stim_array(:,2)==chans(ch);
    PW = stim_array(ch_idx,4);
    
    for b = 1:numbin
        binnedPW(b,ch)= sum( (PW >= bin_bottom(b)) & (PW < bin_bottom(b) + binsize) );
    end
    
end

figure;
bar(bin_bottom,binnedPW);
