%%%
% Plots tuning surfaces for RW chaos task from CSV files of force
% direction, velocity direction, and firing rate
%%%

%% read csv files
file = '/home/raeed/Dropbox/Research/ForceKin/ForceKin Paper/Data/Arthur_S1_012-s';
reaches_mat = csvread([file '.csv']);
% reaches_mat = csvread('/home/raeed/Dropbox/ForceKin Paper/Data/Arthur_S1_016.csv');
thv = reaches_mat(:,1);
thf = reaches_mat(:,2);
fr = reaches_mat(:,3:end);

%% Find PDs of select neurons
% Uniform - 13, 35
% Looks good - 11, 15, 31

% find each PD with circular mean
for neuron_ctr = 1:size(fr,2)
    dir_mat = [cos(thv) sin(thv) cos(thf) sin(thf)];
    fit_linear = LinearModel.fit(dir_mat,fr(:,neuron_ctr));

    coefs = fit_linear.Coefficients.Estimate;
    velPD = atan2(coefs(3),coefs(2));
    forcePD = atan2(coefs(5),coefs(4));
%     velPD = angle(fr(:,neuron_ctr)'*exp(1i*thv));
%     forcePD = angle(fr(:,neuron_ctr)'*exp(1i*thf));
%     
%     figure
%     polar(thv,fr(:,neuron_ctr),'o')
%     hold on
%     polar([velPD velPD], [0 10], 'r-')
    
    % fit other model
    new_mat = [cos(thv-velPD) cos(thf-forcePD) cos(thv-velPD).*cos(thf-forcePD)];
    new_fit = LinearModel.fit(new_mat,fr(:,neuron_ctr));
    
    % get residuals
    resid_lin(:,neuron_ctr) = fit_linear.Residuals.Raw;
    resid_non(:,neuron_ctr) = new_fit.Residuals.Raw;
end

%% extract residuals into csv
csvwrite(['/home/raeed/Dropbox/Research/ForceKin/ForceKin Paper/Data/Arthur_S1_012-s_resid_lin.csv'],[thv thf resid_lin(:,[13 35 11 15 31])])
csvwrite(['/home/raeed/Dropbox/Research/ForceKin/ForceKin Paper/Data/Arthur_S1_012-s_resid_nonlin.csv'],[thv thf resid_non(:,[13 35 11 15 31])])

