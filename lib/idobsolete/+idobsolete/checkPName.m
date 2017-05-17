function Value = checkPName(sys, Value)
% Check for "PName" property value of model. Called by idlti.set.PName.

%   Copyright 1986-2011 The MathWorks, Inc.

Value = ChannelNameCheck(Value,'PName',sys);

if length(Value)~=length(sys.ParameterVector) && ~isempty(Value)
   ctrlMsgUtils.error('Ident:idmodel:PnamePvecLenMismatch')
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
if ischar(a) && ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) && ndims(a)==2 && min(size(a))==1,
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1)
      ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(sys)))
   end
else
   ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(sys)))
end

% Make sure that nonempty names are unique
if ~strcmpi(Name(end-3:end),'unit') && length(a)>1
   nonemptya = setdiff(a,{''}); %removes duplicate entries in a as well as ''.
   eI = strcmp(a,'');
   if length(a)~=(sum(eI)+length(nonemptya))
      ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,upper(class(sys)))
   end
end
