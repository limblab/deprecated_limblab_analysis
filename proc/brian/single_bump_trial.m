% generates trial color plots

%tt = co_trial_table(bdf);
%co_res = batch_co_bump(bdf);
%good_cells = res(:,10) < .05 | res(:,11) < .05 | res(:,12) < .05;
%co_res = co_res(good_cells,:);
%co_res = sortrows(co_res, 6);


spike_times = [];
spike_codes = [];

for cell = 1:size(co_res, 1)
    chan = co_res(cell, 1);
    unit = co_res(cell, 2);
    
    s = get_unit(bdf, chan, unit);
    bumps = tt(tt(:,2) == 2 & tt(:,3) == double('H'),4);
    [x,r] = raster(s, bumps, -.125, .250, -1);
    spike_times = [spike_times, r'];
    spike_codes = [spike_codes, cell*ones(1,length(r))];
end

