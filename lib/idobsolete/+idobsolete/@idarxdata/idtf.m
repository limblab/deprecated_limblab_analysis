function D2 = idtf(D, varargin)
% IDARX to IDTF conversion.
% Works only when IDARX represents an FIR model.

%   Author(s): Rajiv Singh
%   Copyright 2011-2012 The MathWorks, Inc.
[~,nb,nk] = arxorder(D);
[ny,nu] = iosize(D);
B = D.B;
den = num2cell(ones(ny,nu));
num = cell(ny,nu);
iod = max(0,nk-1);
nk = nk-iod;
for ky = 1:ny
   for ku = 1:nu
      num{ky,ku} = squeeze(B(ky,ku,iod(ky,ku)+(1:nb(ky,ku)+nk(ky,ku)))).';
   end
end

S = pmodel.tf.createMIMO(num,den,iod);
D2 = idpack.tfdata(S,D.Ts);
D2.NoiseVariance = D.NoiseVariance;
D2.Delay = D.Delay;

cov = D.Covariance;
if ~ischar(cov) && ~isempty(cov)
   np = size(cov,1);
   Ind = cell(ny,nu);
   Free2 = false(np+ny*nu,1);
   L = 0;
   for ky = 1:ny
      for ku = 1:nu
         Ind{ky,ku} = L + (1:nb(ky,ku));
         L = L+nb(ky,ku)+1;
      end
   end
   Ind = Ind.';
   Free2(cat(2,Ind{:})) = true;
   cov.Free  = Free2;
   D2.Covariance = cov;
end
