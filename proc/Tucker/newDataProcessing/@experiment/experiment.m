classdef experiment < matlab.mixin.SetGet
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
        fr
        binConfig
        bin
    end
    properties (Transient = true)
        scratch
    end
    methods (Static = true)
        function ex=experiment()
            %constructor
            %% meta
                m.experimentVersion=0;
                m.includedSessions={};
                m.mergedate={};
                m.processedWith={'function','date','computer name','user name','Git log','File log','operation_data'};
                m.knownProblems={};
                m.fileSepShift=1;
                m.duration=0;
                m.fileSepShift=[];
                
                m.task='Unknown';
                m.hasEmg=0;
                m.hasLfp=0;
                m.hasKinematics=0;
                m.hasForce=0;
                m.hasAnalog=0;
                m.hasUnits=0;
                m.hasTriggers=0;
                m.hasChaoticLoad=0;
                m.hasBumps=0;
                
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
                set(ex,'analog',analogData());%empty analogData class object
            %% triggers
                set(ex,'triggers',triggerData());%empty triggerData class object
            %% units
                set(ex,'units',unitData());%empty unitData class object
            %% trials
                set(ex,'trials',trialData());%empty trialData class object
            %% fr
                set(ex,'fr',firingRateData());%empty firingRateData class object
            %% bin configuration
                %settings to compute binned object from the experiment
                bc.filter=filterConfig('poles',8,'cutoff',20,'SR',20);
                bc.FR.offset=0;
                bc.FR.method='bin';
                bc.includedData={struct('includeField','units','which','all')};
                set(ex,'binConfig',bc);
            %% bin
                set(ex,'bin',binned()); %empty binned  class object
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
            elseif isempty(find(strcmp(meta.task,{'RW','CO','BD','DCO','multi_gadget','UNT','RP','Unknown'}),1))
                warning('meta:UnrecognizedTask','This task string is not recognized. Standard analysis functions may fail to operate correctly using this task string')
            elseif ~isfield(meta,'knownProblems') || ~iscell(meta.knownProblems)
                error('meta:BadknownProblemsFormat','The knownProblems field must contain a cell array, where each cell contains a string ')
            elseif ~isfield(meta,'processedWith') || ~iscell(meta.processedWith)
                error('meta:BadprocessedWithFormat','the processedWith field must be a cell array with each row containing cells that describe the processing functions')
            elseif ~isfield(meta,'duration') || ~isnumeric(meta.duration)
                error('meta:BaddurationFormat','the duration field must be numeric, and contain the duration of the data file in seconds')
            elseif ~isfield(meta,'fileSepTime') || (~isempty(meta.fileSepTime) && size(meta.fileSepTime,2)~=2) || ~isnumeric(meta.fileSepTime)
                error('meta:BadfileSepTimeFormat','the fileSepTime field must be a 2 column array, with each row containing the start and end of time gaps where two files were concatenated')
            elseif ~isfield(meta.trials,'numTrials') || ~isnumeric(meta.numTrials)...
                    ||~isfield(meta,'numReward') || ~isnumeric(meta.numReward)...
                    ||~isfield(meta,'numAbort') || ~isnumeric(meta.numAbort)...
                    || ~isfield(meta,'numFail') || ~isnumeric(meta.numFail) ...
                    || ~isfield(meta,'numIncomplete') || ~isnumeric(meta.numIncomplete)
                error('meta:BadtrialsFormat','meta must have the following fields: numTrials, numReward, numAbort, numFail, numIncomplete. Each field must contain an integer number of trials')
            elseif ~isfield(meta,'dataWindow') || ~isnumeric(meta.dataWindow) ...
                    || numel(meta.dataWindow)~=2 
                error('meta:baddataWindowFormat','the dataWindow field must be a 2 element numeric vector')
            elseif ~isfield(meta,'hasLfp')
                error('meta:NoHasLfp','meta must include a hasLfp field with a boolean flag')
            elseif ~isfield(meta,'hasEmg')
                error('meta:NoHasEmg','meta must include a hasEmg field with a boolean flag')
            elseif ~isfield(meta,'hasForce')
                error('meta:NoHasForce','meta must include a hasForce field with a boolean flag')
            elseif ~isfield(meta,'hasAnalog')
                error('meta:NoHasAnlog','meta must include a hasAnalog field with a boolean flag')
            elseif ~isfield(meta,'hasUnits')
                error('meta:NoHasUnits','meta must include a hasUnits field with a boolean flag')
            elseif ~isfield(meta,'hasTriggers')
                error('meta:NoHasTriggers','meta must include a hasTriggers field with a boolean flag')
            elseif ~isfield(meta,'hasTrials')
                error('meta:NoHasTrials','meta must include a hasTrials field with a boolean flag')
            elseif ~isfield(meta,'hasChaoticLoad')
                error('meta:NoHasChaoticLoad','meta must include a hasChaoticLoad field with a boolean flag')
            elseif ~isfield(meta,'hasBumps')
                error('meta:NoHasBumps','meta must include a hasBumps field with a boolean flag')
            else
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
            if ~isa(analog,'analogData')
                error('analog:badFormat','analog must be a analogData class object. See the analogData class for details')
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
        function set.fr(ex,fr)
            if ~isa(fr,'firingRateData')
                error('fr:badFormat','fr must be a firingRateData class object. See the firingRateData class for details')
            else
                ex.fr=fr;
            end
        end
        function set.binConfig(ex,binConfig)
            if isempty(binConfig) 
                ex.binConfig=binConfig;
            elseif (~isfield(binConfig,'filter') || ~isa(binConfig.filter,'filterConfig'))
                error('binConfig:BadfilterFormat','the filter field must be a filterconfig object')
            elseif ~isfield(binConfig,'FR') || ~isfield(binConfig.FR,'offset') ...
                    || ~isfield(binConfig.FR,'method') || ~isnumeric(binConfig.FR.offset)...
                    || ~ischar(binConfig.FR.method)
                error('binConfig:badFRFormat','the FR field of binconfig must have 2 fields: offset and method. offset must be the offset time between neural and external data, and method must be a string defining the type of calculation used to compute firing rate ')
            else
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
        %end of set methods    
    end
    methods (Static = false)
        addSession(ex,session)
        
        addOperation(ex,operation,varargin)
        
        calcFR(ex)
        binData(ex)
    end
end