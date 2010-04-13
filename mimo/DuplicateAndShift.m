function DS_spikes = DuplicateAndShift(spikes,numlags)

    [numpts,Nin] = size(spikes);
    DS_spikes = zeros(numpts,Nin*numlags);

    for i = 1:Nin*numlags
        n = ceil(i/numlags);
        lag = mod(i-1,numlags);
        prepend = zeros(lag,1);
        DS_spikes(:,i) = [prepend; spikes(1:end-lag,n)];
    end

end