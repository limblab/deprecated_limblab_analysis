function pname = getDefaultParNames(D, varargin)
% Get default parameter names for IDARX models.

% Author(s): Rajiv Singh
% Copyright 2013 The MathWorks, Inc.
np = nparams(D);
[na, ~] = arxorder(D);
par = (1:np)';
pname = cell(np,1);
D1 = setp(D,par);
A = D1.A; B = D1.B; 
ny = size(na,1); [~,nu,nb] = size(B);
for ka = 1:max(na(:))+1
   for ky1 = 1:ny
      for ky2 = 1:ny
         pn = A(ky1,ky2,ka);
         if pn<0
            pname{abs(pn)} = ['-A',int2str(ka-1),'(',int2str(ky1),',',int2str(ky2),')'];
         end
      end
   end
end
for kb = 1:nb
   for ky1 = 1:ny
      for ku = 1:nu
         pn = B(ky1,ku,kb);
         if pn>0
            pname{pn} = ['B',int2str(kb-1),'(',int2str(ky1),',',int2str(ku),')'];
         end
      end
   end
end
