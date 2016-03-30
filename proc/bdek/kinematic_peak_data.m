function comp_table = kinematic_peak_data(bdf,param_list,samples)

tot_peak = cell(samples,1);
FirstPlot = cell(1,length(bdf.units));

for i = 1:length(bdf.units)
    [~, p] = KLD_nongauss(bdf,param_list,i);
    FirstPlot{1,i} = p;
end

listing = vertcat(FirstPlot{:,:});
nonzero = listing(find(listing(:,3)),:);
length_nonzero = length(nonzero(:,1));
unit_indx = nonzero(:,1);

comp_table = cell(length_nonzero,1);
for j = 1: length_nonzero % foreach unit
    comp_table{j} = kinematic_peak_data_helper(param_list,j);
end

%comp_table = vertcat(table{:,:});

% f = figure('Position', [400 400 770 450]);
% t = uitable('Parent', f, 'Position', [25 25 720 400]);
% 
% set(t,'Data', comp_table);
% set(t, 'ColumnName', {'Unit', 'Peak Time', 'PT 5th|Percentile', 'PT 95th|Percentile', 'PT Variance',...
%     'Peak Amplitude','PA 5th|Percentile', 'PA 95th|Percentile','PA Variance'});

end

