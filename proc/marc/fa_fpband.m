function [lambda, proj] = fa_fpband(fMat, events, tbin,fs)

% ul = unit_list(bdf);
training_set = zeros(length(events), size(fMat,1));
% triallength=length(fMat{1,1});

for chan=1:size(fMat,1)
%     spikes = bdf.units(cell).ts;
%     table = raster(spikes, events, start_delay, stop_delay, -1);

    for trial=1:length(events)
%         training_set(trial,cell) = length(table{trial});
%           training_set(trial,chan) = squeeze(fMat(chan);
            training_set(trial,chan) = fMat(chan,tbin,trial);
    end
end

% lambda = factoran(training_set+.05*randn(size(training_set)), 3);
lambda=factoran(training_set,2);
%warning('Kludge Mode');
%q = [training_set + .01*randn(size(training_set)); training_set + .01*randn(size(training_set))];
%lambda = factoran(q,3);
proj = training_set * lambda;



