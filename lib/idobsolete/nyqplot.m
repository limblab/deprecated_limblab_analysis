function nyqplot(varargin)
%NYQPLOT Plots a Nyquist diagram of a frequency function.
%   OBSOLETE function. Use NYQUIST instead. See HELP IDMODEL/NYQUIST.

%   Copyright 1986-2011 The MathWorks, Inc.

if nargout == 0
   nyquist(varargin{:});
elseif nargout <= 2
   [fr,w] = freqresp(varargin{:});
else
   [fr,w,covfr] = freqresp(varargin{:});
end
 