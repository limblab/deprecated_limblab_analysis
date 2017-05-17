function List = getAlgorithmFields(ModelType)
% Get list of algorithm options that could be specified as PV pairs to
% estimators. Since such options must be specified using options objects,
% these names have to detected in PV pairs to estimators when there is a
% conflict: that is, when both options and PV pairs are used.
%
% Type: One of 'linear', 'nlblack' or 'nlgrey'.

%   Copyright 2010-2013 The MathWorks, Inc.

switch lower(ModelType)
   case 'linear'
      List = {'Algorithm', 'Focus', 'MaxIter', 'Tolerance', 'LimitError', ...
         'MaxSize','SearchMethod', 'Criterion', 'Weighting', 'FixedParameter',...
         'Display', 'Trace', 'N4Weight', 'N4Horizon', 'Regularization', 'Advanced'};
   case 'nlblack'
      % REVISIT
   case 'nlgrey'
end
