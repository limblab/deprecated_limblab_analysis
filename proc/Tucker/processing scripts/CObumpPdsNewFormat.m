% %get PDs from CObump data
%     if ~exist('NEVNSx','var')
%         NEVNSx=cerebus2NEVNSx('E:\local processing\Han\20160411_COBump_ctrHold_Delay','Han_20160411_COBump_area2_001');
%     end
%% load test data into cds
    if ~exist('cds','var')
        cds=commonDataStructure();
        cds.file2cds('E:\local processing\Han\20160411_COBump_ctrHold_Delay\Han_20160411_COBump_area2_001.nev','arrayS1Area2','monkeyHan',6,'ignoreJumps','taskCObump');
        save('E:\local processing\Han\20160411_COBump_ctrHold_Delay\cds.mat','cds','-v7.3')
    end
    %
    
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
    ex.bin.pdConfig.useParallel=true;
    ex.bin.pdConfig.pos=true;
    ex.bin.pdConfig.vel=true;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    ex.bin.pdConfig.units={};%just use all of them
    
% set binConfig parameters:
%     ex.binConfig.include(1).field='lfp';
%         ex.binConfig.include(1).which={};
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
    
% load experiment from cds:
ex.addSession(cds)

% calculate the firing rate
    %ex.calcFiringRate()
% bin the data
    ex.binData()
    save('E:\local processing\Han\20160411_COBump_ctrHold_Delay\ex.mat','ex','-v7.3')