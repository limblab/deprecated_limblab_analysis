% %get PDs from CObump data
%     if ~exist('NEVNSx','var')
%         NEVNSx=cerebus2NEVNSx('E:\local processing\Han\20160411_COBump_ctrHold_Delay','Han_20160411_COBump_area2_001');
%     end
%% load test data into cds
    if ~exist('cds','var')
        cds=commonDataStructure();
        cds.file2cds('E:\local processing\chips\experiment_20160509_COBump_bumptuning\Chips_20160509_COBump_area2_tucker_001','arrayS1Area2','monkeyChips',6,'ignoreJumps','taskCObump');
        save('E:\local processing\chips\experiment_20160509_COBump_bumptuning\cds.mat','cds','-v7.3')
    end
    %
    
%% create new experiment object
if ~exist('ex','var')
    ex=experiment();

% set which variables to load from cds
    ex.meta.hasLfp=false;
    ex.meta.hasKinematics=true;
    ex.meta.hasForce=true;
    ex.meta.hasUnits=true;
    ex.meta.hasTrials=true;

% set configuration parameters that are not default 
%pdConfig setup:
    ex.bin.pdConfig.useParallel=true;
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
ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
% calculate the firing rate
    %ex.calcFiringRate()
% bin the data
    ex.binData()
    save('E:\local processing\chips\experiment_20160421_COBump_bumpTuning\ex.mat','ex','-v7.3')
end
    %% PDs:
    abortMask=true(size(ex.trials.data,1),1);
    abortMask(strmatch('A',ex.trials.data.result,'exact'))=false;
    %do hold bumps:
    %get trials with hold period bumps:
    CHBumpTrials=ex.trials.data.ctrHoldBump & abortMask;
    ex.bin.pdConfig.windows=[ex.trials.data.bumpTime(CHBumpTrials),ex.trials.data.bumpTime(CHBumpTrials)+.125];
    ex.bin.fitPds
    ex.analysis(end).notes='pds during center hold';
    %do delay bumps
    targetDirs=unique(ex.trials.data.tgtDir);
    targetDirs=targetDirs(~isnan(targetDirs));
    for i=1:numel(targetDirs)
        delayTrials=ex.trials.data.delayBump & ex.trials.data.tgtDir==targetDirs(i) & abortMask;
        ex.bin.pdConfig.windows=[ex.trials.data.bumpTime(CHBumpTrials),ex.trials.data.bumpTime(CHBumpTrials)+.125];
        ex.bin.fitPds
        ex.analysis(end).notes=['pds during delay, with target at: ',num2str(targetDirs(i))];
    end
 %% parse PDs from expeiment and test dependence on condition
 dPD=[];
dModdepth=[];
tgtDir=[];
relPD=[];
moddepth=[];
for i=1:numel(targetDirs)
    tgtDir=[tgtDir;repmat(targetDirs(i),size(ex.analysis(i+1).data,1),1)];
    relPD=[relPD;ex.analysis(1).data.forceDir-targetDirs(i)*pi/180];
    dPD=[dPD;ex.analysis(i+1).data.forceDir-ex.analysis(1).data.forceDir];
    dModdepth=[dModdepth;ex.analysis(i+1).data.forceModdepth-ex.analysis(1).data.forceModdepth];
    moddepth=[moddepth;ex.analysis(1).data.forceModdepth];
end

mask=~(isnan(moddepth) | isnan(dPD));


%correct wrapping issues and round to get absolute angle deviation:
relPD(relPD>pi)=relPD(relPD>pi)-2*pi;
dPD(dPD>pi)=relPD(dPD>pi)-2*pi;
relPD(relPD<-pi)=relPD(relPD<-pi)+2*pi;
dPD(dPD<-pi)=relPD(dPD<-pi)+2*pi;

relPD=abs(relPD);
dPD=abs(dPD);

%put data into a table and run an anova to see the dependence of changes in
%PD and modulation depth on target direction and relative PD
testTable=table(tgtDir(mask),relPD(mask),moddepth(mask),dPD(mask),dModdepth(mask),'VariableNames',{'targetDir','initialPDDeviation','initialModdepth','PDChange','moddepthChange'});
testTable.targetDir=categorical(testTable.targetDir);
testTable.initialModdepth=double(testTable.initialModdepth);
glmePD=fitglme(testTable,'PDChange~targetDir+initialPDDeviation+initialModdepth');
%glmePD=fitglme(testTable,'PDChange~targetDir+initialPDDeviation');
testStatsPD=anova(glmePD);
glmeModdepth=fitglme(testTable,'moddepthChange~targetDir+initialPDDeviation+initialModdepth');
%glmeModdepth=fitglme(testTable,'moddepthChange~targetDir+initialPDDeviation');
testStatsModdepth=anova(glmeModdepth);