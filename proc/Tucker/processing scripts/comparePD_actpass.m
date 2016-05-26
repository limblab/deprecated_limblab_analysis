function [figureList,dataStruct]=comparePD_actpass(folderpath,inputData)
%% load data into cds
    cds=commonDataStructure();
    if ~strcmp(folderpath(end),filesep)
        folderpath=[folderpath,filesep];
    end
    cds.file2cds([folderpath,inputData.fileName],inputData.ranBy,inputData.array,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task);

    dataStruct.cds=cds;
%% create new experiment object
    ex=experiment();

% set which variables to load from cds
    ex.meta.hasLfp=false;
    ex.meta.hasKinematics=true;
    ex.meta.hasForce=true;
    ex.meta.hasUnits=true;
    ex.meta.hasTrials=true;

% set configuration parameters that are not default 
%pdConfig setup:
    ex.bin.pdConfig.pos=false;
    ex.bin.pdConfig.vel=false;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    ex.bin.pdConfig.units={};%just use all of them
    ex.bin.pdConfig.bootstrapReps=50;
% set binConfig parameters:
%     ex.binConfig.include(1).field='lfp';
%         ex.binConfig.include(1).which={};
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};
    ex.binConfig.include(3).field='force';
        ex.binConfig.include(3).which={};
        
% set firingRateConfig parameters
    ex.firingRateConfig.cropType='tightCrop';
    ex.firingRateConfig.offset=-.015;
    %ex.firingRateConfig.lags=[-2 3];
    
% load experiment from cds:
ex.addSession(cds)
ex.units.deleteInvalid;
ex.units.removeSorting;
ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
% calculate the firing rate
    %ex.calcFiringRate()
% bin the data
    ex.binData()
    %save('E:\local processing\chips\experiment_20160421_COBump_bumpTuning\ex.mat','ex','-v7.3')
    ex.units.deleteInvalid;
    ex.units.removeSorting;
    %% PDs:
    abortMask=true(size(ex.trials.data,1),1);
    abortMask(strmatch('A',ex.trials.data.result,'exact'))=false;
    %do bumps:
    %get trials with bumps:
    bumpTrials=~isnan(ex.trials.data.bumpTime) & abortMask;
    ex.bin.pdConfig.windows=[ex.trials.data.bumpTime(bumpTrials),ex.trials.data.bumpTime(bumpTrials)+.125];
    %run pd analysis for force pds:
    ex.bin.pdConfig.pos=false;
    ex.bin.pdConfig.vel=false;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    ex.bin.fitPds
    ex.analysis(end).notes='force pds during bump';
    
    ex.bin.pdConfig.pos=false;
    ex.bin.pdConfig.speed=true;
    ex.bin.pdConfig.vel=true;
    ex.bin.pdConfig.force=false;
    ex.bin.fitPds
    ex.analysis(end).notes='vel pds during bump';
    %do move PDs
    %get move onsets:
    
    moveTrials=~isnan(ex.trials.data.goCueTime) & abortMask;
    ex.bin.pdConfig.windows=[ex.trials.data.goCueTime(moveTrials),ex.trials.data.goCueTime(moveTrials)+.125];
    %get force pds
    ex.bin.pdConfig.pos=false;
    ex.bin.pdConfig.vel=false;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    ex.bin.fitPds
    ex.analysis(end).notes='force pds during move';
    
    ex.bin.pdConfig.pos=false;
    ex.bin.pdConfig.speed=true;
    ex.bin.pdConfig.vel=true;
    ex.bin.pdConfig.force=false;
    ex.bin.fitPds
    ex.analysis(end).notes='vel pds during move';
        
    dataStruct.experiment=ex;
    figureList=[];
    %plot act vs pass force PD
    figureList(end+1)=figure;
    plot(ex.analysis(1).data.forceDir,ex.analysis(3).data.forceDir,'xk')
    hold on
    p=polyfit(ex.analysis(1).data.forceDir,ex.analysis(3).data.forceDir,1);
    fitRange=[min(ex.analysis(1).data.forceDir),max(ex.analysis(1).data.forceDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Force PD: during reaching vs during bumps')
    ylabel('PD during reach')
    xlabel('PD during bump')
    format_for_lee(figureList(end))
    %plot act vs pass vel PD
    figureList(end+1)=figure;
    plot(ex.analysis(2).data.velDir,ex.analysis(4).data.velDir,'xk')
    hold on
    p=polyfit(ex.analysis(2).data.velDir,ex.analysis(4).data.velDir,1);
    fitRange=[min(ex.analysis(2).data.velDir),max(ex.analysis(2).data.velDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Vel PD: during reaching vs during bumps')
    ylabel('PD during reach')
    xlabel('PD during bump')
    format_for_lee(figureList(end))
    %plot act move vs force PD
    figureList(end+1)=figure;
    plot(ex.analysis(3).data.forceDir,ex.analysis(4).data.velDir,'xk')
    hold on
    p=polyfit(ex.analysis(3).data.forceDir,ex.analysis(4).data.velDir,1);
    fitRange=[min(ex.analysis(3).data.forceDir),max(ex.analysis(3).data.forceDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Vel PD vs Force PD, during reaching')
    ylabel('vel PD')
    xlabel('force PD')
    format_for_lee(figureList(end))
    %plot pass move vs force PD
    figureList(end+1)=figure;
    plot(ex.analysis(1).data.forceDir,ex.analysis(2).data.velDir,'xk')
    hold on
    p=polyfit(ex.analysis(1).data.forceDir,ex.analysis(2).data.velDir,1);
    fitRange=[min(ex.analysis(1).data.forceDir),max(ex.analysis(1).data.forceDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Vel PD vs Force PD, during bumps')
    ylabel('PD during reach')
    xlabel('PD during bump')
    format_for_lee(figureList(end))
    
    save('E:\local processing\chips\experiment_20160421_COBump_bumpTuning\ex.mat','ex','-v7.3')
    
    