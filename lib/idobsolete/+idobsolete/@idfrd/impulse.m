function ymod = impulse(varargin)
% This command is obsolete. Estimate a nonparametric impulse response model
% using the IMPULSEEST command (with negative delay if you want to view
% the feedback effects) and then call the IMPULSE command on the resulting
% model.
%
% See also IMPULSEEST, DYNAMICSYSTEM/IMPULSE, DYNAMICSYSTEM/IMPULSEPLOT.

% Old help
%IMPULSE  Non-parametric estimation and plot of impulse response from data.
%
%   IMPULSE(DAT) estimates and plots the impulse response from the data set
%   DAT given as an IDDATA dataset or IDFRD model. The plot is shown over a
%   time grid that contains both negative and positive time values.
%
%   IMPULSE(DAT,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations as a region around zero. Any response
%   outside this region is considered to be significant. 
%
%   A significant response value for negative time value(s) is an
%   indication of feedback in data. For multi-input models, the impulse
%   response is computed by applying the impulse input to each input
%   channel independently. The IMPULSE command cannot be used for time
%   series data (data with no inputs) or continuous-time frequency response
%   data.
%
%   IMPULSE(DAT,T) uses the time vector specification in T (expressed in
%   the time units of DAT) for computing the impulse response. If T is a
%   scalar, the time from -T/4 to T is covered. T should be of the form
%   Ti:Ts:Tf where Ts is the data sample time. 
%
%   IMPULSE(DAT1, DAT2, DAT3,...,T) plots the impulse responses of multiple
%   IDDATA/IDFRD datasets DAT1, DAT2, DAT3, ... on a single plot. The time
%   vector T is optional.  You can also specify a color, line style, and
%   markers for each system, as in:
%      IMPULSE(DAT1,'r',DAT2,'y--',DAT3,'gx').
%
%   MOD = IMPULSE(DAT) returns the model of the impulse response, as an FIR
%   filter encapsulated by an IDTF model. The impulse response of MOD
%   plotted can be using IMPULSE(MOD). Note that MOD is a causal model
%   which has zero response for times t<0.
%
%   NMOD = IMPULSE(DAT,'noncausal') returns the non-causal model NMOD whose
%   impulse response produces the impulse response of DAT over a time range
%   that contains the negative time values. NMOD contains a negative value
%   for its InputDelay property. The plot shown by IMPULSE(DATA) is the
%   impulse response of NMOD.
%
%   The calculation of the impulse response from data is based on a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the
%   name/value pair IMPULSE( ....,'PW',NA) in the input argument list. NA
%   must be a positive integer.
%
%  See also DYNAMICSYSTEM/IMPULSE, IDDATA/STEP, CRA, IDDATA/COVF, SPA.

%   Copyright 1986-2012 The MathWorks, Inc.

ctrlMsgUtils.warning('Ident:analysis:iddataObsoleteImpulseStep','impulse','impulse')
no = nargout; ni = nargin;
for k = 1:length(varargin)
   if isa(varargin{k},'idfrd')
      varargin{k} = iddata(complexSymmetric(varargin{k}));
   end
end

if no==0
   ArgNames = cell(ni,1);
   for ct = 1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
end

varargin = [varargin,{'noncausal'}]; 
if nargout
   ymod = idarx(impulsestep('impulse',varargin{:}));
else
   impulsestep('impulse',varargin{:});
end
