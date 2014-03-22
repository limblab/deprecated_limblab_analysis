function out = fitTuningCurves_VS(data,tuningPeriod,epoch,useArray,paramSetName,doPlots)
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
blocks = params.ad_exclude_fraction;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
bootNumIters = str2double(params.number_iterations{1});
clear params;


disp(['Vector sum tuning, ' tuningPeriod ' movement, ' num2str(movementTime) ' second window...']);

%% Get data
sg = data.(useArray).sg;

% see if file is being divided into blocks
if strcmpi(epoch,'AD')
    numBlocks = length(blocks)-1;
else
    numBlocks = 1;
end

for iBlock = 1:numBlocks
    [fr,theta,mt] = getFR(data,useArray,tuningPeriod,paramSetName,iBlock);
    
    % Do bootstrapping with regression
    statTestParams = {'bootstrap',bootNumIters,confLevel};

    [pds, pd_cis, boot_pds] = vectorSumPDs(fr,theta,statTestParams,'doplots',doPlots);
%     [mds, md_cis, boot_mds] = vectorSumMDs(fr,theta,statTestParams,'doplots',doPlots);
%     [bos, bo_cis, boot_bos] = vectorSumPDs(fr,theta,statTestParams,'doplots',doPlots);
    mds = [];
    md_cis = [];
    bos = [];
    bo_cis = [];
    boot_mds = [];
    boot_bos = [];
    
    out(iBlock).pds = [pds pd_cis];
    out(iBlock).mds = [mds md_cis];
    out(iBlock).bos = [bos bo_cis];
    
    out(iBlock).boot_pds = boot_pds;
    out(iBlock).boot_mds = boot_mds;
    out(iBlock).boot_bos = boot_bos;
    
    out(iBlock).sg = sg;
    out(iBlock).fr = fr;
    out(iBlock).theta = theta;
    out(iBlock).mt = mt;
    out(iBlock).params.stats = statTestParams;
    out(iBlock).params.bin_angles = binAngles;
    out(iBlock).params.movement_time = movementTime;
    
end
