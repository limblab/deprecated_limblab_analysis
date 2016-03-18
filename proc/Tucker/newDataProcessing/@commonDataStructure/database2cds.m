function database2cds(cds,conn,filepath,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %loads data associated with a specific source file from the database 
    %into the cds. If data already exists in the cds, the new data will be
    %merged, not appended.
    %
    %Accepts the following options as additional input arguments:
    %'noForce'      ignores any force data 
    %'noKin'        ignores any kinematic data
    %'noEMG'        ignores any EMG data
    %'noLFP'        ignores any lfp data
    %'noTriggers'   ignores any trigger data
    %'noAnalog'     ignores any analog data
    %'noUnits'      ignores any unit data
    %'noEvents'     ignores any event data
    
    %% set options
        if ~isempty(varargin)
            for i = 1:length(varargin)
                optStr = char(varargin{i});           
                if strcmp(optStr,'noKin')
                    opts.kin = 0;
                elseif strcmp(optStr,'noFlags')
                    opts.flags = 0;
                elseif strcmp(optStr,'noForce')
                    opts.force = 0;
                elseif strcmp(optStr,'noEMG')
                    opts.emg = 0;
                elseif strcmp(optStr,'noLFP')
                    opts.lfp = 0;
                elseif strcmp(optStr,'noTriggers')
                    opts.triggers = 0;
                elseif strcmp(optStr,'noAnalog')
                    opts.analog = 0;
                elseif strcmp(optStr,'noUnits')
                    opts.units = 0;
                elseif strcmp(optStr,'noEvents')
                    opts.events = 0;
                end
            end
        end
    
    %% Events: 
        if opts.events
            %load cds.enc, cds.words, and cds.databursts tables
            cds.eventsFromDatabase(conn,filepath,opts)
        end
    %% the kinematics
        %pos, vel, acc tables and kinFilterConfig
        if opts.kin
            cds.kinFromDatabase(conn,filepath,opts)
        end
        
    %% force
        %force table and kinFilterConfig
        if opts.force
            cds.forceFromDatabase(conn,filepath,opts)
        end

    %% Units
        if opts.units
            cds.unitsFromDatabase(conn,filepath,opts)
        end
        
    %% EMG
        %emg table and emgFilterConfig
        if opts.emg
            cds.emgFromDatabase(conn,filepath,opts)
        end
    
    %% LFP
        %lfp table and lfpFilterConfig
        if opts.lfp
            cds.lfpFromDatabase(conn,filepath,opts)
        end
        
    %% Triggers
        %triggers table
        if opts.triggers
            cds.triggersFromDatabase(conn,filepath,opts)
        end
        
    %% Analog
        %analog cell array
        if opts.analog
            cds.analogFromDatabase(conn,filepath,opts)
        end
        
    %% trials
        %trials table
        if opts.trials
            cds.trialsFromDatabase(conn,filepath,opts)
        end
        
    %% data flags
        %data flags table
        if opts.flags
            cds.flagsFromDatabase(conn,filepath,opts)
        end
    %% meta and everything else that's not optional
        %meta
        cds.metaFromDatabase(conn,filepath,opts)
        %aliases
        %binConfig
end