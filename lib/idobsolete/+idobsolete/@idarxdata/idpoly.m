function D2 = idpoly(D, varargin)
% IDARX to IDPOLY conversion.

%   Copyright 1986-2014 The MathWorks, Inc.

[na,nb,nk] = arxorder(D);
[ny,nu] = iosize(D);
A = D.A; B = D.B;
Ap = cell(ny,ny);
Bp = cell(ny,nu);

for ky = 1:ny
   for ky2 = 1:ny
      Ap{ky,ky2} = squeeze(A(ky,ky2,1:na(ky,ky2)+1)).';
   end
   
   for ku = 1:nu
      Bp{ky,ku} = squeeze(B(ky,ku,1:nb(ky,ku)+nk(ky,ku))).';
   end
end

S = pmodel.polynomial(Ap,Bp,[],[],[],zeros(ny,nu));
S = pmodel.polynomial.fixNkInB(S,D.Ts,nk);
D2 = idpack.polydata(S,D.Ts);
D2.NoiseVariance = D.NoiseVariance;
ISB = D.InterSample;
if nu>1 && isscalar(ISB), ISB = repmat(ISB,[nu 1]); end
D2.InterSample = ISB;
D2.Delay = D.Delay;

cov = D.Covariance;
if ~ischar(cov) && ~isempty(cov)
   np = size(cov,1);
   Dcov = setParameterVector(D,1:np);
   Dcov.Covariance = [];
   D2cov = idpoly(Dcov);
   par2 = getParInfo(D2cov,'Value');
   % make cov column order to agree with the new parameter order 
   cov = permute(cov, abs(par2));
   Free = cov.Free;
   par3 = find(par2(Free)<0);
   par4 = find(par2(Free)>=0);
   if isa(cov,'idpack.FactoredCovariance')
      cov.R(par3,par4) = -cov.R(par3,par4);
      cov.R(par4,par3) = -cov.R(par4,par3);
   else
      Value = getValue(cov,@(x,y)x/y);
      Value(par3,par4) = -Value(par3,par4);
      Value(par4,par3) = -Value(par4,par3);
      cov = setValue(cov,Value);
   end
   D2.Covariance = cov;
end
