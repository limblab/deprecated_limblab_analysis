classdef (CaseInsensitiveProperties, TruncatedProperties) idfrd <frd & idobsolete.idlti
   % Class defining obsolete @idfrd aspects.
   
   %   Copyright 2009-2012 The MathWorks, Inc.
      
   methods      
      function idf = select(idf,varargin)
         %IDFRD/SELECT Selects IDFRD model at certain frequencies.
         % SELECT is obsolete. Use IDFRD/FSELECT instead.
         
         idf = fselect(idf,varargin{:});
      end
      
      function Report = estInfo2Report(sys, es)
         % Copy obsolete EstimationInfo to model report at load time.
         % For object versions <11 (SITB ver < 8.0)
         % Specialized to choose the right report class for a particular
         % estimator.
         % Here, assume that Report is of the right class.
         
         Report = sys.Report;
         Status = es.Status;
         if ~isempty(strfind(Status,'modified'))
            Report.Status = ctrlMsgUtils.message('Ident:general:msgModifiedAfterEstimation');
         elseif ~isempty(strfind(Status,'Not estimated'))
            Report.Status = ctrlMsgUtils.message('Ident:general:msgCreatedNotEstimated');
         elseif ~isempty(strfind(Status,'Estimated'))
            Report.Status = ctrlMsgUtils.message('Ident:estimation:msgStatusValue2',es.Method);
         else
            Report.Status =  Status;
         end
         
         Report.Method = es.Method;
         if isfield(es,'WindowSize'),Report.WindowSize = es.WindowSize; end
         D = Report.DataUsed;
         if isfield(es,'DataName'), D.Name = es.DataName; end
         if isfield(es,'DataTs'), D.Ts = es.DataTs; end
         if isfield(es,'DataLength'), D.Length = es.DataLength; end
         if isfield(es,'DataInterSample'), D.InterSample = es.DataInterSample; end
         if isfield(es,'DataDomain')
            if strcmpi(es.DataDomain(1),'t')
               D.Type = ctrlMsgUtils.message('Ident:general:msgTDdata');
            else
               D.Type = ctrlMsgUtils.message('Ident:general:msgFDdata');
            end
         end
         
         Report.DataUsed = D;
      end
   end
   
   methods (Hidden)
      ymod = impulse(varargin)
      ymod = step(varargin)

      function sys = inherit(sys, refsys)
         % Copy common properties.
         sys = inherit@idobsolete.idlti(sys,refsys);
         if isprop(refsys,'Units')
            sys.Units = refsys.Units;
         end
      end
   end
   
   methods (Access = protected)      
      function S = getEstimationInfo(sys)
         % Default implementation of get.EstimationInfo
         ArraySize = getArraySize(sys);
         if prod(ArraySize)>1
            ctrlMsgUtils.error('Ident:general:getObsoletePropValArray','EstimationInfo')
         end
         
         S =  struct(...
            'Status','Not estimated from data.',...
            'Method', [],...
            'WindowSize', [],...
            'DataName', [],...
            'DataLength',[],...
            'DataTs',1,...
            'DataDomain','Time',...
            'DataInterSample','zoh');
         Report = sys.Report;
         if ~isempty(Report)
            S.Status = Report.Status;
            S.Method = Report.Method;
            S.WindowSize = Report.WindowSize;
            d = Report.DataUsed;
            S.DataName = d.Name;
            S.DataLength = d.Length;
            S.DataTs = d.Ts;
            DataType = d.Type;
            if any(strcmpi(DataType,{'time',''})) %revisit: xlate
               S.DataDomain = 'Time';
            else
               S.DataDomain = 'Frequency';
            end
            S.DataInterSample = d.InterSample;
            % ad extra Period field for periodic data (populated by etfe)
            if ~any(isinf(d.Period(:)))
               S.Period = d.Period;
            end
         end
      end
   end
   
end
