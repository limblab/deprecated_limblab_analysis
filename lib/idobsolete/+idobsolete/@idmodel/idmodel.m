classdef (CaseInsensitiveProperties, TruncatedProperties, Hidden) idmodel < idobsolete.idlti
   % Class defining obsolete @idobsolete.idmodel's parametric attributes.
   %
   %  Replaced by idParametric.
   %
   % See also idlti, idParametric.
   
   %   Copyright 2009-2015 The MathWorks, Inc.
   
   properties (Hidden, Dependent)
      ParameterVector
      PName
      CovarianceMatrix
      Algorithm
      InitialState
      
      Focus          % alias of Algorithm.Focus
      MaxIter        % alias of Algorithm.MaxIter
      Tolerance      % alias of Algorithm.Tolerance
      LimitError     % alias of Algorithm.LimitError
      MaxSize        % alias of Algorithm.MaxSize
      SearchMethod   % alias of Algorithm.SearchMethod
      Criterion      % alias of Algorithm.Criterion
      Weighting      % alias of Algorithm.Weighting
      FixedParameter % alias of Algorithm.FixedParameter
      Display        % alias of Algorithm.Display
      Trace          % alias of Algorithm.Trace
      N4Weight       % alias of Algorithm.N4Weight
      N4Horizon      % alias of Algorithm.N4Horizon
      Advanced       % alias of Algorithm.Advanced
      Approach       % alias of Algorithm.Approach
   end
   
   methods
      function Value = get.ParameterVector(sys)
         % GET method for obsolete property "ParameterVector"
         % ParameterVector: parameter order and inclusion rules would
         % change in 8.0. Hence ParameterVector may be different from
         % result of GETP(sys.Data_).
         
         Value = getParameterVector(sys);
      end
      
      function Value = get.PName(sys)
         % GET method for obsolete property "PName"
         
         Value = getPName(sys);
      end
      
      function Value = get.CovarianceMatrix(sys)
         % GET method for obsolete property "CovarianceMatrix"
         
         Value = getCovarianceMatrix(sys);
      end
      
      function Value = get.Algorithm(sys)
         % GET method for obsolete property "Algorithm"
         
         Value = getAlgorithm(sys);
      end
      
      function Value = get.InitialState(sys)
         % GET method for obsolete property "InitialState"
         Value = getInitialState(sys);
      end
      
      function Value = get.Focus(sys)
         % GET method for obsolete algorithm option alias "Focus"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Focus')
         end
         Value = sys.Algorithm.Focus;
      end
      
      function Value = get.MaxIter(sys)
         % GET method for obsolete algorithm option alias "MaxIter"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','MaxIter')
         end
         Value = sys.Algorithm.MaxIter;
      end
      
      function Value = get.Tolerance(sys)
         % GET method for obsolete algorithm option alias "Tolerance"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Tolerance')
         end
         Value = sys.Algorithm.Tolerance;
      end
      
      function Value = get.LimitError(sys)
         % GET method for obsolete algorithm option alias "LimitError"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','LimitError')
         end
         Value = sys.Algorithm.LimitError;
      end
      
      function Value = get.MaxSize(sys)
         % GET method for obsolete algorithm option alias "MaxSize"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','MaxSize')
         end
         Value = sys.Algorithm.MaxSize;
      end
      
      function Value = get.SearchMethod(sys)
         % GET method for obsolete algorithm option alias "SearchMethod"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','SearchMethod')
         end
         Value = sys.Algorithm.SearchMethod;
      end
      
      function Value = get.Approach(~)
         % GET method for obsolete algorithm option alias "Approach"
         Value = '';
      end
      
      function Value = get.Criterion(sys)
         % GET method for obsolete algorithm option alias "Criterion"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Criterion')
         end
         Value = sys.Algorithm.Criterion;
      end
      
      function Value = get.Weighting(sys)
         % GET method for obsolete algorithm option alias "Weighting"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Weighting')
         end
         Value = sys.Algorithm.Weighting;
      end
      
      function Value = get.FixedParameter(sys)
         % GET method for obsolete algorithm option alias "FixedParameter".
         % FixedParameter is a singleton even for model arrays since it
         % belongs to (singleton) Algorithm.
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','FixedParameter')
         end
         Value = sys.Algorithm.FixedParameter;
      end
      
      function Value = get.Display(sys)
         % GET method for obsolete algorithm option alias "Display"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Display')
         end
         Value = sys.Algorithm.Display;
      end
      
      function Value = get.Trace(sys)
         % GET method for obsolete algorithm option alias "Trace"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Trace')
         end
         Value = lower(sys.Algorithm.Display);
      end
      
      function Value = get.N4Weight(sys)
         % GET method for obsolete algorithm option alias "N4Weight"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','N4Weight')
         end
         Value = sys.Algorithm.N4Weight;
      end
      
      function Value = get.N4Horizon(sys)
         % GET method for obsolete algorithm option alias "N4Horizon"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','N4Horizon')
         end
         Value = sys.Algorithm.N4Horizon;
      end
      
      function Value = get.Advanced(sys)
         % GET method for obsolete algorithm option alias "Advanced"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray2','Advanced')
         end
         Value = sys.Algorithm.Advanced;
      end
      
      function sys =  set.ParameterVector(sys, Value)
         % SET method for obsolete property "ParameterVector"
         sys = setParameterVector(sys, Value);
         sys = incrementEstimationStatus(sys);
      end
      
      function sys = set.PName(sys, Value)
         % SET method for obsolete property "PName"
         
         sys = setPName(sys, Value);
      end
      
      function sys = set.CovarianceMatrix(sys,Value)
         % SET method for obsolete property "CovarianceMatrix".
         if isempty(Value)
            sys.Data_.Covariance = [];
         else
            sys = setCovarianceMatrix(sys,Value);
         end
      end
      
      function sys = set.InitialState(sys, Value)
         % SET method for obsolete dependent property "InitialState".
         sys = setInitialState(sys, Value);
      end
      
      function sys = set.Algorithm(sys, Value)
         % SET method for obsolete property "Algorithm"
         
         sys = setAlgorithm(sys, Value);
      end
      
      function sys = set.Approach(sys,~)
         % SET method for obsolete property "Approach"
         % no-op; "Approach" was removed from Algorithm
      end
      
      function sys = set.Focus(sys, Value)
         % SET method for obsolete algorithm option alias "Focus"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Focus')
         end
         sys.Algorithm.Focus = Value;
      end
      
      function sys = set.MaxIter(sys, Value)
         % SET method for obsolete algorithm option alias "MaxIter"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','MaxIter')
         end
         sys.Algorithm.MaxIter = Value;
      end
      
      function sys = set.Tolerance(sys, Value)
         % SET method for obsolete algorithm option alias "Tolerance"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Tolerance')
         end
         sys.Algorithm.Tolerance = Value;
      end
      
      function sys = set.LimitError(sys, Value)
         % SET method for obsolete algorithm option alias "LimitError"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','LimitError')
         end
         sys.Algorithm.LimitError = Value;
      end
      
      function sys = set.MaxSize(sys, Value)
         % SET method for obsolete algorithm option alias "MaxSize"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','MaxSize')
         end
         sys.Algorithm.MaxSize = Value;
      end
      
      function sys = set.SearchMethod(sys, Value)
         % SET method for obsolete algorithm option alias "SearchMethod"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','SearchMethod')
         end
         sys.Algorithm.SearchMethod = Value;
      end
      
      function sys = set.Criterion(sys, Value)
         % SET method for obsolete algorithm option alias "Criterion"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Criterion')
         end
         sys.Algorithm.Criterion = Value;
      end
      
      function sys = set.Weighting(sys, Value)
         % SET method for obsolete algorithm option alias "Weighting"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Weighting')
         end
         sys.Algorithm.Weighting = Value;
      end
      
      function sys = set.FixedParameter(sys, Value)
         % SET method for obsolete algorithm option alias "FixedParameter"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','FixedParameter')
         end
         if ~isempty(Value)
            ctrlMsgUtils.warning('Ident:idmodel:obsoleteFixedPar')
         end
         sys.Algorithm.FixedParameter = Value;
      end
      
      function sys = set.Display(sys, Value)
         % SET method for obsolete algorithm option alias "Display"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Display')
         end
         sys.Algorithm.Display = Value;
      end
      
      function sys = set.Trace(sys, Value)
         % SET method for obsolete algorithm option alias "Trace"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Trace')
         end
         sys.Algorithm.Display = Value;
      end
      
      function sys = set.N4Weight(sys, Value)
         % SET method for obsolete algorithm option alias "N4Weight"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','N4Weight')
         end
         sys.Algorithm.N4Weight = Value;
      end
      
      function sys = set.N4Horizon(sys, Value)
         % SET method for obsolete algorithm option alias "N4Horizon"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','N4Horizon')
         end
         sys.Algorithm.N4Horizon = Value;
      end
      
      function sys = set.Advanced(sys, Value)
         % SET method for obsolete algorithm option alias "Advanced"
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray2','Advanced')
         end
         sys.Algorithm.Advanced = Value;
      end
   end
   
   methods (Hidden)
      function Value = getParameterVector(sys)
         % Default implementation of get.ParameterVector
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','ParameterVector')
         end
         
         Value = getParInfo(sys.Data_,'Value');
      end
      
      function mnk = inpd2nk(md)
         %INPD2NK converts input delays to state space models with explicit
         %delays.
         %
         % INPD2NK is obsolete, use ABSORBDELAY instead.
         %
         %   See also ABSORBDELAY.
         try
            mnk = absorbDelay(idss(md)); % inpd2nk delivers idss
         catch ME
            throw(ME)
         end
      end
      
      function Report = estInfo2Report(sys, es)
         % Copy obsolete EstimationInfo to model report at load time.
         %
         % For object versions <11 (SITB ver < 8.0)
         % Specialized to choose the right report class for a particular
         % estimator.
         % Here, assume that Report is of the right class.
         %
         % For 11< ver < 16, nonlinear models upgrade
         Report = idobsolete.estInfo2Report(sys, es);
      end
      
      function sys = inherit(sys, refsys)
         % Copy common properties.
         sys = inherit@idobsolete.idlti(sys,refsys);
         sys.TimeUnit = refsys.TimeUnit;
      end
   end
   
   methods(Access = protected)
      function Value = getInitialState(sys)
         % GET method implementation for InitialState property.
         
         Data = sys.Data_;
         if numel(Data)==1
            Value = getInitialState(Data);
         else
            Value = cell(size(Data));
            for ct = 1:numel(Data)
               Value{ct} = getInitialState(Data(ct));
            end
         end
      end
      
      function sys = setInitialState(sys, ~)
         % Default implementation of set method for InitialState
         
         %if ~iscell(Value), Value = {Value}; end
         %if isscalar(Value), Value = repmat(Value,size(sys.Data_)); end
         
         ctrlMsgUtils.error('Ident:general:invalidProp','InitialState',class(sys))
      end
      
      function Value = getAlgorithm(sys)
         % GET method implementation for Algorithm property.
         Value = idobsolete.getAlgorithm(sys);
      end
      
      function Value = getPName(sys)
         % Default implementation of get.PName
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','PName')
         end
         
         Value = getParInfo(sys.Data_, 'Name');
      end
      
      function Value = getCovarianceMatrix(sys)
         % Default implementation of get.CovarianceMatrix
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','CovarianceMatrix')
         end
         
         Value = sys.Data_.Covariance;
         if isempty(Value)
            % If covariance was estimated, but estimation failed, return
            % []. If covariance was chosen to be not estimated, return
            % 'none'. If model was never estimated, return the original
            % specification ('estimate' or 'none').
            Flag = sys.Algorithm.CovarianceFlag;
            if sys.Data_.EstimationStatus>=1 && strcmpi(Flag,'estimate')
               Value = [];
            else
               Value = Flag;
            end
         elseif ~isfloat(Value)
            Warn = ctrlMsgUtils.SuspendWarnings;
            Value = getValue(Value,@(x,y)x/y);
            delete(Warn)
            if any(any(~isfinite(Value)))
               ctrlMsgUtils.warning('Ident:idmodel:illdefinedCov')
            end
         end
      end
      
      function sys = setParameterVector(sys, Value)
         % Default implementation of set.ParameterVector
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','ParameterVector')
         end
         
         % RE: setParInfo recognizes the old parameter definition for all
         % model types.
         sys.Data_ = setParInfo(sys.Data_,'Value',Value);
      end
      
      function sys = setPName(sys, Value)
         % Default implementation of set.PName
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','PName')
         end
         
         Value = idobsolete.checkPName(sys, Value);
         if ~isempty(Value)
            sys.Data_ = setParInfo(sys.Data_,'Name',Value);
         end
      end
      
      function sys = setCovarianceMatrix(sys,Value)
         % Default implementation of set.CovarianceMatrix
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','CovarianceMatrix')
         end
         
         if ~ischar(Value) && (~isnumeric(Value) || ~ismatrix(Value) || ...
               size(Value,1)~=size(Value,2))
            ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
         end
         
         if isnumeric(Value)
            par = getParameterVector(sys);
            if isempty(Value)
               sys.Data_.Covariance = [];
            elseif numel(par)==size(Value,1) && size(Value,1)==size(Value,2)
               Free = true(1,size(Value,1));
               Fixed = getParInfo(sys.Data_,'Fixed');
               Free(Fixed) = false;
               sys.Data_.Covariance = idpack.RawCovariance(Value,Free);
            else
               ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
            end
         else
            sys.Algorithm.CovarianceFlag = Value;
            sys.Data_.Covariance = [];
         end
      end
      
      function sys = setAlgorithm(sys, Value)
         % Default implementation of set.Algorithm
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','Algorithm')
         end
         sys = idobsolete.setAlgorithm(sys, Value);
      end      
   end
end
