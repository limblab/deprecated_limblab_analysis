% %get PDs from CObump data
%     if ~exist('NEVNSx','var')
%         NEVNSx=cerebus2NEVNSx('E:\local processing\Han\20160411_COBump_ctrHold_Delay','Han_20160411_COBump_area2_001');
%     end
%% load test data into cds
    if ~exist('cds','var')
        cds=commonDataStructure();
        cds.file2cds('E:\local processing\Han\20160411_COBump_ctrHold_Delay\Han_20160411_COBump_area2_001.nev','arrayS1Area2','monkeyHan',3,'ignoreJumps','taskCObump');
    end
%% create new experiment object
    ex=experiment();

%% set which variables to load from cds
    ex.meta.hasLfp=true;
    ex.meta.hasKinematics=true;
    ex.meta.hasForce=true;
    ex.meta.hasUnits=true;
    ex.meta.hasTrials=true;

%% set configuration parameters that are not default 
%pdConfig setup:
    ex.binned.pdConfig.useParallel=true;
    ex.binned.pdConfig.pos=true;
    ex.binned.pdConfig.vel=true;
    ex.binned.pdConfig.force=true;
    ex.binned.pdConfig.speed=true;

%% load experiment from cds:
ex.addSession(cds)

%% set binConfig parameters:
    ex.binConfig.include(1).field='lfp';
        ex.binConfig.include(1).which={};
    ex.binConfig.include(2).field='units';
        ex.binConfig.include(2).which=[];
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};
    ex.binConfig.include(3).field='force';
        ex.binConfig.include(3).which={};

%% set firingRateConfig parameters
    ex.firingRateConfig.offset=-15;

%% set firingRateConfig parameters: 
    %ex.firingRateConfig.lags=[-2 3];

%% calculate the firing rate
    ex.calcFiringRate()
%% bin the data
    ex.binData()
    ex.firingRateConfig.lags=[-2 3];
    ex.firingRateConfig.cropType='tightCrop';
    ex.binData('recalcFiringRate')