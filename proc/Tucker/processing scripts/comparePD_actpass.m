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
    % load experiment from cds:
    ex.addSession(cds)
    ex.units.deleteInvalid;
    ex.units.removeSorting;
    
%% set experiment configuration parameters that are not default 
    %pdConfig setup:
    ex.bin.pdConfig.pos=false;
    ex.bin.pdConfig.vel=false;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    ex.bin.pdConfig.units={};%just use all of them
    ex.bin.pdConfig.bootstrapReps=50;
    % set binConfig parameters:
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};
    ex.binConfig.include(3).field='force';
        ex.binConfig.include(3).which={};
        
    % set firingRateConfig parameters
    ex.firingRateConfig.cropType='tightCrop';
    ex.firingRateConfig.offset=-.015;
    %ex.firingRateConfig.lags=[-2 3];
    
%% bin the data
    ex.binData()
    %save('E:\local processing\chips\experiment_20160421_COBump_bumpTuning\ex.mat','ex','-v7.3')
    
%% update the trials table with movement onset     
    %compute movement speed:
    speed=sqrt(ex.kin.data.vx.^2+ex.kin.data.vy.^2);
    %get the movement window for trials that got to the move phase and
    %weren't incomplete:
    moveMask=~isnan(ex.trials.data.goCueTime);
    moveMask(strmatch('I',ex.trials.data.result,'exact'))=false;
    moveWindows=[ex.trials.data.goCueTime(moveMask),ex.trials.data.endTime(moveMask)];
    moveTime=nan(size(moveWindows(:,1)));
    %loop through windows:
    for i=1:size(moveWindows,1)
        %get the index of the first point in the trial as the following
        %code will work only withing the trial and we need a reference back
        %to the whole timeseries:
        offset=find(ex.kin.data.t>moveWindows(i),1,'first');
        %get list of extrema
        [peaks,ipeaks,valleys,ivalleys]=extrema(speed);
        peakData=sortrows([peaks',ipeaks'],2);
        valleyData=sortrows([valleys',ivalleys'],2);
        [~,imax]=max(peakData(:,1));
        if imax==1
            %get the first minima before the peak that is below 5% of the peak
            %amplitude
            candidates=valleyData(valleyData(:,1)<.05*peakData(imax,1),:);
            if isempty(candidates)
                %just get the global minima between the go cue and the peak
                %speed:
                [~,imin]=min(speed(offset:offset+peakData(imax,2)));
            else
                %find the last candidate before peak speed:
                imin=find(candidates(:,2)<peakData(imax,2),1,'last');
            end
            moveTime(i)=ex.kin.data.t(offset+imin);
        else
            %peak speed was the beginning of the trial. I don't know how
            %the monkey finished the trial while going slower than he was
            %during the delay, but we are just gonna stick an NaN in there
            %and ignore it. Hopefully this never actually happens
            moveTime(i)=nan;
        end
        
    end
    
    trialMoveTimes=nan(size(ex.trials.data.endTime));
    trialMoveTimes(moveMask)=moveTime;
    trials=[ex.trials.data,table(trialMoveTimes,'VariableNames',{'moveTime'})];
    ex.trials.appendTable(trials,'overWrite',true)
    
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
    
    moveTrials=~isnan(ex.trials.data.moveTime) & abortMask;
    ex.bin.pdConfig.windows=[ex.trials.data.moveTime(moveTrials),ex.trials.data.moveTime(moveTrials)+.125];
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
    
    
    
    