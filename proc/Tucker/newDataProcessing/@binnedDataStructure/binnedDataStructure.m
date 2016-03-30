classdef binnedDataStructure < matlab.mixin.SetGet
    properties (Access = public)
        weinerConfig
        GPFAConfig
        kalmanConfig
        PDConfig
        data
        meta
        PDs
        weiner
        GPFA
        kalman
    end
    properties (Transient = true)
        %scratch space for user data. Not saved with the common_data_structure
        scratch
    end
    methods (Static = true)%do not call any property of cds
        function bds=binnedDataStructure(varargin)
            %% configs
                bds.weinerConfig=[];
                bds.GPFAConfig=[];
                bds.kalmanConfig=[];
                bds.PDConfig=[];
            %% meta
                m.cdsVersion=-1;%should be inherited from source cds
                m.bdsVersion=0;
                m.dataSource='empty_bds';
                m.rawFilename='Unknown';
                m.lab=-1;
                m.task='Unknown';
                m.array='Unknown';
                m.monkey='Unknown';
                
                m.knownProblems={};
                m.processedWith={'function','date','computer name','user name','Git log','File log','operation_data'};
                
                m.includedData.EMG=0;
                m.includedData.LFP=0;
                m.includedData.kinematics=0;
                m.includedData.force=0;
                m.includedData.analog=0;
                m.includedData.units=0;
                m.includedData.triggers=0;
                
                m.duration=0;
                m.dateTime='-1';
                m.fileSepTime=[];
                m.percentStill=0;
                m.stillTime=0;
                
                m.trials.num=0;
                m.trials.reward=0;
                m.trials.abort=0;
                m.trials.fail=0;
                m.trials.incomplete=0;
                set(cds,'meta',m);
            %% PDs
                bds.PDs=[];
            %% weiner
                bds.weiner=[];
            %% GPFA
                bds.GPFA=[];
            %% kalman
                bds.kalman=[];
            %% data
                bds.data=cell2table(cell(0,2),'VariableNames',{'t','data'});
        end
    end
    methods
        %setter functions for the binnedDataStructure class:
        %configs
        function set.weinerConfig(bds,weinerConfig)
            if ~isempty(weinerConfig)
                error('weinerConfig:notImplemented','this setter function not implemented')
            %data list:
            %unit list:
            %lags:
            %cross validation:
            else
                bds.weinerConfig=weinerConfig;
            end
        end
        function set.GPFAConfig(bds,GPFAConfig)
            if ~isempty(GPFAConfig)
                error('GPFAConfig:notImplemented','this setter function not implemented')
            else
                bds.GPFAConfig=GPFAConfig;
            end
        end
        function set.kalmanConfig(bds,kalmanConfig)
            if ~isempty(kalmanConfig)
                error('kalmanConfig:notImplemented','this setter function not implemented')
            else
                bds.kalmanConfig=kalmanConfig;
            end
        end
        function set.PDConfig(bds,PDConfig)
            if ~isempty(PDConfig)
                error('PDConfig:notImplemented','this setter function not implemented')
                %unit list
                %feature list
            else
                bds.PDConfig=PDConfig;
            end
        end
        
        %decoders:
        function set.weiner(bds,weiner)
            if ~isempty(weiner)
                error('weinerConfig:notImplemented','this setter function not implemented')
            
            else
                bds.weiner=weiner;
            end
        end
        function set.GPFA(bds,GPFA)
            if ~isempty(GPFA)
                error('GPFAConfig:notImplemented','this setter function not implemented')
            else
                bds.GPFA=GPFA;
            end
        end
        function set.kalman(bds,kalman)
            if ~isempty(kalman)
                error('kalmanConfig:notImplemented','this setter function not implemented')
            else
                bds.kalman=kalman;
            end
        end
        function set.PDs(bds,PDs)
            if ~isempty(PDs)
                error('PDConfig:notImplemented','this setter function not implemented')
            else
                bds.PDs=PDs;
            end
        end
        
        %etc
        function set.data(bds,data)
            if ~isempty(data) || isa(data,'table') ...
                    || isempty(find(strcmp('t',data.Properties.VariableNames),1))
                error('data:baddataFormat','the data field must be a table and have a column t with times')
            else
                bds.data=data;
            end
        end
        function set.meta(bds,meta)
            if ~isfield(meta,'cdsVersion') || ~isnumeric(meta.cdsVersion)
                error('meta:BadcdsVersionFormat','the cdsVersion field must contain a numeric value')
            elseif ~isfield(meta,'dataSource') || ~ischar(meta.dataSource)
                error('meta:BaddataSourceFormat','the dataSource field must contain a string describing the source data, e.g. NEVNSx, or bdf')
            elseif ~isfield(meta,'rawFilename')
                error('meta:BadrawFilenameFormat','The rawFilename field must contain a string with the name of the raw file that the data is sourced from')
            elseif ~isfield(meta,'lab') || ~isnumeric(meta.lab) || isempty(find(meta.lab==[-1 1 2 3 6],1))
                error('meta:BadlabnumFormat','the labnum field must be a numeric value from the following set: [-1 1 2 3 6]')
            elseif ~isfield(meta,'task') || ~ischar(meta.task)  
                error('meta:BadtaskFormat','the task field must contain a string')
            elseif isempty(find(strcmp(meta.task,{'RW','CO','BD','DCO','multi_gadget','UNT','RP','Unknown'}),1))
                %standard loading will catch 'Unknown' 
                warning('meta:UnrecognizedTask','This task string is not recognized. Standard analysis functions may fail to operate correctly using this task string')
            elseif ~isfield(meta,'monkey') || ~ischar(meta.monkey)
                error('meta:BadmonkeyFormat','The monkey name must contain a string with the monkey name')
            elseif ~isfield(meta,'array') || ~ischar(meta.array)
                error('meta:BadarrayFormat','The array field must contain a string with the name of the array, e.g. M1, S1, PMd')
            elseif ~isfield(meta,'knownProblems') || ~iscell(meta.knownProblems)
                error('meta:BadknownProblemsFormat','The knownProblems field must contain a cell array, where each cell contains a string ')
            elseif ~isfield(meta,'processedWith') || ~iscell(meta.processedWith)
                error('meta:BadprocessedWithFormat','the processedWith field must be a cell array with each row containing cells that describe the processing functions')
            elseif ~isfield(meta,'includedData') || ~isfield(meta.includedData,'EMG') ...
                    || ~isfield(meta.includedData,'LFP') || ~isfield(meta.includedData,'kinematics')...
                    || ~isfield(meta.includedData,'force') || ~isfield(meta.includedData,'analog')...
                    || ~isfield(meta.includedData,'units') || ~isfield(meta.includedData,'triggers')
                error('meta:BadincludedDataFormat','the includedData field must be a structure with the following fields: EMG, LFP, kinematics, force, analog, units, triggers')
            elseif ~isfield(meta,'duration') || ~isnumeric(meta.duration)
                error('meta:BaddurationFormat','the duration field must be numeric, and contain the duration of the data file in seconds')
            elseif ~isfield(meta,'dateTime') || ~ischar(meta.dateTime)
                error('meta:BaddateTimeFormat','Date time must be a string containing the date at which the raw data was collected')
            elseif ~isfield(meta,'fileSepTime') || (~isempty(meta.fileSepTime) && size(meta.fileSepTime,2)~=2) || ~isnumeric(meta.fileSepTime)
                error('meta:BadfileSepTimeFormat','the fileSepTime field must be a 2 column array, with each row containing the start and end of time gaps where two files were concatenated')
            elseif ~isfield(meta,'percentStill') || ~isnumeric(meta.percentStill)
                error('meta:BadpercentStillFormat','the percentStill field must be a fractional value indicating the percentage of the file where the cursor was still')
            elseif ~isfield(meta,'stillTime') || ~isnumeric(meta.stillTime)
                error('meta:BadFormat','the stillTime field must contain a numeric variable with the number of seconds where the curstor was still')
            elseif ~isfield(meta,'trials') || ~isfield(meta.trials,'num')...
                    ||~isfield(meta.trials,'reward') || ~isnumeric(meta.trials.reward)...
                    ||~isfield(meta.trials,'abort') || ~isnumeric(meta.trials.abort)...
                    || ~isfield(meta.trials,'fail') || ~isnumeric(meta.trials.fail) ...
                    || ~isfield(meta.trials,'incomplete') || ~isnumeric(meta.trials.incomplete)
                error('meta:BadtrialsFormat','the trials field must be a struct with the following fields: num, reward, abort, fail, incomplete. Each field must contain an integer number of trials')
            elseif ~isfield(meta,'bdsVersion') || ~isnumeric(meta.bdsVersion)
                error('meta:BadbdsVersionFormat','the bdsVersion field must contain a numeric value')
            elseif ~isfield(meta,'SR') || ~isnumeric(meta.SR)
                error('meta:BadSRFormat','the SR field must be a number specifying the sample rate for the bds')
            elseif ~isfield(meta,'offset') || ~isnumeric(meta.offset)
                error('meta:badoffsetFormat','the offset field must be a number indicating the offset in s between the neural data and external data sources')
            else
                bds.meta=meta;
            end
        end
    end
    methods (Static = false)
        addProblem(bds,problem)
        addOperation(bds,operation,varargin)
        calcWeiner(bds)
        calcGPFA(bds)
        calcKalman(bds)
        calcPDs(bds)
    end
end