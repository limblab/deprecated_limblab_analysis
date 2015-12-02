function metaFromNEVNSx(cds,NEVNSx,opts)
    meta.rawFilename=NEVNSx.NEV.MetaTags.Filename;
    meta.dataSource='NEVNSx';
    DateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
        ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];
    meta.datetime=DateTime;
    meta.duration=NEVNSx.NEV.MetaTags.DataDurationSec;
    meta.lab=opts.labnum;
    meta.task=opts.task;
    meta.knownProblems=cds.meta.knownProblems;
    meta.processedWith=cds.meta.ProcessedWith;
    if isfield(NEVNSx.MetaTags,'FileSepTime')
        meta.fileSepTime=NEVNSx.MetaTags.FileSepTime;
    else
        meta.fileSepTime=[];
    end
    meta.numTrials=size(cds.trials,1);
    meta.percentStill=sum(cds.still)/size(cds.still.t,1);
    meta.stillTime=meta.percentStill*meta.duration;
    
    set(cds,'meta',meta)
    %cds.setField('meta',meta)
    cds.addOperation(mfilename('fullpath'))
    %% session summary
end