function metaFromNEVNSx(cds,NEVNSx,opts)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %metaFromNEVNSx populates the cds.meta field using data pulled from the
    %NEVNSx object. If this is the first data loaded into the cds, then the
    %cds.meta fields will be populated de-novo. otherwise, some fields will
    %be made into arrays to contain the initial data, and the data from the
    %new NEVNSx
    
    %% fields that depend on whether cds.meta was already populated:
    if cds.meta.cdsVersion==0
        % source/data info
        meta.cdsVersion=cds.meta.cdsVersion;
        meta.rawFilename=NEVNSx.NEV.MetaTags.Filename;
        meta.dataSource='NEVNSx';
        meta.array=opts.array;

        meta.knownProblems=cds.meta.knownProblems;
        meta.processedWith=cds.meta.processedWith;

        %timing
        dateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
            ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];
        meta.dateTime=dateTime;
        meta.duration=NEVNSx.NEV.MetaTags.DataDurationSec;
        if isfield(NEVNSx.MetaTags,'FileSepTime')
            meta.fileSepTime=NEVNSx.MetaTags.FileSepTime;
        else
            meta.fileSepTime=[];
        end
    else
        meta=cds.meta;

        % source/data info
        meta.cdsVersion=[meta.cdsVersion;cds.meta.cdsVersion];
        meta.rawFilename=[meta.rawFilename;NEVNSx.NEV.MetaTags.Filename];
        meta.dataSource=[meta.dataSource;'NEVNSx'];
        
        meta.array=opts.array;

        meta.knownProblems=cds.meta.knownProblems;
        meta.processedWith=cds.meta.processedWith;

        %timing
        dateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
            ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];
        meta.dateTime=dateTime;
        meta.duration=NEVNSx.NEV.MetaTags.DataDurationSec;
        if isfield(NEVNSx.MetaTags,'FileSepTime')
            meta.fileSepTime=NEVNSx.MetaTags.FileSepTime;
        else
            meta.fileSepTime=[];
        end
    end
    %% things that don'd depend on whether cds.meta already had info in it
    if ~isfield(meta,task)
        if isempty(find(meta.lab==opts.labNum,1))
            error('metaFromNEVNSx:differentLabs','data was merged from different labs. This suggests an error in file selection or input labeling')
        end
        if isempty(find(strcmp(meta.task,opts.task),1))
            error('metaFromNEVNSx:differentTasks','data was merged from different tasks. This suggests an error in file selection or input labeling')
        end
        if isempty(find(strcmp(meta.task,opts.task),1))
            error('metaFromNEVNSx:differentTasks','data was merged from different tasks. This suggests an error in file selection or input labeling')
        end
    else
        meta.task=opts.task;
        meta.lab=opts.labNum;
        meta.monkey=opts.monkey;
    end
    
    %data info:
    meta.includedData.EMG=~isempty(cds.EMG);
    meta.includedData.LFP=~isempty(cds.LFP);
    meta.includedData.kinematics=~isempty(cds.pos);
    meta.includedData.force=~isempty(cds.force);
    meta.includedData.analog=~isempty(cds.analog);
    meta.includedData.units=~isempty(cds.units);
    meta.includedData.triggers=~isempty(cds.triggers);
    
    meta.percentStill=sum(cds.dataFlags.still)/size(cds.dataFlags.still,1);
    meta.stillTime=meta.percentStill*meta.duration;
    meta.dataWindow=[0 meta.duration];
    
    meta.trials.num=size(cds.trials,1);
    meta.trials.reward=numel(find(strcmpi(cds.trials.result,'R')));
    meta.trials.abort=numel(find(strcmpi(cds.trials.result,'A')));
    meta.trials.fail=numel(find(strcmpi(cds.trials.result,'F')));
    meta.trials.incomplete=numel(find(strcmpi(cds.trials.result,'I')));
    
    
    set(cds,'meta',meta)
    %cds.setField('meta',meta)
    cds.addOperation(mfilename('fullpath'))
    %% session summary
end