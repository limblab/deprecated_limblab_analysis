classdef (CaseInsensitiveProperties, TruncatedProperties, Hidden) idnlgrey ...
      < idobsolete.idnlmodel
   
   %   Author(s): Rajiv Singh
   %   Copyright 2014 The MathWorks, Inc.     
   
   methods (Access = protected)
       function Value = getAlgorithm(sys)
         % GET method implementation for Algorithm property.
         Value = getAlgorithm@idobsolete.idnlmodel(sys);
         Value.SimulationOptions = sys.SimulationOptions;
      end
      
      function sys = setAlgorithm(sys, Value)
         % set.Algorithm implementation for idnlarx models.
         %[errmsg, algo] = idnlgrey.checkgetAlgorithm(Value, sys.Order.ny);
         %error(errmsg)
         % If sys is a static system and Solver is specified to not be
         % 'FixedStepDiscrete' or 'Auto', then change the Solver to
         % 'FixedStepDiscrete' and inform the user about it.
         if ((sys.Order.nx == 0) && ...
               isempty(ltipack.matchKey(Value.SimulationOptions.Solver, {'auto' 'FixedStepDiscrete'})))
            Value.SimulationOptions.Solver = 'FixedStepDiscrete';
            ctrlMsgUtils.warning('Ident:idnlmodel:discreteSolverForStaticSystem')
         end
         
         if isstruct(Value) && isfield(Value,'SimulationOptions')
            sys.SimulationOptions = Value.SimulationOptions;
            Value = rmfield(Value,'SimulationOptions');
         end
         sys = idobsolete.setAlgorithm(sys, Value);
         % Check consistency of sys.
         if sys.CrossValidation_
            error(isvalid(sys, 'SkipFileName'));
         end
         sys = incrementEstimationStatus(sys);
      end
      
      
      function Value = getCovarianceMatrix(sys)
         % GET method for "CovarianceMatrix" property.
         Value = getcov(sys,'value');
         if isempty(Value)
            % If covariance was estimated, but estimation failed, return
            % []. If covariance was chosen to be not estimated, return
            % 'none'. If model was never estimated, return the original
            % specification ('estimate' or 'none').
            Flag = sys.Algorithm.CovarianceFlag;
            if pvget(sys,'Estimated')>=1 && strcmpi(Flag,'estimate')
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
      
      function sys = setCovarianceMatrix(sys, Value)
         % SET method for "CovarianceMatrix" property.
         if ~ischar(Value) && (~isnumeric(Value) || ~ismatrix(Value) ||...
               size(Value,1)~=size(Value,2))
            ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
         end
         
         if isnumeric(Value)
            sys = setcov(sys, Value);
         else
            sys.Algorithm.CovarianceFlag = Value;
            sys = removeCovariance(sys);
         end
      end
   end
   
   methods (Static, Hidden)
      [AlgoPV, PV] = parseObsoletePVPairs(Command,PV)
   end
end