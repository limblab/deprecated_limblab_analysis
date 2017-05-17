classdef (CaseInsensitiveProperties, TruncatedProperties, Hidden) idnlmodel < ltipack.SingleRateSystem
   % Class defining obsolete @idnlmodel attributes.
   
   %   Author(s): Rajiv Singh
   %   Copyright 2014-2015 The MathWorks, Inc.
   
   properties (Hidden, Dependent)
      uname  % alias of InputName
      yname  % alias of OutputName
      uunit  % alias of InputUnit
      yunit  % alias of OutputUnit
      
      % Estimation algorithm settings (structure)
      %
      % A structure defining the algorithm used by estimation methods of
      % nonlinear models. Type "idprops idnlhw algorithm", "idprops idnlarx
      % algorithm" and "idprops idnlgrey algorithm", or look up the model
      % object reference pages, for more information.
      Algorithm
      
      % Parameter covariance matrix.
      %
      % CovarianceMatrix holds the covariance matrix of the estimated
      % parameters. It is typically created as a result of model
      % estimation using PEM. Set it to a string as a flag denoting how it
      % should be handled (estimated or not) during estimaion. Assignable
      % values:
      % * 'None' - inhibit computations of uncertainties.
      % * 'Estimate' - facilitate covariance estimation.
      % * Symmetric and positive Npe-by-Npe matrix or []. Npe is the number
      %   of free parameters of the model.
      CovarianceMatrix      
   end
   
   properties(Hidden, Dependent, SetAccess = protected)
      % Estimation information (structure, read-only)
      %
      % EstimationInfo is a structure with information from the estimation
      % process. Type "idprops idnlhw estimationinfo", "idprops idnlarx
      % estimationinfo" and "idprops idnlgrey estimationinfo", for more
      % information.
      EstimationInfo
   end
   
   properties(Access = protected)
      ExtraOptions = []; % see also EstimationOptions in @idnlmodel
      Covariance_ = 'none';
   end
   
   methods
      function Value = get.EstimationInfo(sys)
         % GET method for obsolete property "EstimationInfo"
         Value = getEstimationInfo(sys);
      end
      
      function Value = get.uname(sys)
         % GET method for obsolete alias property "uname"
         Value = sys.InputName;
      end
      
      function Value = get.uunit(sys)
         % GET method for obsolete alias property "uunit"
         Value = sys.InputUnit;
      end
      
      function Value = get.yname(sys)
         % GET method for obsolete alias property "yname"
         Value = sys.OutputName;
      end
      
      function Value = get.yunit(sys)
         % GET method for obsolete alias property "yunit"
         Value = sys.OutputUnit;
      end
      
      function sys = set.uname(sys, Value)
         % SET method for obsolete property alias "uname"
         sys.InputName = Value;
      end
      
      function sys = set.uunit(sys, Value)
         % SET method for obsolete property alias "uunit"
         sys.InputUnit = Value;
      end
      
      function sys = set.yname(sys, Value)
         % SET method for obsolete property alias "yname"
         sys.OutputName = Value;
      end
      
      function sys = set.yunit(sys, Value)
         % SET method for obsolete property alias "yunit"
         sys.OutputUnit = Value;
      end
      
      function Value = get.Algorithm(sys)
         % GET method for Algorithm property
         Value = getAlgorithm(sys);
      end
      
      function sys = set.Algorithm(sys, Value)
         sys = setAlgorithm(sys, Value);
      end
      
      function Value = get.CovarianceMatrix(sys)
         % GET method for "CovarianceMatrix" property.
         Value = getCovarianceMatrix(sys);
      end
      
      function sys = set.CovarianceMatrix(sys, Value)
         % SET method for "CovarianceMatrix" property.
         sys = setCovarianceMatrix(sys, Value);
      end
   end
   
   methods (Hidden)
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
   end
   
   methods(Access = protected)
      
      function Value = getCovarianceMatrix(sys)
         % Default implementation of getCovarianceMatrix method.
         Value = sys.Covariance_;
      end
      
      function sys = setCovarianceMatrix(sys, Value)
          % Default implementation of setCovarianceMatrix method.
          sys.Covariance_ = Value;
      end
      
      function Value = getEstimationInfo(sys)
         % Default implementation of get.EstimationInfo
         Value = idobsolete.getEstimationInfo(sys.Report, class(sys));
      end
      
      function Value = getAlgorithm(sys)
         % GET method implementation for Algorithm property.
         Value = idobsolete.getAlgorithm(sys);
      end
      
      function sys = setAlgorithm(sys, Value)
         % Default implementation of set.Algorithm
         sys = idobsolete.setAlgorithm(sys, Value);
         sys = incrementEstimationStatus(sys);
      end      
   end
   
   methods (Hidden, Static)
      [AlgoPV, PV] = parseObsoletePVPairs(Command,PV)
   end
end

%--------------------------------------------------------------------------
function Algo = localCopyExtraOptions(Algo, Extras)
% Copy Extras fields to corresponding locations in Algo.

fl = fieldnames(Extras);
for ct = 1:length(fl)
   if ~isstruct(Extras.(fl{ct}))
      Algo.(fl{ct}) = Extras.(fl{ct});
   else
      Algo.(fl{ct}) = localCopyExtraOptions(Algo.(fl{ct}), Extras.(fl{ct}));
   end
end
end
