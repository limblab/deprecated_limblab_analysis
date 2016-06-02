function plot_stimulations(data,sample_rate,trig,handles,EMG_labels,EMG_enable)

% Determine which elements in data are stimulations
stim_temp = find(EMG_enable(1:15));

% Plot stimulations on appropriate sub-fig in GUI
plot(handles.stim_plot,(1:size(data,1))/sample_rate*1000, data(:,1:length(stim_temp),trig));

% Add legend
legend(handles.stim_plot,EMG_labels{EMG_enable(1:15)},'Location','NorthEast');

% Add Labels
xlabel(handles.stim_plot,'time (msec)')
ylabel(handles.stim_plot,'Current (mA)')

% Force all callbacks to process - including our abort!
drawnow;