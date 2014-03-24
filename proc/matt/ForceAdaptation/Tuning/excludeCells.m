function [istuned, master_sg] = excludeCells(data,tuning,tracking_chan)
% This function will check all of the cells against various exclusion
% criteria. For each cell:
%
% Cell-related criteria:
%   1) Is there a high SNR for waveforms
%           Look at waveforms for each cell
%   2) Is there a low percentage of short ISIs
%           Look at ISI of all spikes
%   3) Is there a minimum task-related average firing rate?
%           Look at FR used for tuning and take average
%   4) Is it the same cell in each epoch?
%
% Tuning-related criteria:
%   1) Is CI on each cell less than some level?
%   2) Is there an agreeable R2 for cosine fits?
%
% 
% Data input is from baseline only. I assume that if it meets criteria
% there then it will for the rest, or else it won't pass the "same neuron"
% test.

paramFile = fullfile(tuning.meta.out_directory, [tuning.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
ciSig = str2double(params.ci_significance{1});
confLevel = str2double(params.confidence_level{1});
numIters = str2double(params.number_iterations{1});
r2Min = str2double(params.r2_minimum{1});
minFR = str2double(params.minimum_firing_rate{1});
isiThresh = str2double(params.isi_threshold{1});
isiPercent = str2double(params.isi_percent{1});
waveSNR = str2double(params.waveform_snr{1});
clear params;

blt = tuning.BL;
adt = tuning.AD(end); % for now, only use last block
wot = tuning.WO;

sg_bl = blt.sg;
sg_ad = adt.sg;
sg_wo = wot.sg;

badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);

% remove that index from each
[master_sg, idx_bl] = setdiff(sg_bl,badUnits,'rows');

[~, idx_ad] = setdiff(sg_ad,badUnits,'rows');

[~, idx_wo] = setdiff(sg_wo,badUnits,'rows');

% one element for each criteria. must meet criteria in all three task epochs
%   1) Waveform SNR
%   2) ISI Percentage
%   3) FR threshold
%   4) Neuron Tracking
%   5) PD CI
%   6) Cosine R2
istuned = zeros(size(master_sg,1),6);

units = data.units(idx_bl);

%% Check that SNR of waveforms is above some threshold
for unit = 1:size(master_sg,1)
    wf = diff(units(unit).wf);
    istuned(unit,1) = max(rms(a')./std(double(a'))) >= waveSNR;
end

%% Check that ISI of neuron is above some threshold
for unit = 1:size(master_sg,1)
    isi = diff(units(unit).ts);
    istuned(unit,2) = sum(isi < isiThresh/1000)/length(isi) < isiPercent/100;
end


%% Check that neuron meets firing rate criterion in each epoch
for unit = 1:size(master_sg,1)
    istuned(unit,3) = mean(mean(adt.mfr,1),2) >= minFR;
end


%% Check that same neuron is in each epoch
for unit = 1:size(master_sg,1)
    % Look at tracking output and determine if any are different
    idx = tracking_chan(:,1)==master_sg(unit,1)+.1*master_sg(unit,2);
    istuned(unit,4) = ~any(diff(tracking_chan(idx,:)));
end


%% Check confidence in PD estimates
pds_bl = blt.pds;
pds_ad = adt.pds;
pds_wo = wot.pds;

pds_bl = pds_bl(idx_bl,:);
pds_ad = pds_ad(idx_ad,:);
pds_wo = pds_wo(idx_wo,:);


for unit = 1:size(master_sg,1)
    t_bl = checkTuningCISignificance(pds_bl(unit,:),ciSig,true);
    t_ad = checkTuningCISignificance(pds_ad(unit,:),ciSig,true);
    t_wo = checkTuningCISignificance(pds_wo(unit,:),ciSig,true);
    
    istuned(unit,5) = all([t_bl,t_ad,t_wo]);
end


%% Check that r-squared of fit is okay
if isfield(blt,'r_squared') && ~isempty(blt.r_squared)
    rs_bl = blt.r_squared;
    rs_ad = adt.r_squared;
    rs_wo = wot.r_squared;
    
    rs_bl = sort(rs_bl(idx_bl,:),2);
    rs_ad = sort(rs_ad(idx_ad,:),2);
    rs_wo = sort(rs_wo(idx_wo,:),2);
    
    % get 95% CI for each
    rs_bl = [rs_bl(:,ceil(numIters - confLevel*numIters)), rs_bl(:,floor(confLevel*numIters))];
    rs_ad = [rs_ad(:,ceil(numIters - confLevel*numIters)), rs_ad(:,floor(confLevel*numIters))];
    rs_wo = [rs_wo(:,ceil(numIters - confLevel*numIters)), rs_wo(:,floor(confLevel*numIters))];
else
    % glm etc won't have r-squared
    rs_bl = ones(size(master_sg,1),1);
    rs_ad = ones(size(master_sg,1),1);
    rs_wo = ones(size(master_sg,1),1);
end

% check significance
istuned = zeros(size(master_sg,1),1);
for unit = 1:size(master_sg,1)
    % also only consider cells that are described by cosines
    %   have bootstrapped r2... see if 95% CI is > threshold?
    t_r_bl = rs_bl(unit,1) > r2Min;
    t_r_ad = rs_ad(unit,1) > r2Min;
    t_r_wo = rs_wo(unit,1) > r2Min;
    
    % only consider cells that are tuned in all epochs
    %   first column is CI bound, second is r-squared
    istuned(unit,6) = all([t_r_bl,t_r_ad,t_r_wo]);
end

