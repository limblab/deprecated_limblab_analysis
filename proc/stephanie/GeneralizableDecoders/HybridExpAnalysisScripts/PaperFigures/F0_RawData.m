% F0: First paper figure showing raw data 
% Use Jango data 8-20

monkeyname = 'Jango';
HybridEMGlist=Jango_HybridData_EMGQualityInfo();
BaseFolder = 'Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
SubFolder = {'08-20-14s'};

% Step 1b:  Load data into workspace | Open folder directory for saving figs 
 cd([BaseFolder SubFolder{1} '\']);
 foldername = [BaseFolder SubFolder{1} '\'];
 hyphens = find(SubFolder{1}=='-'); SubFolder{1}(hyphens)=[];
    load([foldername 'HybridData_' monkeyname '_' SubFolder{1}(1,1:6)]);
    datalabel = SubFolder{1}(1:6);
SpringFile = 1;


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

% Normalize EMGs according to the biggest EMG across all 3 tasks
%Or across both tasks, if there isn't a spring session for that day
if SpringFile == 1
    [IsoEMGsNormed WmEMGsNormed SprEMGsNormed] = NormalizeGeneralizableEMGs(IsoBinned.emgdatabin,WmBinned.emgdatabin,SprBinned.emgdatabin, SpringFile);
    IsoBinned.emgdatabin = IsoEMGsNormed; WmBinned.emgdatabin = WmEMGsNormed; SprBinned.emgdatabin = SprEMGsNormed;
else
    [IsoEMGsNormed WmEMGsNormed] = NormalizeGeneralizableEMGs(IsoBinned.emgdatabin,WmBinned.emgdatabin,1, SpringFile);
    IsoBinned.emgdatabin = IsoEMGsNormed; WmBinned.emgdatabin = WmEMGsNormed;
end

% Load bdf
load('Z:\data\Jango_12a1\BDFStructs\Generalizability\WithHandle\08-20-14\Jango_20140820_SprHandleHoriz_Utah10ImpEMGs_SN_003-s');
bdf3Trunk = cell(length(bdf3.units),1);
for i = 1:length(bdf3.units) 
    indices = find(bdf3.units(i).ts>=246&bdf3.units(i).ts<=262);
    bdf3Trunk{i,1} = bdf3.units(i).ts(indices);
end


bdf3Trunk=bdf3Trunk(~cellfun('isempty',bdf3Trunk));
subplot(3,1,1); hold on;
for i = 1:length(bdf3Trunk)    
        ts = bdf3Trunk{i};
        plot([ts ts]', [(i-1)*ones(size(ts)),i*ones(size(ts))]','k')
end
xlim([246 262])

TaskEMG_Spring(SprBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'SprEMGs1');

% Make and save figures showing the EMGs for the 3 different tasks
save = 0;
%First List of EMGs
TaskEMG_Isometric(IsoBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'IsoEMGs1');
TaskEMG_Movement(WmBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'WmEMGs1');
if SpringFile == 1
    TaskEMG_Spring(SprBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'SprEMGs1');
end



