maxcx = 0;
maxcy = 0;

n_count = 0;

mcx = zeros(448,1);
mcy = zeros(448,1);

for f = 1:6
    spikes = all_data{f,3}.spikeratedata;
    xcur = all_data{f,3}.cursorposbin(:,1);
    ycur = all_data{f,3}.cursorposbin(:,2);
    for n = 1:size(spikes,2)
        n_count = n_count+1;
        [cx] = xcorr(spikes(:,n),xcur,15,'coeff');
        [cy] = xcorr(spikes(:,n),ycur,15,'coeff');
        
        [~,Ix] = max(abs(cx));
        [~,Iy] = max(abs(cy));
        
        mcx(n_count) = abs(cx(Ix));
        mcy(n_count) = abs(cy(Iy));
        
        maxcx = maxcx*(n_count-1)/n_count + abs(cx(Ix))/n_count;
        maxcy = maxcy*(n_count-1)/n_count + abs(cy(Iy))/n_count;
        
    end
end