function ymod = step(varargin)
% This command is obsolete. Estimate a nonparametric impulse response model
% using the IMPULSEEST command (with negative delay if you want to view
% the feedback effects) and then call the STEP command on the resulting
% model. 
%
% See also IMPULSEEST, DYNAMICSYSTEM/STEP, DYNAMICSYSTEM/STEPPLOT.

%STEP  Non-parametric estimation and plot of step response from data.
%
%   STEP(DAT) estimates and plots the step response from the data set
%   DAT given as an IDDATA dataset or IDFRD model. The plot is shown over a
%   time grid that contains both negative and positive time values.
%
%   STEP(DAT,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations as a region around zero. Any response
%   outside this region is considered to be significant. 
%
%   For multi-input models, the step response is computed by applying the
%   step input to each input channel independently. The STEP command cannot
%   be used for time series data (data with no inputs) or continuous-time
%   frequency response data.
%
%   STEP(DAT,T) uses the time vector specification in T (expressed in
%   the time units of DAT) for computing the step response. If T is a
%   scalar, the time from -T/4 to T is covered. T should be of the form
%   Ti:Ts:Tf where Ts is the data sample time. 
%
%   STEP(DAT1, DAT2, DAT3,...,T) plots the step responses of multiple
%   IDDATA/IDFRD datasets DAT1, DAT2, DAT3, ... on a single plot. The time
%   vector T is optional.  You can also specify a color, line style, and
%   markers for each system, as in:
%      STEP(DAT1,'r',DAT2,'y--',DAT3,'gx').
%
%   STEP(DAT, 'InputLevel', [U1;U2])
%   STEP(DAT, T, 'InputLevel', [U1;U2]) 
%   uses a step from level U1 to level U2 to generate the step response.
%   For multiinput models the levels may be different for different inputs,
%   by letting the InputLevel matrix be 2-by-NU, where NU = number of input
%   channels in DAT.
%
%   MOD = STEP(DAT) returns the model of the step response, as an FIR
%   filter encapsulated by an IDTF model. The step response of MOD can be
%   plotted using STEP(MOD). Note that MOD is a causal model which has zero
%   response for times t<0 (unless a nonzero value for input level U1 is
%   used)
%
%   NMOD = STEP(DAT,'noncausal') returns the non-causal model NMOD whose
%   step response produces the step response of DAT over a time range that
%   contains the negative time values. NMOD contains a negative value for
%   its InputDelay property. The plot shown by STEP(DATA) is the step
%   response of NMOD.
%
%   The calculation of the step response from data is based on a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the
%   name/value pair STEP( ....,'PW',NA) in the input argument list. NA
%   must be a positive integer.
%
%  See also DYNAMICSYSTEM/STEP, IDDATA/IMPULSE, CRA, IDDATA/COVF, SPA.

%   Copyright 1986-2012 The MathWorks, Inc.

ctrlMsgUtils.warning('Ident:analysis:iddataObsoleteImpulseStep','step','step')
no = nargout; ni = nargin;
for k = 1:ni
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
   ymod = idarx(impulsestep('step',varargin{:}));
else
   impulsestep('step',varargin{:});
end
