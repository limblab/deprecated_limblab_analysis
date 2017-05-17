function sysOut = idarx(sys, varargin)
%IDPOLY  Converts IDPOLY into IDARX model.
%
%   SYS = IDARX(SYS) converts an ARX-form IDPOLY system SYS to the obsolete
%   IDARX form.
%     A(q) y(t) = B(q) u(t) + e(t)
%
%   The resulting model is represented by an object of class @idarx.
%
% See also IDPOLY, IDARX, IDNLARX, ARX, NLARX, POLYEST.

%   Copyright 2009-2011 The MathWorks, Inc.

if numel(sys.Data_)>1
   ctrlMsgUtils.error('Ident:transformation:idltiArray2idarx','idpoly')
elseif sys.Ts==0
   ctrlMsgUtils.error('Ident:idmodel:CTIDARX')
end

[~, ~, nc, nd, nf] = polyorder(sys.Data_);
if norm([nc nd nf],1)~=0
   ctrlMsgUtils.error('Ident:transformation:invalidIdpoly2Idarx')
end

% Copy meta data, algorithm and estimation info
Data = idarx(sys.Data_); 
sysOut = inherit(idarx.make(Data, iosize(sys.Data_)),sys);

if nargin>1
   sysOut = set(sysOut, varargin{:});
end
