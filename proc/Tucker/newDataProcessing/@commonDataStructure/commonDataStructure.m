classdef commonDataStructure < matlab.mixin.SetGet & operationLogger
    properties (SetAccess = private, GetAccess=public)%anybody can read these, but only class methods can write to them
        meta
        kin
        force
        lfp
        emg
        analog
        triggers
        units
        trials
    end
    properties (Transient = true, SetAccess = private, Hidden=true)
        %Not saved with the common_data_structure. used to store transient
        %data during loading
        kinFilterConfig
        NEV
        NS1
        NS2
        NS3
        NS4
        NS5
        NSxInfo
        enc
        words
        databursts
    end
    properties (Transient = true, Access = public)
        aliasList%allows user to set aliases for incoming data streams in order to process correctly. 
    end
    events
        ranOperation
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
                
                m.hasEmg=false;
                m.hasLfp=false;
                m.hasKinematics=false;
                m.hasForce=false;
                m.hasAnalog=false;
                m.hasUnits=false;
                m.hasSorting=false;
                m.hasTriggers=false;
                m.hasChaoticLoad=false;
                m.hasBumps=false;
                                
                m.numSorted=0;
                m.numWellSorted=0;
                m.numDualUnits=0;
                
                m.duration=0;
                m.dateTime='-1';
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
                set(cds,'kinFilterConfig',filterConfig('poles',8,'cutoff',25,'sampleRate',100));%a low pass butterworth 
            %% empty kinetics tables
                cds.enc=cell2table(cell(0,3),'VariableNames',{'t','th1','th2'});
                cds.kin=cell2table(cell(0,9),'VariableNames',{'t','x','y','vx','vy','ax','ay','still','good'});
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
                cds.units=struct('chan',[],'ID',[],'array',{},'wellSorted',false,'monkey',{},'spikes',cell2table(cell(0,2),'VariableNames',{'ts','wave'}));
            %% empty table of trial data
                cds.trials=cell2table(cell(0,5),'VariableNames',{'trial_number','start_time','go_time','end_time','trial_result'});
            %% empty NEVNSx fields:
                set(cds,'NEV',[])
                set(cds,'NS1',[])
                set(cds,'NS2',[])
                set(cds,'NS3',[])
                set(cds,'NS4',[])
                set(cds,'NS5',[])
                set(cds,'NSxInfo',[])
                %% empty table of words
                cds.words=cell2table(cell(0,2),'VariableNames',{'ts','word'});
            %% empty table of databursts
                cds.databursts=cell2table(cell(0,2),'VariableNames',{'ts','word'});
            %% empty list of aliases to apply when loading analog data
                cds.aliasList=cell(0,2);
            %% set up listners
                addlistener(cds,'ranOperation',@(src,evnt)cds.cdsLoggingEventCallback(src,evnt));
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
            if ~istable(kin) || size(kin,2)~=9 ...
                    || isempty(find(strcmp('t',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('still',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('good',kin.Properties.VariableNames),1))...
                    || isempty(find(strcmp('x',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('y',kin.Properties.VariableNames),1))...
                    || isempty(find(strcmp('vx',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('vy',kin.Properties.VariableNames),1))...
                    || isempty(find(strcmp('ax',kin.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('ay',kin.Properties.VariableNames),1))
                error('kin:badFormat','kin must be a table with 9 columns: t, x, y, vx, vy, ax, and ay. t is the time of each sample, and (x,y), (vx,vy), (ax,ay) are the position velocity and acceleration respectively. ')
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
            if isempty(units)
                cds.units=units;
            elseif ~isstruct(units)
                error('units:badFormat','Units must be a struct')
            elseif ~isfield(units,'chan') 
                error('units:badchanFormat','units must have a field called chan that contains a numeric array of channel numbers')
            elseif ~isfield(units,'ID')
                error('units:badIDFormat','units must have a field called ID that contains a numeric array of the ID numbers')
            elseif ~isfield(units,'wellSorted')
                error('units:badWellSortedFormat','units must have a field called wellSorted that contains a logical')
            elseif ~isfield(units,'array')
                error('units:badArrayFormat','units must have a field called array that contains a cell array of strings, where each string specifies the array on which the unit was collected')
            elseif ~isfield(units,'monkey')
                error('units:badMonkeyFormat','units must have a field called array that contains a cell array of strings, where each string specifies the monkey on which the unit was collected')
            elseif ~isfield(units,'spikes') 
                error('units:missingspikes','units must have a field called spikes containing tables of the spike times and waveforms')
            else
                cds.units=units;
            end
        end 
        function set.NEV(cds,NEV)
            %check for one of the random fields that should be in the NEV
            %object if its the thing that Blackrock's loading function
            %produces:
            if ~isempty(NEV) && (~isstruct(NEV) || (~isfield(NEV,'Data') && ~isfield(NEV.Data,'SerialDigitalIO')))
                error('NEV:badFormat','The passed object does not appear to be an NEV object')
            end
            cds.NEV=NEV;
        end
        function set.NS1(cds,NS1)
            if ~isempty(NS1) && ( ~isstruct(NS1) && ~isfield(NS1,'MetaTags'))
                error('NS1:badFormat','The NS1 must be a NSx object loaded using the openNSxLimblab function')
            end
            cds.NS1=NS1;
        end
        function set.NS2(cds,NS2)
            if ~isempty(NS2) && ( ~isstruct(NS2) && ~isfield(NS2,'MetaTags'))
                error('NS2:badFormat','The NS2 must be a NSx object loaded using the openNSxLimblab function')
            end
            cds.NS2=NS2;
        end
        function set.NS3(cds,NS3)
            if ~isempty(NS3) && ( ~isstruct(NS3) && ~isfield(NS3,'MetaTags'))
                error('NS3:badFormat','The NS3 must be a NSx object loaded using the openNSxLimblab function')
            end
            cds.NS3=NS3;
        end
        function set.NS4(cds,NS4)
            if ~isempty(NS4) && ( ~isstruct(NS4) && ~isfield(NS4,'MetaTags'))
                error('NS4:badFormat','The NS4 must be a NSx object loaded using the openNSxLimblab function')
            end
            cds.NS4=NS4;
        end
        function set.NS5(cds,NS5)
            if ~isempty(NS5) && ( ~isstruct(NS5) && ~isfield(NS5,'MetaTags'))
                error('NS5:badFormat','The NS5 must be a NSx object loaded using the openNSxLimblab function')
            end
            cds.NS5=NS5;
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
            elseif isempty(find(strcmp(meta.task,{'RW','CO','CObump','BD','DCO','multi_gadget','UNT','RP','Unknown'}),1))
                %standard loading will catch 'Unknown' 
                warning('meta:UnrecognizedTask',['The task string: ',meta.task,' is not recognized. Standard analysis functions may fail to operate correctly using this task string'])
            elseif ~isfield(meta,'monkey') || ~ischar(meta.monkey)
                error('meta:BadmonkeyFormat','The monkey name must contain a string with the monkey name')
            elseif ~isfield(meta,'array') || ~ischar(meta.array)
                error('meta:BadarrayFormat','The array field must contain a string with the name of the array, e.g. M1, S1, PMd')
            elseif ~isfield(meta,'knownProblems') || ~iscell(meta.knownProblems)
                error('meta:BadknownProblemsFormat','The knownProblems field must contain a cell array, where each cell contains a string ')
           elseif ~isfield(meta,'duration') || ~isnumeric(meta.duration)
                error('meta:BaddurationFormat','the duration field must be numeric, and contain the duration of the data file in seconds')
            elseif ~isfield(meta,'dateTime') || ~ischar(meta.dateTime)
                error('meta:BaddateTimeFormat','Date time must be a string containing the date at which the raw data was collected')
            elseif ~isfield(meta,'percentStill') || ~isnumeric(meta.percentStill)
                error('meta:BadpercentStillFormat','the percentStill field must be a fractional value indicating the percentage of the file where the cursor was still')
            elseif ~isfield(meta,'stillTime') || ~isnumeric(meta.stillTime)
                error('meta:BadFormat','the stillTime field must contain a numeric variable with the number of seconds where the curstor was still')
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
            elseif ~isfield(meta,'hasSorting') || ~islogical(meta.hasSorting)
                error('meta:NoHasSorting','meta must include a hasSorting field with a boolean flag')
            elseif ~isfield(meta,'numSorted') || ~isnumeric(meta.numSorted)
                error('meta:NoNumSorted','meta must include a numSorted field with an integer count of the number of units sorted in the file')
            elseif ~isfield(meta,'numWellSorted') || ~isnumeric(meta.numWellSorted)
                error('meta:NoNumWellSorted','meta must include a numWellSorted field with an integer specifying how many of the sorted units are well sorted from noise and other units on the channel')
            elseif ~isfield(meta,'numDualUnits') || ~isnumeric(meta.numDualUnits)
                error('meta:noNumDualUnits','meta must include a numDualUnits field with an integer specifying the number of dual units that have been sorted in the array')
            else
                cds.meta=meta;
            end
        end
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
        file2cds(cds,filePath,varargin)
        database2cds(cds,conn,filepath,varargin)
        %data preprocessing functions
        checkEMG60hz(cds)
        checkLFP60hz(cds)
        %storage functions
        upload2DB(cds)
        save2fsmres(cds)
        S=saveobj(cds)
    end
    methods (Static = true)
        function cds=loadobj(cds)
            %stub function. If the CDS is extended to require listeners
            %after re-loading then this section can be used to
            %re-instantiate those listeners. Similarly this function can be
            %used to perform a version check on load and throw a warning if
            %the current version is newer than the cds loaded
        end
    end
    methods (Static = false, Access = protected, Hidden=true)
        %the following methods are all hidden from the user and may only be
        %called by methods of the cds class.
        nev2NEVNSx(cds,fname)
        NEVNSx2cds(cds,NEVNSx,varargin)
            eventsFromNEV(cds,opts)
            kinematicsFromNEV(cds,opts)
            forceFromNSx(cds,opts)
            [filteredData,time]=getFilteredFromNSx(cds,filterConfig,chans)
            handleForce=handleForceFromRaw(cds,rawForce,opts)
            unitsFromNEV(cds,opts)
            testSorting(cds)
            emgFromNSx(cds)
            lfpFromNSx(cds)
            triggersFromNSx(cds)
            analogFromNSx(cds)
            metaFromNEVNSx(cds,opts)
            pos=enc2handlepos(cds,dateTime,lab)
            pos=enc2WFpos(cds)
            mergeTable(cds,fieldName,mergeData)
        [task,opts]=getTask(cds,task,opts)
        writeSessionSummary(cds)
        sanitizeTimeWindows(cds)
        idx=skipResets(cds,time)
        clearTempFields(cds)
        %trial table functions
        getTrialTable(cds,opts)
        getWFTaskTable(cds,times)
        getRWTaskTable(cds,times)
        getCOTaskTable(cds,times)
        getCObumpTaskTable(cds,times)
        getBDTaskTable(cds,times)
        getUNTTaskTable(cds,times)
        getRPTaskTable(cds,times)
        getDCOTaskTable(cds,times)
        %general functions
        addProblem(cds,problem)
    end
    methods (Access = protected, Hidden=true)
        %callbacks
        function cdsLoggingEventCallback(cds,src,evnt)
            %because this method is a callback we get the experiment passed
            %twice: once as the primary input to the method, and once as
            %the source of the callback.
            %
            %this implementation expects that the event data will be of the
            %loggingListnerEventData subclass to event.EventData so that
            %the operation name and operation data properties are available
            
            cds.addOperation([class(src),'.',evnt.operationName],cds.locateMethod(class(src),evnt.operationName),evnt.operationData)
        end
    end
end
        
