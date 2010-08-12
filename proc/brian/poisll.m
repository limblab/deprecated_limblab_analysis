function L = poisll(x, pds, ns)

ncells = length(pds);
pdcomps = [cos(pds); sin(pds)];


L = 0;
for cell = 1:ncells
    la = x(1)*pdcomps(1,cell) + x(2)*pdcomps(2,cell);
    ll = exp(-la) .* la.^ns(cell) ./ gamma(ns(cell)+1);
    L = L + log(ll);    
end


