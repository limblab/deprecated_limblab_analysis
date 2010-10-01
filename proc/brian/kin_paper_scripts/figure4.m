% figure4.m

% Generates firgure 4b

clear all;
load ../timeglm

t = -5:.01:5;

out = [out_a; out_m; out_p; out_t1; out_t2];
summary = [summary_a, summary_m, summary_p, summary_t1, summary_t2];

s = [];
for i = 1:length(summary)
    s = [s summary{i}];
end

% Find the cells that meet our criterion
cutoff = mean(out,2) - 2*var(out,[],2);
good_cells = min(out,[],2) < cutoff;

%out = out(good_cells,:);
%summary = summary{good_cells};

lags = zeros(length(summary), 3);
for i = 1:length(summary)
    lags(i,:) = [summary{i}.peaktime summary{i}.halfwidth];
end

errorbar(1:length(summary), lags(:,1), lags(:,2), lags(:,3), 'k.');
    


