function NEVNSx2cds(cds,NEVNSx,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %NEVNSx2cds(NEVNSx,options...)
    %takes an NEVNSx object and a structure of options, and fills a common
    %data structure (CDS) object from the data in the NEVNSx structure.
    %Accepts the following options as additional input arguments:
    %'rothandle'    assumes the handle was flipped upside down, and
    %               converts force signals appropriately
    %'ignoreJumps' does not flag jumps in encoder output when converting
    %               encoder data to position. Useful for Lab1 where the
    %               encoder stream is used to process force, not angle
    %               steps. 
    %'ignoreFilecat'   Ignores the join time between two files. Normally
    %               the join time is flagged and included in the list of
    %               bad kinematic times so that artifacts associated with
    %               the kinematic discontinuity can be avoided in further
    %               processing
    %lab number:    an integer number designating the lab from the set 
    %               1,2,3,6
    %'taskTASKNAME' specifies the task performed during data collection.
    %               NEVNSx2cds looks for the first part of the argument to
    %               match the string 'task' and then takes the remainder of
    %               the string to be the task name. for example 'taskRW'
    %               would result in the task being set to 'RW'
    %'arrayARRAYNAME'   specifies the array used for data collection.
    %               NEVNSx2cds looks for the first part of the argument to
    %               match the string 'array' and then takes the remainder of
    %               the string to be the array name. for example 'arrayM1'
    %               would result in the task being set to 'M1'
    %'monkeyMONKEYNAME' specifies the monkey that this data is from.
    %               NEVNSx2cds looks for the first part of the argument to
    %               match the string 'monkey' and then takes the remainder of
    %               the string to be the monkey name. for example 'monkeyChips'
    %               would result in the task being set to 'Chips'
    %example: cds.NEVNSx2cds(NEVNSx, 'rothandle', 3) 
    %imports the data from NEVNSx into the fields of cds, assuming the
    %robot handle was inverted, and the data came from lab3
    
    %% Initial setup
        % make sure LaTeX is turned off and save the old state so we can turn
        % it back on at the end
        defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
        set(0, 'defaulttextinterpreter', 'none');

        %initial setup
        opts=struct('labNum',-1,'rothandle',false,'ignore_jumps',false,'ignore_filecat',false,'robot',false,'task','Unknown','hasChaoticLoad',false); 

        % Parse arguments
        if ~isempty(varargin)
            for i = 1:length(varargin)
                optStr = char(varargin{i});           
                if strcmp(optStr, 'rothandle')
                    opts.rothandle = true;
                elseif strcmp(optStr, 'chaoticLoad')
                    opts.hasChaoticLoad=true;
                elseif strcmp(optStr, 'ignoreJumps')
                    opts.ignore_jumps=true;
                elseif strcmp(optStr, 'ignoreFilecat')
                    opts.ignore_filecat=true;
                elseif ischar(optStr) && length(optStr)>4 && strcmp(optStr(1:4),'task')
                    opts.task=optStr(5:end);
                elseif ischar(optStr) && length(optStr)>5 && strcmp(optStr(1:5),'array')
                    opts.array=optStr(6:end);
                elseif ischar(optStr) && length(optStr)>5 && strcmp(optStr(1:6),'monkey')
                    opts.monkey=optStr(7:end);
                elseif isnumeric(varargin{i})
                    opts.labNum=varargin{i};    %Allow entering of the lab number               
                else 
                    error('Unrecognized option: %s', optStr);
                end
            end
        end
        %check the options and throw warnings if some things aren't set:
        flag=0;
        if strcmp(opts.task,'Unknown')
            flag=true;
            warning('NEVNSx2cds:taskNotSet','No task was passed as an input variable. Further processing can attempt to automatically identify the task, but success is not garaunteed')
        end
        if ~isfield(opts,'array')
            flag=true;
            warning('NEVNSx2cds:arrayNotSet','No array label was passed as an input variable.')
        end
        if opts.labNum==-1
            flag=true;
            warning('NEVNSx2cds:labNotSet','The lab number where this data was collected was not passed as an input variable')
        end
        if ~isfield(opts,'monkey')
            flag=true;
            warning('NEVNSx2cds:monkeyNotSet','The monkey from which this data was collected was not passed as an input variable')
        end
        if flag
            while 1
                s=input('Do you want to cancel and re-run this data load including the information missing above? (y/n)\n','s');
                if strcmpi(s,'y')
                    error('NEVNSx2cds:UserCancelled','User cancelled execution to re-run with additional input')
                elseif strcmpi(s,'n')
                    break
                else
                    disp([s,' is not a valid response'])
                end
            end
        end
        %set the robot flag if we are using one of the robot labs:
        if opts.labNum == 2 || opts.labNum == 3 || opts.LabNum ==6
            opts.robot=true;
        end
        %get the date of the file so processing that depends on when the
        %file was collected has something to work with
        opts.dateTime= [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
            ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];
        opts.duration= NEVNSx.NEV.MetaTags.DataDurationSec;
    %% get the info of data we have to work with
        % Build catalogue of entities
        unit_list = unique([NEVNSx.NEV.Data.Spikes.Electrode;NEVNSx.NEV.Data.Spikes.Unit]','rows');

        NSxInfo.NSx_labels = {};
        NSxInfo.NSx_sampling = [];
        NSxInfo.NSx_idx = [];
        if ~isempty(NEVNSx.NS2)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS2.ElectrodesInfo.Label}';
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(1000,1,size(NEVNSx.NS2.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS2.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS3)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS3.ElectrodesInfo.Label};
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(2000,1,size(NEVNSx.NS3.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS3.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS4)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS4.ElectrodesInfo.Label}';
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(10000,1,size(NEVNSx.NS4.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS4.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS5)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS5.ElectrodesInfo.Label}';
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(30000,1,size(NEVNSx.NS5.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS5.ElectrodesInfo,2)];
        end
        %sanitize labels
        NSxInfo.NSx_labels = NSxInfo.NSx_labels(~cellfun('isempty',NSxInfo.NSx_labels));
        NSxInfo.NSx_labels = deblank(NSxInfo.NSx_labels);
        %apply aliases to labels:
        if ~isempty(cds.aliasList)
            for i=1:size(cds.aliasList,1)
                NSxInfo.NSx_labels(~cellfun('isempty',strfind(NSxInfo.NSx_labels,cds.aliasList{i,1})))=cds.aliasList(i,2);
            end
        end
        % check that we don't have a data stream using the reserved name
        % 'good'
        if ~isempty(find(strcmp('good',NSxInfo.NSx_labels),1));
            error('NEVNSx2cds:goodIsAReservedName','the cds and experiment code uses the label good as a flag for kinematic data, and treats this label specially when refiltering. This label is reserved to avoid unintended behaviro when refiltering other data sreams. Please use the alias function to re-name the good channel of input data')
        end
    %% Events: 
        %if events are already in the cds, then we keep them and ignore any
        %new words in the NEVNSx. Otherwise we load the events from the
        %NEVNSx, followed by the task
        if isempty(cds.words)
            %do this first since the task check requires the words to already be processed, and task is required to work on kinematics and force
            cds.eventsFromNEVNSx(NEVNSx,opts)
            % if a task was not passed in, set task varable
            if strcmp(opts.task,'Unknown')%if no task label was passed into the function call try to get one automatically
                opts=cds.getTask(task,opts);
            end
            
        end
        
    %% the kinematics
        %convert event info into encoder steps:
        if isempty(cds.words)
            error('NEVNSx2cds:noWordsLoaded','Words have not been loaded into the cds yet. This means there was no encoder data in this NEVNSx, and no prior file was loaded that contained that data. If encoder data is in a different file, load that file to include kinematics, and use the noKin flag when loading this file')
        end
        cds.kinematicsFromNEVNSx(NEVNSx,opts)
       

    %% the kinetics
        cds.forceFromNEVNSx(NEVNSx,NSxInfo,opts)

    %% The Units
        if ~isempty(unit_list)   
            cds.unitsFromNEVNSx(NEVNSx,opts)
        end
        
    %% EMG
        cds.emgFromNEVNSx(NEVNSx,NSxInfo)
            
    %% LFP. any collection channel that comes in with the name chan* will be treated as LFP
        cds.lfpFromNEVNSx(NEVNSx,NSxInfo)

    %% Triggers
        %get list of triggers
        cds.triggersFromNEVNSx(NEVNSx,NSxInfo)

    %% Analog
        cds.analogFromNEVNSx(NEVNSx,NSxInfo)

    %% trial data
        %if we have databursts and we don't have a trial table yet, compute
        %the trial data, otherwise skip it
        if (~isempty(cds.databursts) && isempty(cds.trials))
            if strcmp(opts.task,'Unknown') 
                warning('NEVNSx2cds:UnknownTask','The task for this file is not known, the trial data table may be inaccurate')
            end
            cds.getTrialTable(opts)
        end
    %% sanitize times so that all our data is in the same window.
        cds.sanitizeTimeWindows
    %% Set metadata. Some metadata will already be set, but this should finish the job
        cds.metaFromNEVNSx(NEVNSx,opts)
    %% write metadata to database
        %cds.upload2DB
    %% save to fsmres if possible
        %cds.save2fsmres()
end
