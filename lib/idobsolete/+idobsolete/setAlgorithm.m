function sys = setAlgorithm(sys, Algo)
% Update DefaultOptions based on Algorithm setting.

%   Author(s): Rajiv Singh
%   Copyright 2010-2014 The MathWorks, Inc.

% Clean up Algorithm for outdated fields.
if isa(sys,'idlti')
   Algo = localUpdateOldLinearAlgo(Algo, size(sys,1));
end

% Keep only those algorithm entries that are not at their default values.
Options = getDefaultOptions(sys);
Algo = localPruneAlgorithm(sys, Algo, Options);

% Validate changed Algorithm option values.
Algo = idoptions.utValidateEstimationOptions(Algo,[],sys);

% Transfer applicable options from Algorithm structure to default options
% stored with the model (if any)

if ~isempty(Options)
   [Options, Algo] = algorithm2Option(Options, Algo);
end

sys = setDefaultOptions(sys, Options, Algo);

%--------------------------------------------------------------------------
function Algo = localPruneAlgorithm(sys, Algo, Options)
% Validate algorithm structure.

IsLinear = isa(sys, 'idlti');

DefaultAlgo = idobsolete.getDefaultAlgorithm(sys);
if ~isempty(Options)
   DefaultAlgo = option2Algorithm(Options, DefaultAlgo);
end
if isfield(Algo,'ProgressWindow')
   Algo = rmfield(Algo, 'ProgressWindow');
end
if ~isscalar(Algo) || ~isstruct(Algo) || ~all(ismember(fieldnames(Algo),fieldnames(DefaultAlgo))) || ...
      ~isstruct(Algo.Advanced) || ...
      ~all(ismember(fieldnames(Algo.Advanced), fieldnames(DefaultAlgo.Advanced))) ||...
      IsLinear && ( ...
      ~isstruct(Algo.Advanced.Search) || ...
      ~all(ismember(fieldnames(Algo.Advanced.Search), fieldnames(DefaultAlgo.Advanced.Search))) ||...
      ~isstruct(Algo.Advanced.Threshold) || ...
      ~all(ismember(fieldnames(Algo.Advanced.Threshold), fieldnames(DefaultAlgo.Advanced.Threshold)))...
      )
   ctrlMsgUtils.error('Ident:general:invalidAlgorithm')
end

flnew = fieldnames(Algo);

% Prune Algo fields whose values are their default.
for ct = 1:length(flnew)
   p = flnew{ct};
   if (ischar(Algo.(p)) && ischar(DefaultAlgo.(p)) && ...
         strcmpi(Algo.(p), DefaultAlgo.(p))) || ...
         isequal(Algo.(p), DefaultAlgo.(p))
      Algo = rmfield(Algo, flnew{ct});
   end
end

if isfield(Algo, 'Advanced')
   Advanced = Algo.Advanced;
   advfl = fieldnames(Advanced);
   for ct = 1:length(advfl)
      if isequal(Advanced.(advfl{ct}), DefaultAlgo.Advanced.(advfl{ct}))
         Advanced = rmfield(Advanced, advfl{ct});
      end
   end
   
   if IsLinear && ~isempty(Advanced) && isfield(Advanced, 'Search')
      Search = Advanced.Search;
      searchfl = fieldnames(Search);
      for ct = 1:length(searchfl)
         if isequal(Search.(searchfl{ct}), DefaultAlgo.Advanced.Search.(searchfl{ct}))
            Search = rmfield(Search, searchfl{ct});
         end
      end
      Advanced.Search = Search; % Search fieldnames can't be empty if Search exists 
   end
   
   if IsLinear && ~isempty(Advanced) && isfield(Advanced, 'Threshold')
      Threshold = Advanced.Threshold;
      threshfl = fieldnames(Threshold);
      for ct = 1:length(threshfl)
         if isequal(Threshold.(threshfl{ct}), DefaultAlgo.Advanced.Threshold.(threshfl{ct}))
            Threshold = rmfield(Threshold, threshfl{ct});
         end
      end
      Advanced.Threshold = Threshold;
   end
   
   Algo.Advanced = Advanced;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = localUpdateOldLinearAlgo(Value,ny)
% Check if Algorithm is of the old format and fix deprecated fields
%
% Potential differences:
% - SearchDirection is place of SearchMethod
% - Missing Criterion and Weighting
% - GnsPinvTol in place of GnPinvConst
% - Trace in place of Display
% - Missing InitGnaTol
% - Replace search method 'GNS' with 'GN' 
% - Remove field "Approach"
% - Regularization (R2013b)

fie = fieldnames(Value);
val = struct2cell(Value);
Indr = strcmpi(fie,'SearchDirection');
if any(Indr) && ~any(strcmpi(fie,'SearchMethod'))
   fie{Indr} = 'SearchMethod';
   Value = cell2struct(val,fie);
end

% Replace GNS with GN for SearchMethod
if strcmpi(Value.SearchMethod,'gns')
   Value.SearchMethod = 'gn';
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
   fie{IndT} = 'Display';
   Value = cell2struct(val,fie);
end

% Remove "Approach"
if any(strcmp('Approach',fie))
   Value = rmfield(Value,'Approach');
end

% Add Regularization if not present
if ~any(strcmp('Regularization',fie))
   R = idoptions.RegularizedEstimation.getRegulStruct;
   Value.Regularization = R;
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

% Add InitGnaTol if not present
if ~any(strcmp('InitGnaTol',fie))
   Value.Advanced.Search.InitGnaTol = 1e-4;
end

