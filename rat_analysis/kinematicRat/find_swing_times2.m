function swing_times = find_swing_times2(endpoint_marker, lowpeak_mm, peakdist_ms)

%graphing based on x distance, where a fully extended limb is the most
%positive value and swing lasts from most positive to most negative
swing_times = {};


inverted = 1.01*max(endpoint_marker(:, 1)) - endpoint_marker(:, 1);
if lowpeak_mm==0
    hpk = endpoint_marker(1, 1)/2; 
    lpk = inverted(1, 1)/2; 
  
else
    hpk = endpoint_marker(1, 1)+lowpeak_mm; 
    lpk = inverted(1, 1)+lowpeak_mm; 
end

    [high_peaks, high_locs] = findpeaks(endpoint_marker(:, 1), 'MinPeakDistance', peakdist_ms, 'MinPeakHeight', hpk);
    
    [low_peaks, low_locs] = findpeaks(inverted, 'MinPeakDistance', peakdist_ms, 'MinPeakHeight', lpk);
%check that there are the correct number of peaks - high and low
%if length(high_locs)~=length(low_locs)
    disp('Check your high and low peaks')
    figure(1); %swing peaks/low_peaks
    findpeaks(inverted, 'MinPeakDistance', peakdist_ms, 'MinPeakHeight', lpk)
    figure(2); %stance peaks/high_peaks
    findpeaks(endpoint_marker(:, 1), 'MinPeakDistance', peakdist_ms, 'MinPeakHeight', hpk)
    rm = char(input('Remove values from fig1 array? y/n', 's'));
    if rm=='y'
        idx = input('Which indices to remove?');
        low_locs(idx) = [];
    end
    rm = char(input('Remove values from fig2 array? y/n', 's'));
    if rm=='y'
        idx = input('Which indices to remove?');
        high_locs(idx) = [];
    end
%end



%start at first full swing
if high_locs(1)>low_locs(1)
    low_locs = low_locs(2:end);
end

%pair off values in order, making sure they are low then high
for i=1:length(low_locs)
    disp(1)
    if i<=length(high_locs)
    if high_locs(i)<low_locs(i) %they are in the right order
        disp(2)
        swing_times{end+1} = [high_locs(i) low_locs(i)];
        
    end
    end
end


end