function out = g_anova2(data)
% G_ANOVA -- runs a "general" two-way ANOVA
%
%   OUT = G_ANOVA2(DATA) runs a "general" two-way anova, meaning that it 
%       does not require that all categories have the same number of 
%       samples as the built-in matlab ANOVA function does.
%
%   DATA takes the form of a cell matrix where each cell contains a vector
%   representing one category of data.  Each element of the vector is an
%   individual sample.  (e.g., {[1 2 3 4], [1 2 3];
%                               [2 3 2],   [6 9 11]})
%
%   OUT returns an anova result structure.  The example data above returns:
%
%    SS: [2.8889 5.3333 8.2222] (within, between, total)
%    df: [2 6 8]                (within, between, total)
%    MS: [1.4444 0.8889]        (within, between)
%     F: 1.6250
%     p: 0.2729

[p,q] = size(data);
t = zeros(p,q);
xsq = cell(p,q);
sxsq = zeros(p,q);
n = zeros(p,q);

for a = 1:p
    for b = 1:q
        n(a,b) = length(data{a,b});
        t(a,b) = sum(data{a,b});
        xsq{a,b} = data{a,b}.^2;
        sxsq(a,b) = sum(xsq{a,b});
    end
end

N = sum(sum(n));
T = sum(sum(t));
Xm = T / N;

% SS calculations
SSt = sum(sum(sxsq)) - T.^2/N;
SSb = sum(sum(t.^2 ./ n)) - T.^2/N;
SSw = SSt - SSb;

SSr = sum(sum(t')'.^2 ./ sum(n')') - T.^2/N;
SSc = sum(sum(t).^2 ./ sum(n)) - T.^2/N;
SSi = SSb - SSr - SSc;

% df calculations
dfr = size(data,1) - 1;
dfc = size(data,2) - 1;
dfb = numel(data) - 1;
dfi = dfb - dfr - dfc;
dft = N - 1;
dfw = dft - dfb;

% MS calculations
MS = [SSr/dfr, SSc/dfc, SSi/dfi, SSw/dfw];
F = [MS(1)/MS(4), MS(2)/MS(4), MS(3)/MS(4)]; 
p = 1 - fcdf(F, [dfr dfc dfi], dfw);

out = struct('SS', [SSr SSc SSi SSb SSw SSt], ...
             'df', [dfr dfc dfi dfb dfw dft], ...
             'MS', MS, 'F', F, 'p', p);
         



