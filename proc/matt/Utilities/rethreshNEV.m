% This may not work for files that use sorted units...
% Must save file as .nex. Load in .nex file
filename = 'C:\Users\limblab\Desktop\LabCode\Jaco_IsoHC_11-16-12_001.nex';
nf = readNexFile(filename);

disp('Data loaded.')

oldRMSMult = 4;
newRMSMult = 5.5;

% loop along all channels
oldRMS = zeros(1,length(nf.neurons));
newRMS = zeros(1,length(nf.neurons));
numRem = zeros(1,length(nf.neurons));

for iChan = 1:length(nf.neurons)
    % Calculate the old threshold
    relwaves = nf.waves{iChan}.waveforms;
    relwaves(relwaves > 0) = 0;
    oldRMS(iChan) = min(max(abs(relwaves),[],1))./oldRMSMult;
    
    % Compute a new threshold
    newRMS(iChan) = oldRMS(iChan).*newRMSMult;
    
    % Remove all spikes and waveforms that are below new threshold
    % Find bad waveforms
    badWs = max(abs(relwaves),[],1) < newRMS(iChan);
    nf.waves{iChan}.waveforms(:,badWs) = [];
    nf.waves{iChan}.timestamps(badWs) = [];
    nf.neurons{iChan}.timestamps(badWs) = [];
    numRem(iChan) = sum(badWs);
end

disp('Spikes removed.')

[a,b,c] = fileparts(filename);
filename2 = [a filesep b '_' num2str(newRMSMult) c];
[result, wf] = writeNexFile(nf, filename2);

% Calculate VAF
% fn = 'OLPred_mfxval_Jaco_IsoHC_11-16-12_Thresh6.mat';
% load(fn);
% mvaf6 = mean(OLPredData.mfxval.vaf);
% svaf6 = std(OLPredData.mfxval.vaf);
