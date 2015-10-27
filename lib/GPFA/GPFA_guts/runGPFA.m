do_cross_val = false;
plot_conditions = true;

Brain_area = 'PMd';
t1 = [6 0];
t2 = [9 0];
block = 8;
move_col = 13;

trial_table = eval(sprintf('alldays(%d).tt',block));
units = eval(sprintf('alldays(1).%s_units',Brain_area));

runIdx = sprintf('_%s_%s_[%d %d]_[%d %d]_%d',modaye,Brain_area,t1(1),t1(2),t2(1),t2(2),block);

[trial_rast,dat] = trial_raster(units,trial_table,t1,t2);
%[trial_rast,dat] = trial_raster(totunits,trial_table,t1,t2);

% ===========================================
% 1) Basic extraction of neural trajectories
% ===========================================

% Results will be saved in mat_results/runXXX/, where XXX is runIdx.
% Use a new runIdx for each dataset.

method = 'gpfa';

% Select number of latent dimensions
xDim = 8; %find optimal using CV (below section)
kernSD = 30; % find optimal kernal using CV (below section)

% Extract neural trajectories
result = neuralTraj(runIdx, dat, 'method', method, 'xDim', xDim,... 
                    'kernSDList', kernSD);

% Orthonormalize neural trajectories
[estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);

ord_seqTrain = seqTrain;
for tr = 1:length(seqTrain)
    tId = seqTrain(tr).trialId; 
    ord_seqTrain(tId) = seqTrain(tr);
end
orig_seqTrain = seqTrain; seqTrain = ord_seqTrain;

% Plot neural trajectories in 3D space
plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3);
plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3,'nPlotMax',1000);

% Plot each dimension of neural trajectories versus time
plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);

fprintf('\nDone\n');

%%
tt2 = trial_table(386:end,:);
trial_table(386:end,:) = [];

seqTrain2 = seqTrain(386:end);
seqTrain(386:end) = [];

%% Plot traces separated by direction (CO) or uncertainty (UN)
to_plot = 'traces'; %
%to_plot = 'endpoints';

neur_endpoint = zeros(length(trial_table),xDim);
for i = 1:length(trial_table)
    neur_endpoint(i,:) = seqTrain(i).xorth(:,end)';
end
%
ttt = trial_table(:,7)-trial_table(:,6);
ttt_bin = floor(ttt./(result.binWidth./1000));
if plot_conditions
    figure; hold on; 
    if length(unique(trial_table(:,move_col)))<size(trial_table,1) % && length(unique(trial_table(:,3)))==1 % We're in center-out
        co_is = unique(trial_table(:,move_col)); 
        [coinds, seqdirs] = deal(cell(length(co_is),1));
        cols2plot = distinguishable_colors(length(co_is));
        %cols2plot = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
        for j = 1:length(co_is)
            coinds{j} = find(trial_table(:,move_col)==co_is(j));
            seqdirs{j} = seqTrain(coinds{j});
 
            switch to_plot
                case 'traces'
                    plot3D_addon(seqdirs{j}, 'xorth', cols2plot(j,:), 'dimsToPlot', 1:3,'nPlotMax',1000);%,'goCueInds',ttt_bin);
                    %plot2D_addon(seqdirs{j}, 'xorth', cols2plot(j,:), 'dimsToPlot', 1:2,'nPlotMax',1000);
                case 'endpoints'
                    plot3(neur_endpoint(coinds{j},1),neur_endpoint(coinds{j},2),neur_endpoint(coinds{j},3),'.','Color',cols2plot(j,:));
                    %plot3(planepts(coinds{j},1),planepts(coinds{j},2),planepts(coinds{j},3),'.','Color',cols2plot(j,:));
            end
        end
    else %we're in the uncertainty case
        likeconds = flipud(unique(trial_table(:,3)));
        cols2plot = {'b','g','r'};
        [uninds, seqlikes] = deal(cell(length(likeconds),1));
        for j = 1:length(likeconds)
            %subplot(1,length(likeconds),j);
            uninds{j} = find(trial_table(:,3)==likeconds(j));
            seqlikes{j} = seqTrain(uninds{j});
            switch to_plot
                case 'traces'
                    plot3D_addon(seqlikes{j}, 'xorth', cols2plot{j}, 'dimsToPlot', 1:3, 'nPlotMax',1000);
                    %plot2D_addon(seqlikes{j}, 'xorth', cols2plot{j}, 'dimsToPlot', 1:2, 'nPlotMax',1000);
                case 'endpoints'
                    plot3(neur_endpoint(uninds{j},1),neur_endpoint(uninds{j},2),neur_endpoint(uninds{j},3),'.','Color',cols2plot(j,:));
            end
        end
    end
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