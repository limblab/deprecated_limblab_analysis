function plotPDBox(varargin)

A = [];
G = [];

% Build vectors to plot
for i = 1:length(varargin)
    pd = varargin{i};
    A = [A; pd(:,2)];
    G = [G; i*ones(length(pd),1)];
end

boxplot(A,G);