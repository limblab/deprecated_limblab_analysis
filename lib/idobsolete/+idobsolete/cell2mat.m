function x = cell2mat(xcell,Ts)
% Utility to convert B or F polynomial from cell format to double matrix.
% Dimensions are reconciled by zero padding.

% Copyright 2009-2014 The MathWorks, Inc.

nu = numel(xcell);
rownc = cellfun(@(x)size(x,2),xcell);
x = zeros(nu,max(rownc));
for ku = 1:nu
   if isempty(xcell{ku})
      continue;
   end
    if Ts~=0
        x(ku,1:rownc(ku)) = xcell{ku};
    else
        x(ku,end-rownc(ku)+1:end) = xcell{ku};
    end
end
