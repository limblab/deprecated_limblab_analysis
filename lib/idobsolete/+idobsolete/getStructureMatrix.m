function Value = getStructureMatrix(Data, Prop)
% Compute IDSS structure matrix value from its parameter object.

%   Copyright 2010 The MathWorks, Inc.

if numel(Data)>1
   ctrlMsgUtils.error('Ident:general:getObsoletePropValArray',[upper(Prop),'s'])
end
if ~strcmpi(Prop,'X0')
   Par = Data.Structure.(Prop);
else
   Par = Data.X0;
   if size(Par.Value,2)>1
      % fetch only last column
      Par = subsrefParameter(Par,{':',size(Par.Value,2)});
   end
end
Value = Par.Value;
Value(Par.Free) = NaN;

