function Value = getParStruct(sys, ParName)
% Get obsolete parameter structure.

%   Copyright 2011 The MathWorks, Inc.
%     $Date: 2010/02/08 22:46:47

if strcmpi(ParName,'InputLevel')
   Value = sys.InputLevel; return
end

if numel(sys.Data_)>1
   ctrlMsgUtils.error('Ident:idmodel:idprocObsoletePropValArray',ParName)
end

S = sys.Structure;
[ny, nu] = size(S);
Status = cell(ny, nu); Val = zeros(ny,nu);
Min = -Inf(ny, nu); Max = Inf(ny, nu);

for ct = 1:ny*nu
   Par = S(ct).(ParName);
   if isempty(Par)
      Status{ct} = 'zero';
      Val(ct) = 0;
      Max(ct) = Inf;
      if any(strncmpi(ParName,{'TZ','KP'},2))
         Min(ct) = -Inf;
      else
         Min(ct) = 0;
      end
   else
      Val(ct) = Par.Value;
      Min(ct) = Par.Minimum;
      Max(ct) = Par.Maximum;
      if Par.Free
         Status{ct} = 'estimate';
      else
         Status{ct} = 'fixed';
      end
   end
end

Value = struct('status',{Status},'min',Min,'max',Max,'value',Val);
