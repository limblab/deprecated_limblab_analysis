function out = bump_pop_vect(bdf, pd_table)
% calculates population vectors for psychophysics bump direction experiment
%   BDF is a bdf
%   PD_TABLE is a table of pds (3 columns: chan, unit, pd) calculated from
%   a rw file.

[ul, ia, ib] = intersect(unit_list(bdf), pd_table(:,[1 2]), 'rows');
pds = pd_table(ib,3);

tt = bc_trial_table(bdf);
tt = tt(tt(:,7) ~= 65,:);
st = zeros(size(ul,1), size(tt,1));

for i = 1:length(ul)
    table = raster(get_unit(bdf,ul(i,1),ul(i,2)), tt(:,4), 0.10, 0.30, -1);
    for j = 1:length(table)
        st(i,j) = length(table{j});
    end
end

x = cos(pds)' * st;
y = sin(pds)' * st;

out = atan2(y,x)*180/pi;

plot(tt(:,3), out, 'ko');

corrcoef([out',tt(:,3)])