function kinematic_peak_data(bdf,samples)

tot_peak = cell(samples,1);
FirstPlot = cell(1,length(bdf.units));

for i = 1:length(bdf.units)
    [~, p] = KLdivergence(bdf,1000,4000,i,0.05);
    FirstPlot{1,i} = p;
end

listing = vertcat(FirstPlot{:,:});
nonzero = listing(find(listing(:,3)),:);
length_nonzero = length(nonzero(:,1));
unit_indx = nonzero(:,1);

table = cell(length_nonzero,1);
for j = 1: length_nonzero
    for i = 1:samples
        [~,peaks] = KLdivergence(bdf,1000,4000,unit_indx(j,1),0.05);
        tot_peak{i,1} = peaks;
    end

    arrayed = vertcat(tot_peak{:,:});

    table{j,1} = [unit_indx(j,1) mean(arrayed(:,2)) prctile(arrayed(:,2),[5 95]) mean(arrayed(:,3)) prctile(arrayed(:,3),[5 95])];
end

comp_table = vertcat(table{:,:});

f = figure('Position', [400 400 620 450]);
t = uitable('Parent', f, 'Position', [25 25 570 400]);

set(t,'Data', comp_table);
set(t, 'ColumnName', {'Unit', 'Peak Time', 'PT 5th|Percentile', 'PT 95th|Percentile', 'Peak Amplitude', ...
                      'PA 5th|Percentile', 'PA 95th|Percentile'});

end

