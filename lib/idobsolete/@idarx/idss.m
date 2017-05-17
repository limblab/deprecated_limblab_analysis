function sys = idss(oldsys, varargin)
%IDSS Constructs or converts to a state-space model with identifiable parameters.
%
%  Construction:
%     SYS = IDSS(A,B,C,D)
%     SYS = IDSS(A,B,C,D,K,X0,Ts)
%     SYS = IDSS(A,B,C,D,K,X0,Ts,'Property',Value,..)
%
%    creates a state-space model structure of the form:
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%    A, B, C, D and K are the state-space matrices. X0 is the initial
%    condition, and Ts is the sample time. SYS is an object of class
%    @idss.
%
%    The input arguments K, X0 and Ts are optional. When not specified,
%    their default values are K = zeros(Nx,Ny), X0 = zeros(Nx,1), and Ts
%    = 1, where Nx = number of states and Ny = number of outputs. Use
%    NaNs to denote unknown matrix values. Property-value pairs may be
%    used to specify various properties of the model such as
%    input/output names, units etc. For a full list of IDSS model
%    properties, type GET(IDSS).
%
%  Continuous-time Models:
%   Using Ts = 0 creates a continuous-time model:
%      dx/dt  = A x(t) + B u(t) + K e(t) ;      x[0] = X0
%        y(t) = C x(t) + D u(t) + e(t)
%
%   SYS = IDSS creates an empty IDSS object of sample time = -1.
%   SYS = IDSS(D) specifies a static gain matrix D.
%
%  Arrays of identified state-space models:
%    You can create arrays of state-space models by using ND arrays for
%    A,B,C,D. The first two dimensions of A,B,C,D define the number of
%    states, inputs, and outputs, while the remaining dimensions specify
%    the array sizes. For example,
%       sys = idss(rand(2,2,3,4),[2;1],[1 1],0)
%    creates a 3x4 array of SISO state-space models. You can also use
%    indexed assignment and STACK to build SS arrays:
%       % Create 2x1 array of SISO models
%       sys = idss(zeros(1,1,2))
%       % Assign 1st model
%       sys(:,:,1) = idss(rand(2),rand(2,1),rand(1,2),1,rand(2,1))
%       % Assign 2nd model
%       sys(:,:,2) = idss(-1)
%       % Add 3rd model to array
%       sys = stack(1,sys,idss(rand(5),rand(5,1),rand(1,5),0,rand(5,1),[],0.1))
%
%  Creating IDSS Model by Estimation:
%    An IDSS model with estimated values of its matrices can be created
%    by using the estimation commands SSEST and N4SID on time- or
%    frequency-domain data. If you want to configure your model
%    structure in a specific way before estimation, such as fixing some
%    coefficients to known values, specifying initial guesses for
%    unknown parameters or specifying parameter bounds, you can take a
%    multi-step approach:
%     1. Create an IDSS model structure SYS using this constructor.
%     2. Configure properties of SYS. Use SYS.Structure to modify the
%        parameter constraints.
%     3. Estimate parameters using SSEST: SYS = SSEST(DATA, SYS, OPTIONS);
%
%  Conversion:
%    SYS2 = IDSS(SYS) converts any dynamic system SYS to identified state
%    space form by computing a state-space realization of SYS. The
%    resulting SYS2 is of class @idss.
%
%    SYS2 = IDSS(SYS, 'split') treats the last Ny input channels of SYS
%    as noise channels of SYS2. SYS must be a TF, SS or ZPK model of
%    Control System Toolbox. SYS must have Ny output and Nu input
%    channels such that Nu>=Ny. The subsystem SYS(:,Ny+1:Nu) must
%    contain nonzero feedthrough term.
%
%  See also SSDATA, SSEST, N4SID, PEM, IDGREY, IDPOLY, IDPROC, IDTF,
%  DYNAMICSYSTEM, SSESTOPTIONS.

%   Copyright 1986-2012 The MathWorks, Inc.
Data = idss(oldsys.Data_);
if ~isempty(oldsys.EstimationInfo.DataInterSample)
   Data.InterSample = repmat(oldsys.EstimationInfo.DataInterSample,...
      [length(Data.Delay.Input),1]);
end
Data = setLastOperation(Data, {'convert','idarx'});
sys = inherit(idss.make(Data, iosize(oldsys.Data_)), oldsys);
if nargin>1
   sys = set(sys, varargin{:});
end

%{
ms = getarxms(oldsys.na,oldsys.nb,oldsys.nk);
if any(any(isnan(ms.As))')
   ms.Cs = ms.As(1:size(ms.Cs,1),:);
end
sys = set(sys,'As',ms.As,'Bs',ms.Bs,'Cs',ms.Cs,...
   'Ds',ms.Ds,'Ks',ms.Ks,'X0s',ms.X0s);
covv = oldsys.CovarianceMatrix;
if any(any(isnan(ms.As))') && ~ischar(covv)
   sys.CovarianceMatrix = [[covv,covv];[covv,covv]];
else
   sys.CovarianceMatrix = covv;
end
%}

