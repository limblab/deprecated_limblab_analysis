function res = neuron_dropping(bdf)

tt = co_trial_table(bdf);

% Find all delay bump trials
dbtrials = tt( tt(:,3) == double('D') & tt(:,10) == double('R'), :);
%dbtrials = tt( tt(:,3) == double('H'), : );
%dbtrials = tt( tt(:,3) == -1 & tt(:,10) == double('R'), :);
ul = unit_list(bdf);

training_set = zeros(length(dbtrials), length(ul)+1);
res = [];

time= 0.45;

for droppedneuron=0:size(ul,1)
    for cell=1:length(ul)
    	if cell==droppedneuron
        	continue;
        end

        spikes = bdf.units(cell).ts;
        table = raster(spikes, dbtrials(:,6), time, time+.100, -1);
        for trial=1:length(dbtrials)
            training_set(trial,cell+1) = length(table{trial});
        end
    end

    training_set(:,1) = dbtrials(:,5); % 5 for target, 2 for bump direction
    res = [res; pnbayesf(training_set, 5)];
    
end
return;
%-------taking the mean

for i=1:size(res,1)
    res(i,1) = mean(res(i,:));
end
%-------determining neuron impact in %

for a=2:size(res,1)
    res(a,1) = res(a,1)/res(1,1)
    res(a,2) = bdf.units(a).id(1);
end

