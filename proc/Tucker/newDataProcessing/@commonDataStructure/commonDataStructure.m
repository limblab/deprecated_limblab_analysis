classdef commonDataStructure < matlab.mixin.SetGet%handle
    properties (Access = public)%anybody can read/write/whatever to these
        kinFilterConfig
    end
    properties (SetAccess = private)%anybody can read these, but only class methods can write to them
        meta
        enc
        kin
        force
        lfp
        emg
        analog
        triggers
        units
        trials
        words
        databursts
        aliasList
    end
    properties (Transient = true)
        %scratch space for user data. Not saved with the common_data_structure
        scratch
    end
    methods (Static = true)
        function cds=commonDataStructure(varargin)
            %cds=common_data_structure(str,varargin)
            %constructor function. 
            
            %% set meta field
                m.cdsVersion=0;
                m.dataSource='empty_cds';
                m.rawFileName='Unknown';
                m.lab=-1;
                m.task='Unknown';
                m.array='Unknown';
                m.monkey='Unknown';
                
                m.knownProblems={};
                m.processedWith={'function','date','computer name','user name','Git log','File log','operation_data'};
                
                m.hasEmg=0;
                m.hasLfp=0;
                m.hasKinematics=0;
                m.hasForce=0;
                m.hasAnalog=0;
                m.hasUnits=0;
                m.hasTriggers=0;
                m.hasChaoticLoad=0;
                m.hasBumps=0;
                
                m.duration=0;
                m.dateTime='-1';
                m.fileSepTime=[];
                m.percentStill=0;
                m.stillTime=0;
                m.dataWindow=[0 0];
                
                m.numTrials=0;
                m.numReward=0;
                m.numAbort=0;
                m.numFail=0;
                m.numIncomplete=0;
                set(cds,'meta',m);
            %% filters
                set(cds,'kinFilterConfig',filterConfig('poles',8,'cutoff',25,'SR',100));%a low pass butterworth 
            %% empty kinetics tables
                cds.enc=cell2table(cell(0,3),'VariableNames',{'t','th1','th2'});
                cds.dataFlags=cell2table(cell(0,3),'VariableNames',{'t','still','good'});
                cds.kin=cell2table(cell(0,7),'VariableNames',{'t','x','y','vx','vy','fx','fy','still','good'});
                cds.force=cell2table(cell(0,3),'VariableNames',{'t','fx','fy'});
            %% empty emg table
                cds.emg=cell2table(cell(0,2),'VariableNames',{'t','emg'});
            %% empty lfp table
                cds.lfp=cell2table(cell(0,2),'VariableNames',{'t','lfp'});
            %% empty analog field
                cds.analog=[];
            %% empty triggers field
                cds.triggers=cell2table(cell(0,2),'VariableNames',{'t','triggers'});
            %% units
                cds.units=struct('chan',[],'ID',[],'array',{},'spikes',cell2table(cell(0,2),'VariableNames',{'ts','wave'}));
            %% fr
                cds.fr=cell2table(cell(0,2),'VariableNames',{'t','r'});
            %% empty table of trial data
                cds.trials=cell2table(cell(0,5),'VariableNames',{'trial_number','start_time','go_time','end_time','trial_result'});
            %% empty table of words
                cds.words=cell2table(cell(0,2),'VariableNames',{'ts','word'});
            %% empty table of databursts
                cds.databursts=cell2table(cell(0,2),'VariableNames',{'ts','word'});
            %% empty list of aliases to apply when loading analog data
                cds.aliasList=cell(0,2);
            %% scratch space
                cds.scratch=[];
        end
    end
    methods
        %the following are setter methods for the common_data_structure class, 
        % set methods must be in a methods block with no attributes
        
        function set.kinFilterConfig(cds,FilterConfig)
            if ~isa(FilterConfig,'filterConfig')
                error('kinFilterConfig:badFormat','kinFilterConfig must be a filterConfig object')
            else
                cds.kinFilterConfig=FilterConfig;
            end
        end

        function set.kin(cds,kin)
            if ~istable(kin) || size(kin,2)~=7 ...
                    || isempty(find(strcmp('t',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('still',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('good',kin.Properties.VariableNames),1))...
                    || isempty(find(strcmp('x',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('y',kin.Properties.VariableNames),1))...
                    || isempty(find(strcmp('vx',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('vy',kin.Properties.VariableNames),1))...
                    || isempty(find(strcmp('ax',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('ay',kin.Properties.VariableNames),1))
                error('kin:badFormat','kin must be a table with 7 columns: t, x, y, vx, vy, ax, and ay. t is the time of each sample, and (x,y), (vx,vy), (ax,ay) are the position velocity and acceleration respectively. ')
            else
                cds.kin=kin;
            end
        end

        function set.force(cds,force)
            if ~istable(force)...
                    || isempty(find(strcmp('t',force.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('fx',force.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('fy',force.Properties.VariableNames),1))
                error('force:badFormat','force must be a table with at least 3 columns: t, fx and fy. t is the time of each sample, and fx and fy are the x and y force respectively. For the robot task these should be handle force, for wrist flexion they will be torque about the wrist')
            else
                cds.force=force;
            end
        end
        function set.emg(cds,emg)
            if ~istable(emg) ...
                    || isempty(find(strcmp('t',emg.Properties.VariableNames),1)) 
                error('emg:badFormat','emg must be a table with a column t indicating the times of each row')
            else
                cds.emg=emg;
            end
        end
        function set.lfp(cds,lfp)
            if ~istable(lfp) ...
                    || isempty(find(strcmp('t',lfp.Properties.VariableNames),1)) 
                error('lfp:badFormat','lfp must be a table with a column t indicating the times of each row')
            else
                cds.lfp=lfp;
            end
        end
        function set.triggers(cds,triggers)
            if ~istable(triggers) ...
                    || isempty(find(strcmp('t',triggers.Properties.VariableNames),1)) 
                error('triggers:badFormat','triggers must be a table with a column t indicating the times of each row')
            else
                cds.triggers=triggers;
            end
        end
        function set.enc(cds,enc)
            if ~istable(enc) || size(enc,2)~=3 ...
                    || isempty(find(strcmp('t',enc.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('th1',enc.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('th2',enc.Properties.VariableNames),1))
                error('enc:badFormat','enc must be a table with 3 columns: t, th1 and th2. t is the time of each sample, and th1 and th2 are the values read from the encoder stream. For the robot these should be the angle of the two motors')
            else
                cds.enc=enc;
            end
        end
        function set.analog(cds,analog)
            if (~iscell(analog) && ~isempty(analog))
                error('analog:badFormat','analog must be a cell array, with each cell containing a table of analog data collected at a single frequency')
            else
                cds.analog=analog;
            end
        end
        function set.units(cds,units)
            f=@(x) ~isa(x,'table');
            f2=@(x) size(x,2)~=2;
            f3=@(x) isempty(find(strcmp('ts',x.Properties.VariableNames),1));
            f4=@(x) isempty(find(strcmp('wave',x.Properties.VariableNames),1));
            
            if isempty(units)
                cds.units=units;
            elseif ~isstruct(units)
                error('units:badFormat','Units must be a struct')
            elseif ~isfield(units,'chan') ||  ~isnumeric([units(:).chan])
                error('units:badchanFormat','units must have a field called chan that contains a numeric array of channel numbers')
            elseif ~isfield(units,'ID') || ~isnumeric([units(:).ID])
                error('units:badIDFormat','units must have a field called ID that contains a numeric array of the ID numbers')
            elseif ~isfield(units,'array') ||  ~iscellstr({units.array})
                error('units:badarrayFormat','units must have a field called array that contains a cell array of strings, where each string specifies the array on which the unit was collected')
            elseif ~isfield(units,'spikes') 
                error('units:missingspikes','units must have a field called spikes containing tables of the spike times and waveforms')
            elseif ~isempty({units.spikes}) && (~isempty(find(cellfun(f,{units.spikes}),1)) ...
                    || ~isempty(find(cellfun(f2,{units.spikes}),1)) ...
                    || ~isempty(find(cellfun(f3,{units.spikes}),1)) ...
                    || ~isempty(find(cellfun(f4,{units.spikes}),1)) )
                error('units:badFormat','all elements in units.spikes must be tables with 2 columns: ts and wave. ts contains the timestamps of each wave, and wave contains the snippet of the threshold crossing')
            else
                cds.units=units;
            end
        end 
        function set.words(cds,words)
            if ~istable(words) || isempty(find(strcmp('ts',words.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('word',words.Properties.VariableNames),1))
                error('words:badFormat','words must be a table with 2 columns: ts and word. each row of ts contains the word timestamp, and each row of word contains the word itself')
            else
                cds.words=words;
            end
        end
        function set.databursts(cds,databursts)
            if ~isempty(databursts) && (~istable(databursts) || isempty(find(strcmp('ts',databursts.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('db',databursts.Properties.VariableNames),1)))
                error('databursts:badFormat','databursts must be a table with 2 columns: ts and db. each row of ts contains the databurst timestamp, and each row of db contains the databurst itself')
            else
                cds.databursts=databursts;
            end
        end
        function set.aliasList(cds,aliasList)
            if ~isempty(aliasList) && (~iscell(aliasList) || size(aliasList,2)~=2)
                error('aliasList:badFormat','The alias list must be a cell array with 2 columns. Each row contains the name in the sorce file, and the desired name as strings')
            else
                cds.aliasList=aliasList;
            end
        end
        function set.meta(cds,meta)
            if ~isfield(meta,'cdsVersion') || ~isnumeric(meta.cdsVersion)
                error('meta:BadcdsVersionFormat','the cdsVersion field must contain a numeric value')
            elseif ~isfield(meta,'dataSource') || ~ischar(meta.dataSource)
                error('meta:BaddataSourceFormat','the dataSource field must contain a string describing the source data, e.g. NEVNSx, or bdf')
            elseif ~isfield(meta,'rawFileName') || ~ischar(meta.rawFileName)
                error('meta:BadrawFileNameFormat','The rawFilename field must contain a string with the name of the raw file that the data is sourced from')
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
            elseif ~isfield(meta,'includedData') || ~isfield(meta.includedData,'emg') ...
                    || ~isfield(meta.includedData,'lfp') || ~isfield(meta.includedData,'kinematics')...
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
            elseif ~isfield(meta,'dataWindow') || ~isnumeric(meta.dataWindow) ...
                    || numel(meta.dataWindow)~=2 
                error('meta:baddataWindowFormat','the dataWindow field must be a 2 element numeric vector')
            else
                cds.meta=meta;
            end
        end
%         function set.fr(cds,fr)
%             if ~isempty(fr) && (~isa(fr,'table') || size(fr,2)~=2 || isempty(find(strcmp('t',fr.Properties.VariableNames),1)) ...
%                     || isempty(find(strcmp('r',fr.Properties.VariableNames),1)))
%                 error('FR:badFormat','The FR field must be a table with 2 columns: t and r. t is the time of each observation, and r is the firing rate at time t in hz')
%             else
%                 cds.fr=fr;
%             end
%         end
    end
    methods (Static = false)
        %The following are methods for the common_data_structure class, but
        %are defined in alternate files. These files MUST be stored in the
        %@common_data_structure folder, and are only accessible through
        %instances of the class
        %
        %static methods are methods that d not operate on an instance of
        %the class, but instead use only passed variables and functions to
        %generate output. Non-static methods operate on a specific instance
        %of the class. When defined non-static methods must take an
        %instance of the class as the first variable. When called
        %non-static methods are passed all the additional parameters, but
        %not the class. The class instance is passed implicitly by calling
        %the method from a class instance.
        
        %data loading functions:
        bdf2cds(cds,bdf)
        sourceFile2cds(cds,folderPath,fileName,varargin)
        database2cds(cds,conn,filepath,varargin)
        NEVNSx2cds(cds,NEVNSx,varargin)
            eventsFromNEVNSx(cds,NEVNSx,opts)
            kinematicsFromNEVNSx(cds,NEVNSx,opts)
            forceFromNEVNSx(cds,NEVNSx,NSx_info,opts)
            unitsFromNEVNSx(cds,NEVNSx,opts)
            emgFromNEVNSx(cds,NEVNSx,NSxInfo)
            lfpFromNEVNSx(cds,NEVNSx,NSxInfo)
            analogFromNEVNSx(cds,NEVNSx,NSxInfo)
            metaFromNEVNSx(cds,NEVNSx,opts)
            enc2handlepos(cds,dateTime,lab)
            enc2WFpos(cds)
            mergeTable(cds,fieldName,mergeData)
        %data preprocessing functions
        [task,opts]=getTask(cds,task,opts)
        writeSessionSummary(cds)
        checkEMG60hz(cds)
        checkLFP60hz(cds)
        %trial table functions
        getTrialTable(cds,opts)
        getWFTaskTable(cds,times)
        getRWTaskTable(cds,times)
        getCOTaskTable(cds,times)
        getBDTaskTable(cds,times)
        getUNTTaskTable(cds,times)
        getRPTaskTable(cds,times)
        getDCOTaskTable(cds,times)
        %general functions
        addProblem(cds,problem)
        addOperation(cds,operation,varargin)
        sanitizeTimeWindows(cds)
        
    end
end
        
