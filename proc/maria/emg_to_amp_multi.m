%inputs
emg_file = 'EMGdata';
load(emg_file); %imports an 8x135 cell called rawCycleData
%each row corresponds to a different animal, each col corresponds to a
%different step (only one animal has 135 steps)
%each cell is ndatapts x 15 array (15 is number of muscles)
%SO to extract an individual muscle over one step, follow this format:
%rawCycleData{1}(:, 1)

%choose which step and which muscle(s) to use
animalnum = 7; 
stepnum = 2;
musclenum = [2 3];
%TODO add a "repeat" and "delay" option here

%define limits in this order: emglow_limit, emghigh_limit, amplow_limit,
%amphigh_limit
emglow_limit = [.35 .5]; %get rid of low noise
emghigh_limit = [2 4]; %get rid of excessively high spikes
amplow_limit = [1.2 1.5]; %lowest level of stim to twitch
amphigh_limit = [4 4];  %highest level of stim to use

%define stim parameters
pw = [200 200]; %TODO: add way to check if this is array or single num, then either apply to all channels (single num) or each channel (array)
ch = [2 3];

%check that all of the above input arrays are the same length as the number of muscles
lm = length(musclenum)
if lm~=length(emglow_limit) || lm~=length(emghigh_limit) || lm~=length(amplow_limit) || lm~=length(amphigh_limit) || lm~=length(ch) || lm~=length(pw)
    error('Incorrect number of values in arrays for EMG limits, amplitude limits, channels, or pws; check that there is one value per muscle')
end

%step = rawCycleData{stepnum}(:, musclenum)
steps = num2cell([1:lm]);
size(steps)
for i=1:length(steps)
    steps{i} = rawCycleData{animalnum, stepnum}(:, musclenum(i));
    figure(i)
    plot(steps{i})
end
%-----keep changing step to steps from here. TODO
%do absolute value of the whole thing

%do a little bit of smoothing?

%create min and max stim levels
%NOTE: these will depend on the different muscles
for j=1:lm %do all of the following for each muscle
    step = steps{j};
    for i=1:length(step)
        step(i) = abs(step(i));
        if step(i)<emglow_limit(j)
            step(i)=0;
        elseif step(i)>emghigh_limit(j)
            step(i)=amphigh_limit(j);
        else
            step(i)=amplow_limit(j)+step(i)*(amphigh_limit(j)-amplow_limit(j))/(emghigh_limit(j)-emglow_limit(j)); %follows EMG_to_stim format
        end
        
    end
    
    zero_ind = find(step==0);
    seq = 0;
    
    %zero_ind = zero_ind([1:50])
    removals = [];
    for i=2:length(zero_ind)
        if zero_ind(i)==(zero_ind(i-1)+1)
            %disp(['index: ' num2str(zero_ind(i))]);
            seq = seq+1;
            %disp(['seq length: ' num2str(seq)]);
        else
            if seq>=25 %if more than n zeros in a row, we won't mess with it
                removals = [removals; zero_ind(i-seq:i-1)];
                %disp(['deleting ' num2str(zero_ind(i-seq)) ' to ' num2str(zero_ind(i-1))])
            end
            seq = 0; %reset
        end
        if i+1>length(zero_ind)
            removals = [removals; zero_ind(i-seq:i-1)];
            %disp(['deleting ' num2str(zero_ind(i-seq)) ' to ' num2str(zero_ind(i-1))])
            break;
        end
        
    end
    zero_ind = setdiff(zero_ind, removals);
    
    for i=2:length(zero_ind)
        step(zero_ind(i))=step(zero_ind(i)-1);
    end
    figure(j);
    hold on;
    plot(step)
    
    steps{j} = step; %change the value for that muscle in the set of steps
    
end


%-----okay, I'm here so far. update step, do same stuff, save .mat file
%-----TODO: make .mat file reader thing. (that's basically what this is?)
delta = .5;

%for every muscle selected
    %NO WAIT THIS WILL RUN EACH OF THEM CONSECUTIVELY. drat. 
    %also, are there the same number of data points for each muscle? add a
    %check
    %TODO: make this check each muscle for each advance to next data point
for j=1:lm %get stim arrays for all the muscles
    for i=2:length(steps{1}) %all of the channels have the same no. of data pts
        if abs(steps{j}(i)-steps{j}(i-1))<delta
            %do nothing/keep stim constant
            steps{j}(i) = steps{j}(i-1); %set the array to reflect actual stimulated values
        end
    end
    figure(j); 
    plot(steps{j})
end
%timing for 5000 Hz sample - take ???? no of samples/5000

%% Do stimulation (run arrays concurrently)

%if the stimulator object doesn't exist yet, set it up:
if ~exist('ws', 'var')
    serial_string = 'COM7'; %use instrfind to check location
    ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
    ws.init(1, ws.comm_timeout_disable);
end

%set constant parameters for stimulator
for i=1:lm
    command{1} = struct('Freq', 30, ...        % Hz
        'CathDur', pw(i), ...    % us
        'AnodDur', pw(i) ...    % us
        );
    ws.set_stim(command, ch(i));
end

%set up timing (so I can regulate how quickly we go through the arrays)
timing = 0;
tic

amps = [0 0 0 0 0 0 0 0];

for i=2:length(steps{1}) %all of the channels have the same no. of data pts
    timing = timing + 1/5000;
    
    for j=1:size(steps, 2) %TODO change this to lm in the real code
        if steps{j}(i)~=steps{j}(i-1) % update changed amps for stim
            %large delta, stim now with new amp
            amps(j) = steps{j}(i)*1000;
        else
            %disp('do nothing/keep stim constant');
            amps(j) = 0;
        end
    end
    for j=1:size(steps, 2)
        if amps(j)~=0 %stimulate all of the channels that are changing. 
            disp(['stim ch ' num2str(ch(j)) ' at ' num2str(amps(j))]);
            command{1} = struct('CathAmp', amps(j)+32768, ... % uA
                'AnodAmp', 32768-amps(j), ... % uA
                'Run', ws.run_cont);
            ws.set_stim(command, ch(j)); 
        end
    end
    %timing=0; tic;
    
    %toc;
    %timing
    if toc<timing %if it takes less than 1/5000 sec to stim each step, wait
        disp('pausing');
        pause(timing-toc);
    end
    
end


%End all of the stimulation
command{1} = struct('Run', ws.run_stop);
ws.set_stim(command, ch);

%NOTE: sampling happened at 5000 hz
%we want to stim at ?? hz