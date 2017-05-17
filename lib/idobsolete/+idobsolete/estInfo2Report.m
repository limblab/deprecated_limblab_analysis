function Report = estInfo2Report(sys, esOld)
% Copy obsolete EstimationInfo (esOld) to model report at load time.
%
% For linear models, esOld was produced by models created in versions <11
% (SITB ver < 8.0, MATLAB ver < R2012a). For nonlinear models, 
% Specialized to choose the right report class for a particular
% estimator.
% Here, assume that Report is of the right class.

%   Author(s): Rajiv Singh
%   Copyright 2010-2015 The MathWorks, Inc.

nu = size(sys,2);
Report = sys.Report;
Status = esOld.Status;
if ~isempty(strfind(Status,'modified'))
   Report.Status = ctrlMsgUtils.message('Ident:general:msgModifiedAfterEstimation');
elseif ~isempty(strfind(Status,'Not estimated'))
   Report.Status = ctrlMsgUtils.message('Ident:general:msgCreatedNotEstimated');
elseif ~isempty(strfind(Status,'Estimated'))
   Report.Status = ctrlMsgUtils.message('Ident:estimation:msgStatusValue2',esOld.Method);
else
   Report.Status =  Status;
end

Report.Method = esOld.Method;
Report.Fit.FPE = esOld.FPE;
Report.Fit.LossFcn = esOld.LossFcn;
if isfield(esOld,'WhyStop') && ~isempty(esOld.WhyStop)
   T = idresults.SearchInfo('auto');
   T = T.Termination;
   T.WhyStop = esOld.WhyStop;
   T.UpdateNorm = esOld.UpdateNorm;
   T.LastImprovement = esOld.LastImprovement;
   T.Iterations = esOld.Iterations;
   Report.Termination = T;
end

D = Report.DataUsed;
D.Length = esOld.DataLength;

if isfield(esOld,'DataName') 
   D.Name = esOld.DataName;
   ISB = esOld.DataInterSample;
   if isempty(ISB) && nu>0
      ISB = repmat({'zoh'},[nu 1]);
   elseif size(ISB,1)==1 && nu>1
      ISB = repmat(ISB,[nu 1]);
   end      
   D.InterSample = ISB;
   D.Ts = esOld.DataTs;
   if isfield(esOld,'DataDomain')
      if strcmpi(esOld.DataDomain(1),'t')
         D.Type = ctrlMsgUtils.message('Ident:general:msgTDdata');
      else
         D.Type = ctrlMsgUtils.message('Ident:general:msgFDdata');
      end
   end
end
Report.DataUsed = D;
if isfield(esOld,'InitialState')
   Report.IC_{1} = esOld.InitialState;
end

