function kk = isempty(m)
%IDARX/ISEMPTY
%   ISEMPTY(Model)
%   Returns TRUE (1) if the model is empty

%   Copyright 1986-2010 The MathWorks, Inc.

na = m.na; nb = m.nb; b = m.B; nk = m.nk; 
kk = false;
%return
if isempty(na)
   kk = true;
elseif sum(sum([na,nb]))==0
   kk = true;
elseif ~any(na(:)) && ~any(nk(:)) && isequal(b,zeros(size(b,1),size(b,2),1))
   kk = true;
end
