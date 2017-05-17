classdef (CaseInsensitiveProperties, TruncatedProperties) idss < idobsolete.idmodel
   % Class defining obsolete properties and methods of idss.
   
   %   Copyright 2009-2015 The MathWorks, Inc.   
   methods (Hidden, Static)
      function X0 = checkX0(X0)
         % Check value of X0.
         
         if ~isnumeric(X0) || ~isvector(X0) || any(~isfinite(X0))
            ctrlMsgUtils.error('Ident:idmodel:idssObsoleteChk1')
         else
            X0 = double(full(X0(:)));
         end
         
      end
   end
   
   properties(Hidden, Dependent)
      % Flag to denote default handling of initial conditions during
      % estimation and prediction:
      nk
      X0
      CanonicalIndices
      DisturbanceModel
      SSParameterization
      As
      Bs
      Cs
      Ds
      Ks
      X0s
   end
   
   properties(Hidden, Dependent, SetAccess = private)
      dA
      dB
      dC
      dD
      dK
      dX0
   end
   
   methods
      
      function Value = get.nk(sys)
         % GET method for obsolete property "nk"
         % (backwards incompatible with v < 8.0 if InputDelay is set
         % separately from nk)
         
         ArraySize = size(sys.Data_);
         IOSize = iosize(sys.Data_(1));
         Value = zeros([1,IOSize(2),ArraySize]);
         Ts = getTs(sys);
         
         for ct = 1:prod(ArraySize)
            S = sys.Data_(ct).Structure;
            % If D is fixed to zero value, that counts as 1 nk value
            nk = double(all(S.d.Value==0 & ~S.d.Free,1));
            if Ts~=0
               % add Input Delay
               nk = nk + sys.Data_(ct).Delay.Input.';
            end
            Value(:,:,ct) = nk;
         end
      end
      
      function Value = get.X0(sys)
         % GET method for obsolete property "X0"
         Value = localGetX0(sys.Data_);
         if size(Value,2)>1
            Value = Value(:,end,:);
         end
      end
      
      function Value = get.dA(sys)
         % GET method for obsolete property "dA"
         Value = getdABCDK(sys, 'dA');
      end
      
      function Value = get.dB(sys)
         % GET method for obsolete property "dB"
         Value = getdABCDK(sys, 'dB');
      end
      
      function Value = get.dC(sys)
         % GET method for obsolete property "dC"
         Value = getdABCDK(sys, 'dC');
      end
      
      function Value = get.dD(sys)
         % GET method for obsolete property "dD"
         Value = getdABCDK(sys, 'dD');
      end
      
      function Value = get.dK(sys)
         % GET method for obsolete property "dK"
         Value = getdABCDK(sys, 'dK');
      end
      
      function Value = get.dX0(sys)
         % GET method for obsolete property "dX0"
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','dX0')
         end
         Value = getdX0(Data);
      end
      
      function Value = get.As(sys)
         % GET method for obsolete property "As"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','As')
         end
         Value = idobsolete.getStructureMatrix(sys.Data_,'a');
      end
      
      function Value = get.Bs(sys)
         % GET method for obsolete property "Bs"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','Bs')
         end
         Value = idobsolete.getStructureMatrix(sys.Data_,'b');
      end
      
      function Value = get.Cs(sys)
         % GET method for obsolete property "Cs"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','Cs')
         end
         Value = idobsolete.getStructureMatrix(sys.Data_,'c');
      end
      
      function Value = get.Ds(sys)
         % GET method for obsolete property "Ds"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','Ds')
         end
         Value = idobsolete.getStructureMatrix(sys.Data_,'d');
      end
      
      function Value = get.Ks(sys)
         % GET method for obsolete property "Ks"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','Ks')
         end
         Value = idobsolete.getStructureMatrix(sys.Data_,'k');
      end
      
      function Value = get.X0s(sys)
         % GET method for obsolete property "X0s"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','X0s')
         end
         Value = idobsolete.getStructureMatrix(sys.Data_,'X0');
      end
      
      function Value = get.CanonicalIndices(sys)
         % GET method fot dependent, obsolete property "CanonicalIndices"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','CanonicalIndices')
         end
         [~,Value] = getSSForm(sys.Data_);
      end
      
      function Value = get.SSParameterization(sys)
         % GET method for obsolete property "SSParameterization"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','SSParameterization')
         end
         Value = getSSForm(sys.Data_);
      end
      
      function Value = get.DisturbanceModel(sys)
         % GET method for obsolete property "DisturbanceModel"
         
         % Note: difference in get/set behavior
         % Get behavior: if "any" free, value is 'estimate'
         % Set behavior: if 'estimate', set "all" to free.
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','DisturbanceModel')
         end
         kf = sys.Structure.k.Free;
         if any(kf(:))
            Value = 'Estimate';
         else
            if norm(sys.k,1)==0
               Value = 'None';
            else
               Value = 'Fixed';
            end
         end
      end
      
      function sys = set.nk(sys, Value)
         % SET method for obsolete property "nk"
         
         Data = sys.Data_;
         ArraySize = ltipack.getLTIArraySize(2, Data, Value);
         if isempty(ArraySize)
            error('Ident:general:SysPropArraySizeMismatch','nk')
         end
         Ts = getTs(sys);
         IOSize = sys.IOSize_;
         Sz = size(Value);
         if ~isnumeric(Value) || ~isequal(Sz(1:2),[1 IOSize(2)])
            ctrlMsgUtils.error('Ident:idmodel:idssObsoleteChk3',IOSize(2))
         end
         
         for ct = 1:numel(Data)
            Datact = Data(min(ct,end));
            nk = Value(:,:,min(ct,end));
            
            if strncmpi(getSSForm(Datact),'s',1)
               %error('The property "nk" cannot be set for structured state-space models.')
            end
            
            if ~idpack.isNonnegIntVector(nk)
               ctrlMsgUtils.error('Ident:general:NonnegIntMatrixRequired','nk')
            elseif Ts==0 && ~isequal(nk, logical(nk))
               ctrlMsgUtils.error('Ident:idmodel:idssObsoleteChk4')
            end
            
            % nk = 0 implies feedthrough, nk = 1 implies no feedthrough.
            % Values > 1 (DT case) are added to (external) input delays.
            Datact.Structure.d.Value(:,nk>0) = 0;
            % Fix all columns with nk>0 and free all columns with nk==0.
            Datact.Structure.d.Free = repmat(nk==0,IOSize(1),1);
            if Ts~=0  && any(nk>1)
               % Set extra lags to InputDelay (backwards incompatible with
               % v<8.0)
               if norm(Datact.Delay.Input)>0
                  ctrlMsgUtils.warning('Ident:idmodel:ssNKInpDelayDependency')
                  Warn = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:ssNKInpDelayDependency'); %#ok<NASGU>
               end
               Datact.Delay.Input = max(nk.'-1,0);
            end
            Data(ct) = Datact;
         end
         sys.Data_ = Data;
         sys = incrementEstimationStatus(sys);
      end
      
      function  sys = set.X0(sys, Value)
         % SET method for obsolete property "X0".
         % Value must be [], column vector or array of column vectors
         % matching the system array size. Cannot specify multi-experiment
         % values since this property is only to maintain b.c.
         
         Data = sys.Data_;
         nx = order(Data(1));
         ssys = size(Data);
         if isempty(Value)
            Value = zeros([nx,1,ssys]);
         elseif iscolumn(Value) && prod(ssys)>1
            Value = repmat(Value,[1 1 ssys]);
         end
         
         Value = idobsolete.idss.checkX0(Value); % no size checks
         
         for ct = 1:numel(Data)
            if order(Data(ct))~=nx
               % Not supported for varying state dimension
               ctrlMsgUtils.error('Ident:idmodel:idssObsoleteChk2')
            end
            Data(ct) = setX0Value(Data(ct),Value(:,ct));
            
            % If any X0 entry is set to a non-zero value, it is set "free".
            if norm(Value(:,ct),1)>0, Data(ct).X0.Free = true; end
         end
         
         sys.Data_ = Data;
         
         %gtreeelkjjz..,cx.
         if sys.CrossValidation_
            sys = checkConsistency(sys);
         end
         
      end
      
      function  sys = set.As(sys, Value)
         % SET method for obsolete property "As"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','As')
         end
         sys.Data_.Structure.a = setStructureMatrix(sys.Data_.Structure.a, Value, 'As');
         sys = incrementEstimationStatus(sys);
      end
      
      function  sys = set.Bs(sys, Value)
         % SET method for obsolete property "Bs"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','Bs')
         end
         sys.Data_.Structure.b = setStructureMatrix(sys.Data_.Structure.b, Value, 'Bs');
         sys = incrementEstimationStatus(sys);
      end
      
      function  sys = set.Cs(sys, Value)
         % SET method for obsolete property "Cs"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','Cs')
         end
         sys.Data_.Structure.c = setStructureMatrix(sys.Data_.Structure.c, Value, 'Cs');
         sys = incrementEstimationStatus(sys);
      end
      
      function  sys = set.Ds(sys, Value)
         % SET method for obsolete property "Ds"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','Ds')
         end
         sys.Data_.Structure.d = setStructureMatrix(sys.Data_.Structure.d, Value, 'Ds');
         sys = incrementEstimationStatus(sys);
      end
      
      function  sys = set.Ks(sys, Value)
         % SET method for obsolete property "Ks"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','Ks')
         end
         
         sys.Data_.Structure.k = setStructureMatrix(sys.Data_.Structure.k, Value, 'Ks');
         sys = incrementEstimationStatus(sys);
      end
      
      function  sys = set.X0s(sys, Value)
         % SET method for obsolete property "X0s"
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','X0s')
         end
         sys.Data_.X0 = setStructureMatrix(sys.Data_.X0, Value, 'X0s');
         
         % Update InitialState flag.
         init = sys.InitialState;
         if norm(Value)==0 && any(strcmpi(init,{'Estimate','Fixed'}))
            sys.InitialState = 'zero';
         elseif ~any(isnan(Value)) && any(strcmpi(init,{'Estimate','Zero'}))
            sys.InitialState = 'fixed';
         elseif all(isnan(Value)) && any(strcmpi(init,{'Fixed','Zero'}))
            sys.InitialState = 'estimate';
         else
            % sys.SSParameterization = 'Structured'; --> no need because no-op)
            if any(strcmpi(init,{'Fixed','Zero'}))
               sys.InitialState = 'estimate';
            end
         end
      end
      
      function sys = set.SSParameterization(sys, Value)
         % SET method for obsolete property "SSParameterization"
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','SSParameterization')
         end
         
         if strcmpi(Value,'c')
            Value = 'Canonical'; % b.c.
         else
            Value = ltipack.matchKey(Value,{'structured','free','canonical','companion','modal'});
            if isempty(Value)
               ctrlMsgUtils.error('Ident:idmodel:idssSSParValue')
            end
         end
         
         [sys.Data_,ResetCov] = setSSForm(sys.Data_,Value); % use CanonicalIndices = 'auto';
         sys = incrementEstimationStatus(sys,ResetCov);
      end
      
      function sys = set.CanonicalIndices(sys, Value)
         % SET method for obsolete property "CanonicalIndices"
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','CanonicalIndices')
         end
         
         if ~ischar(Value)
            if ~idpack.isNonnegIntVector(Value)
               ctrlMsgUtils.error('Ident:general:NonnegIntVectorRequired','CanonicalIndices')
            end
            
            Nx = order(sys);
            if length(Value)~=size(sys,1) || sum(Value)~=Nx
               ctrlMsgUtils.error('Ident:idmodel:idssSetCheck2',Nx)
            end
         end
         
         % Update canonical form.
         if strncmpi(getSSForm(sys.Data_),'c',1)
            sys.Data_ = canon(sys.Data_,Value);
            sys = incrementEstimationStatus(sys);
         end
      end
      
      function sys = set.DisturbanceModel(sys, Value)
         % SET method for obsolete property "DisturbanceModel"
         if isempty(Value)
            % no change
            return
         end
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','DisturbanceModel')
         end
         
         Value = ltipack.matchKey(Value,{'zero','none','estimate','fixed'});
         
         Data = sys.Data_;
         K = Data.Structure.k;
         switch Value
            case {'zero', 'none'}
               K.Value = 0; % (using scalar expansion)
               K.Free = false;
            case 'estimate'
               K.Free = true;
            case 'fixed'
               K.Free = false;
            otherwise
               ctrlMsgUtils.error('Ident:idmodel:idssDistValue')
         end
         if ~isequal(Data.Structure.k,K)
            sys = incrementEstimationStatus(sys);
         end
         Data.Structure.k = K;
         sys.Data_ = Data;
      end
      
      function Report = estInfo2Report(sys, es)
         % Copy EstimationInfo to model Report.
         if strcmpi(es.Method,'n4sid')
            Report = idresults.n4sid;
         else
            Report = idresults.ssest;
         end
         if isfield(es,'N4Horizon')
            Report.N4Horizon = es.N4Horizon;
            Report.N4Weight = es.N4Weight;
         end
         sys = setReport(sys,Report);
         Report = estInfo2Report@idobsolete.idmodel(sys, es);
      end
      
   end %methods
   
   methods (Access = protected)
      
      function Value = getdABCDK(sys, dp)
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray',dp)
         end
         
         % Quick return if no covariance information is available (not
         % estimated or lost becasue of model modification after
         % estimation)
         if isempty(Data.Covariance)
            Value = []; return
         end
         
         switch dp
            case 'dA'
               Value = getdABCDK(Data);
            case 'dB'
               [~,Value] = getdABCDK(Data);
            case 'dC'
               [~,~,Value] = getdABCDK(Data);
            case 'dD'
               [~,~,~,Value] = getdABCDK(Data);
            case 'dK'
               [~,~,~,~,Value] = getdABCDK(Data);
         end
         
      end
      
      function sys = setInitialState(sys, Value)
         % In addition to modifying X0 entries, InitialState stores the
         % original specification since spec is more than just the value.
         %
         % Value must be a cell array for right array size.
         
         if ~iscell(Value), Value = {Value}; end
         if isscalar(Value), Value = repmat(Value,size(sys.Data_)); end
         
         for ct = 1:numel(sys.Data_)
            Data = sys.Data_(ct);
            Vct = ltipack.matchKey(Value{ct}, {'Estimate','Zero','Fixed','Auto','Backcast'});
            if isempty(Vct)
               ctrlMsgUtils.error('Ident:estimation:badSSInitCharValue')
            end
            Data = setInitialState(Data, lower(Vct));
            sys.Data_(ct) = Data;
         end
      end
      
      function Value = getCovarianceMatrix(sys)
         % IDSS implementation of get method for CovarianceMatrix
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','CovarianceMatrix')
         end
         
         Data = sys.Data_;
         Value = Data.Covariance;
         if isempty(Value) || isfloat(Value)
            Value = getCovarianceMatrix@idobsolete.idmodel(sys);
         else
            Value = getFreeValue(Value,@(x,y)x/y);
            % Value is in new format and does not contain X0
            
            X0Cov = getExtraCov(Data, 'X0CovT', 'value');            
            nx = numel(sys.X0s);
            x0Free = isnan(sys.X0s);
            if ~isempty(X0Cov) && size(X0Cov,1)==nx
               X0Cov = X0Cov(x0Free,x0Free);
               Value = blkdiag(Value, X0Cov);
            else
               Value = blkdiag(Value, zeros(sum(x0Free)));
            end
            
            % Next reaarange Value in "old" order
            FreeWithX0 = isfreewithx0(Data);
            Data2 = Data; Data2.Covariance  = [];
            parval = NaN(numel(FreeWithX0),1); % initialize
            npold = sum(FreeWithX0);
            parval(FreeWithX0) = (1:npold)';
            Data2 = setpwithx0(Data2, parval);
            OldOrder = getParInfo(Data2,'Value'); % returns only "free" entries as pars
            Value = Value(OldOrder, OldOrder);
         end
      end
      
      function sys = setCovarianceMatrix(sys,Value)
         %Store covariance matrix.
         % Specialized for X0 covariance separation and difference in
         % definition of a "parameter".
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','CovarianceMatrix')
         end
         
         if ~ischar(Value) && (~isnumeric(Value) || ~ismatrix(Value) || size(Value,1)~=size(Value,2))
            ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
         end
         
         if isnumeric(Value)
            par = getParameterVector(sys);
            if isempty(Value)
               sys.Data_.Covariance = [];
               sys.Data_.X0CovT = [];
            elseif numel(par)==size(Value,1) && size(Value,1)==size(Value,2)
               Data = sys.Data_;
               Free = isfree(Data);
               
               % Remove x0 covariance
               freeX0 = isnan(sys.X0s); % note: sys.X0s is always column vector
               nxfree = sum(freeX0);
               X0Cov = zeros(length(freeX0));
               X0CovFree = Value(end-nxfree+1:end,end-nxfree+1:end);
               X0Cov(freeX0,freeX0) = X0CovFree;
               Data.X0CovT = idpack.RawCovariance(X0Cov,freeX0);
               
               npold = size(Value,1); % old format
               npnew = nparams(sys);  % new format
               Data2 = Data; Data2.Covariance  = []; 
               Data2 = setp(Data2, NaN(npnew,1)); % initialize
               Data2 = setParInfo(Data2,'Value',(1:npold)');
               NewOrder = getp(Data2);
               I0 = isfinite(NewOrder);
               I = NewOrder(I0);
               Value = Value(1:end-nxfree,1:end-nxfree);               
               FreeFree = Free(I0);
               Free(I0) = FreeFree(I);
               
               Cov = idpack.RawCovariance(Value(I,I));
               Cov.Free = Free;
               Data.Covariance = Cov;
               
               sys.Data_ = Data;
            else
               ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
            end
         else
            sys.Algorithm.CovarianceFlag = Value;
            sys.Data_.Covariance = [];
            sys.Data_.X0CovT = [];
         end
      end      
   end
end

%--------------------------------------------------------------------------
%                 Local Functions
%--------------------------------------------------------------------------
function Value = localGetX0(Data)
% get X0 Value

if isscalar(Data)
   Value = Data.X0.Value;
else
   ArraySize = size(Data);
   ValueArray = cell(ArraySize);
   for ct = 1:numel(Data)
      ValueArray{ct} = Data(ct).X0.Value;
   end
   % Turn into ND array
   try
      Value = cat(3,ValueArray{:});
      Value = reshape(Value,[size(Value,1) size(Value,2) ArraySize]);
   catch %#ok<CTCH>
      % A,B,C,K,X0 cannot be represented as ND arrays
      ctrlMsgUtils.error('Control:ltiobject:get4','X0')
   end
end
end
