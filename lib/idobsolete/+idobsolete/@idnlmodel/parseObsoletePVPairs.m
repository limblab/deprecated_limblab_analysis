function [AlgoPV, PV] = parseObsoletePVPairs(Command,PV)
%PARSEOBSOLETEPVPAIRS Separate out algorithm properties from estimator PV list.
% Default implementation for common algorithm properties of all nonlinear
% models. STATIC METHOD.

% Copyright 2014-2015 The MathWorks, Inc.

AlgoPV = cell(1,0);
if isempty(PV)
   return
elseif rem(length(PV),2)~=0
   ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs',Command,Command)
end
AlgProps = {'SearchMethod','MaxIter','Tolerance','LimitError','MaxSize',...
   'Criterion','Weighting','Display','Trace','IterWavenet','Regularization'};
L = 2*ones(1,length(AlgProps));
L([2 5]) = 4;
for ct = 1:numel(AlgProps)
   if isempty(PV)
      break;
   end
   thisProp = AlgProps{ct};
   I = idpack.findOptionInList(thisProp,PV(1:2:end),L(ct));
   if ~isempty(I)
      Value = PV{2*(I(end))};
      
      AlgoPV = [AlgoPV, thisProp, Value]; %#ok<AGROW>
      PV([2*I-1, 2*I]) = [];
   end
end

% Trace->Display
I = strcmp(AlgoPV,'Trace');
if any(I)
   AlgoPV{I} = 'Display';
end
