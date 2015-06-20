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
%     tbl = table(polar_PM_curve(:,i),polar_DL_curve(:,i),'VariableNames',{'PM_curve','DL_curve'});
%     lm = fitlm(tbl,'DL_curve ~ PM_curve - 1');
%     complex_scale_factor(1,i) = lm.Coefficients.Estimate;
%     
%     complex_scale_manual(1,i) = (polar_PM_curve(:,i)'*polar_PM_curve(:,i))\polar_PM_curve(:,i)'*(polar_DL_curve(:,i));

    % Fit with optimization
    problem = createOptimProblem('fmincon','objective',@(x) (find_curve_dist(exp(1i*pi/4)*polar_PM_curve(:,i),(x(1)+1i*x(2))*polar_PM_curve(:,i)))^2,'x0',rand(2,1));
%     real_imag_scale = fminsearch(@(x) (find_curve_dist(exp(1i*pi/4)*polar_PM_curve(:,i),(x(1)+1i*x(2))*polar_PM_curve(:,i)))^2,[-1;0]);
    gs = GlobalSearch('NumStageOnePoints',20);
    real_imag_scale = run(gs,problem);
    complex_scale_factor(1,i) = real_imag_scale(1)+1i*real_imag_scale(2);
end

scale_factor = abs(complex_scale_factor);
rot_factor = angle(complex_scale_factor);

%% Plot fits
for i = 1:size(FR_PM,2)
    fig = figure;
    
    max_rad = max(abs([polar_PM_curve(:,i);polar_DL_curve(:,i)]));
    h=polar(0,max_rad);
    set(h,'color','w')
    hold on
    
    h=polar(angle(repmat(polar_PM_curve(:,i),2,1)),abs(repmat(polar_PM_curve(:,i),2,1)));
    set(h,'linewidth',2,'color',[0.6 0.5 0.7])
    hold on
    h=polar(angle(repmat(exp(1i*pi/4)*polar_PM_curve(:,i),2,1)),abs(repmat(exp(1i*pi/4)*polar_PM_curve(:,i),2,1)));
    set(h,'linewidth',2,'color',[1 0 0])
    h=polar(angle(repmat(polar_PM_curve(:,i)*complex_scale_factor(i),2,1)),abs(repmat(polar_PM_curve(:,i)*complex_scale_factor(i),2,1)));
    set(h,'linewidth',2,'color',[0 1 0])
    
%     saveas(fig,['Unit ' num2str(i) '.png'])
end

output_data.scale_factor = scale_factor;
output_data.rot_factor = rot_factor;
figure_handles = [];

end

function [dist,shift] = find_curve_dist(curve1,curve2)
    %% try every possible rotation
    min_dist = inf;
    for i = 0:length(curve1)-1
        temp_dist = sum((abs(curve1-circshift(curve2,i))).^2);
        if temp_dist<min_dist
            min_dist = temp_dist;
            shift = i;
        end
    end
    dist = min_dist;
    
%     dist = sum((abs(curve1-curve2)).^2);
%     shift = 0;
end