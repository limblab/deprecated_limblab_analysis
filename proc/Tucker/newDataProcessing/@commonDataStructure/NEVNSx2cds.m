function NEVNSx2cds(cds,NEVNSx,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %NEVNSx2cds(NEVNSx,options...)
    %takes an NEVNSx object and a structure of options, and fills a common
    %data structure (CDS) object from the data in the NEVNSx structure.
    %Accepts the following options as additional input arguments:
    %'noforce'      ignores any force data in the NEVNSx, treating it as
    %               plain analog data, rather tahn formatted force
    %'nokin'        ignores any kinematic or kinetic data
    %'rothandle'    assumes the handle was flipped upside down, and
    %               converts force signals appropriately
    %'ignore_jumps' does not flag jumps in encoder output when converting
    %               encoder data to position. Useful for Lab1 where the
    %               encoder stream is used to process force, not angle
    %               steps. 
    %'ignore_filecat'   Ignores the join time between two files. Normally
    %               the join time is flagged and included in the list of
    %               bad kinematic times so that artifacts associated with
    %               the kinematic discontinuity can be avoided in further
    %               processing
    %lab number:    an integer number designating the lab from the set 
    %               1,2,3,6
    %
    %example: cds.NEVNSx2cds(NEVNSx, 'rothandle', 3) 
    %imports the data from NEVNSx into the fields of cds, assuming the
    %robot handle was inverted, and the data came from lab3
    
    %% Initial setup
        % make sure LaTeX is turned off and save the old state so we can turn
        % it back on at the end
        defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
        set(0, 'defaulttextinterpreter', 'none');

        %initial setup
        opts=struct('force',1,'kin',1,'analog',1,'lfp',1,'emg',1,'labnum',-1,'rothandle',0,'ignore_jumps',0,'ignore_filecat',0,'robot',0); 

        % Parse arguments
        if ~isempty(varargin)
            for i = 1:length(varargin)
                opt_str = char(varargin{i});           
                if strcmp(opt_str, 'noforce')
                    opts.force = 0;
                elseif strcmp(opt_str, 'nokin')
                    opts.kin = 0;
                    opts.force = 0;
                elseif strcmp(opt_str,'noemg')
                    opts.emg=0;
                elseif strcmp(opt_str,'nolfp')
                    opts.lfp=0;
                elseif strcmp(opt_str,'noanalog')
                    opts.analog=0;
                elseif strcmp(opt_str, 'rothandle')
                    opts.rothandle = varargin{i+1};
                elseif strcmp(opt_str, 'ignore_jumps')
                    opts.ignore_jumps=1;
                elseif strcmp(opt_str, 'ignore_filecat')
                    opts.ignore_filecat=1;
                elseif ischar(opt_str) && length(opt_str)>4 && strcmp(opt_str(1:4),'task')
                    task=opt_str(5:end);
                elseif ischar(opt_str) && length(opt_str)>5 && strcmp(opt_str(1:5),'array')
                    opts.array=opt_str(6:end);
                elseif isnumeric(varargin{i})
                    opts.labnum=varargin{i};    %Allow entering of the lab number               
                else 
                    error('Unrecognized option: %s', opt_str);
                end
            end
        end
    %% get the info of data we have to work with
        % Build catalogue of entities
        unit_list = unique([NEVNSx.NEV.Data.Spikes.Electrode;NEVNSx.NEV.Data.Spikes.Unit]','rows');

        NSx_info.NSx_labels = {};
        NSx_info.NSx_sampling = [];
        NSx_info.NSx_idx = [];
        if ~isempty(NEVNSx.NS2)
            NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS2.ElectrodesInfo.Label}';
            NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(1000,1,size(NEVNSx.NS2.ElectrodesInfo,2))];
            NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS2.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS3)
            NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS3.ElectrodesInfo.Label};
            NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(2000,1,size(NEVNSx.NS3.ElectrodesInfo,2))];
            NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS3.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS4)
            NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS4.ElectrodesInfo.Label}';
            NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(10000,1,size(NEVNSx.NS4.ElectrodesInfo,2))];
            NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS4.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS5)
            NSx_info.NSx_labels = {NSx_info.NSx_labels{:} NEVNSx.NS5.ElectrodesInfo.Label}';
            NSx_info.NSx_sampling = [NSx_info.NSx_sampling repmat(30000,1,size(NEVNSx.NS5.ElectrodesInfo,2))];
            NSx_info.NSx_idx = [NSx_info.NSx_idx 1:size(NEVNSx.NS5.ElectrodesInfo,2)];
        end
        %sanitize labels
        NSx_info.NSx_labels = NSx_info.NSx_labels(~cellfun('isempty',NSx_info.NSx_labels));
        NSx_info.NSx_labels = deblank(NSx_info.NSx_labels);
        %apply aliases to labels:
        if ~isempty(cds.aliasList)
            for i=1:size(cds.aliasList,1)
                NSx_info.NSx_labels(find(~cellfun('isempty',strfind(NSx_info.NSx_labels,cds.aliasList{i,1}))))=cds.aliasList(i,2);
            end
        end
    %% Events: 
        %do this first since the task check requires the words to already be processed, and task is required to work on kinematics and force
        eventsFromNEVNSx(cds,NEVNSx)
    %% if a task was not passed in, set task varable
        if ~exist('task','var')%if no task label was passed into the function call
            if strcmp(cds.meta.task,'Unknown')
                task=[];
            else 
                task=cds.meta.task;
            end
        end
        [opts]=cds.getTask(task,opts);
        
    %% the kinematics
        %convert event info into encoder steps:
        if opts.kin && exist('all_enc','var')
            kinematicsFromNEVNSx(cds,NEVNSx,opts)
        end

    %% the kinetics
        if opts.force
            forceFromNEVNSx(cds,NEVNSx,NSx_info,opts)
        end
    %% The Units
        if ~isempty(unit_list)   
            unitsFromNEVNSx(cds,NEVNSx,opts)
        end
    %% EMG
        if ~isempty(emgList) 
            emgFromNEVNSx(cds,NEVNSx,NSxInfo)
        end
    %% LFP. any collection channel that comes in with the name chan* will be treated as LFP
        if opts.lfp
            LFPFromNEVNSx(cds,NEVNSx,NSxInfo)
        end
    %% Sync lines
        %get list of sync lines
%         if 
%             
%         else
%             
%         end
    %% Analog
        if opts.analog
            analogFromNEVNSx(cds,NEVNSx,NSxInfo)
        end
    %% trial data
        if strcmp(cds.meta.task,'Unknown') || isempty( cds.meta.task)
            warning('NEVNSx2cds:UnknownTask','The task for this file is not known, the trial data table may be inaccurate')
        end
        cds.getTrialTable
    %% set metadata
        metaFromNEVNSx(cds,NEVNSx,opts)
        
end
