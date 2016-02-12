clear;
clc;
close all;

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

root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';


% allFiles = allFiles(strcmpi(allFiles(:,1),'Mihili'),:);
% dateInds = strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO');
dateInds = [6];
dateColors = {'b','r','g','m'};

epochs = {'BL','AD3','WO3'};

useArray = 'M1';
paramSetName = 'movement';

for iDate = 1:length(dateInds)
    doFile = allFiles(dateInds(iDate),:);
    
    [spikes,allMT,indices] = combineAllEpochs(root_dir,doFile,epochs,useArray,paramSetName);
    
    % reorganize indices to combine epochs and targets
    
    
    %-------------------------------------------------------------------------%
    %%%% DEFINE THESE FOLLOWING VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    diff_conds = []; % e.g. {[1 3 5],[2 4 6]} means that
    %                                   trials [1 3 5] are from condition 1 and
    %                                   trials [2 4 6] are from condition 2.
    %                                   There can be any number of different
    %                                   conditions. If you don't want to
    %                                   separate by condition, set empty
    %                                   (diff_conds = [])
    trial_table = allMT; % Trial table size with rows
    %                                     representing trials
    t1 = [4,0];
    t2 = [6,-400];
    numTargets = 8;
    units = spikes; % Cell array in which each cell contains spike
    %                          from a single neuron
    % runIdx = 'Target_On to Go_Cue'; % Some identifying tag for the run
    %                            (e.g. 'Target_On to Go_Cue 01_30_2014')
    % directory = 'C:\Users\Matt Perich\Desktop\lab\code\s1_analysis\proc\matt\DimReduction\results\'; % Directory string for saving data.
    directory = 'C:\\Users\\Matt Perich\\Desktop\\lab\\code\\s1_analysis\\proc\\matt\\DimReduction\\results'; % Directory string for saving data.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %-------------------------------------------------------------------------%
    
    % automatically generate a subfolder
    runIdx = [useArray '_'];
    for iEpoch = 1:length(epochs)
        runIdx = [runIdx, epochs{iEpoch} '_'];
    end
    runIdx = [runIdx, '_' num2str(t1(1)) '_' num2str(t2(1)) '_' doFile{2}];
    
    
    %-------------------------------------------------------------------------%
    %%%% ADDITIONAL OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cross validation takes a long time. For exploratory types of analysis,
    % leave this as false.
    do_cross_val = false;
    % Plot the traces
    plot_conditions = true; % Plot separate conditions
    [trial_rast,dat] = trial_raster(units,trial_table,t1,t2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %-------------------------------------------------------------------------%
    
    
    %%
    % ===========================================
    % 1) Basic extraction of neural trajectories
    % ===========================================
    method = 'gpfa';
    
    % Select number of latent dimensions
    xDim = 8; %find optimal using CV (below section)
    kernSD = 30; % find optimal kernal using CV (below section)
    binWidth = 20;
    
    % Extract neural trajectories
    result = neuralTraj_limblab(runIdx, dat, directory, 'method', method, 'xDim', xDim,...
        'kernSDList', kernSD,'binWidth',binWidth);
    
    % Orthonormalize neural trajectories
    [estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
    
    % Seq train will NOT be ordered by trial. This makes labeling by trial
    % with indices quite difficult, so we reorder it to be sequential. We also
    % keep the original (orig_SeqTrain) in case a shuffled form is desired
    ord_seqTrain = seqTrain;
    for tr = 1:length(seqTrain)
        tId = seqTrain(tr).trialId;
        ord_seqTrain(tId) = seqTrain(tr);
    end
    orig_seqTrain = seqTrain; seqTrain = ord_seqTrain;
    
    % Plot neural trajectories in 3D space
    % plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3);
    % plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3,'nPlotMax',1000);
    
    % Plot each dimension of neural trajectories versus time
    % plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
    
    fprintf('\nDone\n');
    
    %%
    % Make figure to show progression of activity
    if 0
        figure; hold all;
        dims = 1:3;
        dimAvg = zeros(length(dims),length(seqTrain));
        for iTrial = 1:length(seqTrain)
            dimAvg(:,iTrial) = mean(seqTrain(iTrial).xorth(dims,:),2);
        end
        
        
        
        allChange = [];
        for iReach = 1:size(indices,2)
            % get average in baseline for each dimension and reach direction
            bl_avg = mean(dimAvg(:,indices{1,iReach}),2);
            inds = [];
            for iEpoch = 1:length(epochs)
                inds = [inds;indices{iEpoch,iReach}];
            end
            dat = mean( abs(dimAvg(:,inds) - repmat(bl_avg,1,length(inds))),1);
            plot(dat,'o');
            allChange = [allChange, dat(floor(length(dat)/2):end)];
        end
        set(gca,'FontSize',14,'TickDir','out');
        box off;
        xlabel('Trials','FontSize',14);
        ylabel('Abs(Mean Change in Low-D FR)','FontSize',14);
        
        
        %
        % Make figure to show progression of activity
        dims = 1:8;
        dimAvg = zeros(length(dims),length(seqTrain));
        for iTrial = 1:length(seqTrain)
            dimAvg(:,iTrial) = mean(seqTrain(iTrial).xorth(dims,:),2);
        end
        
        
        if iDate == 1
            figure;
            hold all;
        end
        
        for iEpoch = 1:length(epochs)
            dat = [];
            for iReach = 1:size(indices,2)
                % get average in baseline for each dimension and reach direction
                bl_avg = mean(dimAvg(:,indices{1,iReach}),2);
                
                inds = indices{iEpoch,iReach};
                dat = [dat, sum( abs(dimAvg(:,inds) - repmat(bl_avg,1,length(inds))),1)];
            end
            
            plot(iEpoch,mean(dat),'o','LineWidth',3,'Color',dateColors{iDate});
            plot([iEpoch,iEpoch],[mean(dat) + std(dat)./length(dat), mean(dat) - std(dat)./length(dat)],'-','LineWidth',2);
            
            allDat{iDate} = dat;
            
        end
    end
end
set(gca,'FontSize',14,'TickDir','out');
box off;
xlabel('Trials','FontSize',14);
ylabel('Abs(Mean Change in Low-D FR)','FontSize',14);

%% plot by color
%plotEachDimVsTime(seqTrain([indices{1,1};indices{2,1};indices{3,1}]), 'xorth', result.binWidth,'redTrials',indices{2,1},'blueTrials',indices{3,1},'nPlotMax',1000);

%% Plot traces
if plot_conditions
    figure; hold on;
    if 1
        diff_conds = indices(:,1);
        %cols2plot = distinguishable_colors(length(diff_conds));
        cols2plot = rand(length(diff_conds),3);
        
        cond_seqTrain = cell(length(diff_conds),1);
        for j = 1:length(diff_conds)
            cond_seqTrain{j} = seqTrain(diff_conds{j});
            plot3D_addon(cond_seqTrain{j}, 'xorth', cols2plot(j,:),...
                'dimsToPlot', 1:3,'nPlotMax',10000);
        end
        
    end
    
    
    %% Plot traces for each direction with subplot for each epoch
    figure; hold on;
    a = zeros(1,length(epochs));
    subplot1(1,length(epochs),'Gap',[0 0]);
    
    cols2plot = rand(numTargets,3);
    
    for i = 1:3
        a(i) = subplot1(i);
        diff_conds = indices(i,:);
        
        cond_seqTrain = cell(length(diff_conds),1);
        for j = 1:length(diff_conds)
            cond_seqTrain{j} = seqTrain(diff_conds{j});
            plot3D_addon(cond_seqTrain{j}, 'xorth', cols2plot(j,:),...
                'dimsToPlot', 1:3,'nPlotMax',10000);
        end
        set(a(i),'XLim',[-2,2],'YLim',[-2,2],'ZLim',[-2,2]);
    end
    
    Link = linkprop(a,{'CameraUpVector', 'CameraPosition', 'CameraTarget'});
    setappdata(gcf, 'StoreTheLink', Link);
    
    %% Plot traces for different epochs with subplot for each target
    figure;
    a = zeros(1,numTargets);
    subplot1(2,numTargets/2,'Gap',[0 0]);
    cols2plot = [0,0,1;1,0,0;0,1,0];
    for i = 1:numTargets
        a(i) = subplot1(i);
        hold on;
        diff_conds = indices(:,i);
        
        cond_seqTrain = cell(length(diff_conds),1);
        for j = 1:length(diff_conds)
            cond_seqTrain{j} = seqTrain(diff_conds{j});
            plot3D_addon(cond_seqTrain{j}, 'xorth', cols2plot(j,:),...
                'dimsToPlot', 1:3,'nPlotMax',10000);
        end
        set(a(i),'XLim',[-2,2],'YLim',[-2,2],'ZLim',[-2,2]);
    end
    
    Link = linkprop(a,{'CameraUpVector', 'CameraPosition', 'CameraTarget'});
    setappdata(gcf, 'StoreTheLink', Link);
    
    %%
    % plotTrajProgression(seqTrain,indices([1,2],:));
    % plotTrajProgression(seqTrain,indices([1,3],:));
    
end

%%
if do_cross_val
    % ========================================================
    % 2) Full cross-validation to find:
    %  - optimal state dimensionality for all methods
    %  - optimal smoothing kernel width for two-stage methods
    % ========================================================
    
    % Select number of cross-validation folds
    numFolds = 4;
    
    % Perform cross-validation for different state dimensionalities.
    % Results are saved in mat_results/runXXX/, where XXX is runIdx.
    for xDim = [2 5 8]
        %neuralTraj(runIdx, dat, 'method',  'pca', 'xDim', xDim, 'numFolds', numFolds);
        %neuralTraj(runIdx, dat, 'method', 'ppca', 'xDim', xDim, 'numFolds', numFolds);
        %neuralTraj(runIdx, dat, 'method',   'fa', 'xDim', xDim, 'numFolds', numFolds);
        neuralTraj(runIdx, dat, 'method', 'gpfa', 'xDim', xDim, 'numFolds', numFolds);
    end
    fprintf('\n');
    % NOTES:
    % - These function calls are computationally demanding.  Cross-validation
    %   takes a long time because a separate model has to be fit for each
    %   state dimensionality and each cross-validation fold.
    
    % Plot prediction error versus state dimensionality.
    % Results files are loaded from mat_results/runXXX/, where XXX is runIdx.
    kernSD = 30; % select kernSD for two-stage methods
    plotPredErrorVsDim(runIdx, kernSD);
    % NOTES:
    % - Using this figure, we i) compare the performance (i.e,,
    %   predictive ability) of different methods for extracting neural
    %   trajectories, and ii) find the optimal latent dimensionality for
    %   each method.  The optimal dimensionality is that which gives the
    %   lowest prediction error.  For the two-stage methods, the latent
    %   dimensionality and smoothing kernel width must be jointly
    %   optimized, which requires looking at the next figure.
    % - In this particular example, the optimal dimensionality is 5. This
    %   implies that, even though the raw data are evolving in a
    %   53-dimensional space (i.e., there are 53 units), the system
    %   appears to be using only 5 degrees of freedom due to firing rate
    %   correlations across the neural population.
    % - Analogous to Figure 5A in Yu et al., J Neurophysiol, 2009.
    
    % Plot prediction error versus kernelSD.
    % Results files are loaded from mat_results/runXXX/, where XXX is runIdx.
    xDim = 8; % select state dimensionality
    plotPredErrorVsKernSD(runIdx, xDim);
    % NOTES:
    % - This figure is used to find the optimal smoothing kernel for the
    %   two-stage methods.  The same smoothing kernel is used for all units.
    % - In this particular example, the optimal standard deviation of a
    %   Gaussian smoothing kernel with FA is 30 ms.
    % - Analogous to Figures 5B and 5C in Yu et al., J Neurophysiol, 2009.
end