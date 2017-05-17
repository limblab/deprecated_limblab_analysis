function [Props,AsgnVals] = pnames(m, varargin)
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(M)  returns the list PROPS of
%   public properties of the object M (a cell vector), as well as
%   the assignable values ASGNVALS for these properties (a cell vector
%   of strings).  PROPS contains the true case-sensitive property names.
%   These include the public properties of M's parent(s).
%
%   See also  GET, SET.

%       Author: L. Ljung
%       Copyright 1986-2010 The MathWorks, Inc.


% IDMODEL properties
Props = {'A';'B';'dA';'dB';'na';'nb';'nk';'InitialState'};

% Add public parent properties unless otherwise requested
% Also return assignable values if needed

if nargin==1
   if nargout==1
      Props = [Props; idmodelpnames];
   else
      AsgnVals = {'A-polynomial (ny-by-ny-by-na array)';...
         'B-polynomial (ny-by-nu-by-nb array)';...
         'Std deviation of A-polynomial (cannot be set)';...
         'Std deviation of B-polynomial (cannot be set)';...
         'Orders of the A-polynomial (ny-by-ny matrix)';...
         'Orders of the B-polynomial (ny-by-nu matrix)';...
         'Input-Output delay matrix (ny-by-nu matrix)';...
         '''Zero'' or ''Estimate'''};
      [IDMProps, IDMVals] = idmodelpnames;
      Props = [Props ; IDMProps];
      AsgnVals = [AsgnVals ; IDMVals];
   end
end

