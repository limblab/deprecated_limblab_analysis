function result = subsref(M,Struct)
%SUBSREF  Subscripted reference for static or dynamic models.
%
%   The following reference operations can be applied to any model M:
%      M(rows,columns)    select subset of rows and columns
%      M.propertyName     access value of property "propertyName".
%
%   For arrays of models, indexed referencing takes the form
%      M(rows,columns,j1,...,jk)
%   where k is the number of array dimensions. Use
%      M(:,:,j1,...,jk)
%   to access the (j1,...,jk) model in the model array.
%
%   See also DYNAMICSYSTEM/SUBSASGN, DYNAMICSYSTEM, STATICMODEL.

% Overridden to handle obsolete struct-type get/set of model parameters.

%   Copyright 1993-2011 The MathWorks, Inc.

ni = nargin;
if ni==1,
   result = M;  return
end

try
   % Peel off first layer of subreferencing
   switch Struct(1).type
      case '.'
         % The first subreference is of the form M.fieldname
         Struct(1).subs = ltipack.matchProperty(Struct(1).subs,...
            ltipack.allprops(M),class(M));
         if length(Struct)>1 && any(strcmp(Struct(1).subs,...
               {'Kp','Tp1','Tp2','Tp3','Tw','Zeta','Td','Tz'})) && ...
               strcmp(Struct(2).type,'.')
            Value = getParStruct(M, Struct(1).subs);
            result = Value.(Struct(2).subs);
            Struct = Struct(2:end);
         else
            result = builtin('subsref',M,Struct(1));
         end
      case '()'
         % The first subreference is of the form M(indices)
         result = subparen(M,Struct(1).subs);
      case '{}'
         ctrlMsgUtils.error('Control:ltiobject:subsref3')
   end
   if length(Struct)>1
      % SUBSREF for InputOutputModel objects can't be invoked again
      % inside this method so jump out to make sure that downstream
      % references to InputOutputModel properties are handled correctly,
      result = ltipack.dotref(result,Struct(2:end));
   end
catch E
   ltipack.throw(E,'subsref',class(M))
end
