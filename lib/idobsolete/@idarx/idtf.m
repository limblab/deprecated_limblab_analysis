function sys = idtf(oldsys, varargin)
% IDARX to IDTF conversion.

%   Copyright 2011-2012 The MathWorks, Inc.
OldData = oldsys.Data_;
na = arxorder(OldData);
if any(na(:)>0)
   sys = idtf(idpoly(oldsys)); return
end
Data = idtf(OldData);
if ~isempty(oldsys.EstimationInfo.DataInterSample)
   Data.InterSample = repmat(oldsys.EstimationInfo.DataInterSample,...
      [length(Data.Delay.Input),1]);
end
Data = setLastOperation(Data, {'convert','idarx'});
sys = inherit(idtf.make(Data, iosize(oldsys.Data_)), oldsys);

if nargin>1
   sys = set(sys, varargin{:});
end
