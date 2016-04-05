%script to test experiment:
%% create new experiment object
ex=experiment();

%% set which variables to load from cds
ex.meta.hasLfp=true;
ex.meta.hasKinematics=true;
ex.meta.hasForce=true;
ex.meta.hasUnits=true;
ex.meta.hasTrials=true;

%% load experiment from cds:
ex.addSession(cds)

%% set binConfig parameters:
ex.binConfig.include(1).field='lfp';
    ex.binConfig.include(1).which={'elec78','elec88','elec56'};
ex.binConfig.include(2).field='units';
    ex.binConfig.include(2).which=1:40;
ex.binConfig.include(2).field='kin';
    ex.binConfig.include(2).which={};
ex.binConfig.include(3).field='units';
    ex.binConfig.include(3).which=1:40;
ex.binConfig.include(4).field='force';
    ex.binConfig.include(4).which={};
ex.binConfig.include(5).field='trials';
    ex.binConfig.include(5).which={};

%% set firingRateConfig parameters: 
%ex.firingRateConfig.lags=[-2 3];

%% calculate the firing rate
ex.calcFiringRate()
%% bin the data
ex.binData()
ex.firingRateConfig.lags=[-2 3];
ex.firingRateConfig.cropType='tightCrop';
ex.binData('recalcFiringRate')