classdef (CaseInsensitiveProperties, TruncatedProperties, Hidden) idproc < idobsolete.idmodel
   % Class defining obsolete properties and methods of idproc.
   
   %   Copyright 1993-2015 The MathWorks, Inc.
   
   properties (Hidden, Dependent)
      InputLevel
      DisturbanceModel
      ulevel
   end
   
   properties(Hidden)
      X0
   end
   
   methods
      function Value = pvget(sys, Property)
         % For parameters, return struct
         PropertyName = ltipack.matchKey(Property,...
            {'Kp','Tp1','Tp2','Tp3','Tw','Td','Zeta','Tz'});
         if ~isempty(PropertyName)
            Value = getParStruct(sys,PropertyName);
         else
            Value = sys.(Property);
         end
      end
      
      function Value = get.InputLevel(sys)
         % GET method for InputLevel property. 
         
         % InputLevel is a vector of nu entries even for multioutput
         % systems. InputLevel is not scaled to handle multi-experiment
         % values.         
         Data = sys.Data_;
         if numel(Data)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','InputLevel')
         end
         
         [~, nu] = iosize(Data);
         status = repmat({'zero'},[1, nu]);
         Min = -Inf(1,nu);
         Max = Inf(1,nu);
         Val = zeros(1,nu);
         
         u0 = Data.EstimationOptions.InputOffset;
         if isnumeric(u0) && ~isempty(u0)
            Val = u0(:,min(1,end));
            status = repmat({'fixed'},[1, nu]);
         elseif isa(u0,'param.Continuous')
            u0 = subsrefParameter(u0,{':',1}); % retain info on first experiment only
            Val = u0.Value; Min = u0.Minimum; Max = u0.Maximum;
            u0f = u0.Free;
            for ku = 1:nu
               if u0f(ku)
                  status{ku} = 'estimate';
               else
                  status{ku} = 'fixed';
               end
            end
         end
         Value = struct('status',{status},'min',Min(:)','max',Max(:)','value',Val(:)');
      end
      
      function sys = set.InputLevel(sys, Value)
         % SET method for InputLevel property
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','InputLevel')
         end
         
         sys = setParValue(sys, 'InputLevel',Value);
      end
      
      function Value = get.DisturbanceModel(sys)
         % GET method for DisturbanceModel property
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','DisturbanceModel')
         end
         
         NoiseTF = sys.NoiseTF;
         ny = numel(NoiseTF.num);
         a = num2cell(eye(ny)); c = num2cell(ones(ny,1));
         Flag = sys.Data_.EstimationOptions.DisturbanceModel;
         
         for ky = 1:ny
            a{ky,ky} = NoiseTF.den{ky};
            c{ky} = NoiseTF.num{ky};
         end
         
         DM = idpoly(a,[],c,[],[],'Ts',0,'NoiseVariance',sys.NoiseVariance);
         %Cov = getcov(sys,'factors');
         DM = setcov(DM, getNoiseCovariance(sys.Data_));
         Value = {Flag, DM};
      end
      
      function sys = set.DisturbanceModel(sys, Value)
         % SET method for DisturbanceModel property
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','DisturbanceModel')
         end
         
         if ischar(Value) || (iscellstr(Value) && isscalar(Value))
            if ~ischar(Value), Value = Value{1}; end
            sys.Data_.EstimationOptions.DisturbanceModel = Value;
         elseif iscell(Value) && numel(Value)==2 && ischar(Value{1}) && isa(Value{2},'idpoly')
            sys.NoiseTF = Value;
         elseif isa(Value,'idpoly')
            sys.NoiseTF = Value;
         else
            ctrlMsgUtils.error('Ident:idmodel:idprocObsoleteDMSet')
         end
      end
      
      function Value = get.X0(sys)
         % GET method for X0 property
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','X0')
         end
         Value = sys.Data_.X0;
      end
      
      function sys = set.X0(sys, Value)
         % SET method for X0 property
         if numel(sys.Data_)>1
            ctrlMsgUtils.error('Ident:general:setObsoletePropValArray','X0')
         end
         if isnumeric(Value) && ismatrix(Value) && isreal(Value) && all(isfinite(Value(:)))
            sys.Data_.X0 = double(full(Value));
         else
            ctrlMsgUtils.error('Ident:idmodel:idprocObsoleteX0Set')
         end
      end
      
      function Value = get.ulevel(sys)
         % GET method for ulev property
         Value = sys.InputLevel;
      end
      
      function sys = set.ulevel(sys, Value)
         % SET method for ulevel property
         sys.InputLevel = Value;
      end
   end
   
   methods(Access = protected)
      function sys = setInitialState(sys, Value)
         % SET method overload for obsolete property "InitialState".
         % InitialState coexists with public polyest option
         %
         % Value must be a cell array for right array size.
         
         if ~iscell(Value), Value = {Value}; end         
         if isscalar(Value), Value = repmat(Value,size(sys.Data_)); end
         
         for ct = 1:numel(sys.Data_)
            Vct = ltipack.matchKey(Value{ct}, {'Estimate','Zero','Fixed',...
               'Auto','Backcast', 'Model'});
            if isempty(Vct)
               ctrlMsgUtils.error('Ident:idmodel:idpolyIncorrectIni');
            else
               %{
               if any(Vct(1)=='FM')
                  Vct = 'Zero'; % this is not b.c. 
               end
               %}
               sys.Data_(ct) = setInitialState(sys.Data_(ct),lower(Vct));
            end
         end
      end      
   end
end
