function Par = setStructureMatrix(Par, StructureMatrix, Name)
% Update parameter object's Value and Free properties using structure
% matrix.

%   Copyright 2010 The MathWorks, Inc.

if ~isequal(size(Par.Value),size(StructureMatrix))
   ctrlMsgUtils.error('Ident:idmodel:idssStructureMatrixSize',Name)
end
Free = isnan(StructureMatrix);
Par.Value(~Free) = StructureMatrix(~Free);
Par.Free = Free;
