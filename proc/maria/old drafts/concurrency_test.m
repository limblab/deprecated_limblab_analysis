%test file

timing = 0;
tic

a = [0 0 1 2 1 1 1 0 1 0];
b = [0 2 2 1 1 1 2 2 0 0];
a = [a a a a a a a a a a a a a a a a a a a a a a];
b = [b b b b b b b b b b b b b b b b b b b b b b]; 
steps = {a b};
ch = [2 4]

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
%             command{1} = struct('CathAmp', amps(j)+32768, ... % uA
%                 'AnodAmp', 32768-amps(j), ... % uA
%                 'Run', ws.run_cont);
%             ws.set_stim(command, ch(j)); 
        end
    end
    %timing=0; tic;
    
    toc;
    timing
    if toc<timing %if it takes less than 1/5000 sec to stim each step, wait
        disp('pausing');
        pause(timing-toc);
    end
    
end