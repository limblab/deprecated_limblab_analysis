function [pos_mi, mis] = batch_mi(bdf, sig)

units = unit_list(bdf);
pos_mi = zeros(length(units), 4);

mis = zeros(length(units), 201);

tic; 
for i = 1:length(units)
    et = toc;
    chan = units(i,1);
    unit = units(i,2);
    
    disp(sprintf('%s: %d of %d (%d-%d)\tET: %f', sig, i, length(units), chan, unit, et));

    s = get_unit(bdf, chan, unit);
    b = train2bins(s, .001); % 1ms bins
    b = b(1000:end); % drop points before begin mi
    if strcmp(sig, 'vel')
        v = bdf.vel(:,2:3);
    elseif strcmp(sig, 'pos')
        v = bdf.pos(:,2:3);
        v = v - repmat(mean(v), size(v,1), 1);
    else
        error('Unknown signal: %s', sig);
    end

    if (length(b) > length(v))
        b = b(1:size(v));
    else
        v = v(1:length(b),:);
    end
    
    breakpoint = floor(length(b)/2);
    v1 = v(1:breakpoint,:);
    v2 = v(1+breakpoint:end,:);
    b1 = b(1:breakpoint);
    b2 = b(1+breakpoint:end);
    
    d1 = tmi(b1, v1, -1000:10:1000);
    d2 = tmi(b2, v2, -1000:10:1000);
    
    t = -1000:10:1000;
    t = t.*0.001;
    
    %figure; plot(t,d); title(sprintf('Pos MI: %d - %d', chan, unit));
    
    bls = zeros(1,10);
    for j = 1:10
        test_spikes = rand_spikes(length(b), sum(b));
        bls(j) = mi(test_spikes', v);
    end
    
    baseline = mean(bls);
    
    [peak1 peak_width good_cell1] = peak_analysis(d1,t);
    [peak2 peak_width good_cell2] = peak_analysis(d2,t);
    if good_cell1 && good_cell2
        pos_mi(i,:) = [chan, unit, peak1, peak2];
    else
        pos_mi(i,:) = [chan, unit, NaN, NaN];
    end
    
    %mis(i,:) = d;
end


