function out = fitTuningCurves_Reg(data,tuningPeriod,epoch,useArray,paramSetName,doPlots)
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
adBlocks = params.ad_exclude_fraction;
woBlocks = params.wo_exclude_fraction;
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

% see if file is being divided into blocks
if strcmpi(epoch,'AD')
    numBlocks = length(adBlocks)-1;
else
    numBlocks = 1;
end

for iBlock = 1:numBlocks
    [fr,theta,mt] = getFR(data,useArray,tuningPeriod,paramSetName,iBlock);
    
    % Do bootstrapping with regression
    statTestParams = {'bootstrap',bootNumIters,confLevel};
    
    [tcs,cbs,rs,boot_pds,boot_mds] = regressTuningCurves(fr,theta,statTestParams,'doplots',doPlots);
    pds = tcs(:,3);
    pd_cis = cbs{3};
    mds = tcs(:,2);
    md_cis = cbs{2};
    
    out(iBlock).pds = [pds pd_cis];
    out(iBlock).mds = [mds md_cis];
    
    out(iBlock).boot_pds = boot_pds;
    out(iBlock).boot_mds = boot_mds;
    out(iBlock).r_squared = rs;
    
    out(iBlock).sg = sg;
    out(iBlock).fr = fr;
    out(iBlock).theta = theta;
    out(iBlock).mt = mt;
    out(iBlock).params.stats = statTestParams;
    out(iBlock).params.bin_angles = binAngles;
    out(iBlock).params.movement_time = movementTime;
    if strcmpi(epoch,'ad')
        out(iBlock).params.block = adBlocks(iBlock:iBlock+1);
    elseif strcmpi(epoch,'wo')
        out(iBlock).params.block = woBlocks;
    end
end
