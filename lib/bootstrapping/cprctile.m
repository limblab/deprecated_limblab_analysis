function out = cprctile(in, prct)
% CPRCTILE Percentiles of a sample in a circular dataset
%   OUT = CPRCTILE(IN, P) Works identically to PRCTILE but accounts for the
%   boundry conditions on IN assuming that it is circular (0 - 2*pi)

in = sort(mod(in, 2*pi));
out = prct;

mid = mod(circ_mean(in), 2*pi);
midx = find(in <= mid, 1, 'last');

mod_in = mod(in - mid,2*pi);
mod_in = mod_in - 2*pi*(mod_in > pi);

for i = 1:length(out);
    if prct(i) == 50
        out(i) = mid;
    else 
        out(i) = prctile(mod_in, prct(i)) + mid;
    end
end


% for i = 1:length(out)
%     p = prct(i)/100;
%     if p == 0.5
%         out(i) = mid;
%     else
%         delta = fix((p-.5)*length(in));
%         if midx+delta < 1
%             out(i) = in(midx+delta+length(in)) - 2*pi;
%         elseif midx+delta > length(in)
%             out(i) = in(midx+delta-length(in)) + 2*pi;
%         else
%             out(i) = in(midx+delta);
%         end
%     end
% end



