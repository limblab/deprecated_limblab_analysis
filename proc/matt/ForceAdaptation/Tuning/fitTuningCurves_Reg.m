function out = fitTuningCurves_Reg(data,tuningPeriod,tuningMethod,useArray,doPlots)
% notes about inputs
% notes about outputs
% can pass tuning method in as cell array with multiple types
%
% NOTE: right now, target direction or 'pre' window for movement don't work with RT

if nargin < 4
    doPlots = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
movementTime = str2double(params.movement_time{1});
bootNumIters = str2double(params.number_iterations{1});
binAngles = str2double(params.bin_angles{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp([tuningMethod ' tuning, ' tuningPeriod ' movement, ' num2str(movementTime) ' second window...']);

%% Get data
sg = data.(useArray).unit_guide;

[fr,theta,mt] = getFR(data,useArray,tuningPeriod);

% Do bootstrapping with regression
statTestParams = {'bootstrap',bootNumIters,confLevel};

switch lower(tuningMethod)
    case 'regression'
        [tcs,pd_cis,md_cis] = regressTuningCurves(fr,theta,statTestParams,'doplots',doPlots);
        pds = tcs(:,3);
        mds = tcs(:,2);
    case 'vectorsum'
        [pds, pd_cis] = vectorSumPDs(fr,theta,statTestParams,'doplots',doPlots);
        mds = [];
        md_cis = [];
end

out.pds = [pds pd_cis];
out.mds = [mds md_cis];

out.unit_guide = sg;
out.fr = fr;
out.theta = theta;
out.mt = mt;
out.params.stats = statTestParams;
out.params.bin_angles = binAngles;
out.params.movement_time = movementTime;
