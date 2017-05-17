function [y,ysd]=idsim(data, th, varargin)%data,th,init,inhib)
%IDSIM  Simulates a given dynamic system.
%   OBSOLETE function. Use SIM instead. Type "help idParametric/sim" for
%   more information.

%   L. Ljung 10-1-86, 9-9-94
%   Copyright 1986-2013 The MathWorks, Inc.

y=[];ysd=[];
if nargin < 4, inhib = 0;end
if nargin<3,init=[];end
if nargin<2
   disp('Usage: Y = SIM(MODEL,UE)')
   disp('       [Y,YSD] = SIM(MODEL,UE,INIT)')
   return
end

if nargout <= 1;
   y = sim(th, data, varargin{:});
else 
   [y,ysd] = sim(th, data, varargin{:});
end
