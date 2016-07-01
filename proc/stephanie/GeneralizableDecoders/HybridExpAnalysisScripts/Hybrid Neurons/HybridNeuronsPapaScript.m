%HybridNeuronsPapaScript

clear;close all;
% Step 1a: Initialize folders
  monkeyname = 'Kevin';
  HybridEMGlist=Kevin_HybridData_EMGQualityInfo();
  BaseFolder = 'Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
SubFolder={'05-15-15','05-19-15s','05-21-15s','05-25-15s','05-26-15s','06-03-15','06-04-15s','06-06-15','06-08-15'};

monkeyname = 'Jango';
HybridEMGlist=Jango_HybridData_EMGQualityInfo();
BaseFolder = 'Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
SubFolder = {'07-23-14','07-24-14s','07-25-14s','08-19-14s','08-20-14s',...
     '08-21-14s','09-23-14s','09-25-14','09-26-14','10-10-14s','10-11-14s'...
     '10-12-14s','11-06-14','11-07-14'};


for z = 1:length(SubFolder)
    % Step 1b:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{z} '\']);
    foldername = [BaseFolder SubFolder{z} '\'];
    hyphens = find(SubFolder{z}=='-'); SubFolder{z}(hyphens)=[];
    load([foldername 'HybridData_' monkeyname '_' SubFolder{z}(1,1:6)]);
    datalabel = SubFolder{z}(1:6);

% Initialize springfile variable
if SubFolder{z}(end)=='s'
    SpringFile = 1;
else SpringFile = 0;
end

% Step 1| Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,WmBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
IsoBinned.spikeguide = []; WmBinned.spikeguide = [];
if ~(isempty(badUnits))
    for i = 1:length(badUnits(:,1))
        badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(i,1) & WmBinned.neuronIDs(:,2) == badUnits(i,2));
        WmBinned.spikeratedata(:,badUnitInd) = [];
         badUnitInd = find(IsoBinned.neuronIDs(:,1) == badUnits(i,1) & IsoBinned.neuronIDs(:,2) == badUnits(i,2));
         IsoBinned.spikeratedata(:,badUnitInd) = [];
    end
    WmBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end
if SpringFile == 1
    SprBinned.spikeguide =[];
    badUnits = checkUnitGuides_sn(WmBinned.neuronIDs,SprBinned.neuronIDs);
    newIDs = setdiff(WmBinned.neuronIDs, badUnits, 'rows');
    if ~(isempty(badUnits))
        for i = length(badUnits(:,1))
            badUnitInd = find(SprBinned.neuronIDs(:,1) == badUnits(i,1) & SprBinned.neuronIDs(:,2) == badUnits(i,2));
            SprBinned.spikeratedata(:,badUnitInd) = [];
        end
        SprBinned.neuronIDs = newIDs; SprBinned.neuronIDs = newIDs;
    end
end

% Find the right EMGlist
% Only keep EMG data for the 4 wrist muscles
EMGlistIndex = find(strcmp(HybridEMGlist,datalabel));
binnedData = IsoBinned;
IsoBinned.emgguide = cellstr(IsoBinned.emgguide); WmBinned.emgguide = cellstr(WmBinned.emgguide);
for j=1:length(HybridEMGlist{EMGlistIndex,2})
    EMGindtemp = strmatch(HybridEMGlist{EMGlistIndex,2}(j,:),(binnedData.emgguide)); emg_vector(j) = EMGindtemp(1);
end
IsoBinned.emgguide = IsoBinned.emgguide(emg_vector); IsoBinned.emgdatabin = IsoBinned.emgdatabin(:,emg_vector);
WmBinned.emgguide = WmBinned.emgguide(emg_vector); WmBinned.emgdatabin = WmBinned.emgdatabin(:,emg_vector);
if SpringFile == 1
    SprBinned.emgguide = cellstr(SprBinned.emgguide);
    SprBinned.emgguide = SprBinned.emgguide(emg_vector); SprBinned.emgdatabin = SprBinned.emgdatabin(:,emg_vector);
end


% CreateNeuronPercentiles_KinVsEMG(WmBinned,[monkeyname,' ',datalabel,' WM'])
% SaveFigure('X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', [monkeyname,' ',datalabel,' WM'])
% if SpringFile==1
%     CreateNeuronPercentiles_KinVsEMG(SprBinned,[monkeyname,' ',datalabel,' Spring'])
%     SaveFigure('X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', [monkeyname,' ',datalabel,' Spring'])
%     NeuronsThatCare_XCorrelation(SprBinned,['Xcorr Spr ', monkeyname,' ',datalabel])
%     SaveFigure('X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', ['Xcorr Spr ', monkeyname,' ',datalabel])
% end

%NeuronsThatCare_XCorrelation(WmBinned,['Xcorr WM ', monkeyname,' ',datalabel])
NeuronsThatCare_XCorrelation_Stats(WmBinned,['Xcorr Hist WM ', monkeyname,' ',datalabel])
SaveFigure('Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', ['Xcorr Vel Hist WM ', monkeyname,' ',datalabel])
%SaveFigure('Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', ['Xcorr WM ', monkeyname,' ',datalabel])
%NeuronsThatCare_XCorrelation(IsoBinned,['Xcorr Iso ', monkeyname,' ',datalabel])
%SaveFigure('Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', ['Xcorr Iso ', monkeyname,' ',datalabel])

%CreateNeuronPercentiles_2Tasks(IsoBinned,'Isometric', WmBinned, 'Movement',[monkeyname,' ',datalabel,' Iso v Move'])
%SaveFigure('X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\NeuronsThatCare\', [monkeyname,' ',datalabel,' Two Tasks'])


%close all

end

