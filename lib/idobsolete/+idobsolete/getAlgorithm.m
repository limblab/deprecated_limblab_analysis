function Value = getAlgorithm(sys)
% GET method implementation for Algorithm property.

%   Author(s): Rajiv Singh
%   Copyright 2010-2014 The MathWorks, Inc.

[Options, Extras] = getDefaultOptions(sys);

% Create obsolete Algorithm structure using Options and Extras.
% Options and Extras are stored under Model.Data_ (linear) or Model
% (nonlinear, protected) as properties EstimationOptions and ExtraOptions
% respectively.
Value = idobsolete.getDefaultAlgorithm(sys);

% Copy extras
if ~isempty(Extras)
   Value = localCopyExtraOptions(Value, Extras);
end

% Copy options
if ~isempty(Options)
   Value = option2Algorithm(Options,Value);
end

%--------------------------------------------------------------------------
%                   Local Functions
%--------------------------------------------------------------------------
%$$$$$$$$$$$$$$$$$$$ WAER WEQ TWQETRET REYT WQ%^% BNW%Y W
function Algo = localCopyExtraOptions(Algo, Extras)
% Copy Extras fields to corresponding locations in Algo.

fl = fieldnames(Extras);
for ct = 1:length(fl)
   if ~isstruct(Extras.(fl{ct}))
      Algo.(fl{ct}) = Extras.(fl{ct});
   else
      Algo.(fl{ct}) = localCopyExtraOptions(Algo.(fl{ct}), Extras.(fl{ct}));
   end
end
