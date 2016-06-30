function spikePlots(bdf, varargin)
%SPIKEPLOTS  Produce raster plots and tuning curves using M1 and PMd data
%   from Mihili
%
%   spikePlots(NEURAL_DATA, TRIAL_TABLE, TIME_WINDOW, NEURON_#, TT_LABEL)
%
% Varargin
if nargin < 3
    window = 2;  % Time window around cue_time (seconds)
    n_neuron = 2;
    tt_label = 4;% 4 sets the cue to GO_CUE
else
    window = varargin{1};
    n_neuron = varargin{2};
    tt_label = varargin{3};
%     dco = varargin{4};
end

% Brain region (e.g. PMd or M1)
brainRegion = inputname(1);
brainRegion = brainRegion(1:3);
sorted_units = get_sorted_units(bdf);
one_neuron = sorted_units{n_neuron}; % Pick which neuron to work with

% Generate the appropriate trial table
trial_table = DCO_trial_table(bdf);
cue_times = trial_table(:, tt_label); % Times of each cue (each time is new trial
% dco_cues = dco.start_idx;
n_trials = length(cue_times);

% Time window
t1 = 1/3 * window; % Back end of time window
t2 = 2/3 * window; % Front end


%% Plot position and speed
if 1
velocity = bdf.vel;
sampleInterval = 0.001; % sec
pre = 1; % seconds
post = 4;
rate = 1/sampleInterval;
avg_speed = zeros((pre+post)*rate + 1,1);

% *** bdf.vel and cue_times do not both start at 0 sec!! bdf.vel starts at
% 1 sec, where as cue_times is indexed from 0 sec *** %
velocityAndGoCueTimeDif = 1000;
cue_idxs = cue_times*rate - velocityAndGoCueTimeDif;
yOffset = -32.5;
speeds = sqrt(power(velocity(:,2),2) + power(velocity(:,3),2)); % Convert x & y velocity to speed


% figure; hold on;
% for iTrial = 10:n_trials
%     if isfinite(dco_cues(iTrial))
%         iIdx = dco_cues(iTrial);
%         % Speed
%         iSpeed = speeds((iIdx - pre*rate):(iIdx + post*rate));
%         avg_speed = avg_speed + iSpeed;
%         plot(-pre:sampleInterval:post,iSpeed)
% 
%         %pause
%     end
% end



figure; hold on;
for iTrial = 10:n_trials
    if isfinite(cue_times(iTrial))
        iIdx = find(bdf.vel(:,1) <= cue_times(iTrial),1,'last');
        % Speed
        iSpeed = speeds((iIdx - pre*rate):(iIdx + post*rate));
        avg_speed = avg_speed + iSpeed;
        plot(-pre:sampleInterval:post,iSpeed)

        %pause
    end
end
avg_speed = avg_speed/n_trials;
plot(-pre:sampleInterval:post,avg_speed, 'r')
line('XData',[0 0], 'YData',[0 max(avg_speed)*5],'LineStyle', '-','Color','r');


figure; hold on;
for iTrial = 10:n_trials
    if isfinite(cue_times(iTrial))
        iIdx = find(bdf.vel(:,1) <= cue_times(iTrial),1,'last');

        % Position
        iXpos = bdf.pos((iIdx - pre*rate):(iIdx + post*rate),2);
        iYpos = bdf.pos((iIdx - pre*rate):(iIdx + post*rate),3) - yOffset;
        plot(iXpos, iYpos);

        %pause
    end
end
end

%%
% No for loop - bsxfun!
% spikesInWindow = bsxfun(@ge, one_neuron, (cue_times - t1)') & bsxfun(@le, one_neuron, (cue_times + t2)');
%% Raster Plot
if 0
figure
hold on

for iTrial = 10:n_trials
    t_cue = cue_times(iTrial);  % Cue time
    iDirection = trial_table(iTrial, 12);     % Current trial's CENTROID location
    if length(count(spikesInWindow(:,iTrial))) > 1
        % Plot the spike times within the time window, zeroed at t_cue
        plot(one_neuron(spikesInWindow(:,iTrial)) - t_cue, iDirection, 'k.', 'markersize',7)
    end
%         plot(cue_times(iTrial) - t_cue, iDirection, 'r.') % Plot the cue time for each trial
    xPos = cue_times(iTrial) - t_cue;
    line('XData',[xPos xPos],'YData',[0 max(trial_table(:,12))],'LineWidth', 2,'Color','r');
end

fs = 20;
xlabel('Time (sec)','FontSize',fs)
ylabel('Direction','FontSize',fs)
plot_title = sprintf('Raster plot - \n %s, neuron #%d ', brainRegion, n_neuron);
title(plot_title,'FontSize',fs + 2)
end

%% Tuning Curve
if 0
n_neurons = length(sorted_units);
one_neuron = sorted_units{n_neuron};


bin = .3; % Time bin in seconds
directions = unique(trial_table(:,12));
dirDegrees = directions*(180/pi);


fastNeurons = [];

for iNeuron = 1:n_neurons

    one_neuron = sorted_units{iNeuron};
    spikesInWindow = bsxfun(@ge, one_neuron, cue_times') & bsxfun(@le, one_neuron, (cue_times + bin)');
%     spikesInWindow = spikesInWindow(:,iStimIdx:(iStimIdx+1));
    spike_count = zeros(length(directions),1);
    avg_spike_count = zeros(length(directions),1);
    

    for iDir = 1:length(directions)
       trialsInDirection = find(trial_table(:,12) == directions(iDir));
       n_trials = length(trialsInDirection);
       
       iSpikes = spikesInWindow(:,trialsInDirection);
       avg_spike_count(iDir) = sum(sum(iSpikes))/n_trials;
    end

    firingRates = avg_spike_count/bin;


    if mean(firingRates) >= 3
        figure
        e = std(firingRates)*ones(size(dirDegrees));
        errorbar(dirDegrees,firingRates,e);
        xlim([0 315])
        ylim([0 30])
        fs=20;
        xlabel('Target Direction (degrees)')
        ylabel('Firing Rate (Hz)')
        plot_title = sprintf('Firing rate vs. Target Dir. - \n Unit #%d ', iNeuron);
        title(plot_title,'FontSize',fs + 2)
        fastNeurons = [fastNeurons iNeuron];
        pause
    end
end
   
fastNeurons'
    
end



%% Peri-Stimulus Time Histogram
% From "Matlab for Neuroscientsits" (Pg. 175):
if 0
    fs = 20;
    
    bin = .05; % Time bin in seconds
    edges = -1.5:bin:1.5;   % Time range, seconds
    psth = zeros(length(edges),1);
    for iTrial = 10:n_trials
        t_cue = cue_times(iTrial);              % Time of GO_CUE, seconds
        iSpikes = spikesInWindow(:,iTrial);     % Spikes within window of cue for the current trial
        n_Spikes = length(iSpikes(iSpikes==1)); % Total number of spikes for current trial
        
        
        % Add current trial's spike times
        N = histc(one_neuron(iSpikes) - t_cue, edges);
        if size(N) == size(psth)
            psth = psth + N;
        end
    end
    figure
    bar(edges,psth, 'histc');
    xlim([-1.1 1])
    xlabel('Time (sec)')
    ylabel('# of spikes')
    plot_title = sprintf('Peri-Stimulus Time Histogram - \n %s, neuron #%d ', brainRegion, n_neuron);
    title(plot_title,'FontSize',fs + 2)
end

%% Tuning Curves
if 0
    % 'one_neuron's firing rates centered around cue at t=0. Units: spikes/second
    firingRates = psth / bin;
    
    fs = 20;
    figure
    plot(edges, firingRates)
    axis([-1 1 0 max(firingRates)*1.1])
    xlabel('Time (sec)','FontSize',fs)
    ylabel('Spikes / Second','FontSize',fs)
    plot_title = sprintf('Firing Rates - \n %s, neuron #%d ', brainRegion, n_neuron);
    title(plot_title,'FontSize',fs + 2)
    
    % So to make a tuning curve, I want the instantaneous firing rate of
    % one neuron for each Centroid location
    
end

