function [mle_cond,rcurve,file_name] = plot_rec_curves_StimDAQ_fxfy(out_struct,calmat,emg_enable,time_window,is_mle,saveFilename,vecGood)
% load('recruit_train_01');
% out_struct.pulses = 3;

%% User specified times for begin/end of "steady-state" force response
platON = time_window(1);
platOFF = time_window(2);

%% Compute general force properties from stim train
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

%% Fit sigmoid to data
% Choose either MLE fit or nonlinlsqsqrs fit to form sigmoid approximation
% to recruitment curve
mle_cond = is_mle && out_struct.pulses > 10;

% RECRUITMENT CURVES FOR Fx, Fy
% MLE estimation of sigmoid parameters
sigParams = zeros(8,size(magForce,2));

% Fx
magFx = zeros(size(magForce));
stdFx = zeros(size(magForce));
for ii = 1:size(magForce,2) %num muscles
    for jj = 1:size(magForce,1) %num stims
        magFx(jj,ii) = mean(forceCloud(jj,ii).fX);
        stdFx(jj,ii) = std(forceCloud(jj,ii).fX);
    end
    sigParams(1:4,ii) = fitMaxLikelihoodRecruitCurve(magFx(:,ii),stdFx(:,ii),amps(:,ii));
end

% Fy
magFy = zeros(size(magForce));
stdFy = zeros(size(magForce));
for ii = 1:size(magForce,2) %num muscles
    for jj = 1:size(magForce,1) %num stims
        magFy(jj,ii) = mean(forceCloud(jj,ii).fY);
        stdFy(jj,ii) = std(forceCloud(jj,ii).fY);
    end
    sigParams(5:8,ii) = fitMaxLikelihoodRecruitCurve(magFy(:,ii),stdFy(:,ii),amps(:,ii));
end
rcurve.magFx = magFx; rcurve.stdFx = stdFx;
rcurve.magFy = magFy; rcurve.stdFy = stdFy;
rcurve.sigParams = sigParams;
rcurve.mle_cond = mle_cond;
rcurve.time_window = time_window;
rcurve.vecGood = vecGood;

% Plot recruitment curves - fX
plot_recruit_curves_fxfy(out_struct,magFx(:,vecGood),stdFx(:,vecGood),amps(:,vecGood),pws(:,vecGood),vecGood,'r','Fx');
% plot_sigmoid_MLE_fxfy(sigParams(1:4,:),amps,'k');

% Plot recruitment curves - fY
plot_recruit_curves_fxfy(out_struct,magFy(:,vecGood),stdFy(:,vecGood),amps(:,vecGood),pws(:,vecGood),vecGood,'g','Fy');
% plot_sigmoid_MLE_fxfy(sigParams(5:8,:),amps,'b');

%% Ask user what name to save recruitment curve as...
[file_name,file_path] = uiputfile(saveFilename, 'Save recruitment curve file');
if (isequal(file_name,0) || isequal(file_path,0)); return;  end; % The user cancelled
save(fullfile(file_path, file_name), 'rcurve');
