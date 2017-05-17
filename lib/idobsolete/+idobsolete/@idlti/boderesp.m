function  [mag,phase,w,sdamp,sdphase] = boderesp(sys,w)
%BODERESP  Computes a model's frequency function,along with its standard deviation
% This method is obsolete. Use FREQRESP, BODE or IDLTI/SPECTRUM instead.

% old help:
%   [MAG,PHASE,W] = BODERESP(M)
%
%   where M is a model object (IDMODEL, IDPOLY, IDSS, IDFRD, or IDGREY).
%   MAG is the magnitude of the response and PHASE is the phase (in degrees).
%   W is the vector of frequencies for which the response is computed. These
%   can be specified by [MAG,PHASE,W] = BODERESP(M,W). The frequency unit is
%   angular frequency (rad/s or rad/M.TimeUnit).
%   Only frequencies up to the Nyquist frequency are considered.
%
%   If M has NY outputs and NU inputs, and W contains NW frequencies,
%   the MAG and PHASE are NY-by-NU-by-NW array such that MAG(ky,ku,k) gives
%   the response from input ku to output ky at the frequency W(k).
%
%   If M describes a time series, MAG is returned as its power spectrum and
%   PHASE will be identically zero.
%   Both discrete and continuous time models are handled.
%
%   To obtain the disturbance (noise) spectrum associated with the outputs
%   of the model M, use BODERESP(M('noise')).  To access a particular
%   input/output response use BODERESP(M(ky,ku)).
%
%   The standard deviations for the magnitude and phase are obtained by
%   [MAG,PHASE,W,SDMAG,SDPHAS] = BODERESP(M).
%
%   See also IDMODEL/BODE, FFPLOT, IDMODEL/NYQUIST and IDFRD.

%   L. Ljung 7-7-87,1-25-92
%   Copyright 1986-2011 The MathWorks, Inc.

if isnan(sys)
   mag = NaN; phase = NaN; w = NaN;
   sdamp = NaN; sdphase = NaN;
   ctrlMsgUtils.warning('Ident:idmodel:NaNParams')
   return
end
nu = size(sys,'nu');
timeseries =  nu==0;
ni = nargin;
if ni<2, w = []; end
DefaultFreq = isempty(w); % b.c. requirement; w = [] means generate frequency vector
Ts = abs(sys.Ts);
if ~isempty(w) && Ts>0
   w = w(w<=pi/Ts); % only up to Nyquist
   if isempty(w)
      ctrlMsgUtils.error('Ident:analysis:EmptyFrequency')
   elseif any(w>pi/Ts)
      ctrlMsgUtils.warning('Ident:dataprocess:freqAboveNyquist')
   end
end

if nargout>3
   if DefaultFreq
      [GC,w,gccov] = freqresp(sys);
   else
      [GC,w,gccov] = freqresp(sys,w);
   end
else
   if DefaultFreq
      [GC,w] = freqresp(sys);
   else
      [GC,w] = freqresp(sys,w);
   end
end

mag = abs(GC);
phase = (180/pi)*unwrap(atan2(imag(GC),real(GC)),[],3);
w = w(:);
if nargout<4, return, end
%
%   Now translate these covariances to those of abs(GC) and arg(GC)
%
if timeseries
   sdamp = sqrt(gccov); sdphase = zeros(size(gccov));
else
   if isempty(gccov)
      sdamp = []; sdphase = [];
   else
      C1 = gccov(:,:,:,1,1);
      C2 = gccov(:,:,:,2,2);
      C3 = gccov(:,:,:,1,2);
      sdamp = real(sqrt((real(GC).^2).*C1+2*((real(GC)).*(imag(GC))).*C3...
         +(imag(GC).^2).*C2))./abs(GC);
      sdphase = (180/pi)*sqrt((imag(GC).^2).*C1-2*((real(GC)).*imag(GC)).*C3...
         +(real(GC).^2).*C2)./(abs(GC).^2);
   end
end
