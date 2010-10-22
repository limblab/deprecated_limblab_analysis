% figure4.m

% Generates firgure 4b

clear all;
load timeglm

t = -5:.01:5;

out = [out_a; out_m; out_p; out_t1; out_t2];
summary = [summary_a, summary_m, summary_p, summary_t1, summary_t2];
counts = [length(summary_a) length(summary_m) length(summary_p) length(summary_t1) length(summary_t2)]; 

s = [];
for i = 1:length(summary)
    s = [s summary{i}];
end

% Find the cells that meet our criterion
cutoff = mean(out,2) - 3*sqrt(var([out(:,1:200) out(:,801:1001)],[],2));
good_cells = min(out,[],2) < cutoff;

%out = out(good_cells,:);
%summary = summary{good_cells};

lags = zeros(length(summary), 3);
for i = 1:length(summary)
    lags(i,:) = [summary{i}.peaktime summary{i}.halfwidth];
end

total = 0;
tmp = [];
for i = 1:length(counts)
    tmp = [tmp; sortrows(lags(total+1:total+counts(i),:),1)];
    total = total + counts(i);
end
lags = tmp;

lags = lags(good_cells,:);
lags = lags(lags(:,3)-lags(:,2) < 2, :);
errorbar(1:length(lags), lags(:,1), lags(:,2), lags(:,3), 'k.');



