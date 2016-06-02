function [peak, width, good_peak, peakness, peak_height] = peak_analysis(d,t)
    sd = smooth(d, 21)';
    dd = d - sd;
    if var(sd) > var(dd)*5
        good_peak = 1;
        peak_start = find(sd > mean(sd), 1, 'first');
        peak_end = find(sd > mean(sd), 1, 'last');
        width = peak_end - peak_start;
    else 
        good_peak = 0;
        width = 0;
    end
    peak = t(sd==max(sd));
    peakness = var(sd) / var(dd);
    peak_height = max(sd);
end