function sys = setPolyFormat(sys,Value)
%SETPOLYFORMAT Specify format for B and F polynomials of multi-input IDPOLY model.
%
%   SYS = setPolyFormat(SYS, 'double') converts the B and F polynomials of
%   multi-input IDPOLY model SYS from cell matrices to double matrices. You
%   might want to do this for backward compatibility reasons, since product
%   versions older than 8.0 used double matrices multi-input data for B and
%   F polynomials. The above call designates the model to be working in a
%   backward compatibility mode. Model display shows a message that the
%   model has been configured to work in a backward-compatibility mode.
%
%   SYS = setPolyFormat(SYS, 'cell') performs the reverse operation: it
%   converts double format to cell format. The cell arrays contain Nu
%   double vectors, one for each model input (Nu = number of inputs).
%
%   Note:
%   1. Single-input, single-output models always use double row vectors to
%   store B and F polynomial values.
%   2. Multi-output models always used cell arrays. You cannot switch
%   format to double for multioutput models.
%
%   To see the effect of incompatibility, suppose you have the following
%   code in an existing MATLAB file from a release before ver 8.0:
%       %----------------- START CODE ----------------------------
%       m = arx(data, [3 2 2 1 1]); % 2-input ARX model estimation
%       Zeros1 = roots(m.B(1,:))
%       %------------------ END CODE -----------------------------
%   In ver 8.0 or later, the second command which extracts the
%   value of the B polynomial using m.B throws error since the model uses
%   cell array to store "B" values. To use the double format without
%   errors, configure the model to operate in "backward compatibility"
%   model by calling setPolyFormat command after creation, so that the new
%   code looks like:
%       %----------------- START CODE ----------------------------
%       m = arx(data, [3 2 2 1 1]); % 2-input ARX model estimation
%       m = setPolyFormat(m, 'double') % enforce double format
%       Zeros1 = roots(m.B(1,:))
%       %------------------ END CODE -----------------------------
%
%   The alternative to using the backward compatibility mode is to update
%   any code that operates on B and F values. For the above example, the
%   alternative code (recommended) would be:
%       %----------------- START CODE ----------------------------
%       m = arx(data, [3 2 2 1 1]); % 2-input ARX model estimation
%       Zeros1 = roots(m.B{1})
%       %------------------ END CODE -----------------------------
%
% See also IDPOLY, POLYDATA.

%  Copyright 2009-2015 The MathWorks, Inc.

if ischar(Value)
   if strcmpi(Value,'cell')
      Value = 0;
   elseif strcmpi(Value, 'double')
      if size(sys,1)>1
         ctrlMsgUtils.error('Ident:idmodel:setPolyFormatCheck2')
      end
      Value = 1;
   else
      ctrlMsgUtils.error('Ident:idmodel:setPolyFormatCheck1')
   end
else
   ctrlMsgUtils.error('Ident:idmodel:setPolyFormatCheck1')
end

for ct = 1:prod(getArraySize(sys))
   sys.Data_(ct).BFFormat = Value;
end
