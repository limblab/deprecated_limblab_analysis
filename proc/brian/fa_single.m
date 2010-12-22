function [lambda, proj] = fa_single(bdf, events, start_delay, stop_delay)

ul = unit_list(bdf);
training_set = zeros(length(events), length(ul));

for cell=1:length(ul)
    spikes = bdf.units(cell).ts;
    table = raster(spikes, events, start_delay, stop_delay, -1);
    for trial=1:length(events)
        training_set(trial,cell) = length(table{trial});
    end
end

%lambda = factoran(training_set+.05*randn(size(training_set)), 3);
warning('Kludge Mode');
q = [training_set + .01*randn(size(training_set)); training_set + .01*randn(size(training_set))];
lambda = factoran(q,3);

proj = training_set * lambda;



