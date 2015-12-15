function metaFromNEVNSx(cds,NEVNSx,opts)
    % source/data info
    meta.cdsVersion=cds.meta.cdsVersion;
    meta.rawFilename=NEVNSx.NEV.MetaTags.Filename;
    meta.dataSource='NEVNSx';
    meta.lab=opts.labnum;
    meta.task=opts.task;
    meta.array=opts.array;
    meta.monkey=opts.monkey;
    
    meta.knownProblems=cds.meta.knownProblems;
    meta.processedWith=cds.meta.processedWith;
    %included data:
    meta.includedData.EMG=~isempty(cds.EMG);
    meta.includedData.LFP=~isempty(cds.LFP);
    meta.includedData.kinematics=~isempty(cds.pos);
    meta.includedData.force=~isempty(cds.force);
    meta.includedData.analog=~isempty(cds.analog);
    meta.includedData.units=~isempty(cds.units);
    meta.includedData.triggers=~isempty(cds.triggers);
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