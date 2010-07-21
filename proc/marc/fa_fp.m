function [lambda, proj] = fa_fp(fparr, events, start_delay, stop_delay,fs)

% ul = unit_list(bdf);
training_set = zeros(length(events), size(fparr,1));
triallength=length(fparr{1,1});

for chan=1:size(fparr,1)
%     spikes = bdf.units(cell).ts;
%     table = raster(spikes, events, start_delay, stop_delay, -1);

    for trial=1:length(events)
%         training_set(trial,cell) = length(table{trial});
          training_set(trial,chan) = mean(fparr{chan,trial}(start_delay*1000+fs:(stop_delay*1000+fs)));
    end
end

% lambda = factoran(training_set+.05*randn(size(training_set)), 3);
lambda=factoran(training_set,3);
%warning('Kludge Mode');
%q = [training_set + .01*randn(size(training_set)); training_set + .01*randn(size(training_set))];
%lambda = factoran(q,3);
proj = training_set * lambda;



