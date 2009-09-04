function b = rand_spikes(bins, spikes)
% RAND_SPIKES returns a list of bins with SPIKES spikes shuffled into BINS
% bins

q = [1:bins; rand(1,bins)]';
sq = sortrows(q,2);

b = zeros(1,bins);
b(sq(1:spikes,1)) = 1;
