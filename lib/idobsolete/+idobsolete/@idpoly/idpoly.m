classdef (CaseInsensitiveProperties, TruncatedProperties) idpoly < idobsolete.idmodel
   % Class defining obsolete properties and methods of idpoly.
   
   %   Author(s): Lennert Ljung, Rajiv Singh
   %   Copyright 2009-2015 The MathWorks, Inc.
  
   properties(Hidden, Dependent)
      % Flag to denote default handling of initial conditions during
      % estimation and prediction:
      na
      nb
      nc
      nd
      nf
      nk
   end
   
   properties(Hidden, Dependent, SetAccess = private)
      da
      db
      dc
      dd
      df
   end
   
   methods
      function Value = get.na(sys)
         % GET method for na
         Value = localGetPolyOrder(sys.Data_,'a');
      end
      
      function Value = get.nb(sys)
         % GET method for nb
         Value = localGetPolyOrder(sys.Data_,'b');
      end
      
      function Value = get.nc(sys)
         % GET method for nc
         Value = localGetPolyOrder(sys.Data_,'c');
      end
      
      function Value = get.nd(sys)
         % GET method for nd
         Value = localGetPolyOrder(sys.Data_,'d');
      end
      
      function Value = get.nf(sys)
         % GET method for nf
         Value = localGetPolyOrder(sys.Data_,'f');
      end
      
      function Value = get.nk(sys)
         % GET method for nk
         Value = localGetPolyOrder(sys.Data_,'nk');
      end
      
      function Value = get.da(sys)
         % GET method for obsolete property "da"
         Value = getdABCDF(sys, 'da');
      end
      
      function Value = get.db(sys)
         % GET method for obsolete property "db"
         Value = getdABCDF(sys, 'db');
      end
      
      function Value = get.dc(sys)
         % GET method for obsolete property "dc"
         Value = getdABCDF(sys, 'dc');
      end
      
      function Value = get.dd(sys)
         % GET method for obsolete property "dd"
         Value = getdABCDF(sys, 'dd');
      end
      
      function Value = get.df(sys)
         % GET method for obsolete property "df"
         Value = getdABCDF(sys, 'df');
      end
      
      function sys = set.na(sys, Value)
         % SET method for na
         % Note: Changing size of orders (na, nb etc) is not supported.
         % Such SET calls silently ignored pieces of inputs in the past.
         % Now they will error out.
         Ny = sys.IOSize_(1);
         sys = setPolyOrder(sys, 'a', Value, sys.na, [Ny Ny]);
      end
      
      function sys = set.nb(sys, Value)
         % SET method for nb
         sys = setPolyOrder(sys, 'b', Value, sys.nb, sys.IOSize_);
      end
      
      function sys = set.nc(sys, Value)
         % SET method for nc
         sys = setPolyOrder(sys, 'c', Value, sys.nc, [sys.IOSize_(1) 1]);
      end
      
      function sys = set.nd(sys, Value)
         % SET method for nd
         sys = setPolyOrder(sys, 'd', Value, sys.nd, [sys.IOSize_(1) 1]);
      end
      
      function sys = set.nf(sys, Value)
         % SET method for nf
         sys = setPolyOrder(sys, 'f', Value, sys.nf, sys.IOSize_);
      end
      
      function sys = set.nk(sys, Value)
         % SET method for nk
         Value = full(double(Value));
         if sys.Ts==0 && any(Value(:))
            ctrlMsgUtils.error('Ident:idmodel:CTNkSet');
         elseif numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','nk')
         end
         
         nk = sys.nk; % old value
         % size of nk must always match that of nb
         if ~isequal(size(Value),size(nk))
            ctrlMsgUtils.error('Ident:idmodel:nkSize')
         elseif ~idpack.isNonnegIntMatrix(Value)
            ctrlMsgUtils.error('Ident:general:NonnegIntMatrixRequired','nk')
         end
         sys.Data_ = setnk(sys.Data_, Value);
         sys = incrementEstimationStatus(sys);
      end
      
      function Report = estInfo2Report(sys, es)
         % Copy EstimationInfo to model Report.
         if strcmpi(es.Method,'arx')
            Report = idresults.arx;
         else
            Report = idresults.polyest;
         end
         sys = setReport(sys,Report);
         Report = estInfo2Report@idobsolete.idmodel(sys, es);
      end
      
      function [A,B,dA,dB] = arxdata(sys, varargin)
         % Calculate ARX polynomial matrices.
         no = nargout;
         Data = sys.Data_;
         A = []; B = []; dA = []; dB = [];
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:commandNotForModelArray','arxdata')
         elseif numel(Data)==0
            return
         end
         %if no<3, Data.Covariance = []; end
         [A,B] = getABCDF(Data);
         if isscalar(A) % single output
            A = A{1};
            % maintain backward compatibility for single-output models
            B = idobsolete.cell2mat(B,Data.Ts);
         end
         if no>2
            [dA, dB] = getdABCDF(Data);
            if isscalar(dA) % single output
               dA = dA{1};
               % maintain backward compatibility for single-output models
               dB = idobsolete.cell2mat(dB,Data.Ts);
            end
         end
      end      
   end % methods
   
   methods (Access=protected)
      function sys = setInitialState(sys, Value)
         % SET method overload for obsolete property "InitialState".
         %
         % Value must be a cell array for right array size.
         
         if ~iscell(Value), Value = {Value}; end
         if isscalar(Value), Value = repmat(Value,size(sys.Data_)); end
         
         for ct = 1:numel(sys.Data_)
            Vct = ltipack.matchKey(Value{ct}, {'Estimate','Zero','Auto','Backcast'});
            if isempty(Vct)
               ctrlMsgUtils.error('Ident:idmodel:idpolyIncorrectIni');
            else
               sys.Data_(ct) = setInitialState(sys.Data_(ct),lower(Vct));
            end
         end
      end
      
      function Value = getdABCDF(sys, dp)
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
            case 'da'
               Value = getdABCDF(Data);
            case 'db'
               [~,Value] = getdABCDF(Data);
            case 'dc'
               [~,~,Value] = getdABCDF(Data);
            case 'dd'
               [~,~,~,Value] = getdABCDF(Data);
            case 'df'
               [~,~,~,~,Value] = getdABCDF(Data);
         end
         
         DoubleFormat = Data.BFFormat==1;
         if isscalar(Value)
            Value = Value{1};
         elseif DoubleFormat && any(dp(2)=='bf') && isrow(Value)
            Value = idobsolete.cell2mat(Value,Data.Ts);
         end
      end
   end
end

%--------------------------------------------------------------------------
%                   Local Functions
%--------------------------------------------------------------------------
function Value = localGetPolyOrder(Data,PolyName)
% Get polynomial order.
% A, C, D, F: Do not count leading terms

Nsys = numel(Data);
Value1 = polyorder(Data(1),PolyName);
if Nsys==1
   Value = Value1;
else
   Value = zeros([size(Value1),size(Data)]);
   Value(:,:,1) = Value1;
   for ct = 2:Nsys
      Value(:,:,ct) = polyorder(Data(ct),PolyName);
   end
end
end
