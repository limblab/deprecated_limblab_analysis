function [rcurve,file_name] = plot_rec_curves_StimDAQ_sampling(out_struct,calmat,emg_enable,time_window,~,saveFilename,vecGood)

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

% Fit using sampling technique
rcurve = fitUsingSampling(rcurve,vecGood);

[file_name,file_path] = uiputfile(saveFilename, 'Save recruitment curve file');
if (isequal(file_name,0) || isequal(file_path,0)); return;  end; % The user cancelled
save(fullfile(file_path, file_name), 'rcurve');
