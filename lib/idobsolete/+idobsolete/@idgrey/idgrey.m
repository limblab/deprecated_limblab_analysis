classdef (CaseInsensitiveProperties, TruncatedProperties) idgrey < idobsolete.idmodel
   % Class defining obsolete properties and methods of idgrey.
   
   %   Copyright 2009-2015 The MathWorks, Inc.
   
   properties(Hidden, Dependent)
      % Flag to denote default handling of initial conditions during
      % estimation and prediction:
      
      X0
      MfileName
      CDmfile
      FileArgument
      DisturbanceModel
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
      function Value = get.X0(sys)
         % GET method for obsolete property "X0"
         Value = localGetX0(sys.Data_);
         if size(Value,2)>1
            Value = Value(:,end,:);
         end
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
         end
         
         sys.Data_ = Data;
         
         %gtreeelkjjz..,cx.
         if sys.CrossValidation_
            sys = checkConsistency(sys);
         end
      end
      
      function Value = get.dA(sys)
         % GET method for dA property
         Value = getdABCDK(sys, 'dA');
      end
      
      function Value = get.dB(sys)
         % GET method for dB property
         Value = getdABCDK(sys, 'dB');
      end
      
      function Value = get.dC(sys)
         % GET method for dC property
         Value = getdABCDK(sys, 'dC');
      end
      
      function Value = get.dD(sys)
         % GET method for dD property
         Value = getdABCDK(sys, 'dD');
      end
      
      function Value = get.dK(sys)
         % GET method for dK property
         Value = getdABCDK(sys, 'dK');
      end
      
      function Value = get.dX0(sys)
         % GET method for obsolete property "dX0"
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','dX0')
         end
         if ~isempty(Data.Covariance)
            Value = sqrt(diag(getExtraCov(Data, 'X0CovT', 'value')));
            nx = order(Data);
            Value = Value(end-nx+1:end);
         else
            Value = [];
         end
      end
      
      function Value = get.DisturbanceModel(sys)
         % GET method for obsolete property "DisturbanceModel"
         
         % Note: difference in get/set behavior
         % Get behavior: if "any" free, value is 'estimate'
         % Set behavior: if 'estimate', set "all" to free.
         
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','DisturbanceModel')
         end
         
         Value = Data.EstimationOptions.DisturbanceModel;
      end
      
      function sys = set.DisturbanceModel(sys, Value)
         % SET method for DisturbanceModel property
         if isempty(Value)
            % no change
            return
         end
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','DisturbanceModel')
         end
         
         sys.Data_.EstimationOptions.DisturbanceModel = Value;
      end
      
      function Value = get.MfileName(sys)
         % GET method for MfileName property
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','MfileName')
         end
         
         Value = Data.Structure.Function;
      end
      
      function sys = set.MfileName(sys, Value)
         % SET method for MfileName property
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','MfileName')
         end
         
         sys.Structure.Function = Value;
      end
      
      function Value = get.CDmfile(sys)
         % GET method for CDmfile property
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','CDmfile')
         end
         
         Value = Data.Structure.FcnType;
      end
      
      function sys = set.CDmfile(sys, Value)
         % SET method for CDmfile property
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','CDmfile')
         end
         
         sys.Structure.FcnType = Value;
      end
      
      function Value = get.FileArgument(sys)
         % GET method for FileArgument property
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','FileArgument')
         end
         
         Value = Data.Structure.ExtraArgs;
         if iscell(Value) && isscalar(Value), Value = Value{1}; end
      end
      
      function sys = set.FileArgument(sys, Value)
         % SET method for FileArgument property
         
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','FileArgument')
         end
         
         sys.Structure.ExtraArgs = {Value};
      end
      
   end
   
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
         % SET method implementation for InitialState property
         % Value must be a cell array for right array size.
                 
         if ~iscell(Value), Value = {Value}; end         
         if isscalar(Value), Value = repmat(Value,size(sys.Data_)); end
         
         for ct = 1:numel(sys.Data_)
            Data = sys.Data_(ct);
            Vct = ltipack.matchKey(Value{ct}, {'Estimate','Zero','Fixed','Auto','Backcast','Model'});
            if isempty(Vct)
               ctrlMsgUtils.error('Ident:estimation:badGreyInitCharValue')
            end
            Data = setInitialState(Data, lower(Vct));
            sys.Data_(ct) = Data;
         end
      end
      
      function sys = setCovarianceMatrix(sys,Value)
         sys = setCovarianceMatrix@idobsolete.idmodel(sys, Value);
         sys.Data_.X0CovT = [];
         sys.Data_.kCovT = [];
      end
      
   end % protected methods
   
end % class

%--------------------------------------------------------------------------
%                 Local Functions
%--------------------------------------------------------------------------
function Value = localGetX0(Data)
% get X0 Value

if isscalar(Data)
   Value = getX0Value(Data);
else
   ArraySize = size(Data);
   ValueArray = cell(ArraySize);
   for ct = 1:numel(Data)
      ValueArray{ct} = getX0Value(Data(ct));
   end
   % Turn into ND array
   try
      Value = cat(3,ValueArray{:});
      Value = reshape(Value,[size(Value,1) size(Value,2) ArraySize]);
   catch %#ok<CTCH>
      % X0 cannot be represented as ND array
      ctrlMsgUtils.error('Control:ltiobject:get4','X0')
   end
end
end
