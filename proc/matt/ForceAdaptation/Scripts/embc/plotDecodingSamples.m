% plot sample of time decoding kinematics
%   Use same time window for all variables
%   Use same data sample for both areas
clear;
close all;
clc;

%%
% PARAMETERS
monkey = 'Mihili';
epoch = 'BL';
decoders = {'Position','Velocity','Target'};
arrays = {'M1','PMd'};
iFile = 13;
t = [115 137];

%%
% Data
save_dir = 'C:\Users\Matt Perich\Dropbox\lab\embc\Poster\figures';

root_dirs = {'Mihili','Z:\Mihili_12A3\Matt\';
    'Chewie','Z:\Chewie_8I2\Matt\';
    'MrT','Z:\MrT_9I4\Matt\'};

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...    % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S
dateInds = strcmpi(allFiles(:,1),monkey);
doFiles = allFiles(dateInds,:);
root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};

y = doFiles{iFile,2}(1:4);
m = doFiles{iFile,2}(6:7);
d = doFiles{iFile,2}(9:10);

%%
% which indices for each decoder (ie y velocity is 2)
decIdx = 1;

% for now, hard code vertical axis limits
ylims = [-13,13;-30,30;-1,1];
collims = [0,75,150;0,50,100];

for iArray = 1:length(arrays)
    use_array = arrays{iArray};
    bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epoch '_' m d y '_trim.mat']);
    
    for iDec = 1:length(decoders)
        filt_file = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_Decoder_' decoders{iDec} '.mat']);
        load(bin_file);
        [~,testData] = splitBinnedData_Matt(binnedData,t(1),t(2));
        [pred, ~] = predictSignals(filt_file,testData);
        [r2,vaf,mse,orig] = ActualvsOLPred_Matt(testData,pred,0,0);
        
        preds.timeframe = pred.timeframe;
        preds.spikes = pred.spikeratedata;
        preds.sg = pred.spikeguide;
        preds.(decoders{iDec}).r2 = r2;
        preds.(decoders{iDec}).vaf = vaf;
        preds.(decoders{iDec}).mse = mse;
        preds.(decoders{iDec}).pred = pred.preddatabin;
        preds.(decoders{iDec}).orig = orig;
    end
    
    % now, plot raster and predictions
    figure('Position',[100,0,800,1000]);
    subplot1(length(decoders)+1,1,'FontS',24,'Gap',[0 0]);
    subplot1(1);
    hold all;
    imagesc(preds.timeframe,1:size(preds.spikes,2),preds.spikes'); colorbar('East','YTick',collims(iArray,:));
    axis('tight');
    set(gca,'FontSize',24,'TickDir','out');
    box off;
    title(arrays{iArray},'FontSize',24);
    ax(1) = gca;
    
    for iDec = 1:length(decoders)
        subplot1(iDec+1);
        plot(preds.timeframe,preds.(decoders{iDec}).orig(:,decIdx),'LineWidth',2,'Color','k');
        plot(preds.timeframe,preds.(decoders{iDec}).pred(:,decIdx),'LineWidth',2,'Color','m');
        axis('tight');
        set(gca,'FontSize',24,'TickDir','out','YLim',ylims(iDec,:));
        box off;
        xlabel('Time (sec)','FontSize',24);
%         ylabel(decoders{iDec},'FontSize',24);
        ax(iDec+1) = gca;
    end
    linkaxes(ax,'x');
    
    saveas(gcf,[save_dir '\' 'sample_' use_array '.png'],'png');
    saveas(gcf,[save_dir '\' 'sample_' use_array '.fig'],'fig');
end


%% compare M1 and PMd
if 0
use_array = 'M1';
bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epoch '_' m d y '_trim.mat']);

for iDec = 1
    filt_file = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_Decoder_' decoders{iDec} '.mat']);
    load(bin_file);
    [~,testData] = splitBinnedData_Matt(binnedData,t(1),t(2));
    [pred, ~] = predictSignals(filt_file,testData);
    [r2,vaf,mse,orig] = ActualvsOLPred_Matt(testData,pred,0,0);
    
    preds.timeframe = pred.timeframe;
    preds.spikes = pred.spikeratedata;
    preds.sg = pred.spikeguide;
    preds.(decoders{iDec}).r2 = r2;
    preds.(decoders{iDec}).vaf = vaf;
    preds.(decoders{iDec}).mse = mse;
    preds.(decoders{iDec}).pred = pred.preddatabin;
    preds.(decoders{iDec}).orig = orig;
end

% now, plot raster and predictions
figure('Position',[200 200 800 600]);
iDec = 1;
colors = {'r','b'};
subplot1(2,2,'FontS',14,'Gap',[0 0]);
subplot1(1);

hold all;
imagesc(preds.timeframe,1:size(preds.spikes,2),preds.spikes'); colorbar('East');
axis('tight');
set(gca,'FontSize',14,'TickDir','out');
box off;
ax(1) = gca;
subplot1(3);
plot(preds.timeframe,preds.(decoders{iDec}).orig(:,decIdx),'LineWidth',2,'Color','k');
plot(preds.timeframe,preds.(decoders{iDec}).pred(:,decIdx),'LineWidth',2,'Color','r');
axis('tight');
set(gca,'FontSize',14,'TickDir','out');
box off;
xlabel('Time (sec)','FontSize',14);


use_array = 'PMd';
bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epoch '_' m d y '_trim.mat']);

for iDec = 1
    filt_file = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_Decoder_' decoders{iDec} '.mat']);
    load(bin_file);
    [~,testData] = splitBinnedData_Matt(binnedData,t(1),t(2));
    [pred, ~] = predictSignals(filt_file,testData);
    [r2,vaf,mse,orig] = ActualvsOLPred_Matt(testData,pred,0,0);
    
    preds.timeframe = pred.timeframe;
    preds.spikes = pred.spikeratedata;
    preds.sg = pred.spikeguide;
    preds.(decoders{iDec}).r2 = r2;
    preds.(decoders{iDec}).vaf = vaf;
    preds.(decoders{iDec}).mse = mse;
    preds.(decoders{iDec}).pred = pred.preddatabin;
    preds.(decoders{iDec}).orig = orig;
end

% now, plot raster and predictions
subplot1(2);
hold all;
imagesc(preds.timeframe,1:size(preds.spikes,2),preds.spikes'); colorbar('East');
axis('tight');
set(gca,'FontSize',14,'TickDir','out');
box off;
ax(1) = gca;
subplot1(4);
plot(preds.timeframe,preds.(decoders{iDec}).orig(:,decIdx),'LineWidth',2,'Color','k');
plot(preds.timeframe,preds.(decoders{iDec}).pred(:,decIdx),'LineWidth',2,'Color','b');
axis('tight');
set(gca,'FontSize',14,'TickDir','out');
box off;
xlabel('Time (sec)','FontSize',14);
end
% 
% iDec = 1;
% colors = {'r','b'};
% subplot1(2);
% plot(preds.timeframe,preds.(decoders{iDec}).orig(:,decIdx),'LineWidth',2,'Color','k');
% for iArray = 1:length(arrays)
%     use_array = arrays{iArray};
%     
%     bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epoch '_' m d y '_trim.mat']);
%     
%     filt_file = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_Decoder_' decoders{iDec} '.mat']);
%     load(bin_file);
%     [~,testData] = splitBinnedData_Matt(binnedData,t(1),t(2));
%     [pred, ~] = predictSignals(filt_file,testData);
%     [r2,vaf,mse,orig] = ActualvsOLPred_Matt(testData,pred,0,0);
%     
%     preds.timeframe = pred.timeframe;
%     preds.spikes = pred.spikeratedata;
%     preds.sg = pred.spikeguide;
%     preds.(decoders{iDec}).r2 = r2;
%     preds.(decoders{iDec}).vaf = vaf;
%     preds.(decoders{iDec}).mse = mse;
%     preds.(decoders{iDec}).pred = pred.preddatabin;
%     preds.(decoders{iDec}).orig = orig;
%     
%     plot(preds.timeframe,preds.(decoders{iDec}).pred(:,decIdx),'LineWidth',2,'Color',colors{iArray});
%     axis('tight');
%     set(gca,'FontSize',14,'TickDir','out');
%     box off;
%     xlabel('Time (sec)','FontSize',14);
%     
%     
% end
% ax(2) = gca;
% linkaxes(ax,'x');
% 
