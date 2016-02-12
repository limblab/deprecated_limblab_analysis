% generate a set of known tuning curves
%   Evenly sample PD space
%   Have range of random DOMs
%   Assume number of reaches in each direction
%   Generate Poisson noise firing rates from tuning curves
%
% 76 7 7 10
clear;
clc;
close all;

real_tcs = false;
num_neurons = 200;

epochs = 3;
num_reaches = 20;
directions = [-3*pi/4, -pi/2, -pi/4, 0, pi/4, pi/2, 3*pi/4, pi];
noise_factor = 1; % how much gaussian noise to add to each estimate, use 0 for pure poisson
epoch_factor = 1;
fr_factor = 0.1;
base_factor = 5;

max_cb = 40;
max_rs = 0.7;

%%
if real_tcs
    dataSummary;
    doFiles = sessionList(strcmpi(sessionList(:,3),'FF') & strcmpi(sessionList(:,4),'CO'),:);
    
    tc_gen = [];
    for iFile = 1:size(doFiles,1);
        t = loadResults('F:\',doFiles(iFile,:),'tuning',{'tuning'},'M1','movement','regression','onpeak');
        tc_gen = [tc_gen; t(1).bos(:,1), t(1).mds(:,1), t(1).pds(:,1)];
    end
    if size(tc_gen,1) < num_neurons
        num_neurons = size(tc_gen,1);
    else
        tc_gen = tc_gen(randi(size(tc_gen,1),num_neurons,1),:);
    end
else
    dom_range = [5 30]; %in Hz
    % generate tuning curves
    tc_gen = zeros(num_neurons,3);
    tc_gen(:,2) = dom_range(1) + (dom_range(2) - dom_range(1)).*rand(num_neurons,1);
    tc_gen(:,3) = -pi + 2.*pi.*rand(num_neurons,1);
end

%% Generate noisy data and fit new tuning curves
results = repmat(struct(),1,epochs);
for iEpoch = 1:epochs
    disp(['Starting epoch ' num2str(iEpoch) '...']);
    % generate Poisson spiking
    disp(['Generating Poisson spikes for ' num2str(num_neurons) ' neurons...']);
    theta = zeros(num_reaches*length(directions),1);
    fr = zeros(num_reaches*length(directions),num_neurons);
    count = 0;
    for iDir = 1:length(directions)
        for iReach = 1:num_reaches
            count = count+1;
            theta(count) = directions(iDir);
            for unit = 1:num_neurons
                tc = tc_gen(unit,2) + tc_gen(unit,2)*cos(directions(iDir)-tc_gen(unit,3));
                tc = tc + noise_factor*(base_factor + epoch_factor*iEpoch + fr_factor*tc)*(-1+2*rand(1));
                if tc>=0
                    fr(count,unit) = poissrnd(tc);
                else
                    fr(count,unit) = 0;
                end
            end
        end
    end
    disp('Done.');
    
    % now, fit bootstrapped tuning curves to this cell
    disp('Computing new tuning curves...');
    [tc_fit,confBounds,rs,boot_pds,boot_mds,boot_bos] = regressTuningCurves(fr,theta,{'bootstrap',500,0.95},'doplots',false,'domeanfr',true,'doparallel',true);
    clc;
    
    results(iEpoch).theta = theta;
    results(iEpoch).fr = fr;
    results(iEpoch).tc_fit = tc_fit;
    results(iEpoch).cb = confBounds;
    results(iEpoch).rs = rs;
    results(iEpoch).pds = boot_pds;
end
disp('Done.');

%%
% look at confidence bounds
tuned_cells = zeros(epochs,num_neurons);
for iEpoch = 1:epochs
    cb = results(iEpoch).cb;
    rs = results(iEpoch).rs;
    tuned_cells(iEpoch,:) = angleDiff(cb{3}(:,1),cb{3}(:,2),true,false).*(180/pi) <= max_cb & mean(rs,2) >= max_rs;
end

%% Do memory cell test
close all;
clc;

difftest = zeros(num_neurons,epochs,epochs);
for iEpoch = 1:epochs
    for iEpoch2 = iEpoch+1:epochs
        for unit = 1:num_neurons
            difftest(unit,iEpoch,iEpoch2) = isempty(range_intersection([0 0],prctile(angleDiff(results(iEpoch).pds(unit,:),results(iEpoch2).pds(unit,:),true,true),[2.5,97.5])));
        end
    end
end

cell_classifications;

cc = zeros(1,num_neurons);
for unit = 1:num_neurons
    useDiff = squeeze(difftest(unit,:,:));
    
    val = sum(sum(useDiff.*converterMatrix));
    idx = classMapping(:,1)==val;
    if sum(idx) ~= 0
        cc(unit) = classMapping(idx,2);
    else
        warning('DANGER! Class not recognized. Something is probably fishy...');
        cc(unit) = NaN;
    end
end

tuned_cells = all(tuned_cells,1);

cc = cc(tuned_cells);

figure;
[n,x] = hist(cc,1:5);
bar(x,n,1);

disp(['Percent Tuned    : ' num2str(100*sum(tuned_cells)/length(tuned_cells))]);
disp(['Percent Kinematic: ' num2str(100*n(1)/sum(n))]);
disp(['Percent Dynamic  : ' num2str(100*n(2)/sum(n))]);
disp(['Percent Memory I : ' num2str(100*n(3)/sum(n))]);
disp(['Percent Memory II: ' num2str(100*n(4)/sum(n))]);
disp(['Percent Other    : ' num2str(100*n(5)/sum(n))]);

% Plot confidence of fit and PD difference for all epochs
figure;
for iEpoch = 1:epochs
    tc_fit = results(iEpoch).tc_fit;
    cb = results(iEpoch).cb;
    
    subplot(epochs,2,2*(iEpoch-1)+1);
    hist(angleDiff(cb{3}(tuned_cells,1),cb{3}(tuned_cells,2),true,false).*(180/pi))
    subplot(epochs,2,2*(iEpoch-1)+2);
    hist(angleDiff(tc_fit(tuned_cells,3),tc_gen(tuned_cells,3),true,false)*(180/pi));
end

%%
% Plot confidence of fit and PD difference for all epochs
figure;
for iEpoch = 1:epochs
    tc_fit = results(iEpoch).tc_fit;
    cb = results(iEpoch).cb;
    
    subplot(epochs,2,2*(iEpoch-1)+1);
    hist(angleDiff(cb{3}(:,1),cb{3}(:,2),true,false).*(180/pi))
    subplot(epochs,2,2*(iEpoch-1)+2);
    hist(angleDiff(tc_fit(:,3),tc_gen(:,3),true,false)*(180/pi));
end

%% Plot raw data and fits for all epochs
for unit = 1:num_neurons
    figure;
    hold all;
    plot(theta,fr(:,unit),'.');
    plot(directions,tc_gen(unit,2) + tc_gen(unit,2)*cos(directions-tc_gen(unit,3)),'LineWidth',2);
    for iEpoch = 1:epochs
        tc_fit = results(iEpoch).tc_fit;
        plot(directions,tc_fit(unit,2) + tc_fit(unit,2)*cos(directions-tc_fit(unit,3)),'LineWidth',2);
    end
    legend({'FR','Gen'});
    pause;
    close all;
end

