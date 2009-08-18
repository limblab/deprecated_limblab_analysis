function out = g_anova(data)
% G_ANOVA -- runs a "general" one way ANOVA
%
%   OUT = G_ANOVA(DATA) runs a "general" anova, meaning that it does not
%       require that all categories have the same number of samples as the
%       built-in matlab ANOVA function does.
%
%   DATA takes the form of a cell array where each cell contains a vector
%   representing one category of data.  Each element of the vector is an
%   individual sample.  (e.g., {[1 2 3], [2 2 3], [4 4 3]})
%
%   OUT returns an anova result structure.  The example data above returns:
%
%    SS: [2.8889 5.3333 8.2222] (within, between, total)
%    df: [2 6 8]                (within, between, total)
%    MS: [1.4444 0.8889]        (within, between)
%     F: 1.6250
%     p: 0.2729

xsq = cell(1,length(data));
tj  = zeros(1,length(data));
nj  = zeros(1,length(data));
xj  = zeros(1,length(data));
ssq = zeros(1,length(data));

for i=1:length(data)
    xsq{i} = data{i}.^2;
    tj(i) = sum(data{i});
    nj(i) = length(data{i});
    xj(i) = mean(data{i});
    ssq(i) = sum(xsq{i});
end

T = sum(tj);
N = sum(nj);

T_rat = T.^2 / N;         % quantity I
tssq  = sum(ssq);         % quantity II
ssqw  = sum(tj.^2 ./ nj); % quantity III

SSb = ssqw - T_rat;
SSw = tssq - ssqw;
SSt = tssq - T_rat;

SS = [SSb SSw SSt];
df = [length(data)-1, sum(nj-1), sum(nj)-1];
MS = [SSb/df(1), SSw/df(2)];
F = MS(1) / MS(2);

out = struct('SS', SS, 'df', df, 'MS', MS, 'F', F, 'p', 1-fcdf(F,df(1), df(2)));

