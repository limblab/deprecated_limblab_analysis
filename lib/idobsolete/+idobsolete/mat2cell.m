function xcell = mat2cell(x,Ts)
% Utility to convert B or F polynomial from matrix to cell format. The
% format conversion is performed only in multi-input case (nu>1). This
% utility supports double format phase-out plan for IDPOLY.
% Trailing zeros (if Ts>0) or leading zeros (if Ts==0) are retained (R2012a
% onwards).

% Copyright 2009-2011 The MathWorks, Inc.

nu = size(x,1);
% Return cell array even in siso case, since internal storage format is
% always cell.

xcell = cell(1,nu);
for ku = 1:nu
   xvec = x(ku,:);   
   if Ts~=0
      xcell{ku} = xvec(1:find(xvec,1,'last'));
   else
      xcell{ku} = xvec(find(xvec,1,'first'):end);
   end
end
