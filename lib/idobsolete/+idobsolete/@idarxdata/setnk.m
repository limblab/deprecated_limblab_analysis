function D = setnk(D, nk)
% Update nk value.

%   Copyright 1986-2015 The MathWorks, Inc.

sz = size(nk);
[~, nb, nkold] = arxorder(D);
nbmax = max(nb(:));
b = D.B;
bnew = zeros(sz(1),sz(2),nbmax+max(nk(:)));
for ct1 = 1:sz(1)
   for ct2 = 1:sz(2)
      bnew(ct1,ct2,nk(ct1,ct2)+1:nk(ct1,ct2)+nb(ct1,ct2)) = eps;
   end
end

for ky = 1:sz(1)
   for ku = 1:sz(2)
      L1 = nk(ky,ku)+1;
      L2 = nk(ky,ku)+min(nbmax,nb(ky,ku));
      L1old = nkold(ky,ku)+1;
      L2old = nkold(ky,ku)+min(nbmax,nb(ky,ku));
      bnew(ky,ku,L1:L2) = b(ky,ku,L1old:L2old);
   end
end

D.B = bnew;
