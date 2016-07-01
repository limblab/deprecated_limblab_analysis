%KinematicsVsKinetics_MoveandSpringFeb252016

clear;close all
% Step 1a: Initialize folders
 monkeyname = 'Kevin';
  BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
SubFolder={'05-15-15','05-19-15s','05-21-15s','05-25-15s','05-26-15s','06-03-15','06-04-15s','06-06-15','06-08-15'};

% monkeyname = 'Jango';
% BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
% SubFolder = {'07-23-14','07-24-14s','07-25-14s','08-19-14s','08-20-14s',...
%     '08-21-14s','09-23-14s','09-25-14','09-26-14','10-10-14s','10-11-14s'...
%     '10-12-14s','11-06-14','11-07-14'};

for z = 1:length(SubFolder)
    
    % Step 1:  Load data into workspace | Open folder directory for saving figs
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
    
    if SpringFile==1
        
        %Make sure you are using the same neurons for both files
        badUnits = checkUnitGuides_sn(WmBinned.neuronIDs,SprBinned.neuronIDs);
        newIDs = setdiff(WmBinned.neuronIDs, badUnits, 'rows');
        WmBinned.spikeguide = []; SprBinned.spikeguide = [];
        if ~(isempty(badUnits))
            for q = 1:length(badUnits(:,1))
                badUnitInd = find(SprBinned.neuronIDs(:,1) == badUnits(q,1) & SprBinned.neuronIDs(:,2) == badUnits(q,2));
                SprBinned.spikeratedata(:,badUnitInd) = [];
                badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(q,1) & WmBinned.neuronIDs(:,2) == badUnits(q,2));
                WmBinned.spikeratedata(:,badUnitInd) = [];
            end
            SprBinned.neuronIDs = newIDs; WmBinned.neuronIDs = newIDs;
        end
        
        % Make hybrid file between wm and spr
        [SprybridFinal AlteredWmFinal AlteredSprFinal WmTrain WmTest SprTrain SprTest] = makeHybridFileFixed(WmBinned,SprBinned);
        
        % Build model for kinmatics
        options=[]; options.PredCursPos = 1;
        %BuildNormalModels -------------------------------------------------------
        Hmodel = BuildModel(SprybridFinal,options);
        SprModel = BuildModel(SprTrain, options);
        WmModel = BuildModel(WmTrain, options);
        
        % Make predictions of X force and get VAF/mse
        foldlength = 30;
        % Hybrid
        [~,~,HonS_kin_predStruct, HonS_kin_vaf, HonS_kind_mse, HonS_kin_actTrunk] = PeriodicR2_SN(Hmodel,SprTest,foldlength);
        [~,~,HonW_kin_predStruct, HonW_kin_vaf, HonW_kind_mse, HonW_kin_actTrunk] = PeriodicR2_SN(Hmodel,WmTest,foldlength);
        % Within
        [~,~,SonS_kin_predStruct, SonS_kin_vaf, SonS_kind_mse, SonS_kin_actTrunk] = PeriodicR2_SN(SprModel,SprTest,foldlength);
        [~,~,WonW_kin_predStruct, WonW_kin_vaf, WonW_kind_mse, WonW_kin_actTrunk] = PeriodicR2_SN(WmModel,WmTest,foldlength);
        % Across
        [~,~,WonS_kin_predStruct, WonS_kin_vaf, WonS_kind_mse, WonS_kin_actTrunk] = PeriodicR2_SN(WmModel,SprTest,foldlength);
        [~,~,SonW_kin_predStruct, SonW_kin_vaf, SonW_kind_mse, SonW_kin_actTrunk] = PeriodicR2_SN(SprModel,WmTest,foldlength);
        
        
        
        
        % Hybrid vaf means
        HonS_kin_vaf_means(z) = mean(HonS_kin_vaf(:,1)); HonS_kin_vaf_STEs(z) = std(HonS_kin_vaf(:,1))/sqrt(length(HonS_kin_vaf(:,1)));
        HonW_kin_vaf_means(z) = mean(HonW_kin_vaf(:,1)); HonW_kin_vaf_STEs(z) = std(HonW_kin_vaf(:,1))/sqrt(length(HonW_kin_vaf(:,1)));
        % Within vaf means
        SonS_kin_vaf_means(z) = mean(SonS_kin_vaf(:,1)); SonS_kin_vaf_STEs(z) = std(SonS_kin_vaf(:,1))/sqrt(length(SonS_kin_vaf(:,1)));
        WonW_kin_vaf_means(z) = mean(WonW_kin_vaf(:,1)); WonW_kin_vaf_STEs(z) = std(WonW_kin_vaf(:,1))/sqrt(length(WonW_kin_vaf(:,1)));
        % Across vaf means
        WonS_kin_vaf_means(z) = mean(WonS_kin_vaf(:,1)); WonS_kin_vaf_STEs(z) = std(WonS_kin_vaf(:,1))/sqrt(length(WonS_kin_vaf(:,1)));
        SonW_kin_vaf_means(z) = mean(SonW_kin_vaf(:,1)); SonW_kin_vaf_STEs(z) = std(SonW_kin_vaf(:,1))/sqrt(length(SonW_kin_vaf(:,1)));
    else
        % Hybrid vaf means
        HonS_kin_vaf_means(z) = NaN; HonS_kin_vaf_STEs(z) =NaN;
        HonW_kin_vaf_means(z) = NaN; HonW_kin_vaf_STEs(z) = NaN;
        % Within vaf means
        SonS_kin_vaf_means(z) = NaN; SonS_kin_vaf_STEs(z) = NaN;
        WonW_kin_vaf_means(z) = NaN; WonW_kin_vaf_STEs(z) = NaN;
        % Across vaf means
        WonS_kin_vaf_means(z) = NaN; WonS_kin_vaf_STEs(z) = NaN;
        SonW_kin_vaf_means(z) = NaN; SonW_kin_vaf_STEs(z) = NaN;
    end
    
    
    % Make hybrid file between iso and wm
    % Need to make the cursorpos for the iso portions 0. This means make a new
% 'makehybridfile' script


clearvars -except monkeyname BaseFolder SubFolder HonS_kin_vaf_means...
    HonW_kin_vaf_means SonS_kin_vaf_means WonW_kin_vaf_means WonS_kin_vaf_means...
    SonW_kin_vaf_means HonS_kin_vaf_STEs HonW_kin_vaf_STEs SonS_kin_vaf_STEs...
    WonW_kin_vaf_STEs WonS_kin_vaf_STEs  SonW_kin_vaf_STEs



end

% Plot data across days
save =0;foldername = '';
for a=1:length(SubFolder)
 PlotVAFAcrossDays(a,3001,WonW_kin_vaf_means(a), WonW_kin_vaf_STEs(a), HonW_kin_vaf_means(a), HonW_kin_vaf_STEs(a), SonW_kin_vaf_means(a), SonW_kin_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Movement Kinematics VAFs Across Days'])
 PlotVAFAcrossDays(a,3002,SonS_kin_vaf_means(a), SonS_kin_vaf_STEs(a), HonS_kin_vaf_means(a), HonS_kin_vaf_STEs(a), WonS_kin_vaf_means(a), WonS_kin_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Spring Kinematics VAFs Across Days'])
end
