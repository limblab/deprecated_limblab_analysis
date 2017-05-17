function idsimsd(varargin)%u,th,n,noise,ky)
%IDSIMSD Illustrates the uncertainty in simulated model responses.
%   OBSOLETE function. Use SIMSD instead. 
%    See HELP IDMODEL/SIMSD.
 
%   L.Ljung 7-8-87
%   Copyright 1986-2003 The MathWorks, Inc.

if nargin < 2
   disp('Usage: SIMSD(MODEL,INPUT)')
   disp('       SIMSD(MODEL,INPUT,ADD_NOISE,OUTPUTS)')
   disp('       ADD_NOISE one of ''no_noise'', ''noise''.')
   return
end
simsd(varargin{:})
 