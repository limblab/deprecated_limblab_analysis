% %get PDs from CObump data
%     if ~exist('NEVNSx','var')
%         NEVNSx=cerebus2NEVNSx('E:\local processing\Han\20160411_COBump_ctrHold_Delay','Han_20160411_COBump_area2_001');
%     end
%% load test data into cds
cds=commonDataStructure();
cds.file2cds('E:\local processing\chips\experiment_20160511_COBump_bumptuning\Chips_20160511_COBump_area2_tucker_001','arrayS1Area2','monkeyChips',6,'ignoreJumps','taskCObump');
save('E:\local processing\chips\experiment_20160511_COBump_bumptuning\cds.mat','cds','-v7.3')

    %
    
%% create new experiment object
ex=experiment();

% set which variables to load from cds
    ex.meta.hasLfp=false;
    ex.meta.hasKinematics=true;
    ex.meta.hasForce=true;
    ex.meta.hasUnits=true;
    ex.meta.hasTrials=true;

% set binConfig parameters:
%     ex.binConfig.include(1).field='lfp';
%         ex.binConfig.include(1).which={};
    ex.binConfig.include(1).field='units';
ex.binConfig.include(1).which=[];
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
% calculate the firing rate
    %ex.calcFiringRate()
% bin the data
    ex.units.deleteInvalid;
    ex.units.removeSorting;
    ex.binData()

%% PDs:
abortMask=true(size(ex.trials.data,1),1);
abortMask(strmatch('A',ex.trials.data.result,'exact'))=false;
%do bumps:
%get bump windows:
ex.bin.pdConfig.windows=[ex.trials.data.bumpTime(abortMask),ex.trials.data.bumpTime(abortMask)+.125];
% set configuration parameters that are not default 
    ex.bin.pdConfig.pos=true;
    ex.bin.pdConfig.vel=false;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    ex.bin.pdConfig.units={};%just use all of them
    ex.bin.pdConfig.bootstrapReps=100;
ex.bin.fitPds
ex.analysis(end).notes='pds during bump';

%do move:
%reset the pdConfig params
ex.bin.pdConfig.force=false;
ex.bin.pdConfig.vel=true;
%get move onset:
ex.bin.pdConfig.windows=[ex.trials.data.goCueTime(abortMask),ex.trials.data.goCueTime(abortMask)+.25];
ex.bin.fitPds
ex.analysis(end).notes='pds during move';
%% save the experiment
save('E:\local processing\chips\experiment_20160511_COBump_bumptuning\ex.mat','ex','-v7.3')
