function plot_forces(data,sample_rate,trig,handles,EMG_labels,EMG_enable,calMat)

% Determine which elements in data are forces (extract stimuli)
stim_temp = find(EMG_enable(1:15));
% EMG_enable = EMG_enable(16:end);
% EMG_labels = EMG_labels(16:end);

% Transform data using calibration matrix
dataNEW = data(:,length(stim_temp)+1:end,trig)*calMat;

% Remove offset??
dataNEW = remove_offset(dataNEW,sample_rate);

% Plot forces on appropriate sub-fig in GUI
plot(handles.forces_plot,(1:size(data,1))/sample_rate*1000,dataNEW(:,1:3));

legend(handles.forces_plot,{'Fx','Fy','Fz'},'Location','NorthEast');

% Add Labels
xlabel(handles.forces_plot,'time (msec)')
ylabel(handles.forces_plot,'Force (N)')

%--------------------------------------------------------------------------
% Plot force endpoint vectors in separate plot
%--------------------------------------------------------------------------
stepsize = 100;
x = zeros(1,length(dataNEW(1:stepsize:end,1))); 
Fx = dataNEW(1:stepsize:end,1)';
y = zeros(1,length(dataNEW(1:stepsize:end,2)));
Fy = dataNEW(1:stepsize:end,2)';
hArrows = quiver(handles.force_vec_plot,x,y,Fx,Fy);
set(hArrows,'AutoScale','off','AutoScaleFactor',1);
axis(handles.force_vec_plot,'equal');
grid(handles.force_vec_plot);
% Add Labels
xlabel(handles.force_vec_plot,'Fx (N)')
ylabel(handles.force_vec_plot,'Fy (N)')


% Force all callbacks to process - including our abort!
drawnow; 
