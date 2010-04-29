function fa_plot(bdf, lambda, delay, id)

colors = {[0 0 0], [1 0 0], [0 1 0], [0 0 1]};
tt = co_trial_table(bdf);
bumptrials = tt( tt(:,3) == double('H'), : );

ul = unit_list(bdf);
training_set = zeros(length(bumptrials), length(ul));

for cell=1:length(ul)
    spikes = bdf.units(cell).ts;
    table = raster(spikes, bumptrials(:,4), 0.000+delay, 0.150+delay, -1);
    for trial=1:length(bumptrials)
        training_set(trial,cell) = length(table{trial});
    end
end

proj = training_set * lambda;

figure; hold on;
for bumpdir = 0:3
    f = bumptrials(:,2) == bumpdir;    
    plot(proj(f,1), proj(f,2), 'o', ...
        'MarkerFaceColor', colors{bumpdir+1}, ...
        'MarkerEdgeColor', colors{bumpdir+1});    
end
h=title(sprintf('Tiki\\_RW006 Bump\n%0.3f sec',delay));
axis([-15 35 -20 20]);
axis square;

set(h,'FontSize', 16)

print('-dtiff', sprintf('tmp/%03d.tif', id));

close all


