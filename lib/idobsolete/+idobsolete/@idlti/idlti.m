classdef (CaseInsensitiveProperties, TruncatedProperties, Hidden) idlti < lti
   % Class defining obsolete IDLTI attributes.
   
   %   Author(s): Rajiv Singh
   %   Copyright 2009-2015 The MathWorks, Inc.
   
   properties (Hidden, Dependent)      
      udelay % alias of InputDelay
      uname  % alias of InputName
      yname  % alias of OutputName
      uunit  % alias of InputUnit
      yunit  % alias of OutputUnit
   end
   
   properties(Hidden, Dependent, SetAccess = protected)
      EstimationInfo
   end
   
   methods      
      function Value = get.EstimationInfo(sys)
         % GET method for obsolete property "EstimationInfo"
         Value = getEstimationInfo(sys);
      end
      
      function Value = get.udelay(sys)
         % GET method for obsolete alias property "udelay"
         Value = sys.InputDelay;
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
      
      function sys = set.udelay(sys, Value)
         % SET method for obsolete property alias "udelay"
         sys.InputDelay = Value;
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
      
      function varargout = set(sys,varargin)
         %SET  Modifies values of model properties.
         %
         %   SET(M,'Property',VALUE) sets the property with name 'Property'
         %   to the value VALUE. This is equivalent to M.Property = VALUE.
         %
         %   SET(M,'Property1',Value1,'Property2',Value2,...) sets multiple
         %   property values in a single command.
         %
         %   M2 = SET(M,'Property1',Value1,...) returns the modified model M2.
         %
         %   SET(M,'Property') displays information about the specified
         %   property of M.
         %
         %   See also GET, INPUTOUTPUTMODEL.
         no = nargout; ni = nargin;
         if ~isa(sys,'DynamicSystem'),
            % Call built-in SET. Handles calls like set(gcf,'user',ss)
            builtin('set',sys,varargin{:});
            return
         elseif ni<3 || isa(sys,'idproc')
            [varargout{1:no}] = set@lti(sys,varargin{:});
         else
            ClassName = class(sys);
            if rem(ni-1,2)~=0,
               ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
            end
            PublicProps = ltipack.allprops(sys);
            sys.CrossValidation_ = false;
            % Determine complete, case-sensitive match to target property names
            for ct=1:2:ni-1
               varargin{ct} = ltipack.matchProperty(varargin{ct},PublicProps,ClassName);
            end
            
            % Remove duplicate specifications
            Ir = 1:ni-1;
            [~,I] = unique(varargin(1:2:end-1),'legacy');
            Ir([2*I-1,2*I]) = [];
            varargin(Ir) = [];
            ni = ni-length(Ir);
            
            % Move covariance towards the end since it may be reset by
            % other property sets.
            I = find(strcmp(varargin,'CovarianceMatrix'));
            if ~isempty(I)
               varargin = [varargin(1:I-1), varargin(I+2:end), varargin([I I+1])];
            end
            
            % Set property values
            for ct = 1:2:ni-1
               sys.(varargin{ct}) = varargin{ct+1};
            end
            sys.CrossValidation_ = true;
            % Check result
            sys = checkConsistency(sys);
            if no>0, varargout{1} = sys; end
         end
         
         if no==0
            % Use ASSIGNIN to update in place
            sysname = inputname(1);
            if isempty(sysname)
               ctrlMsgUtils.error('Control:ltiobject:setLTI5')
            end
            assignin('caller',sysname,sys)            
         end         
      end       
   end
   
   methods (Hidden)
      [mag,phase,w,sdamp,sdphase] = boderesp(sys,w)
      
      function Value = pvget(sys, Property)
         Value = sys.(Property);
      end
      
      function sys = pvset(sys,varargin)
         % private set
         % do not use "SET" because there might be protected properties in
         % the list
         Pnames = varargin(1:2:end);
         for ct = 1:length(Pnames)
            if strcmp(Pnames,'EstimationInfo')
               Report = estInfo2Report(sys,varargin{2*ct});
               sys = setReport(sys, Report);
            else
               sys.(Pnames{ct}) = varargin{2*ct};
            end
         end
      end
      
      function ts = timestamp(varargin)
         ctrlMsgUtils.warning('Ident:idmodel:timestamp');
         ts = '';
      end
      
      function Version = getVersion(sys)
         Version = sys.Version_;
      end
      
      function sys = inherit(sys, refsys)
         % Copy common properties.         
         sys = copyMetaData(refsys,sys);
         sys.Ts = refsys.Ts;
         sys.Algorithm = refsys.Algorithm;
         sys.InputDelay = refsys.InputDelay;
         sys.TimeUnit = refsys.TimeUnit;
      end
      
   end
   
   methods(Access = protected)            
      function Value = getEstimationInfo(sys)
         % Default implementation of get.EstimationInfo
         ArraySize = getArraySize(sys);
         if prod(ArraySize)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','EstimationInfo')
         end
         Value = idobsolete.getEstimationInfo(sys.Report, class(sys));
      end
      
      function sys = fastSet(sys,varargin)
         % Version of SET without consistency checks.
         % Override lti implementation for ignoring multiple specifications
         % of same property.
         if isa(sys,'idproc')
            sys = fastSet@lti(sys,varargin{:});
            return
         end
         ni = nargin-1;
         if rem(ni,2)~=0,
            ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
         end
         PublicProps = ltipack.allprops(sys);
         ClassName = class(sys);
         sys.CrossValidation_ = false;
         
         % Determine complete, case-sensitive match to target property names
         for ct=1:2:ni-1
            varargin{ct} = ltipack.matchProperty(varargin{ct},PublicProps,ClassName);
         end
         
         % Remove duplicate specifications
         Ir = 1:ni;
         [~,I] = unique(varargin(1:2:end-1),'legacy');
         Ir([2*I-1,2*I]) = [];
         varargin(Ir) = [];
         ni = ni-length(Ir);
         
         for ct = 1:2:ni-1
            sys.(varargin{ct}) = varargin{ct+1};
         end
         sys.CrossValidation_ = true;
      end
   end
end
