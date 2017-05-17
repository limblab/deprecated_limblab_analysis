classdef (Hidden) idarxdata < idpack.ltidata
   % Class representing an idarx model.
   
   %   Author(s): Rajiv Singh
   %   Copyright 1986-2015 The MathWorks, Inc.   
   properties
      A
      B
      IC = 'auto';
      PName_
   end
   
   methods
      % Constructor
      function D = idarxdata(A,B,Ts)
         if nargin>0
            D.A = A;
            D.B = B;
            D.Ts = Ts;
            nu = size(B,2);
            D.Delay.Input = zeros(nu,1);
            D.NoiseVariance = eye(size(A,1));
            D.InterSample = repmat({'zoh'},[nu,1]);
            D.EstimationStatus = -Inf;
         end
      end
      
      function [Ny, Nu] = iosize(D)
         % Compute I/O size
         IOSize = [size(D.A,1), size(D.B,2)];
         if nargout<2
            Ny = IOSize;
         else
            Ny = IOSize(1);
            Nu = IOSize(2);
         end
      end
      
      function boo = isreal(D)
         boo = isreal([D.A(:);D.B(:)]);
      end
      
      function S = getStructure(~)
         S = [];
      end
      
      function D = checkData(D)
         % Check data consistency.
         % Called by lti/checkDataConsistency.
         
         if size(D.A,1)~=size(D.B,1)
            ctrlMsgUtils.error('Ident:idmodel:idarxABNyMismatch')
         end
         
         % Check Structure size first since that establishes I/O size
         D = checkNoiseVarianceSize(D);
      end
      
      function boo = isfinite(D)
         % Returns TRUE if model has finite data.
         
         boo = all(isfinite([D.A(:);D.B(:)]));
      end
      
      function np = nparams(D,~)
         np = length(getnnpar(D.A, D.B));
      end
      
      function p = getParameterVector(D)
         p = getnnpar(D.A,D.B);
      end
      
      function D = setParameterVector(D, p)
         [D.A,D.B] = arxdata(D, p);
      end
      
      function D = idarx(D, varargin)
      end
      
      function Data = getsubsys(Data,rowIndex,colIndex)
         % Extracts subsystem.         
         np = nparams(Data);
         pname = Data.PName_;
         if ~isempty(pname)
            Data.PName_ = [];
            ParList = getsubsysParIndex(Data,rowIndex,colIndex,np);
            ParI = intersect(ParList,(1:np)');
            Data.PName_ = pname(ParI);
         end
         Data.B = Data.B(rowIndex,colIndex,:);
         Data.A = Data.A(rowIndex,rowIndex,:);
         Data = getsubsys@idpack.ltidata(Data, rowIndex,colIndex);
      end
      
      %====================================================================
      % Overloaded methods for consistency in estimation interface
      %====================================================================
      function p = getp(D, ~)
         p = getnnpar(D.A, D.B);
      end
      
      function D = setp(D, p, varargin)
         if nargin>2
            p2 = getp(D);
            free = true(size(p2));
            p2(free) = p; p = p2;
         end
         [D.A,D.B] = arxdata(D, p);
      end
      
      function p = getplabels(D)
         % get parameter labels
         p = D.PName_;
         if isempty(p)
            np = numel(getp(D));
            p = repmat({''},[np,1]);
         end
      end
      
      function p = getpbounds(D)
         % get parameter bounds
         np = nparams(D);
         p = [-Inf(np,1), Inf(np,1)];
      end
      
      function D = setplabels(D,pname)
         % set parameter labels
         if ~isempty(pname) && ~all(cellfun(@(x)isempty(x),pname))
            D.PName_ = pname;
         else
            D.PName_ = [];
         end
      end
      
      function Free = isfree(D)
         Free = true(size(getp(D)));
      end
      
      function D = setfree(D, ~)
         % no op
      end
      
      function D = setpbounds(D, ~)
         % no op
      end
      
      function Value = getInitialState(D)
         Value = D.IC;
      end
      
      function D = setInitialState(D, IC)
         % Set InitialState flag value (b.c.)
         D.IC = IC;
      end
      
      function [na, nb, nk] = arxorder(D)
         % Determine orders
         na = localGetOrder(D, 'a');
         if nargout>1
            [nb, nk] = localGetOrder(D, 'b');
         end
      end
      
      function varargout = gradFresp(D, w, varargin)
         % Compute dH(w)/d\theta.
         [varargout{1:nargout}] = gradFresp(idpoly(D), w, varargin{:});
      end
      
      function varargout = gradZPK(D)
         % Z, P, K gradients
         [varargout{1:nargout}] = gradZPK(idpoly(D));
      end
      
      function varargout = gradOutputTDSim(sys, Data, x0)
         % Time response gradient
         [varargout{1:nargout}] = gradOutputTDSim(idpoly(sys),Data,x0);
      end
      
      function D = noise2meas(D,IsInnovation)
         % Dynamic model representing the noise component.
         D = idarx(noise2meas(idpoly(D),IsInnovation));
      end
      
      function D = augmod(D, IsInnovation)
         % augmenty model with noise component
         D = idarx(augmod(idpoly(D),IsInnovation));
      end
      
      function sys = getNoiseModel(D, IsInnovation, ParOrNonpar)
         % Get dynamical model between noise source and output.
         % IsInnovation: if TRUE, NoiseVariance is not used.
         % ParOrNonPar = 'nonpar' or 'par'. If 'par', result is
         %     idobsolete.idarxdata (this class), otherwise it is
         %     ltipack.ssdata.
         %
         % See also noise2meas, augmod.
         if ParOrNonpar(1)=='n'
            if IsInnovation
               D.NoiseVariance = eye(size(D.NoiseVariance,1));
            end
            D.Covariance = [];
            sys = ss(D,'noise');
         else
            sys = noise2meas(D, IsInnovation);
         end
      end
      
   end
   
   methods % analysis methods
      %--------------------------------------------------------------------
      % Analysis methods
      %--------------------------------------------------------------------
      function [boo,D] = isproper(D,varargin)
         % Returns TRUE if measured component of model is proper.
         boo = true;
      end
      
      function [Dss, SingularFlag] = ss(D, varargin)
         % Convert to ltipack.ssdata
         Reduce = false; % maintain order by default (see getarxms)
         if nargin>2
            Reduce = varargin{2};
            varargin = varargin(1);
         end
         D.Covariance = [];
         [Dss, SingularFlag] = ss(idpoly(D),varargin{:});
         if Reduce, Dss = sminreal(Dss); end
      end
      
      function sys = tf(D, varargin)
         % Convert to ltipack.tfdata
         D.Covariance = [];
         sys = tf(idpoly(D),varargin{:});
      end
      
      function sys = zpk(D, varargin)
         % Convert to ltipack.zpkdata
         D.Covariance = [];
         sys = zpk(idpoly(D),varargin{:});
      end
      
      function sys = frd(D,varargin)
         % Convert to ltipack.frddata
         D.Covariance = [];
         [~,nu] = iosize(D);
         if nu==0
            ctrlMsgUtils.error('Ident:transformation:frdTimeSeries');
         end
         sys = frd(idpoly(D),varargin{:});
      end
      
      function Dpid = pid(D,varargin)
         % Convert to PID.
         Dpid = pid(idpoly(D),varargin{:});
      end
      
      function Dpid = pidstd(D,varargin)
         % Convert to PIDSTD.
         Dpid = pidstd(idpoly(D),varargin{:});
      end
      
      
      function p = pole(D, varargin)
         % Compute poles of measured component of model
         D.Covariance = [];
         p = pole(idpoly(D),varargin{:});
      end
      
      function z = zero(D, varargin)
         % Compute zeros of measured component of model
         D.Covariance = [];
         z = zero(idpoly(D),varargin{:});
      end
      
      function varargout = predict(D,varargin)
         %Time responses (step or impulse) of measured component of
         %poynomial model.
         [varargout{1:nargout}] = predict(idpoly(D),varargin{:});
      end
      
      function varargout = sim(D,varargin)
         %Time responses (step or impulse) of measured component of
         %poynomial model.
         [varargout{1:nargout}] = sim(idpoly(D),varargin{:});
      end
      
      function boo = hasNoiseComponent(D)
         % Determine if idarx model has a noise component
         % similar rules to idpoly
         A = D.A;
         boo = norm(D.NoiseVariance,1)>0 && ~isempty(A) && ...
            ~isequal(A,eye(size(A,1)));
      end
      
      function varargout = d2d(D,varargin)
         % D2D conversion.
         [varargout{1:nargout}] = idarx(d2d(idpoly(D),varargin{:}));
      end
      
      function varargout = dcgain(D,varargin)
         %DC gain of measured component of model
         D.Covariance = [];
         [varargout{1:nargout}] = dcgain(idpoly(D),varargin{:});
      end
      
      function varargout = getFinalValue(D,varargin)
         % Computes steady-state value for a given response type, assuming
         % the model is stable
         D.Covariance = [];
         [varargout{1:nargout}] = getFinalValue(idpoly(D),varargin{:});
      end
      
      function [y,x] = lsim(D,u,t,x0,InterpRule)
         % Linear simulation.
         D.Covariance = [];
         [y,x] = lsim(idpoly(D),u,t,x0,InterpRule);
      end
      
      function [z,p,k] = iodynamics(D)
         % Computes the s-minimal set of poles and zeros for each I/O transfer
         % (with all delays set to zero).
         D.Covariance = [];
         [z,p,k] = iodynamics(idpoly(D));
      end
      
      function nx = order(D)
         nx = order(ss(D,'measured',false)); % maintain order
      end
      
      function boo = isnan(D)
         boo = any(isnan(D.A(:))) || any(isnan(D.B(:)));
      end
      
      function D2 = getNumericLTIData(D,varargin)
         % Transform into the shared numerical tfdata.
         D2 = tf(D,varargin{:});
      end
      
      function sys2 = convertToARMAX(sys)
         % Convert model into ARMAX polynomial form.
         sys2 = idpoly(sys);
      end
      
      function boo = isaimp(D)
         % Test if model has an FIR form.
         % Note: accepts nk>0 as FIR. 
         na = localGetOrder(D, 'a');
         boo = ~any(any(na));
      end
      
      function ysd = getStepImpulseStd(D,varargin)
         ysd = getStepImpulseStd(idpoly(D),varargin{:});
      end
      
   end
   
   methods (Access = protected)
      function Data = copyCommonData(refData, Data, Op)
         Data.NoiseVariance = refData.NoiseVariance;
         Data = setLastOperation(Data,Op);
      end
      
      function D1 = catStructure(~,D1,varargin)
         % Concatenate structures. No op.
      end
      
      function S = getsubsysStructure(varargin)
         % Extract subsystem structure. No op.
         S = [];
      end
      
      function D = setDelayStruct(D,DelayStructure)
         % Set delay structure. 
         D.Delay.Input = DelayStructure.Input;
         % distribute IO delays between nk and ioDelay, trying to preserve
         % nk as much as possible         
         D = setIODelay(D,DelayStructure.IO,false); 
      end
      
   end
end

%--------------------------------------------------------------------------
function [n, nk] = localGetOrder(sys, Poly)
% Get order of a chosen polynomial matrix
% Poly: 'a', or 'b'
% nk: number of leading zeros in each polynomial (only if Poly=='b')

sz = iosize(sys);
switch Poly
   case 'a'
      n = zeros(sz(1));
      a = sys.A;
      for ky1 = 1:sz(1)
         for ky2 = 1:sz(1)
            ak = squeeze(a(ky1,ky2,:));
            Last = find(ak,1,'last');
            if isempty(Last)
               n(ky1,ky2) = 0;
            else
               n(ky1,ky2) = Last-1; % ignore leading entry
            end
         end
      end
   case 'b'
      n = zeros(sz); nk = n;
      b = sys.B;
      for ky = 1:sz(1)
         for ku = 1:sz(2)
            bk = squeeze(b(ky,ku,:));
            First = find(bk,1,'first');
            Last = find(bk,1,'last');
            if isempty(Last)
               n(ky,ku) = 0;
               nk(ky,ku) = length(bk);
            else
               n(ky,ku) = Last-First+1;
               nk(ky,ku) = First-1;
            end
         end
      end
end
end
