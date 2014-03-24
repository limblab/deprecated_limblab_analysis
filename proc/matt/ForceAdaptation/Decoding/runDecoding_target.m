% use binned position and trial table to build a continuous vector of
% target angle relative to hand
clear
clc

%%
root_dirs = {'Mihili','Z:\Mihili_12A3\Matt\';
    'Chewie','Z:\Chewie_8I2\Matt\';
    'MrT','Z:\MrT_9I4\Matt\'};
tt_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
rewriteFiles = false;

numbins = 10; %number of lags for decoder

rewardThresh_RT = 0;
timeLimit_RT = 6;
timeLimit_CO = 3;
minTime_RT = 2.5;
minTime_CO = 0.2;

foldLength = 30;

kin_array = 'M1'; % only needed for PMd

doFiles = {'Mihili','2014-01-14','VR','RT'; ...
    'Mihili','2014-01-15','VR','RT'; ...
    'Mihili','2014-02-18-VR','VR','CO'; ...
    'Mihili','2014-03-03','VR','CO'; ...
    'Mihili','2014-02-03','FF','CO'; ...
    'Mihili','2014-02-14','FF','RT'; ...
    'Mihili','2014-02-17','FF','CO'; ...
    'Mihili','2014-02-18','FF','CO'; ...
    'Mihili','2014-02-24','FF','RT'; ...
    'Mihili','2014-02-24-VR','VR','RT'; ...
    'Mihili','2014-03-04','VR','CO'; ...
    'Mihili','2014-03-06','VR','CO'; ...
    'Mihili','2014-03-07','FF','CO'};

epochs = {'BL','AD','WO'};
arrays = {'PMd','M1'};
decoders = {'Target','Velocity','Position'};

symbols = {'o','s','^','d','v','+','p','>','h','.','<','o','s','^','d','v','+','p','>','h','.','<'};

%% Do decoding
for iArray = 1:length(arrays)
    use_array = arrays{iArray};
    
    %% checks directories and files to make sure they exist
    checkDecodingFiles(root_dirs,use_array,doFiles,epochs,kin_array,rewriteFiles)
    
    %% now, bin the three data files
    binDataFiles(root_dirs,use_array,doFiles,epochs,rewriteFiles)
    
    %% now, make target direction vector and save is new binned data file
    trimBinnedData(root_dirs,tt_dir,use_array,doFiles,epochs,[2 6],0.05,rewriteFiles);
    
    %% Do Decoding
    for iDec = 1:length(decoders)
        switch lower(decoders{iDec})
            case 'position'
                predFlags = [1 0 0];
            case 'velocity'
                predFlags = [0 1 0];
            case 'target'
                predFlags = [0 0 1];
        end
        
        fileVAFs = cell(size(doFiles,1),6);
        fileR2s = cell(size(doFiles,1),6);
        
        % now, build decoder for baseline
        [fileVAFs(:,1),fileR2s(:,1)] = doBaselineDecoding(root_dirs,use_array,doFiles,predFlags,foldLength,numbins);
        
        % Now, make predictions for AD and calculate VAF
        [fileVAFs(:,2), fileR2s(:,2)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',[0 0.33]);
        [fileVAFs(:,3), fileR2s(:,3)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',[0.33 0.66]);
        [fileVAFs(:,4), fileR2s(:,4)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',[0.66 1]);
        
        % Now, make predictions for WO and calculate VAF
        [fileVAFs(:,5), fileR2s(:,5)] = doEpochDecoding(root_dirs,use_array,doFiles,'WO',[0 0.5]);
        [fileVAFs(:,6), fileR2s(:,6)] = doEpochDecoding(root_dirs,use_array,doFiles,'AD',[0.5 1]);
        
        AllTheResults{iArray,iDec} = fileVAFs;
    end
end

%%
%Now that I have ALL THE RESULTS

%  Plot, for PMd, the three conditions
ymin = 0;
ymax = 1;

for iArray = 1:length(arrays)
    figure;
    subplot1(1,size(AllTheResults,2),'Gap',[0,0],'YTickL','Margin');
    
    for iDec = 1:size(AllTheResults,2)
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        temp = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'ff'),:),'UniformOutput',false);
        
        % now find mean/std across files for this condition
        vaf_ff(iDec,:) = nanmean(cellfun(@(x) nanmean(x,1),temp),1);
        vaf_ff_std(iDec,:) = nanstd(cellfun(@(x) nanmean(x,1),temp),1)./sqrt(size(doFiles,1));
        
        temp = cellfun(@(x) nanmean(x,2),fileVAFs(strcmpi(doFiles(:,3),'vr'),:),'UniformOutput',false);
        vaf_vr(iDec,:) = nanmean(cellfun(@(x) nanmean(x,1),temp),1);
        vaf_vr_std(iDec,:) = nanstd(cellfun(@(x) nanmean(x,1),temp),1)./sqrt(size(doFiles,1));
    end
    
    titleVec = {[arrays{iArray} '-Target'],'Velocity','Position'};
    for iDec = 1:size(AllTheResults,2)
        subplot1(iDec);
        hold all;
        
        plot(0:5,vaf_vr(iDec,:),'o','LineWidth',2,'Color','r');
        plot([0:5;0:5],[vaf_vr(iDec,:)-vaf_vr_std(iDec,:);vaf_vr(iDec,:)+vaf_vr_std(iDec,:)],'LineWidth',2,'Color','r');
        plot(0:5,vaf_ff(iDec,:),'o','LineWidth',2,'Color','b');
        plot([0:5;0:5],[vaf_ff(iDec,:)-vaf_ff_std(iDec,:);vaf_ff(iDec,:)+vaf_ff_std(iDec,:)],'LineWidth',2,'Color','b');
        
        axis('tight');
        set(gca,'XTick',[0 1 2 3 4 5],'XTickLabels',{'Baseline','Adaptation1','Adaptation2','Adaptation3','Washout1','Washout2'},'YLim',[ymin ymax],'XLim',[-0.5 5.5],'FontSize',14);
        title(titleVec{iDec},'FontSize',14);
        ylabel('VAF','FontSize',14);
    end
    
    all_vaf_vr(iArray,:,:) = vaf_vr;
    all_vaf_ff(iArray,:,:) = vaf_ff;
    all_vaf_vr_std(iArray,:,:) = vaf_vr_std;
    all_vaf_ff_std(iArray,:,:) = vaf_ff_std;
    
end


%%%%%%%
% Plot the three conditions, comparing the brain areas
for iDec = 1:size(AllTheResults,2)
    figure;
    subplot1(1,2,'Gap',[0,0],'YTickL','Margin');
    
    for iArray = 1:2
        
        vaf_vr = squeeze(all_vaf_vr(iArray,:,:));
        vaf_ff = squeeze(all_vaf_ff(iArray,:,:));
        vaf_vr_std = squeeze(all_vaf_vr_std(iArray,:,:));
        vaf_ff_std = squeeze(all_vaf_ff_std(iArray,:,:));
        
        subplot1(iArray);
        hold all;
        
        plot(0:5,vaf_vr(iDec,:),'o','LineWidth',2,'Color','r');
        plot([0:5;0:5],[vaf_vr(iDec,:)-vaf_vr_std(iDec,:);vaf_vr(iDec,:)+vaf_vr_std(iDec,:)],'LineWidth',2,'Color','r');
        plot(0:5,vaf_ff(iDec,:),'o','LineWidth',2,'Color','b');
        plot([0:5;0:5],[vaf_ff(iDec,:)-vaf_ff_std(iDec,:);vaf_ff(iDec,:)+vaf_ff_std(iDec,:)],'LineWidth',2,'Color','b');
        
        axis('tight');
        set(gca,'XTick',[0 1 2 3 4 5],'XTickLabels',{'Baseline','Adaptation1','Adaptation2','Adaptation3','Washout1','Washout2'},'YLim',[ymin ymax],'XLim',[-0.5 5.5],'FontSize',14);
        
        title([arrays{iArray} '-' decoders{iDec}],'FontSize',14);
        
        if iArray == 1
            ylabel('VAF','FontSize',14);
        end
        
    end
    
end


%%
% Find average VAF in baseline of all days for both areas and all decoders
decoders = {'Target','Velocity','Position'};
arrays = {'PMd','M1'};
whichBlock = 1;

for iDec = 1:size(AllTheResults,2)
    for iArray = 1:2
        fileVAFs = AllTheResults{iArray,iDec};
        
        % get the mean VAF for each file
        temp = cellfun(@(x) nanmean(x,2),fileVAFs,'UniformOutput',false);
        
        % now find mean/std across files for this condition
        bl_vaf(iArray,iDec) = nanmean(cellfun(@(x) nanmean(x,1),temp(:,whichBlock)),1);
        bl_vaf_std(iArray,iDec) = nanstd(cellfun(@(x) nanmean(x,1),temp(:,whichBlock)),1)./sqrt(size(doFiles,1));
    end
end

figure;
h = barwitherr(bl_vaf_std,bl_vaf,'BarWidth',1);
c=get(h,'Children');
for i = 1:length(c)
    set(c{i},'CDataMapping','scaled');
end

colormap([0.8 0.25 0.25;0.25 0.8 0.25;0.25 0.25 1])

set(gca,'XTickLabel',arrays,'YLim',[0 1],'FontSize',14);
ylabel('VAF','FontSize',14);
legend(decoders,'FontSize',14);



