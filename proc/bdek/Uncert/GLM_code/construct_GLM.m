function [X,y,feed,trialinds,min_inds,ids] = construct_GLM(trains,trials2,pva,ts_low)

% Target location
target_mean = 2;

delt = 100; % Kinematic Delay
vis_delay = 200; % Visual System Delay

% Initialize predictors
velcompvec = [];
velvec = [];
Highvarvec = [];
Lowvarvec = [];
speedvec = [];
trialinds = [];
posyvec = [];
posxvec = [];
anycloudvec = [];
surprisevec = [];

% Initialize output
spikevec = cell(length(trains),1);


% Go trial by trial
clc;
for tr=1:length(trials2)
    fprintf('Constructing GLM... Trial %d/%d\n', tr, length(trials2));
    
    % First cut out the spikes for each neuron
    xshift(tr) = trials2(tr,1); % Cursor shift
    onset = round(1000*trials2(tr,3)); % Start index
    feed(tr) = round(1000*trials2(tr,4)) - onset; % Feedback index
    offset = round(1000*trials2(tr,5)); % End index
    min_inds(tr) = round(1000*ts_low(tr))- round(1000*trials2(tr,3)); % Min Speed index
    
    for n=1:length(trains)

        spiketimes = round(1000*trains{n}); % Find Spike indices
        % Only keep spiking that happens during trial
        trial_spiketimes = spiketimes(spiketimes >= onset & spiketimes <= offset);
        
        % Bin spikes to gain binary train
        spikes = zeros(offset-onset+1, 1);
        spikes(trial_spiketimes-onset+1) = 1;
        
        % Append trials together
        spikevec{n} = [spikevec{n} ;spikes];
        
    end
    
    % Keep track of when trials start/stop
    trialinds = [trialinds ;tr*ones(length(spikes),1)];
    
    % Then select the velocity and position traces
    trial_vels = pva.vel((round(1000*pva.vel(:,1)) >= (onset+delt) & ...
                          round(1000*pva.vel(:,1)) <= (offset+delt)),2:3);
                     
    trial_posx = pva.pos((round(1000*pva.pos(:,1)) >= (onset-vis_delay) & ...
                          round(1000*pva.pos(:,1)) <= (offset-vis_delay)),2);  
                      
    trial_posy = pva.pos((round(1000*pva.pos(:,1)) >= (onset-vis_delay) & ...
                          round(1000*pva.pos(:,1)) <= (offset-vis_delay)),3);
     
    % Correct for screen offsets                  
    trial_posy = trial_posy + 32.5;
    trial_posx = trial_posx - 2;

    trial_vel = trial_vels;
    trial_speed = sqrt(sum(trial_vels.^2,2));
    trial_compvel = trial_vels./repmat(trial_speed, [1 2]);    
    
    % Append predictors from current trial to those of previous trials
    velvec = [velvec; trial_vel];
    speedvec = [speedvec; trial_speed];
    velcompvec = [velcompvec; trial_compvel];
    posxvec = [posxvec; trial_posx];
    posyvec = [posyvec; trial_posy];
    
    % Then extract the feedback variances
    Hightrial_var = repmat(trials2(tr,2), [length(trial_vel) 1]);
    Hightrial_var(Hightrial_var==min(trials2(:,2))) = 0;
    Hightrial_var(Hightrial_var==max(trials2(:,2))) = 1;
    Hightrial_var(1:(feed(tr)+vis_delay)) = 0;

    Lowtrial_var = repmat(trials2(tr,2), [length(trial_vel) 1]);
    Lowtrial_var(Lowtrial_var==min(trials2(:,2))) = 1;
    Lowtrial_var(Lowtrial_var==max(trials2(:,2))) = 0;
    Lowtrial_var(1:(feed(tr)+vis_delay)) = 0;
    
    trial_anycloud = Hightrial_var + Lowtrial_var;

    Highvarvec = [Highvarvec; Hightrial_var];
    Lowvarvec = [Lowvarvec; Lowtrial_var];
    anycloudvec = [anycloudvec; trial_anycloud];
    
    % Finally extract the trial surprise = deviance of cursor shift
    surprise = abs(trials2(tr,1) - target_mean);
    trial_surprise = surprise.*trial_anycloud;
    surprisevec = [surprisevec; trial_surprise];
    
    clc;
end
% Collect spike trains of all neurons in a single matrix
y = horzcat(spikevec{:,:});

angles = atan2(velvec(:,2),velvec(:,1));

sinvec = sin(angles);
cosvec = cos(angles);

vxvec = velvec(:,1);
vyvec = velvec(:,2);

ids = zeros(length(trains),1);
for i = 1:length(trains)
    ids(i) = trains{i}(1);
end

X = [cosvec, sinvec, speedvec, vxvec, vyvec, anycloudvec, Highvarvec, Lowvarvec, ...
    posxvec, posyvec, surprisevec];



