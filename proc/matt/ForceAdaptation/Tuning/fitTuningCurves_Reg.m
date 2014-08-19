function out = fitTuningCurves_Reg(data,tuningPeriod,useArray,paramSetName,iBlock,doPlots)
% notes about inputs
% notes about outputs
% can pass tuning method in as cell array with multiple types

if nargin < 6
    doPlots = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_' paramSetName '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
movementTime = str2double(params.movement_time{1});
binAngles = str2double(params.bin_angles{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
bootNumIters = str2double(params.number_iterations{1});
clear params;


disp(['Regression tuning, ' num2str(movementTime) ' second window...']);

%% Get data
sg = data.(useArray).sg;

[fr,theta,mt,force,vel] = getFR(data,useArray,tuningPeriod,paramSetName,iBlock);

% Do bootstrapping with regression
statTestParams = {'bootstrap',bootNumIters,confLevel};

[tcs,cbs,rs,boot_pds,boot_mds] = regressTuningCurves(fr,theta,statTestParams,'doplots',doPlots);
pds = tcs(:,3);
pd_cis = cbs{3};
mds = tcs(:,2);
md_cis = cbs{2};

out.pds = [pds pd_cis];
out.mds = [mds md_cis];

out.boot_pds = boot_pds;
out.boot_mds = boot_mds;
out.r_squared = rs;

out.sg = sg;
out.fr = fr;
out.theta = theta;
out.mt = mt;
out.forces = force;
out.vels = vel;
out.params.stats = statTestParams;
out.params.bin_angles = binAngles;
out.params.movement_time = movementTime;

