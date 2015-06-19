function [figure_handles, output_data]=rotate_tuning_curves(folder,options)
% Find scaling and rotation between two tuning curves in PM and DL
% workspaces

%% Get data to fit
% set up PM tuning curve function
options_PM.only_sorted=1;
options_PM.labnum=6;
options_PM.plot_curves=0;
options_PM.bdf = options.bdf_PM;

[~,tuning_PM] = get_tuning_curves(folder,options_PM);

% set up DL tuning curve function
options_DL.only_sorted = 1;
options_DL.labnum=6;
options_DL.plot_curves=0;
options_DL.bdf = options.bdf_DL;

[~,tuning_DL] = get_tuning_curves(folder,options_DL);

% get relevant data
FR_PM = tuning_PM.binned_FR;
FR_DL = tuning_DL.binned_FR;
angs_PM = repmat(tuning_PM.bins,1,size(FR_PM,2));
angs_DL = repmat(tuning_DL.bins,1,size(FR_DL,2));

%% Convert to complex polar representation
polar_PM_curve = FR_PM.*exp(1i*angs_PM);
polar_DL_curve = FR_DL.*exp(1i*angs_DL);

%% Fit data
for i = 1:size(FR_PM,2)
    tbl = table(polar_PM_curve(:,i),polar_DL_curve(:,i),'VariableNames',{'PM_curve','DL_curve'});
    lm = fitlm(tbl,'DL_curve ~ PM_curve - 1');
    complex_scale_factor(1,i) = lm.Coefficients.Estimate;
end

scale_factor = abs(complex_scale_factor);
rot_factor = angle(complex_scale_factor);