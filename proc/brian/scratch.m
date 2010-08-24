% Hack script to open llfits plots, get the data, find the peaks, and draw
% a plot of the peaks.

files = ls('llfits/*.fig');

peaks = zeros(length(files), 2);

for f = 1:length(files)
    fn = deblank(['llfits/' files(f,:)]);
    open(fn);
    a = gca;
    c = get(a,'Children');
    
    t = get(c(1),'XData');
    llr = get(c(1), 'YData');
    close(gcf);
    
    llrs = smooth(llr,11);
    peaks(f,:) = [min(llrs) t(find(min(llrs) == llrs, 1, 'first'))];
end

    