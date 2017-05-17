function sys = idss(oldsys, varargin)
% IDARX to IDSS conversion.

%   Copyright 1986-2011 The MathWorks, Inc.
[a,b,c,d,k,x0] = ssdata(oldsys);
lam = oldsys.NoiseVariance;
if norm(lam)==0
   k = zeros(size(k));
end
ts = oldsys.Ts;

[~, nu] = iosize(oldsys);
S = pmodel.ss(a,b,c,d,k);
sys = idpack.ssdata(S,ts);
sys.NoiseVariance = lam;
sys.Delay = oldsys.Delay;
sys.X0.Value = x0;
sys = setDefaultParSpec(sys, nu, size(a,1));

%sys = idss(a,b,c,d,k,x0,ts,'NoiseVariance',lam,varargin{2:end});
[na, nb, nk] = arxorder(oldsys);
ms = getarxms(na,nb,nk);
if any(any(isnan(ms.As))')
   ms.Cs = ms.As(1:size(ms.Cs,1),:);
end
S.a.Free = isnan(ms.As);
S.b.Free = isnan(ms.Bs);
S.c.Free = isnan(ms.Cs);
S.d.Free = isnan(ms.Ds);
S.k.Free = isnan(ms.Ks);
sys.Structure = S;
sys.X0.Free = isnan(ms.X0s);

%{
sys = set(sys,'As',ms.As,'Bs',ms.Bs,'Cs',ms.Cs,...
   'Ds',ms.Ds,'Ks',ms.Ks,'X0s',ms.X0s);
%}

covv = oldsys.Covariance;
if isequal(covv,[]), return, end
NewFree = isfree(S);
if any(any(isnan(ms.As))') && (~ischar(covv) && ~isempty(covv))
   L = eye(size(covv,1));
   KFree = [L; L];
   K = zeros(numel(NewFree),size(covv,1));
   K(NewFree,:) = KFree;
   sys.Covariance = preAndPostMult(covv,K,NewFree); % [[covv,covv];[covv,covv]];
else
   sys.Covariance = covv;
end
