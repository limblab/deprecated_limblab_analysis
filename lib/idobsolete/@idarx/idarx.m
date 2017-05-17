classdef (InferiorClasses = {? matlab.graphics.axis.Axes}) idarx < idParametric & idobsolete.idmodel
   % IDARX is obsolete.
   % * Use IDPOLY instead which can now represent ARX models of arbitrary
   %   size.
   % * You can convert an existing IDARX model into IDPOLY using the
   %   "idpoly" command (idpoly_model = idpoly(idarx_model)).
   % * You can convert an IDPOLY model of ARX structure into an IDARX model
   %   using the "idarx" command (idarx_model = idarx(idpoly_model)).
   % * Type "edit idarx" or "type idarx" to view old help content for IDARX.
   
   % Old help content:
   %IDARX  Create IDARX model structure.
   %
   %   M = IDARX(A,B,Ts)
   %   M = IDARX(A,B,Ts,'Property',Value,..)
   %
   %   Describes the multivariable ARX model
   %
   %   A0*y(t)+A1*y(t-T)+ ... + An*y(t-nT) =
   %	                       B0*u(t)+B1*u(t-T)+Bm*u(t-mT) + e(t)
   %
   %   with ny outputs and nu inputs.
   %   A is a ny-by-ny-by-n array, such that A(:,:,k+1) = Ak.
   %   The normalization must be such that A0 = eye(ny).
   %   B is similarly an ny-by-nu-by-m array.
   %
   %   Ts is the sample time.
   %   For more info on IDARX properties, type SET(IDARX) or IDPROPS IDARX.
   %
   %   See also IDPOLY, ARX, IDSS, IDPROC, IDMODEL, IDNLARX, IDGREY, IDPROPS.
   
   %   Author(s): Rajiv Singh
   %   Copyright 1986-2015 The MathWorks, Inc.
   
   properties(Dependent)
      na
      nb
      nk
      A
      B
   end % properties
   
   properties(Dependent, SetAccess = private)
      dA
      dB
   end
   
   properties(Access = private)
      Algorithm_
      EstimationInfo_
   end
   
   % TYPE MANAGEMENT IN BINARY OPERATIONS
   methods (Static, Hidden)
      
      function T = inferiorTypes()
         T = cell(1,0);
      end
      
      function boo = isClosed(op)
         boo = strcmp(op,'cat');
      end
      
      function T = toClosed(~)
         T = 'ss';
      end
      
      function A = getAttributes(A)
         % Override default attributes
         A.Structured = false;
         A.FRD = false;
         A.Generic = false;
      end
      
      function T = toStructured(uflag)
         if uflag
            T = 'uss';
         else
            T = 'genss';
         end
      end
      
      function T = toFRD(~)
         T = 'idfrd';
      end
      
      function T = toGeneric(~)
         T = 'ss';
      end
      
   end % static methods
   
   methods
      function sys = idarx(varargin)
         % Create IDARX model object.
         
         ctrlMsgUtils.warning('Ident:idmodel:idarxObsolete')
         ni = nargin;
         if ni
            % Allow conversion from idpoly (ARX form; see idpoly/idarx),
            % and FIR form idtf but not others
            if isa(varargin{1},'lti') && ~isa(varargin{1},'idarx')
               ctrlMsgUtils.error('Ident:transformation:conversionToIDARX1')
            end
            
            % Quick exit for idarx objects
            if isa(varargin{1},'idarx')
               if ni~=1
                  ctrlMsgUtils.error('Ident:general:useSetForProp','IDARX');
               end
               sys = varargin{1};
               return
            end
            
            % Dissect input list
            PVstart = find(cellfun('isclass',varargin,'char'),1,'first');
            
            if ~isempty(PVstart) && PVstart~=4
               ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','idarx','idarx')
            end
            
            A = varargin{1};
            if nargin>1
               B = varargin{2};
            else
               B = zeros(size(A,1),0);
            end
            if nargin>2
               Ts = varargin{3};
            else
               Ts = -1;
            end
            
            if Ts==0
               ctrlMsgUtils.error('Ident:idmodel:CTIDARX')
            end
            
            [ny,nu,nb] = size(B);
            if nb==0, B = zeros(ny,nu,1); end
            Data = idobsolete.idarxdata(A,B,Ts);
            % consistency check via comnputation of parameter vector
            try
               getParameterVector(Data);
            catch E
               throw(E)
            end
            sys.Data_ = Data;
            sys.IOSize_ = [size(A,1), size(B,2)];
            sys.Algorithm_ = iddef('algorithm');
            sys.EstimationInfo_ = iddef('estimation');
            sys.Algorithm_.Weighting = eye(sys.IOSize_(1));
            
            if ni>3
               try
                  % User-defined properties
                  Settings = varargin(:,PVstart:ni);
                  
                  % Apply settings
                  if ~isempty(Settings)
                     sys = fastSet(sys,Settings{:});
                  end
                  
                  % Consistency check
                  sys = checkConsistency(sys);
                  
               catch E
                  throw(E)
               end
            end
         else
            sys.Data_ = idobsolete.idarxdata(1,zeros(1,0),1);
            sys.Algorithm_ = iddef('algorithm');
            sys.Algorithm_.Weighting = 1;
            sys.EstimationInfo_ = iddef('estimation');
            sys.IOSize_ = [1 0];
         end
      end % constructor
      
      function Value = get.na(sys)
         Value = arxorder(sys.Data_);
      end
      
      function Value = get.nb(sys)
         [~,Value] = arxorder(sys.Data_);
      end
      
      function Value = get.nk(sys)
         [~,~,Value] = arxorder(sys.Data_);
      end
      
      function Value = get.A(sys)
         %Value = arxdata(sys);
         Value = sys.Data_.A;
      end
      
      function Value = get.B(sys)
         %[~,Value] = arxdata(sys);
         Value = sys.Data_.B;
      end
      
      function Value = get.dA(sys)
         [~,~,Value] = arxdata(sys);
      end
      
      function Value = get.dB(sys)
         [~,~,~,Value] = arxdata(sys);
      end
      
      function sys = set.na(sys, Value)
         if ~all(all(fix(Value)==Value)') || any(any(Value<0)')  || ...
               any(~isfinite(Value(:))) || ~isreal(Value) || ~ismatrix(Value) ||...
               size(Value,1)~=size(Value,2)
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset1')
         end
         
         % Adjust ParameterVector
         naold = sys.na; aold = sys.A; szold = size(naold);
         sznew = size(Value);
         if sznew(1)<szold(1)
            aold = aold(1:sznew(1),1:sznew(1),:);
            szold = sznew;
         end
         
         namax = max(Value(:));
         anew = zeros(sznew(1),sznew(1),namax+1);
         for ct1 = 1:sznew(1)
            for ct2 = 1:sznew(2)
               anew(ct1,ct2,2:1+Value(ct1,ct2)) = -eps;
            end
         end
         anew(:,:,1) = eye(sznew(1));
         for ky1 = 1:szold(1)
            for ky2 = 1:szold(1)
               if naold(ky1,ky2) >= Value(ky1,ky2)
                  L = Value(ky1,ky2)+1;
                  anew(ky1,ky2,2:L) = aold(ky1,ky2,2:L);
               else
                  L = min(namax,naold(ky1,ky2))+1;
                  anew(ky1,ky2,2:L) = aold(ky1,ky2,2:L);
                  anew(ky1,ky2,L+1:L+Value(ky1,ky2)-naold(ky1,ky2)) = -eps;
               end
               
            end
         end
         
         sys.Data_.A = anew;
         
         if sys.CrossValidation_
            sys = checkDataConsistency(sys);
         end
      end
      
      function sys = set.nb(sys, Value)
         if ~all(all(fix(Value)==Value)') || any(any(Value<0)') ||  ...
               any(~isfinite(Value(:))) || ~isreal(Value) || ~ismatrix(Value)
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset2')
         end
         
         % Adjust ParameterVector
         nbold = sys.nb; bold = sys.B; szold = size(nbold);
         sznew = size(Value);
         if sznew(1)<szold(1)
            bold = bold(1:sznew(1),:,:);
            szold(1) = sznew(1);
         end
         
         if sznew(2)<szold(2)
            bold = bold(:,1:sznew(2),:);
            szold(2) = sznew(2);
         end
         
         nk = sys.nk;
         if ~isequal(size(Value), size(nk))
            % Reset 'nk' tentatively assuming new value would be provided
            % by the user; otherwise, consistency check will show expected
            % failure.
            nk = zeros(size(Value));
         end
         nbmax = max(Value(:));
         bnew = zeros(sznew(1),sznew(2),nbmax+max(nk(:)));
         for ct1 = 1:sznew(1)
            for ct2 = 1:sznew(2)
               bnew(ct1,ct2,nk(ct1,ct2)+1:nk(ct1,ct2)+Value(ct1,ct2)) = eps;
            end
         end
         
         for ky = 1:szold(1)
            for ku = 1:szold(2)
               L1 = nk(ky,ku)+1;
               L2 = nk(ky,ku)+min(nbmax,nbold(ky,ku));
               bnew(ky,ku,L1:L2) = bold(ky,ku,L1:L2);
               %bnew(ky,ku,L2+1:L2+nbmax-Value(ky,ku)) = eps;
            end
         end
         
         sys.Data_.B = bnew;
         
         if sys.CrossValidation_
            sys = checkDataConsistency(sys);
         end
      end
      
      function sys = set.nk(sys, Value)
         if ~all(all(fix(Value)==Value)')||any(any(Value<0)') || ...
               any(~isfinite(Value(:))) || ~isreal(Value)
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset3')
         end
         
         % If size of nk changes, nb (and hence B) must already be of the
         % new size. Hence assume that size(nk)==size(nb)
         nk = Value; nb = sys.nb; 
         
         % Enforce dim matching regardless of sys.CrossValidation_ flag;
         % IDARX/SET would ensure that nk is changed after nb.
         if ~isempty(nk) && ~isempty(nb) && ~isequal(size(nk,1),size(nb,1))
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset8')
         elseif ~isequal(size(nk,2),size(nb,2))
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset9')
         end
         
         sys.Data_ = setnk(sys.Data_,nk);
         if sys.CrossValidation_
            sys = checkDataConsistency(sys);
         end
      end
      
      function sys = set.A(sys, Value)
         a = Value;
         if ~isnumeric(a) && ndims(a)~=3 && ~all(all(a(:,:,1)==eye(size(a,1))))
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset4')
         end
         
         if ~all(all(a(:,:,1)==eye(size(a,1))))
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset5')
         end
         
         sys.Data_.A = a;
         
         if sys.CrossValidation_
            sys = checkDataConsistency(sys);
         end
      end
      
      function sys = set.B(sys, Value)
         if ~isnumeric(Value) && ndims(Value)~=3
            ctrlMsgUtils.error('Ident:idmodel:idarxPvset4b')
         end
         sys.Data_.B = Value;
         if sys.CrossValidation_
            sys = checkDataConsistency(sys);
         end
      end
   end % public methods
   
   methods(Hidden)
      
      function np = nparams(sys,~)
         % Number of parameters in the model (assumed all free)
         np = sum(sum([sys.na, sys.nb]));
      end
      
      function Out = set(sys,varargin)
         % Specialize DynamicSystem/set to detect simultaneous changes to
         % interdependent properties.
         
         % One or more of na, nb, nk, A, B, ParameterVector can be changed
         % simultaneously. Changing na, nb, nk and ParameterVector all
         % change A, B (no separate storage). To simplify handling of
         % inconsistencies, we use the following rules:
         % - ParameterVector length must be always be consistent with
         %   number of parameters.
         % - size of nk must match [ny nu].
         if ~isa(sys,'DynamicSystem'),
            % Call built-in SET. Handles calls like set(gcf,'user',ss)
            builtin('set',sys,varargin{:});
            return
         end
         
         names = varargin(1:2:end);
         
         ink = idpack.findOptionInList('nk',names,2);
         % Move 'nk' to the end
         if ~isempty(ink)
            vnk = varargin([2*ink-1, 2*ink]);
            varargin([2*ink-1, 2*ink]) = [];
            varargin = [varargin, vnk];
         end
         
         % Move ParameterVector to the very end (after nk)
         ip = idpack.findOptionInList('ParameterVector',names,2);
         if ~isempty(ip)
            vp = varargin([2*ip-1, 2*ip]);
            varargin([2*ip-1, 2*ip]) = [];
            varargin = [varargin, vp];
         end
         
         Out = set@idlti(sys,varargin{:});
         if nargout==0
            % Use ASSIGNIN to update in place
            sysname = inputname(1);
            if isempty(sysname)
               ctrlMsgUtils.error('Control:ltiobject:setLTI5')
            end
            assignin('caller',sysname,Out);
         end
      end
      
      function fnames = fieldnames(sys)
         % FIELDNAMES  Returns the field names of IDARX model.
         
         % Return field names.
         fnames = pnames(sys);
      end
      
      function sys = parset(sys, parvec)
         sys.ParameterVector = parvec;
      end
      
      function sys = inherit(sys, refsys)
         % Copy common properties.
         sys = copyMetaData(refsys,sys);
         sys.TimeUnit = refsys.TimeUnit;
         sys.Ts = refsys.Ts;
         sys.Algorithm = refsys.Algorithm;
         sys.EstimationInfo_ = refsys.EstimationInfo;
         sys.InputDelay = refsys.InputDelay;
         if getEstimationStatus(refsys)==1
            sys.EstimationInfo_.Status = ...
               ctrlMsgUtils.message('Ident:general:msgModifiedAfterEstimation');
         end
      end
      
      function varargout = arxdata(sys, varargin)
         % Calculate ARX polynomial matrices
         [varargout{1:nargout}] = arxdata(sys.Data_, varargin{:});
      end
      
      function res = isaimp(sys)
         % Test if a model is an impulse response model.
         res = isaimp(sys.Data_);
      end
      
      function Value = getParameterVector(sys)
         Value = getParameterVector(sys.Data_);
      end
      
      function Report = estInfo2Report(~, es)
         Report = es;
      end
      
      function [sys,varargout] = pem(sys, varargin)
         [sys,varargout{1:nargout-1}] = pem(idpoly(sys),varargin{:});
         sys = idarx(sys);
      end
      
      function Value = pvget(sys, Prop)
         Value = sys.(Prop);
      end
      
      function sys = pvset(sys, varargin)
         names = varargin(1:2:end);
         values = varargin(2:2:end);
         for ct = 1:length(names)
            sys.(names{ct}) = values{ct};
         end
      end
      
      function sys = setReport(sys, Report)
         % SET "Report" for a scalar system. Report must be a structure.
         sys.EstimationInfo_ = Report;
      end
      
      function sys = d2c(varargin)
         ctrlMsgUtils.error('Ident:idmodel:CTIDARX');
      end
      
      function Value = getStoredReport(sys)
         Value = getReport(sys);
      end      
   end
   
   methods (Access = protected)
      function M = indexref_(M,indrow,indcol,ArrayIndices)
         Data = M.Data_;
         nind = length(ArrayIndices);
         % Select desired models
         if nind>0
            if nind<ndims(Data)
               ctrlMsgUtils.error('Ident:idmodel:idarxArrayRef');
            else
               for ct = 1:nind
                  if ~isequal(ArrayIndices{ct},1) && ~strcmp(ArrayIndices{ct},':')
                     ctrlMsgUtils.error('Ident:idmodel:idarxArrayRef');
                  end
               end
            end
         end
         M = indexref_@ltipack.SystemArray(M,indrow,indcol,ArrayIndices);
      end
      
      function displaySize(sys,sizes)
         % Displays SIZE information in SIZE(SYS)
         ny = sizes(1);
         nu = sizes(2);
         np = nparams(sys);
         if isempty(np), np = 0; end
         disp(ctrlMsgUtils.message('Ident:idmodel:SizeIDARX',ny,nu,np))
      end
      
      function sys = setTs_(sys,Ts)
         % Implementation of @SingleRateSystem:setTs_
         sys = setTs_@idlti(sys,Ts);
         if Ts==0
            ctrlMsgUtils.error('Ident:idmodel:CTIDARX')
         end
      end
      
      function [sys1,sys2] = matchAttributes(sys1,sys2)
         % Enforces matching attributes in binary operations (e.g.,
         % sampling time, variable,...).
         [sys1,sys2] = matchAttributes@lti(sys1,sys2);
         % Match Variables
         %[sys1,sys2] = ltipack.matchVariable(sys1,sys2);
      end
      
      function Value = getAlgorithm(sys)
         Value = sys.Algorithm_;
      end
      
      function Value = getCovarianceMatrix(sys)
         Value = sys.Data_.Covariance;
         if ~isequal(Value,[])
            Value = getValue(Value,@(x,y)x/y);
         end
      end
      
      function Value = getEstimationInfo(sys)
         Value = sys.EstimationInfo_;
      end
      
      function Value = getPName(sys)
         Value = getplabels(sys.Data_);
      end
      
      function sys = setAlgorithm(sys, Value)
         [~,fie,typ,def] = iddef('algorithm');
         if ~isstruct(Value)
            ctrlMsgUtils.error('Ident:idmodel:invalidAlgoStruct','idmodel')
         end
         
         % Backward compatibility check and update (before R2008a, ver 7.2 of SITB)
         Value = LocalUpdateBkCompatibility(Value,size(sys,1));
         fie2 = fieldnames(Value);
         val = struct2cell(Value);
         for kk = 1:length(fie)
            kf = find(strcmp(fie{kk},fie2)==1);
            if isempty(kf)
               ctrlMsgUtils.error('Ident:idmodel:invalidAlgoStruct','idmodel')
            else
               Value1 = checkalg(fie2{kf}, val{kf},fie,typ,def,sys);
               Value.(fie2{kf}) = Value1;
            end
         end
         sys.Algorithm_ = Value;
      end
      
      function sys = setCovarianceMatrix(sys, Value)
         if ischar(Value)
            if lower(Value(1))=='e'
               Value = [];
            else
               Value = 'None';
            end
         end
         
         if sys.CrossValidation_
            np = nparams(sys);
            if ~ischar(Value) && ~isempty(Value)
               [n1,n2] = size(Value);
               if n1~=np || n2~=np
                  ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
               end
            elseif (ischar(Value) && strcmpi(Value(1),'n')) || isempty(Value)
               % If covariance has been nullified the "variance models" should be deleted
               ut = sys.Utility;
               if isfield(ut,'Pmodel')
                  ut.Pmodel = [];
               end
               if isfield(ut,'Idpoly')
                  ut.Idpoly = [];
               end
               sys.Utility = ut;
            end
         end
         
         sys.Data_.Covariance = idpack.RawCovariance(Value);
      end
      
      function sys = setInitialState(sys, Value)
         sys.Data_ = setInitialState(sys.Data_,Value); % no checks, since it is never used
      end
      
      function sys = setEstimationInfo(sys, Value)
         sys.EstimationInfo_ = Value;
      end
      
      function sys = setParameterVector(sys, Value)
         np = nparams(sys);
         if ~isempty(Value) && length(Value)~=np
            ctrlMsgUtils.error('Ident:idmodel:PnamePvecLenMismatch')
         end
         
         sys.Data_ = setParameterVector(sys.Data_, Value);
         %sys = timemark(sys);
      end
      
      function sys = setPName(sys, Value)
         Value =  ChannelNameCheck(Value,'PName',sys);
         if sys.CrossValidation_
            np = nparams(sys);
            if ~isempty(Value) && np~=length(Value)
               ctrlMsgUtils.error('Ident:idmodel:PnamePvecLenMismatch')
            end
         end
         sys.Data_ = setplabels(sys.Data_,Value);
         %sys = timemark(sys);
      end
      
      function sys = checkDataConsistency(sys)
         % Check data consistency.
         
         sys = checkDataConsistency@idlti(sys);
         
         np = nparams(sys);
         pname = getplabels(sys.Data_);
         if ~isempty(pname) && length(pname)~=np
            sys.Data_ = setplabels(sys.Data_,[]);
         end
         
         sys.IOSize_ = iosize(sys.Data_);
         
         Est = sys.EstimationInfo_;
         if strcmpi(Est.Status(1:3),'Est')
            Est.Status = ctrlMsgUtils.message('Ident:general:msgModifiedAfterEstimation');
            sys.EstimationInfo_ = Est;
         end
         
         if ~isequal(size(sys.Algorithm_.Weighting,1),size(sys.nk,1))
            sys.Algorithm_.Weighting = eye(size(sys.nk,1));
         end
         %sys = timemark(sys);
      end
      
      function Value = getReport(sys)
         Value = sys.EstimationInfo_;
      end
      
   end % protected methods
   
   % STATIC METHODS
   methods(Static, Hidden)
      sys = loadobj(s)
      
      function sys = make(D,IOSize)
         % Constructs IDPOLY model from idpack.polydata instance
         Warn = ctrlMsgUtils.SuspendWarnings('Ident:Idmodel:idarxObsolete'); %#ok<NASGU>
         sys = idarx;
         sys.Data_ = D;
         if nargin>1
            sys.IOSize_ = IOSize;  % support for empty model arrays
         else
            sys.IOSize_ = iosize(D); % (arrayness not supported)
         end
      end
      
   end
end

%-------------------------------------------------------------------------%
%                          LOCAL FUNCTIONS                                %
%-------------------------------------------------------------------------%

function Value = LocalUpdateBkCompatibility(Value,ny)
% Check if Algorithm is of the old format: SearchDirection is place of
% Search Method, missing Criterion and Weighting

fie = fieldnames(Value);
val = struct2cell(Value);
Indr = strcmpi(fie,'SearchDirection');
if any(Indr) && ~any(strcmpi(fie,'SearchMethod'))
   %ctrlMsgUtils.warning('Ident:idmodel:oldAlgorithm')
   fie{Indr} = 'SearchMethod';
   Value = cell2struct(val,fie);
end

if ~any(strcmp('Criterion',fie))
   Value.Criterion = 'det';
end

if ~any(strcmp('Weighting',fie))
   Value.Weighting = eye(ny);
end

% Rename Trace to Display
IndT = strcmpi('Trace',fie);
if any(IndT)
   fie = fieldnames(Value); val = struct2cell(Value);
   fie{IndT} = 'Display';
   Value = cell2struct(val,fie);
end

% Replace GnsPinvTol with GnPinvConst
se = Value.Advanced.Search;
fie = fieldnames(se);
val = struct2cell(se);
Indr = strcmp(fie,'GnsPinvTol');
if any(Indr)
   fie{Indr} = 'GnPinvConst';
   val{Indr} = 1e4;
   se = cell2struct(val,fie);
   Value.Advanced.Search = se;
end
end

%--------------------------------------------------------------------------
function Value = checkalg(Property,Value,PropAlg,TypeAlg,DefValue,sys)
%errormsg = [];
switch Property
   case PropAlg
      if strcmp(Property,'SearchMethod') && strcmpi(Value,'gns')
         ctrlMsgUtils.warning('Ident:idmodel:obsoleteSearchMethodGNS')
         Value = 'gn';
      end
      
      focskip = 0;
      if strcmp(Property,'Focus')
         if isa(Value,'idmodel') || isa(Value,'lti') || iscell(Value)
            %focskip = 1;
            if iscell(Value)
               if ~any(length(Value)==[2,4,5])%&length(Value)~=2&length(Value)~=5
                  ctrlMsgUtils.error('Ident:idmodel:invalidFocFilt1')
               end
            else
               [ny,nu]=size(Value);
               if max(ny,nu)>1 || nu==0
                  ctrlMsgUtils.error('Ident:idmodel:invalidFocFilt2')
               end
            end
            return
         end
         if isnumeric(Value),  %%TM
            if size(Value,2)==2 || size(Value,2)==1,
               return
            end
         end
      end %focus
      
      if strcmp(Property,'Weighting')
         ny = size(sys,1);
         if isequal(Value,[])
            Value = eye(ny);
         end
         if ~ismatrix(Value)
            ctrlMsgUtils.error('Ident:general:incorrectWeighting1',ny);
         end
         
         [sr,sc]  = size(Value);
         if ny==0
            if ~isempty(Value)
               ctrlMsgUtils.error('Ident:general:incorrectWeighting2');
            end
         elseif ny==1
            if isempty(Value) || ~(isscalar(Value) && isreal(Value) && isfinite(Value) && Value>0)
               ctrlMsgUtils.error('Ident:general:positiveScalarAlgPropVal','Weighting');
            end
         elseif (sr~=sc) || (sr~=ny) || ~(~isempty(Value) && isreal(Value) && ismatrix(Value) && isnumeric(Value) && ...
               all(isfinite(Value(:))) && (min(eig(Value))>=0))
            ctrlMsgUtils.error('Ident:general:incorrectWeighting1',ny);
         end
      end %Weighting
      
      nr = strcmp(Property,PropAlg);
      prop = PropAlg(nr);
      typ = TypeAlg(nr);
      if isempty(Value)
         Value = DefValue{nr};
         return
      end
      if strcmpi(prop,'Focus') && ~focskip
         try
            Value = pnmatchd(Value,typ{:},6);
         catch
            ctrlMsgUtils.error('Ident:idmodel:invalidFocus')
         end
      elseif strcmp(prop,'N4Horizon')
         if ischar(Value)
            Value = 'Auto';
         else
            [~,nc] = size(Value);
            if nc == 1
               Value = Value*ones(1,3);
            elseif nc~=3
               ctrlMsgUtils.error('Ident:idmodel:invalidN4Horizon1');
            end
            if ~isempty(Value) && (ischar(Value) || ~isreal(Value) || any(Value(:)<0) ||...
                  any(fix(Value(:))~=Value(:)))
               ctrlMsgUtils.error('Ident:idmodel:invalidN4Horizon2')
            end
            
         end
      elseif strcmp(prop,'N4Weight')
         typ = typ{1};
         
         try
            Value = pnmatchd(Value,typ(:),6);
         catch
            ctrlMsgUtils.error('Ident:idmodel:invalidN4Weight')
         end
      else
         typ = typ{1};
         if length(typ)>1
            try
               Value = pnmatchd(Value,typ(:),6);
            catch 
               ctrlMsgUtils.error('Ident:idmodel:invalidAlgoPropVal',prop{1})
            end
         else
            switch typ{1}
               case 'positive'
                  if ischar(Value) || ~isreal(Value) || ~isscalar(Value) || any(Value<0)
                     ctrlMsgUtils.error('Ident:general:nonnegativeNumAlgPropVal',Property)
                  end
               case 'integer'
                  if strcmp(Property,'MaxSize') && (ischar(Value) || isempty(Value))
                     Value = 'Auto';
                  elseif strcmpi(Property,'MaxIter') && (Value==-1 || Value==0)
                     % do nothing
                  elseif ~idpack.isPosIntScalar(Value)
                     ctrlMsgUtils.error('Ident:general:positiveIntAlgPropVal',Property)
                  end
                  if strcmp(Property,'MaxSize') && ~ischar(Value)
                     if Value<50
                        ctrlMsgUtils.warning('Ident:idmodel:smallMaxSize')
                     end
                  end
                  
               case 'intarray'
                  if ~strcmp(prop,'N4Horizon')
                     if ~isempty(Value) && ~idpack.isNonnegRealMatrix(Value)
                        ctrlMsgUtils.error('Ident:general:positiveIntArrayAlgPropVal',Property)
                     end
                  end
               case 'structure'
                  if ~isstruct(Value)
                     ctrlMsgUtils.error('Ident:general:structAlgPropVal',Property)
                  end
                  % More tests could be added
            end
         end
      end
   otherwise
      ctrlMsgUtils.error('Ident:general:unknownAlgoProp',Property,'idmodel algorithm')
end
end

%--------------------------------------------------------------------------
function a = ChannelNameCheck(a,Name,sys)
% Checks specified I/O names
if isempty(a),
   a = a(:);   % make 0x1
   return
end

% Determine if first argument is an array or cell vector
% of single-line strings.
if ischar(a) && ismatrix(a),
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) && ismatrix(a) && min(size(a))==1,
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1)
      ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(sys)))
   end
else
   ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(sys)))
end

% Make sure that nonempty I/O names are unique
if ~strcmpi(Name(end-3:end),'unit') && length(a)>1
   nonemptya = setdiff(a,{''}); %removes duplicate entries in a as well as ''.
   eI = strcmp(a,'');
   if length(a)~=(sum(eI)+length(nonemptya))
      ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,upper(class(sys)))
   end
end
end
