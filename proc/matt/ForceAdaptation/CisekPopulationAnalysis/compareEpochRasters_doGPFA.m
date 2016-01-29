clear all;
clc;
close all;

do_cross_val = false;
arrays = {'M1','PMd'};
doFiles = {'Mihili','2014-02-18','FF','CO'};% ...
%     'Mihili','2014-03-04','VR','CO'; ...
%     'Chewie','2015-07-08','FF','CO'; ...
%     'Chewie','2015-07-15','VR','CO'; ...
%     'MrT','2013-08-23','FF','CO'; ...
%     'MrT','2013-09-05','VR','CO'};

epochs = {'BL','AD','WO'};

ranges = [2 6;];
extraTime = [300 200];

method = 'gpfa';
paramSetName = 'traj';
saveDir = ['F:\\fr_results\\' paramSetName];

for iFile = 1:size(doFiles,1)
    for iArray = 1:length(arrays)
        if ( strcmpi(arrays{iArray},'M1') && ismember(doFiles{iFile,1},{'Chewie','Mihili'}) ) || ( strcmpi(arrays{iArray},'PMd') && ismember(doFiles{iFile,1},{'MrT','Mihili'}) ) || ( strcmpi(arrays{iArray},'both') && ismember(doFiles{iFile,1},{'Mihili'}) )
            useArray = arrays{iArray};
            
            if strcmpi(useArray,'both');
                [units,mt,indices] = combineAllEpochs2('F:\',doFiles(iFile,:),epochs,{'M1','PMd'},'movement');
            else
                [units,mt,indices] = combineAllEpochs2('F:\',doFiles(iFile,:),epochs,useArray,'movement');
            end
            
            for iRange = 1:size(ranges,1)
                % reformat for Byron's code
                [~,dat] = trial_raster(units,mt,[ranges(iRange,1) extraTime(1)],[ranges(iRange,2) extraTime(2)]);
                
                % Basic extraction of neural trajectories
                runIdx = ['-' useArray '-' doFiles{iFile,1} '-' doFiles{iFile,2} '-' num2str(ranges(iRange,1)) '-' num2str(ranges(iRange,2))];
                
                % Select number of latent dimensions
                xDim = 8; %find optimal using CV (below section)
                kernSD = 30; % find optimal kernal using CV (below section)
                binWidth = 20;
                %
                
                % Extract neural trajectories
                result = neuralTraj_limblab(runIdx, dat, saveDir, 'method', method, 'xDim', xDim,...
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
                seqTrain = ord_seqTrain;
                
                save(fullfile(saveDir,'mat_resultsgpfa',['run' runIdx],'results.mat'),'binWidth','dat','indices','kernSD','mt','seqTrain','units','xDim');
                % Plot neural trajectories in 3D space
                % plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3);
                % plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3,'nPlotMax',1000);
                
                % Plot each dimension of neural trajectories versus time
                % plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
                clear tr ord_seqTrain trID estParams result;
            end
        end
    end
end
clc;
disp('Done.');

%% Plot each reach direction in a unique color
runIdx = 'run_M1FF_2100-4100';
nMax = 10;

load(fullfile(saveDir,'mat_resultsgpfa',runIdx,'results.mat'));

figure;
hold all;
useColors = {'r','b','g','m','c',[0.4 0.4 0.4],'y','k'};
for i = 1:size(indices,2)
    idx = indices{1,i};
    plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor',useColors{i});
end


%%
clear;
% close all;
clc;

nMax = 100;

method = 'gpfa';
paramSetName = 'traj';
saveDir = ['F:\\fr_results\\' paramSetName];

doFiles = {'Mihili','2014-02-18','FF','CO'; ...
    'Mihili','2014-03-04','VR','CO'; ...
    'Chewie','2015-07-08','FF','CO'; ...
    'Chewie','2015-07-15','VR','CO'; ...
    'MrT','2013-08-23','FF','CO'; ...
    'MrT','2013-09-05','VR','CO'};
ranges = [2 3;3 5; 4 6; 2 6];

iFile = 1;
iRange = 1;
useArray = 'PMd';

figure;
subplot1(2,4);
for i = 1:8
    % FF M1
    runIdx = ['-' useArray '-' doFiles{iFile,1} '-' doFiles{iFile,2} '-' num2str(ranges(iRange,1)) '-' num2str(ranges(iRange,2))];
    ax(i) = subplot1(i);
    hold all;
    load(fullfile(saveDir,'mat_resultsgpfa',['run' runIdx],'results.mat'));
    idx = indices{1,i};
    plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor','k');
    
    idx = indices{2,i};
    %     idx = idx(1:ceil(length(idx)/2));
    plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor','b','colorGradient',true);
    
    %
    %     idx = indices{3,i};
    %     idx = idx(ceil(length(idx)/2):end);
    %     plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor','b');
    
    set(gca,'Box','off','TickDir','out','FontSize',14);
    if i == 1
        title(runIdx,'FontSize',16);
    end
    
end

linkprop(ax,{'cameraangle','cameraposition','cameraupvector','cameratarget','cameraviewangle'});

%%
clear;
% close all;
clc;

nMax = 100;

method = 'gpfa';
paramSetName = 'traj';
saveDir = ['F:\\fr_results\\' paramSetName];

doFiles = {'Mihili','2014-02-18','FF','CO'; ...
    'Mihili','2014-03-04','VR','CO'; ...
    'Chewie','2015-07-08','FF','CO'; ...
    'Chewie','2015-07-15','VR','CO'; ...
    'MrT','2013-08-23','FF','CO'; ...
    'MrT','2013-09-05','VR','CO'};
ranges = [2 3; 3 5; 4 6; 2 6; 2 4; 3 6];

iFile = 1;
iRange = 4;
useArray = 'PMd';

figure;
i = 6;

% FF M1
runIdx = ['-' useArray '-' doFiles{iFile,1} '-' doFiles{iFile,2} '-' num2str(ranges(iRange,1)) '-' num2str(ranges(iRange,2))];
hold all;
load(fullfile(saveDir,'mat_resultsgpfa',['run' runIdx],'results.mat'));
idx = indices{1,i};
% plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor','k','lw',2);
plotEachDimVsTime_Matt(seqTrain, 'xorth', 20,'useColor','k','nPlotMax',nMax);

% idx = indices{2,i};
% % idx = idx(1:ceil(length(idx)/2));
% % plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor','r','colorGradient',false,'lw',2);
% plotEachDimVsTime_Matt(seqTrain(idx), 'xorth', 20,'useColor','r','nPlotMax',nMax,'colorGradient',true);

% %
%     idx = indices{3,i};
%     idx = idx(ceil(length(idx)/2):end);
%     plot3D_Matt(seqTrain(idx), 'xorth', 'dimsToPlot', 1:3,'nPlotMax',nMax,'useColor','b');

set(gca,'Box','off','TickDir','out','FontSize',14);
axis square;


