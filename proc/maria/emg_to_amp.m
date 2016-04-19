%inputs
emg_file = 'EMGdata'; 
load(emg_file); %imports an 8x135 cell called rawCycleData
%each row corresponds to a different animal, each col corresponds to a
%different step (only one animal has 135 steps)
%each cell is ndatapts x 15 array (15 is number of muscles)
%SO to extract an individual muscle over one step, follow this format:
%rawCycleData{1}(:, 1)

%choose which step and which muscle(s) to use
stepnum = 2; 
musclenum = [2 3]; 
%TODO add a "repeat" and "delay" option here

%define limits in this order: emglow_limit, emghigh_limit, amplow_limit,
%amphigh_limit
emglow_limit = .35; %get rid of low noise
emghigh_limit = 2; %get rid of excessively high spikes
amplow_limit = 1.2; %lowest level of stim to twitch
amphigh_limit = 4;  %highest level of stim to use

%define stim parameters
pw = 200;
ch = 2;

step = rawCycleData{stepnum}(:, musclenum);
%do absolute value of the whole thing

%do a little bit of smoothing?

%create min and max stim levels
%NOTE: these will depend on the different muscles

for i=1:length(step)
    step(i) = abs(step(i)); 
    if step(i)<emglow_limit
        step(i)=0; 
    elseif step(i)>emghigh_limit
        step(i)=amphigh_limit; 
    else
        step(i)=amplow_limit+step(i)*(amphigh_limit-amplow_limit)/(emghigh_limit-emglow_limit); %follows EMG_to_stim format
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
hold on;
plot(step)


%if the stimulator object doesn't exist yet, set it up: 
if ~exist('ws', 'var')
    serial_string = 'COM7'; %use instrfind to check location
    ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
    ws.init(1, ws.comm_timeout_disable);
end


command{1} = struct('Freq', 30, ...        % Hz
    'CathDur', pw, ...    % us
    'AnodDur', pw ...    % us
...%     'CathAmp', amp+32768, ... % uA
...%     'AnodAmp', 32768-amp, ... % uA
    );
ws.set_stim(command, ch);

delta = .5; 
timing = 0; 
tic
for i=2:length(step)
    if abs(step(i)-step(i-1))>delta
        %disp('large delta, stim now');
        %choose new amp TODO but right now just do this. 
        amp = step(i); 
        command{1} = struct('CathAmp', amp*1000+32768, ... % uA
            'AnodAmp', 32768-amp*1000, ... % uA
            'Run', ws.run_cont);
        ws.set_stim(command, ch);
        timing=0; tic;
    else
        %disp('do nothing/keep stim constant');
        step(i) = step(i-1);
        timing = timing + 1/5000;
        toc;
        if toc<timing
            %disp('pausing');
            pause(timing-toc);
        end
        
    end
end
plot(step)
%timing for 5000 Hz sample - take ???? no of samples/5000 
command{1} = struct('Run', ws.run_stop);
ws.set_stim(command, ch);

%NOTE: sampling happened at 5000 hz
%we want to stim at ?? hz