function sys = idpoly(oldsys, varargin)
% IDARX to IDPOLY conversion.

%   Copyright 1986-2012 The MathWorks, Inc.
Data = idpoly(oldsys.Data_);
Data = setLastOperation(Data, {'convert','idarx'});
sys = inherit(idpoly.make(Data, iosize(oldsys.Data_)), oldsys);
if nargin>1
   sys = set(sys, varargin{:});
end
