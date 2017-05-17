function sys = setParValue(sys, Name, Value)
% Check obsolete specifications for parameter value of a process model.
% Supported syntaxes:
%  model.par = 'estimate' or {'estimate'} % sets model.Structure.par.Free
%  model.par = struct(...) % sets model.Structure.par fields
%  model.par = {'min', Min_Value} % sets model.Structure.par.Minimum 
%              Similar syntax for 'status', 'max', 'value'

%   Author(s): Rajiv Singh
%   Copyright 2011-2012 The MathWorks, Inc.
%     $Date: 2010/02/08 22:46:47 

OldValue = getParStruct(sys, Name); % struct of old value; checks model array
if isstruct(Value)
   f = {'status','min','max','value'};
   if ~all(ismember(f,fieldnames(Value)))
      localError('Ident:idmodel:idprocObsoleteChk2',Name)
   elseif isequaln(Value,OldValue)
      return
   end
   sys = localSetStatus(sys,Name,OldValue.status,Value.status);
   sys = localSetMinMax(sys,Name,OldValue.min,Value.min,'Minimum');
   sys = localSetMinMax(sys,Name,OldValue.max,Value.max,'Maximum');
   sys = localSetValue(sys,Name,OldValue.value,Value.value);
elseif ischar(Value)
   if isequal(OldValue.status,{Value}), return, end
   sys = localSetStatus(sys,Name,OldValue.status,{Value});
elseif iscell(Value)
   Type = ltipack.matchKey(Value{1},{'status','Minimum','Maximum','value'});
   if isempty(Type)
      % assume status set
      if isequal(OldValue.status,Value), return, end
      sys = localSetStatus(sys,Name,OldValue.status,Value);
   else
      switch Type
         case 'status'
            % {'status', 'e', 'f', ...}
            if isequal(OldValue.status,Value(2:end)), return, end
            sys = localSetStatus(sys,Name,OldValue.status,Value(2:end));
         case {'Minimum','Maximum'}
            % {'min', [a, b, c ,..]}
            if isequaln(OldValue.(lower(Type(1:3))),Value{2}), return, end
            sys = localSetMinMax(sys,Name,OldValue.(lower(Type(1:3))),Value{2},Type);
         case 'value'
            % {'value', [a, b, c ,..]}
            if isequaln(OldValue.value,Value{2}), return, end
            sys = localSetValue(sys,Name,OldValue.value,Value{2});
      end
   end   
elseif isnumeric(Value)
   % assume value set
   if isequaln(OldValue.value,Value), return, end
   sys = localSetValue(sys,Name,OldValue.value,Value);
else
   if strcmpi(Name,'InputLevel')
      ctrlMsgUtils.error('Ident:idmodel:idprocULev1')
   else   
      ctrlMsgUtils.error('Ident:idmodel:idprocSetChk1',Name,['help idproc.',Name])
   end
end

sys = incrementEstimationStatus(sys);

%--------------------------------------------------------------------------
function sys = localSetStatus(sys, Name, OldValue, NewValue)
% Interprete 'status' settings and update model accordingly.

if ischar(NewValue), NewValue = {NewValue}; end
ny = size(sys,1);
if isscalar(NewValue)
   NewValue = repmat(NewValue,size(OldValue));
end
if (ny==1 && ~isequal(numel(OldValue),numel(NewValue))) || ...
      (ny>1 && ~isequal(size(OldValue), size(NewValue)))
   localError('Ident:idmodel:idprocObsoleteChk3','status',Name)
elseif ~iscellstr(NewValue)
   localError('Ident:idmodel:idprocObsoleteChk4',Name)
end

ulevpar = strcmpi(Name,'InputLevel');
Expected = {'estimate','zero','fixed'};
NewValue = cellfun(@(x)ltipack.matchKey(x,Expected),NewValue,'UniformOutput',false);
if any(cellfun(@(x)isempty(x),NewValue))
   localError('Ident:idmodel:idprocObsoleteChk4',Name)
elseif ~ulevpar
   S = sys.Structure;
   for k = 1:numel(NewValue)
      st = lower(NewValue{k}(1));
      if st~='z' && isempty(S(k).(Name))
         ctrlMsgUtils.error('Ident:idmodel:idprocObsoleteChk5a',Name,Name)
      end
      
      if st=='f'
         S(k).(Name).Free = false;
      elseif st=='e'
         S(k).(Name).Free = true;
      else
         % 'zero'
         if ~isempty(S(k).(Name))
            ctrlMsgUtils.warning('Ident:idmodel:idprocObsoleteChk5b',Name)
            S(k).(Name).Free = false;
            S(k).(Name).Value = 0;
         end
      end
   end
   sys.Structure = S;
else % InputLevel
   [~,nu] = iosize(sys);
   ulev =  getInputOffsetSpec(sys.Data_.EstimationOptions,sys.Type,[nu NaN]);
   Est = strcmpi(NewValue,'estimate');
   if all(strcmpi(NewValue,'fixed'))
      ulev.Free = false;
   elseif all(strcmpi(NewValue,'zero'))
      ulev = [];
   elseif any(Est)
      ulev.Free = Est;
      ulev.Value(Est) = NaN;
      ulev.Value(strcmpi(NewValue,'zero')) = 0;
   else
      % all are either zero or fixed      
      ulev.Free = false;
   end
   sys.Data_.EstimationOptions.InputOffset = ulev;
end

%--------------------------------------------------------------------------
function sys = localSetMinMax(sys, Name, OldValue, NewValue, MinMax)
% Set min/max parameter bounds for the named parameter.
% MinMax: 'min' or 'max'.
if isscalar(NewValue)
   NewValue = repmat(NewValue,size(OldValue));
end
ny = size(sys,1);
ulevpar = strcmpi(Name,'InputLevel');
MinMaxName = lower(MinMax(1:3));
if (ny==1 && ~isequal(numel(OldValue),numel(NewValue))) || ...
      (ny>1 && ~isequal(size(OldValue), size(NewValue)))
   localError('Ident:idmodel:idprocObsoleteChk3',MinMaxName,Name)
elseif ~isnumeric(NewValue)
   localError('Ident:idmodel:idprocObsoleteChk6',MinMaxName,Name)
elseif ~ulevpar
   S = sys.Structure;
   for k = 1:numel(NewValue)
      if ~isempty(S(k).(Name)) && ~isnan(NewValue(k))
         S(k).(Name).(MinMax) = NewValue(k);
      end
   end
   sys.Structure = S;
else % InputLevel
   [~,nu] = iosize(sys);
   ulev =  getInputOffsetSpec(sys.Data_.EstimationOptions,sys.Type,[nu NaN]);
   ulev.(MinMax) = NewValue;
   sys.Data_.EstimationOptions.InputOffset = ulev;
end

%--------------------------------------------------------------------------
function sys = localSetValue(sys, Name, OldValue, NewValue)
% Set parameter value for the named parameter.
if isscalar(NewValue)
   NewValue = repmat(NewValue,size(OldValue));
end
ny = size(sys,1);
ulevpar = strcmpi(Name,'InputLevel');
if (ny==1 && ~isequal(numel(OldValue),numel(NewValue))) || ...
      (ny>1 && ~isequal(size(OldValue), size(NewValue)))
   localError('Ident:idmodel:idprocObsoleteChk3','value',Name)
elseif ~isnumeric(NewValue)
   localError('Ident:idmodel:idprocObsoleteChk6','value',Name)
elseif ~ulevpar
   S = sys.Structure;
   for k = 1:numel(NewValue)
      if ~isempty(S(k).(Name)) 
         S(k).(Name).Value = NewValue(k);
      end
   end
   sys.Structure = S;
else % InputLevel
   [~,nu] = iosize(sys);
   ulev =  getInputOffsetSpec(sys.Data_.EstimationOptions,sys.Type,[nu NaN]);
   ulev.Value = NewValue;
   sys.Data_.EstimationOptions.InputOffset = ulev;
end

%--------------------------------------------------------------------------
function localError(id, varargin)
% Issue error message with obsoletion notice. Notice contents are different
% for InputLevel and the other model parameters.

Name = varargin{end};
msg1 = ctrlMsgUtils.message(id, varargin{:});
if strcmpi(Name,'InputLevel')
   msg2 = ctrlMsgUtils.message('Ident:idmodel:msgIdprocObsoelete2');
else
   msg2 = ctrlMsgUtils.message('Ident:idmodel:msgIdprocObsoelete1');
end
error(id, [msg1, '\n',msg2]);
