function [istuned, master_sg] = excludeCells(data,tuning,tracking,useArray,classifierBlocks)
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

t = tuning.(useArray).tuning;
tracking = tracking.(useArray);
data = data.(useArray);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(t(1).meta.out_directory, [t(1).meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
ciSig = str2double(params.ci_significance{1});
confLevel = str2double(params.confidence_level{1});
numIters = str2double(params.number_iterations{1});
isiThresh = str2double(params.isi_threshold{1});
isiPercent = str2double(params.isi_percent{1});
waveSNR = str2double(params.waveform_snr{1});
% a couple of parameters depend on the array
r2Min = str2double(params.([lower(useArray) '_r2_minimum']){1});
minFR = str2double(params.([lower(useArray) '_minimum_firing_rate']){1});
clear params;

all_sg = {t.sg};

tracking_chan = tracking{1}.chan;

badUnits = checkUnitGuides(all_sg);

% remove that index from each
[master_sg, ~] = setdiff(all_sg{1},badUnits,'rows');

for iBlock = 1:length(all_sg)
    [~, all_idx{iBlock}] = setdiff(all_sg{iBlock},badUnits,'rows');
end

% one element for each criteria. must meet criteria in all three task epochs
%   1) Waveform SNR
%   2) ISI Percentage
%   3) FR threshold
%   4) Neuron Tracking
%   5) PD CI
%   6) Cosine R2
istuned = zeros(size(master_sg,1),6);

units = data.units(all_idx{1});

%% Check that SNR of waveforms is above some threshold
% Compare peak to std of first bin, where presumably no cell is active
for unit = 1:size(master_sg,1)
    wf = units(unit).wf;
    %istuned(unit,1) = max(rms(wf'))/mean(std(double(wf(1:5,:)'))) >= waveSNR;
    sig = max(mean(wf'))-min(mean(wf'));
    istuned(unit,1) = sig / (2*mean(std(double(wf')))) >= waveSNR;
end


%% Check that ISI of neuron is above some threshold
for unit = 1:size(master_sg,1)
    isi = diff(units(unit).ts);
    istuned(unit,2) = sum(isi < isiThresh/1000)/length(isi) < isiPercent/100;
end


%% Check that neuron meets firing rate criterion in each epoch
if isfield(t(1),'fr')
    temp = all_idx{1};
    for unit = 1:size(master_sg,1)
        istuned(unit,3) = mean(t(1).fr(:,temp(unit)),1) >= minFR;
    end
else
    istuned(:,3) = ones(size(istuned(:,3)));
end

%% Check that same neuron is in each epoch
for unit = 1:size(master_sg,1)
    % Look at tracking output and determine if any are different
    idx = tracking_chan(:,1)==master_sg(unit,1)+.1*master_sg(unit,2);
    istuned(unit,4) = ~any(diff(tracking_chan(idx,:)));
end

% don't do this if the classifierBlocks input is empty
if ~isempty(classifierBlocks)
    %% Check confidence in PD estimates
    all_pds = {t.pds};
    for unit = 1:size(master_sg,1)
        sig = zeros(size(all_pds));
        for iBlock = 1:length(all_pds)
            temp = all_pds{iBlock};
            temp = temp(all_idx{iBlock},:);
            sig(iBlock) = checkTuningCISignificance(temp(unit,:),ciSig,true);
        end
        istuned(unit,5) = all(sig(classifierBlocks));
    end
    
    
    %% Check that r-squared of fit is okay
    if isfield(t(1),'r_squared') && ~isempty(t(1).r_squared)
        all_rs = {t.r_squared};
        all_rs_ci = cell(size(all_rs));
        
        for iBlock = 1:length(all_rs)
            temp = all_rs{iBlock};
            temp = sort(temp(all_idx{iBlock},:),2);
            
            all_rs{iBlock} = temp;
            
            % get 95% CI for each
            all_rs_ci{iBlock} = [temp(:,ceil(numIters - confLevel*numIters)), temp(:,floor(confLevel*numIters))];
        end
        
        for unit = 1:size(master_sg,1)
            sig = zeros(size(all_rs));
            for iBlock = 1:length(all_rs)
                % also only consider cells that are described by cosines
                %   have bootstrapped r2... see if 95% CI is > threshold?
                temp = all_rs_ci{iBlock};
                sig(iBlock) = temp(unit,1) > r2Min;
            end
            
            % check significance
            % only consider cells that are tuned in all epochs
            %   first column is CI bound, second is r-squared
            istuned(unit,6) = all(sig(classifierBlocks));
        end
    else
        istuned(:,6) = ones(size(istuned(:,6)));
    end
end

