classdef (CaseInsensitiveProperties, TruncatedProperties, Hidden) idnlarx ...
      < idobsolete.idnlmodel
   
   %   Author(s): Rajiv Singh
   %   Copyright 2014 The MathWorks, Inc.
   
   properties (Hidden, Dependent)
      % Estimation focus
      %
      % One of 'Prediction' or 'Simulation'.
      % 'Prediction' means that the estimation algorithm minimizes the norm
      % of y-ypred, where y is the measured and ypred is the (1-step ahead)
      % predicted output. For 'Simulation' the output error fit (norm of
      % y-ysim, where ysim is the simulated response of the model) is
      % minimized.
      Focus % obsolete idnlarx property "Focus"
   end
   
   methods
      function sys = set.Focus(sys, Value)
         % SET method for obsolete model property "Focus"
         opt = getDefaultOptions(sys);
         if isempty(opt)
            opt = idoptions.nlarx;
         end
         if ischar(Value) && ~strncmpi(opt.Focus,Value,1)
            opt.Focus = Value;
            sys = setDefaultOptions(sys,opt);
            sys = incrementEstimationStatus(sys);
         end
      end
      
      function Value = get.Focus(sys)
         %GET method for obsolete model property "Focus"
         opt = getDefaultOptions(sys);
         if isempty(opt)
            Value = 'prediction';
         else
            Value = opt.Focus;
         end
      end
   end
   
   
   methods (Access = protected)
      function sys = setAlgorithm(sys, Value)
         % set.Algorithm implementation for idnlarx models.
         sys = setAlgorithm@idobsolete.idnlmodel(sys, Value);
         sys = pvset(sys,'Estimated',-1);
      end
   end
end
