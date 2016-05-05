classdef experiment < matlab.mixin.SetGet & operationLogger %matlab.mixin.SetGet is a subclass of the handle class, and implements set & get methods on top of the attributes of handle classes
    properties (Access = public)
        meta
        kin
        force
        lfp
        emg
        analog
        triggers
        units
        trials
        firingRateConfig
        firingRate
        binConfig
        bin
        analysis
    end
    properties (Transient = true)
        scratch
    end
    events
        ranOperation
    end
    methods (Static = true)
        function ex=experiment()
            %constructor
            %% meta
                m.experimentVersion=0;
                m.includedSessions={};
                m.mergeDate={};
                m.processedWith={'operation','function','functionFile','date','computer name','user name','Git log','File log','operation_data'};
                m.knownProblems={'problem'};
                m.fileSepShift=1;
                m.duration=0;
                m.dataWindow=[0 0];
                
                m.task='NoDataLoaded';
                m.hasEmg=false;
                m.hasLfp=false;
                m.hasKinematics=false;
                m.hasForce=false;
                m.hasAnalog=false;
                m.hasUnits=false;
                m.hasTriggers=false;
                m.hasChaoticLoad=false;
                m.hasBumps=false;
                m.hasTrials=false;
                
                m.numTrials=0;
                m.numReward=0;
                m.numAbort=0;
                m.numFail=0;
                m.numIncomplete=0;
                set(ex,'meta',m)
            %% kin
                set(ex,'kin',kinematicData());%empty kinematicData class object
            %% force
                set(ex,'force',forceData());%empty forceData class object
            %% lfp
                set(ex,'lfp',lfpData());%empty lfpData class object
            %% emg
                set(ex,'emg',emgData());%empty emgData class object
            %% analog
                set(ex,'analog',timeSeriesData());%empty timeSeriesData class object
            %% triggers
                set(ex,'triggers',triggerData());%empty triggerData class object
            %% units
                set(ex,'units',unitData());%empty unitData class object
            %% trials
                set(ex,'trials',trialData());%empty trialData class object
            %% fr
                set(ex,'firingRate',firingRateData());%empty firingRateData class object
            %% bin configuration
                %settings to compute binned object from the experiment
                bc.filterConfig=filterConfig('poles',8,'cutoff',10,'sampleRate',20);
                inc.field={};
                inc.which={};
                bc.include=inc;
                set(ex,'binConfig',bc);
            %% firing rate configuration
                frc.offset=0;
                frc.method='bin';
                frc.lagSteps=1;
                frc.cropType='keepSize';
                frc.lags=0;
                frc.sampleRate=20;
                frc.kernelWidth=.05;
                set(ex,'firingRateConfig',frc)
            %% bin
                set(ex,'bin',binnedData()); %empty binned  class object
            %% analysis
                set(ex,'analysis',[]);%empty analysis structure
            %% listners  
                %experiment event listners
                addlistener(ex,'ranOperation',@(src,evnt)ex.experimentLoggingEventCallback(src,evnt));
                %data event listners
                addlistener(ex.kin,'refiltered',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.kin,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.force,'refiltered',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.force,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.lfp,'refiltered',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.lfp,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.emg,'refiltered',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.emg,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.triggers,'refiltered',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.triggers,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                %no listners on analog since its empty. we will add them
                %when we insert data
                addlistener(ex.trials,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.units,'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.bin,'updatedBins',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                %listeners on analysis:
                addlistener(ex.bin,'ranPDFit',@(src,evnt)ex.binAnalysisLoggingCallback(src,evnt));
        end
    end
    methods
        %set methods for experiment class
        function set.meta(ex,meta)
            if ~isfield(meta,'experimentVersion') || ~isnumeric(meta.experimentVersion)
                error('meta:BadExperimentVersionFormat','the experimentVersion field must contain a numeric value')
            elseif ~isfield(meta,'includedSessions') || ~iscell(meta.includedSessions)
                error('meta:BadIncludedSessionsFormat','the includedSessions field must be a cell array of strings, where each string describes once cds that data is drawn from')
            elseif ~isfield(meta,'task') || ~ischar(meta.task)  
                error('meta:BadtaskFormat','the task field must contain a string')
            elseif ~isfield(meta,'knownProblems') || ~iscell(meta.knownProblems)
                error('meta:BadknownProblemsFormat','The knownProblems field must contain a cell array, where each cell contains a string ')
            elseif ~isfield(meta,'processedWith') || ~iscell(meta.processedWith)
                error('meta:BadprocessedWithFormat','the processedWith field must be a cell array with each row containing cells that describe the processing functions')
            elseif ~isfield(meta,'duration') || ~isnumeric(meta.duration)
                error('meta:BaddurationFormat','the duration field must be numeric, and contain the duration of the data file in seconds')
            elseif ~isfield(meta,'mergeDate') 
                error('meta:badMergeDateFormat','meta must have a field containing the merge date for each cds merged into this experiment')
            elseif ~isfield(meta,'numTrials') || ~isnumeric(meta.numTrials)...
                    ||~isfield(meta,'numReward') || ~isnumeric(meta.numReward)...
                    ||~isfield(meta,'numAbort') || ~isnumeric(meta.numAbort)...
                    || ~isfield(meta,'numFail') || ~isnumeric(meta.numFail) ...
                    || ~isfield(meta,'numIncomplete') || ~isnumeric(meta.numIncomplete)
                error('meta:BadtrialsFormat','meta must have the following fields: numTrials, numReward, numAbort, numFail, numIncomplete. Each field must contain an integer number of trials')
            elseif ~isfield(meta,'dataWindow') || ~isnumeric(meta.dataWindow) ...
                    || numel(meta.dataWindow)~=2 
                error('meta:baddataWindowFormat','the dataWindow field must be a 2 element numeric vector')
            elseif ~isfield(meta,'hasLfp') || ~islogical(meta.hasLfp)
                error('meta:NoHasLfp','meta must include a hasLfp field with a boolean flag')
            elseif ~isfield(meta,'hasEmg') || ~islogical(meta.hasEmg)
                error('meta:NoHasEmg','meta must include a hasEmg field with a boolean flag')
            elseif ~isfield(meta,'hasForce') || ~islogical(meta.hasForce)
                error('meta:NoHasForce','meta must include a hasForce field with a boolean flag')
            elseif ~isfield(meta,'hasAnalog') || ~islogical(meta.hasAnalog)
                error('meta:NoHasAnlog','meta must include a hasAnalog field with a boolean flag')
            elseif ~isfield(meta,'hasUnits') || ~islogical(meta.hasUnits)
                error('meta:NoHasUnits','meta must include a hasUnits field with a boolean flag')
            elseif ~isfield(meta,'hasTriggers') || ~islogical(meta.hasTriggers)
                error('meta:NoHasTrials','meta must include a hasTrials field with a boolean flag')
            elseif ~isfield(meta,'hasChaoticLoad') || ~islogical(meta.hasChaoticLoad)
                error('meta:NoHasChaoticLoad','meta must include a hasChaoticLoad field with a boolean flag')
            elseif ~isfield(meta,'hasBumps') || ~islogical(meta.hasBumps)
                error('meta:NoHasBumps','meta must include a hasBumps field with a boolean flag')
            elseif ~isfield(meta,'hasTrials') || ~islogical(meta.hasTrials)
                error('meta:NoHasTrials','meta must include a hasTrials field with a boolean flag')
            else
                if isempty(find(strcmp(meta.task,{'RW','CO','CObump','BD','DCO','multi_gadget','UNT','RP','NoDataLoaded'}),1))
                    warning('meta:UnrecognizedTask','This task string is not recognized. Standard analysis functions may fail to operate correctly using this task string')
                end
                ex.meta=meta;
            end
        end
        function set.kin(ex,kin)
            if ~isa(kin,'kinematicData') 
                error('kin:badFormat','kin must be a kinematicData class object. See the kinematicData class for details')
            else
                ex.kin=kin;
            end
        end
        function set.force(ex,force)
            if ~isa(force,'forceData')
                error('force:badFormat','force must be a forceData class object. See the forceData class for details')
            else
                ex.force=force;
            end
        end
        function set.lfp(ex,lfp)
            if ~isa(lfp,'lfpData')
                error('lfp:badFormat','force must be a lfpData class object. See the lfpData class for details')
            else
                ex.lfp=lfp;
            end
        end
        function set.emg(ex,emg)
            if ~isa(emg,'emgData')
                error('emg:badFormat','emg must be a emgData class object. See the emgData class for details')
            else
                ex.emg=emg;
            end
        end
        function set.analog(ex,analog)
            if ~isa(analog,'timeSeriesData')
                error('analog:badFormat','analog must be a struct array of timeSeriesData class objects. See the analogData class for details')
            else
                ex.analog=analog;
            end
        end
        function set.triggers(ex,triggers)
            if ~isa(triggers,'triggerData')
                error('triggers:badFormat','triggers must be a triggerData class object. See the triggerData class for details')
            else
                ex.triggers=triggers;
            end
        end
        function set.units(ex,units)
            if ~isa(units,'unitData')
                error('units:badFormat','units must be a unitData class object. See the unitData class for details')
            else
                ex.units=units;
            end
        end
        function set.trials(ex,trials)
            if ~isa(trials,'trialData')
                error('trials:badFormat','trials must be a trialData class object. See the trialData class for details')
            else
                ex.trials=trials;
            end
        end
        function set.firingRate(ex,fr)
            if ~isa(fr,'firingRateData')
                error('fr:badFormat','fr must be a firingRateData class object. See the firingRateData class for details')
            else
                ex.firingRate=fr;
            end
        end
        function set.firingRateConfig(ex,frc)
            if ~isstruct(frc)
                error('firingRateConfig:badFormat','fr must be a structure')
            elseif ~isfield(frc,'method') || ~ischar(frc.method)
                error('firingRateConfig:misconfiguredField','the firingRateConfig field must have a method field containing a string with the method for computing fr')
            elseif ~isfield(frc,'lagSteps') || ~isnumeric(frc.lagSteps)
                error('firingRateConfig:misconfiguredField','the firingRateConfig field must have a lagSteps field containing an integer with the number of time steps between successive lags')
            elseif ~isfield(frc,'cropType') || ~ischar(frc.cropType)
                error('firingRateConfig:misconfiguredField','the firingRateConfig field must have a cropType field containing a string with the method for cropping the firing rate data')
            elseif ~isfield(frc,'lags') || ~isnumeric(frc.lags)
                error('firingRateConfig:misconfiguredField','the firingRateConfig field must have a lags field containing an integer with the min and max lags. If one-sided lags are desired a single value can be used. If no lags are desired set this value to 0')
            elseif ~isfield(frc,'sampleRate') || ~isnumeric(frc.sampleRate)
                error('firingRateConfig:misconfiguredField','the firingRateConfig field of the experiment must contain a sampleRate field with a number describing the sample rate in Hz')
            elseif ~isfield(frc,'kernelWidth') || ~isnumeric(frc.kernelWidth)
                error('firingRateConfig:misconfiguredField','the firingRateConfig field of the experiment must contain a kernelWidth field with a number describing the width in s of the gaussian kernel used for the gaussian method of computing firing rate')
            else
                ex.firingRateConfig=frc;
            end
            if frc.sampleRate>ex.binConfig.filterConfig.sampleRate
                warning('firingRateConfig:FRBinSizeMismatch','The firing rate bin size selected is smaller than the configured binsize for binnedData. This will cause errors if using the firing rate to generate binnedData')
            elseif frc.sampleRate~=ex.binConfig.filterConfig.sampleRate
                warning('firingRateConfig:FRBinSizeMismatch','The firing rate bin size selected is smaller than the configured binsize for binnedData. The FR data will be decimated to generate binnedData')
            end
        end
        function set.binConfig(ex,binConfig)
            if isempty(binConfig) 
                ex.binConfig=binConfig;
            elseif (~isfield(binConfig,'filterConfig') || ~isa(binConfig.filterConfig,'filterConfig'))
                error('binConfig:BadFilterFormat','the filterConfig field must be a filterconfig object')
            elseif (~isfield(binConfig,'include') || (~isempty(binConfig.include) && ~isstruct(binConfig.include)))
                error('binConfig:BadincludeFormat','the include field must be a struct array with fields: includedData.includedField and includedData.which')
            elseif ~isfield(binConfig.include,'field') || (numel(binConfig.include.field)>=1 && ~iscellstr({binConfig.include.field}))
                    error('binConfig:BadIncludeFormat','the include field must have a sub-field include.field')
            elseif ~isfield(binConfig.include,'which') 
                    error('binConfig:BadIncludeFormat','the include field must have a sub-field called include.which')
            else
                for i=1:length(binConfig)
                    if ~isempty(binConfig.include(i).which) && ~iscellstr(binConfig.include(i).which) && ~isnumeric(binConfig.include(i).which)
                        error('binConfig:badIncludedFormat','the binConfig.included.which field must be either a cell array of column labels, or a cell containing a numeric matrix')
                    end
                end
                ex.binConfig=binConfig;
            end
        end
        function set.bin(ex,bin)
            if ~isa(bin,'binnedData')
                error('bin:badFormat','bin must be a binnedData class object. See the binnedData class for details')
            else
                ex.bin=bin;
            end
        end
        function set.analysis(ex,anal)
%             if ~isempty(anal) 
%                 if ~isstruct(anal)
%                     error('analysis:notAStructure','the analysis field must be a structure with the following fields: ID, date, type, data')
%                 elseif ~isfield(anal,'notes')
%                     error('analysis:missingNotesField','the analyssis struct array must have an Notes field')
%                 elseif ~isfield(anal,'date')
%                     error('analysis:missingDateField','the analyssis struct array must have a date field')
%                 elseif ~isfield(anal,'type')
%                     error('analysis:missingTypeField','the analyssis struct array must have a type field')
%                 elseif ~isfield(anal,'data')
%                     error('analysis:missingDataField','the analyssis struct array must have a data field')
%                 elseif ~isfield(anal,'config')
%                     error('analysis:missingConfigField','the analyssis struct array must have a config field')
%                 elseif ~isfield(anal,'userName')
%                     error('analysis:missingUserField','the analyssis struct array must have a userName field')
%                 elseif ~isfield(anal,'PCName')
%                     error('analysis:missingPCNameField','the analyssis struct array must have a PCName field')
%                 else
%                     ex.analysis=anal;
%                 end
%             else
%                 ex.analysis=anal;
%             end
ex.analysis=anal;
        end
        %end of set methods    
    end
    methods (Static = false)
        addSession(ex,session)
        addProblem(ex,problem)
        
        calcFiringRate(ex)
        binData(ex,varargin)
    end
    methods (Static = false, Access = protected, Hidden=true)
        [lagData,lagPts,time]=timeShiftBins(ex,data,lags,varargin)
    end
    methods
        %callbacks
        function experimentLoggingEventCallback(ex,src,evnt)
            %because this method is a callback we get the experiment passed
            %twice: once as the primary input to the method, and once as
            %the source of the callback.
            %
            %this implementation expects that the event data will be of the
            %loggingListnerEventData subclass to event.EventData so that
            %the operation name and operation data properties are available
            
            ex.addOperation([class(src),'.',evnt.operationName],ex.locateMethod(class(src),evnt.operationName),evnt.operationData)
        end
        function dataLoggingCallback(ex,src,evnt)
            %because this method is a callback we get the experiment passed
            %as the primary input, and the source class of the event passed
            %as the second input.
            %
            %this method is inteded as a logging callback for when data of
            %the experiment performs an operation such as re-filtering.
            %this implementation expects that the event data will be of the
            %loggingListnerEventData subclass to event.EventData so that
            %the operation name and operation data properties are available
            ex.addOperation([class(src),'.',evnt.operationName],ex.locateMethod(class(src),evnt.operationName),evnt.operationData)
        end
        function binAnalysisLoggingCallback(ex,src,evnt)
           %this method is a callback so the experiment is passed as the 
           %primary input and the source class of the event is passed as
           %the second input.
           %
           %this method copies the results of an analysis run on the binned
           %data in ex.bin into ex.analysis. The point of this is to allow
           %the user to run serial analyses and have them logged in a cell
           %array automatically for later comparison. For example, the user
           %could comput PDs during the instructed delay, and then again
           %during the move and have both sets of PDs stored as cells in
           %the ex.analysis structure
           idx=numel(ex.analysis)+1;
           
           switch evnt.operationName
               case 'fitPds'
                   analysis.type='fitPDs';
                   analysis.config=ex.bin.pdConfig;
                   analysis.date=date;
                   [analysis.userName,analysis.PCName]=ex.getUserHost;
                   analysis.data=ex.bin.pdData;
                   analysis.notes='no notes entered';
               case 'fitGLM'
                   error('binAnalysisLoggingCallback:UnrecognizedAnalysisName',[evnt.operationName, ' is not yet implemented'])
               case 'fitGPFA'
                   error('binAnalysisLoggingCallback:UnrecognizedAnalysisName',[evnt.operationName, ' is not yet implemented'])
               case 'fitKalman'
                   error('binAnalysisLoggingCallback:UnrecognizedAnalysisName',[evnt.operationName, ' is not yet implemented'])
               case 'fitWeiner'
                   error('binAnalysisLoggingCallback:UnrecognizedAnalysisName',[evnt.operationName, ' is not yet implemented'])
               otherwise
                   error('binAnalysisLoggingCallback:UnrecognizedAnalysisName',['Did not recognize: ',evnt.operationName, ' as a valid analysis'])
           end
           if isempty(ex.analysis)
               ex.analysis=analysis;
           else
               ex.analysis(idx)=analysis;
           end
        end
    end
end