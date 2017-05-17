function S = getEstimationInfo(Report, ModelType)
% Create obsolete EstimationInfo structure using model's Report.

%   Author(s): Rajiv Singh
%   Copyright 2010-2014 The MathWorks, Inc.
S = struct(...
   'Status', 'Not estimated',...
   'Method', '',...
   'LossFcn', [],...
   'FPE', [],...
   'DataName', '',...
   'DataLength',[],...
   'DataTs',[],...
   'DataDomain', 'Time',...
   'DataInterSample','',...
   'WhyStop','',...
   'UpdateNorm',[],...
   'LastImprovement',[],...
   'Iterations', [],...
   'InitialState', [],...
   'Warning', 'None');

if strcmp(ModelType,'idnlgrey')
   S = rmfield(S,'InitialState');
   S.InitialGuess = struct('InitialStates',{{}},'Parameters',{{}});
   S.EstimationTime = [];
elseif any(strcmp(ModelType,{'idnlarx','idnlhw'}))
   S.InitRandnState = [];
   S.EstimationTime = [];
end

if isempty(Report), return, end

% Set common items
S.Status = Report.Status;
S.Method = Report.Method;
S.LossFcn = Report.Fit.LossFcn;
S.FPE = Report.Fit.FPE;
S.DataName = Report.DataUsed.Name;
S.DataLength = Report.DataUsed.Length;
S.DataTs = Report.DataUsed.Ts;
DataType = Report.DataUsed.Type;
if isempty(DataType) || ~isempty(strfind(lower(DataType),'time')) %REVISIT: xlate
   S.DataDomain = 'Time';
else
   S.DataDomain = 'Frequency';
end

S.DataInterSample = Report.DataUsed.InterSample;
if strcmp(S.DataInterSample,'not applicable') %revisit: xlate
   S.DataInterSample = {'zoh'};
end

P = properties(Report);
if ismember('Termination',P)  && ~isempty(Report.Termination)
   Search = Report.Termination; 
   if numel(Search)>1
      % Note: Search can be nonscalar if measured and noise models are
      % determined separately (as when focus = 'sim') 
      Search = Search(end); 
   end
   S.WhyStop = Search.WhyStop;
   S.Iterations = Search.Iterations;
   if isfield(Search,'UpdateNorm')
      S.UpdateNorm = Search.UpdateNorm;
   end
   
   if isfield(Search,'LastImprovement')
      S.LastImprovement = Search.LastImprovement;
   end
end

switch ModelType
   case {'idnlarx', 'idnlhw'}
      S.InitRandnState = Report.RandState;
   case 'idnlgrey'
      S.InitialGuess.InitialStates = Report.Parameters.InitialValues.X0;
      S.InitialGuess.Parameters = Report.Parameters.InitialValues.ParVector;
   case 'idss'
      if ~isa(Report,'idresults.ssregest')
         S.N4Horizon = Report.N4Horizon;
         S.N4Weight = Report.N4Weight;
      else
         S.ARXOrder = Report.ARXOrder;
      end
      S.InitialState = Report.InitialState;
   case {'idpoly','idtf','idproc'}
      if isprop(Report,'InitialCondition')
         % InitialState not available in AR, IMPULSEEST reports
         S.InitialState = Report.InitialCondition;
      end
   case 'idgrey'
      S.InitialState = Report.InitialState;
end
