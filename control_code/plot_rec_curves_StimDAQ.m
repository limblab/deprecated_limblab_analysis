function [mle_cond,rcurve,file_name] = plot_rec_curves_StimDAQ(out_struct,calmat,emg_enable,time_window,is_mle,saveFilename,vecGood)

% User specified times for begin/end of "steady-state" force response
platON = time_window(1);
platOFF = time_window(2);
[magForce,calibForces,dirForce,stdForce,forceCloud,amps,pws,stdDir] = compute_force_magnitude(out_struct,calmat,emg_enable,platON,platOFF);
rcurve.magForce = magForce;
rcurve.calibForces = calibForces;
rcurve.dirForce = dirForce;
rcurve.stdForce = stdForce;
rcurve.stdDir = stdDir;
rcurve.forceCloud = forceCloud;
rcurve.amps = amps;
rcurve.pws = pws;
rcurve.mode = out_struct.mode;
rcurve.time_window = time_window;

% Choose either MLE fit or nonlinlsqsqrs fit to form sigmoid approximation
% to recruitment curve
mle_cond = is_mle && out_struct.pulses > 10;
if mle_cond
    % MLE estimation of sigmoid parameters
    sigParams = zeros(4,size(magForce,2));
    for ii = 1:size(magForce,2)
        sigParams(:,ii) = fitMaxLikelihoodRecruitCurve(magForce(:,ii),stdForce(:,ii),amps(:,ii));
    end
else
   % Nonlinear least squares estimation of sigmoid paramters
   sigParams = fit_sigmoid(magForce,amps); 
end
rcurve.sigParams = sigParams;
rcurve.mle_cond = mle_cond;
rcurve.time_window = time_window;
rcurve.vecGood = vecGood;

% Plot curves
plot_recruit_curves(out_struct,magForce,stdForce,dirForce,stdDir,amps,pws,vecGood,'r');
% plot_sigmoid_MLE(sigParams,amps,'k');

[file_name,file_path] = uiputfile(saveFilename, 'Save recruitment curve file');
if (isequal(file_name,0) || isequal(file_path,0)); return;  end; % The user cancelled
save(fullfile(file_path, file_name), 'rcurve');
