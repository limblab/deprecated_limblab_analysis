function [AlgoPV, PV] = parseObsoletePVPairs(Command,PV)
%PARSEOBSOLETEPVPAIRS Separate out algorithm properties from estimator PV list.
% Default implementation for common algorithm properties of all nonlinear
% models. STATIC METHOD.

% Copyright 2014 The MathWorks, Inc.

AlgoPV = cell(1,0);
if isempty(PV)
   return
end

[AlgoPV, PV] = idobsolete.idnlmodel.parseObsoletePVPairs(Command,PV);
AlgProps = {'GradientOptions','Advanced'};

for ct = 1:numel(AlgProps)
   if isempty(PV)
      break;
   end
   thisProp = AlgProps{ct};
   I = idpack.findOptionInList(thisProp,PV,2);
   if ~isempty(I)
      AlgoPV = [AlgoPV, thisProp, PV{2*I(end)}]; %#ok<AGROW>
      PV([2*I-1, 2*I]) = [];
   end
end
