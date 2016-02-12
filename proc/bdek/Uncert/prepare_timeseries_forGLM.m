%% Read in the file and sync neural and kinematic streams
% load ../MrT_data_9_24_2012.mat
% load ../trials2.mat
trains_PMd = trains;

deltats = [100];

for deltind = 1:length(deltats)
delt = deltats(deltind);

y = [];
velcompvec = [];
velvec = [];
varvec = [];
speedvec = [];

surprisevec = [];
spikevec = cell(length(trains_PMd),1);

% Go trial by trial
for tr=1:length(trials2)
    fprintf('Trial %d\n', tr);
    % First cut out the spikes for each neuron
    xshift(tr) = trials2(tr,1);
    onset = round(1000*trials2(tr,4));
    offset = round(1000*trials2(tr,5));
    
    for n=1:length(trains_PMd)
        %fprintf('    Neuron %d\n', n);
        spiketimes = round(1000*trains_PMd{n});
        trial_spiketimes = spiketimes(spiketimes >= onset & spiketimes <= offset);
        spikes = zeros(offset-onset+1, 1);
        spikes(trial_spiketimes-onset+1) = 1;
        spikevec{n} = [spikevec{n}; spikes];
    end
    
    % Then select the velocity traces
    trial_compvel = pva.vel((round(1000*pva.vel(:,1)) >= (onset+delt) & ...
                         round(1000*pva.vel(:,1)) <= (offset+delt)),2:3);
                     
    trial_vel = trial_compvel;
    trial_speed = sqrt(sum(trial_compvel.^2,2));
    trial_compvel = trial_compvel./repmat(trial_speed, [1 2]);
    
    velvec = [velvec; trial_vel];
    speedvec = [speedvec; trial_speed];
    velcompvec = [velcompvec; trial_compvel];
    
    % Then extract the variances
    trial_var = repmat(trials2(tr,2), [length(trial_compvel) 1]);
    varvec = [varvec; trial_var];
    
    % Finally extract the trial surprise = deviance of cursor shift
    surprise = abs(trials2(tr,1) - 2);
    trial_surprise = repmat(surprise, [length(trial_compvel) 1]);
    surprisevec = [surprisevec; trial_surprise];
end

% Collect spike trains of all neurons in a single matrix
y = horzcat(spikevec{:,:});
% 
% for n=1:length(trains_PMd)
%     y = [y, spikevec{n}];
% end

% Collect regressors into a matrix
X = [velcompvec, velvec, speedvec , varvec, surprisevec];

%%
% Apply the GLM
for n=16%:length(trains_PMd)
    %fprintf('Neuron %d:', n);
    [Bhat, dev, stats] = glmfit(X,y(:,n),'poisson');
    %GLMResult(n,:) = [Bhat(7), stats.p(7)];
    RESULT = [delt dev];
    %fprintf('GLM \t %f \t %f\n', Bhat(7), stats.p(7));
    fprintf('delta_t = %.0f\t dev = %.5f\n',delt,dev);
    %[Bhat, stats] = lassoglm(X,y(:,n),'poisson');
    %LassoGLMResult(n,:) = [Bhat(4), stats.p(4)];
    %fprintf('Lasso \t %f \t %f\n', Bhat(4), stats.p(4));
end
end
%% Display the results
% clc
% for n=1:length(trains_PMd)
%     if(length(trains_PMd{n}) >= 1000 && GLMResult(n,2) < 0.05)
%         fprintf('Neuron %d:', n); 
%         fprintf('GLM \t %f \t %f \t %d\n', GLMResult(n,1), GLMResult(n,2), length(trains_PMd{n}));
%     end
% end
% 
