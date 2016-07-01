function PredictingMusclesOverTimeThresholdCrossingsFESGrant

monkeyname = 'Jango';
HybridEMGlist=Jango_HybridData_EMGQualityInfo();
BaseFolder = 'Z:\limblab\User_folders\Stephanie\Data Analysis\FESgrantrenewal\JangoThresholdCrossings\';
SubFolder = {'07-23-14','07-24-14','07-25-14','08-19-14','08-20-14',...
     '08-21-14','09-23-14','09-25-14','09-26-14','10-10-14','10-11-14'...
     '10-12-14','11-06-14','11-07-14'};


for z = 1:length(SubFolder)
    % Step 1b:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{z} '\']);
    foldername = [BaseFolder SubFolder{z} '\'];
    hyphens = find(SubFolder{z}=='-'); SubFolder{z}(hyphens)=[];
    load([foldername 'GenThresh_' monkeyname '_' SubFolder{z}(1,1:6)]);
    datalabel = SubFolder{z}(1:6);
    
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
  
    
% Initiate options variable
options.PredEMGs=1;options.foldlength=60;
% Make Movement Predictions-----------------------------------------------
[~, tempVAF] = mfxval_wmultivariateVAF(WmBinned, options);
Movement_mfxvalStats.meanVAF = mean(tempVAF);
Movement_mfxvalStats.steVAF=std(tempVAF)/sqrt(length(tempVAF));

% PC analysis
[~,~,~,~,Explained,~] = pca(WmBinned.emgdatabin);
PCcumsum=cumsum(Explained);
MovementPCstruct.ExplainedBy1PC = PCcumsum(1);
MovementPCstruct.ExplainedBy2PC = PCcumsum(2);


% Make Isometric Predictions----------------------------------------------
[~, tempVAF2] = mfxval_wmultivariateVAF(IsoBinned, options);
Isometric_mfxvalStats.meanVAF = mean(tempVAF2);
Isometric_mfxvalStats.steVAF=std(tempVAF2)/sqrt(length(tempVAF2));

% PC analysis
[~,~,~,~,ExplainedI,~] = pca(IsoBinned.emgdatabin);
PCcumsumI=cumsum(ExplainedI);
IsometricPCstruct.ExplainedBy1PC = PCcumsumI(1);
IsometricPCstruct.ExplainedBy2PC = PCcumsumI(2);

% Make all structs---------------------------------------------------------
if z == 1
    FullMovementStats = Movement_mfxvalStats;
    FullMovementPCstruct = MovementPCstruct;
    FullIsometricStats = Isometric_mfxvalStats;
    FullIsometricPCstruct = IsometricPCstruct;
else
    FullMovementStats = [FullMovementStats Movement_mfxvalStats];
    FullMovementPCstruct = [FullMovementPCstruct MovementPCstruct];
    FullIsometricStats = [FullIsometricStats Isometric_mfxvalStats];
    FullIsometricPCstruct = [FullIsometricPCstruct MovementPCstruct];
end


clearvars -except  monkeyname BaseFolder SubFolder HybridEMGlist...
    FullMovementStats FullIsometricStats FullMovementPCstruct FullIsometricPCstruct
  
  
end

% Plot mfxval
MarkerSize=20;LineWidth = 2;
figure; hold on;
for a=1:length(FullMovementStats)
h1=errorbar(a,FullIsometricStats(a).meanVAF,FullIsometricStats(a).steVAF,FullIsometricStats(a).steVAF,'.g');
set(h1,'MarkerSize',MarkerSize);set(h1,'LineWidth',2)
h2=errorbar(a,FullMovementStats(a).meanVAF,FullMovementStats(a).steVAF,FullMovementStats(a).steVAF,'.b');
set(h2,'MarkerSize',MarkerSize);set(h2,'LineWidth',2)
end
% Session labels for Jango
xlim([0 15])
ylim([0 1])
 set(gca,'Xtick',1:14,'XTickLabel',{'July 23', 'July 24', 'July 25', 'Aug 19', 'Aug 20', 'Aug 21',...
     'Sept 23', 'Sept 25', 'Sept 26', 'Oct 10', 'Oct 11', 'Oct 12', 'Nov 6', 'Nov 7'})
 ax=gca;
 ax.XTickLabelRotation=45;
 title('Multivariate VAF of Predictions For 2 Different Tasks')
 legend([h1(1),h2(1)],{'Isometric','Movement'})
legend boxoff
MillerFigure

% Plot PC data----------------------------------------------------------------
figure; hold on;
for b=1:length(FullMovementPCstruct)
    h3=plot(b,FullMovementPCstruct(b).ExplainedBy1PC,'.b');
    set(h3,'MarkerSize',MarkerSize);set(h3,'LineWidth',2);
    h4=plot(b,FullMovementPCstruct(b).ExplainedBy2PC,'.c');
    set(h4,'MarkerSize',MarkerSize);set(h4,'LineWidth',2);
    
end
MillerFigure
legend([h3(1),h4(1)],{'1PC','2PC'})
title('Variance Accounted For By 2 Movement PCs')

figure;hold on;
for c=1:length(FullIsometricPCstruct)
    h5=plot(c,FullIsometricPCstruct(c).ExplainedBy1PC,'.g');
    set(h5,'MarkerSize',MarkerSize);
    h6=plot(c,FullIsometricPCstruct(c).ExplainedBy2PC,'.c');
    set(h6,'MarkerSize',MarkerSize);
    ylim([0 100]);
end
MillerFigure;
legend([h5(1),h6(1)],{'1PC','2PC'})
title('Variance Accounted For By 2 Isometric PCs')

%Means
CondensedIsometricStats(1)=mean([FullIsometricStats(1:3).meanVAF]);
CondensedIsometricStats(2)=mean([FullIsometricStats(4:6).meanVAF]);
CondensedIsometricStats(3)=mean([FullIsometricStats(10:12).meanVAF]);
CondensedIsometricStats(4)=mean([FullIsometricStats(13:14).meanVAF]);
figure;plot(1:4,CondensedIsometricStats,'.k','MarkerSize',20);ylim([0 1]);xlim([0 5])
 set(gca,'Xtick',1:4,'XTickLabel',{'July', 'August', 'September','October'});
 title('Isometric multivariate VAFs')
 
 %Means
CondensedMovementStats(1)=mean([FullMovementStats(1:3).meanVAF]);
CondensedMovementStats(2)=mean([FullMovementStats(4:6).meanVAF]);
CondensedMovementStats(3)=mean([FullMovementStats(10:12).meanVAF]);
CondensedMovementStats(4)=mean([FullMovementStats(13:14).meanVAF]);
figure;plot(1:4,CondensedMovementStats,'.k','MarkerSize',20);ylim([0 1]);xlim([0 5])
 set(gca,'Xtick',1:4,'XTickLabel',{'July', 'August', 'September','October'});
 title('Movement multivariate VAFs')
 
 
end