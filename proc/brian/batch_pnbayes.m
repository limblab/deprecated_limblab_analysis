function res = batch_pnbayes(bdf)

tt = co_trial_table(bdf);

% Find all delay bump trials
dbtrials = tt( tt(:,3) == double('D') & tt(:,10) == double('R'), :);
%dbtrials = tt( tt(:,3) == double('H'), : );
%dbtrials = tt( tt(:,3) == -1 & tt(:,10) == double('R'), :);
ul = unit_list(bdf);

training_set = zeros(length(dbtrials), length(ul)+1);
res = [];

for timelag = -1:.05:1
    disp(timelag)
    for cell=1:length(ul)
        spikes = bdf.units(cell).ts;
        table = raster(spikes, dbtrials(:,4), timelag, timelag+.100, -1);
        for trial=1:length(dbtrials)
            training_set(trial,cell+1) = length(table{trial});
        end
    end

    training_set(:,1) = dbtrials(:,5); % 5 for target, 2 for bump direction
    res = [res; pnbayesf(training_set, 5)];
end


