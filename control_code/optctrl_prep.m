function [optctrlOUT,rcurve] = optctrl_prep(pathname,filename,fname_calmat,num_points,auto,time_window,level_act,vecGood,c,rcurve)

%% Offline Processing during Experiment

%% Construct recruitment curve using 1 or more saved files
rcurveFile = cell(1,1);%cell(length(filename),1);
if isempty(rcurve)
    for nf = 1:length(filename)
        load(strcat(pathname{nf},filename{nf}));                % loads out_struct from amplitude modulation
        calMat = load(fname_calmat); calMat = calMat';          % loads calibration matrix

        % Plot recruitment curves and save sigmoid parameters
        saveFilename = strcat(pathname{nf},'recruit_sigmoid');
        is_mle = 1;
        [~,rcurve,fname_rcurve] = plot_rec_curves_StimDAQ(out_struct,calMat.calMat,out_struct.emg_enable,time_window,is_mle,saveFilename,vecGood);
        rcurveFile{nf} = fname_rcurve;
    end
else
    rcurveFile = filename;
    % Plot curves
    out_struct.freq = 70;
    out_struct.emg_labels = {'1','2','3','4','5','6','7','8','9','10'};
    out_struct.is_channel_modulated = vecGood;
    out_struct.mode = 'mod_amp';
    plot_recruit_curves(out_struct,rcurve.magForce,rcurve.stdForce,rcurve.dirForce,rcurve.stdDir,rcurve.amps,rcurve.pws,vecGood,'r');
end

%% User dialog to press OK to continue with plotting fits to rcurves
hwarn = warndlg('Press OK to continue','Plot rcurve fits...');
uiwait(hwarn);

%% Compile data from all recruitment curve files into one large file
nmusc = length(vecGood);

params = []; params2 = []; magForces = []; stdForces = []; magDir = []; stdDir = [];
for ii = 1:length(rcurveFile)
   load(fullfile(pathname{ii},rcurveFile{ii}));
   if size(params,2)~=size(rcurve.amps,2) && ii > 1
        hw = warndlg('#muscles diff for each dataset, using only dataset #1','Warning!');
        uiwait(hw);
        load(strcat(pathname{1},filename{1}));
        load(fullfile(pathname{1},rcurveFile{1}));
   else
       if strcmp(rcurve.mode,'mod_amp')
           params = [params; rcurve.amps(:,vecGood)];
           params2 = [params; rcurve.pws(:,vecGood)];
       else
           params = [params; rcurve.pws(:,vecGood)];
           params2 = [params; rcurve.amps(:,vecGood)];
       end
       magForces = [magForces; rcurve.magForce(:,vecGood)];
       stdForces = [stdForces; rcurve.stdForce(:,vecGood)];
       magDir = [magDir; rcurve.dirForce(:,vecGood)];
       stdDir = [stdDir; rcurve.stdDir(:,vecGood)];
   end
end

if length(rcurveFile) > 1
    if rcurve.mle_cond
        % MLE estimation of sigmoid parameters
        sigParams = zeros(4,nmusc);
    %     sigParamsD = zeros(4,size(params,2));
        for ii = 1:nmusc
            sigParams(:,ii) = fitMaxLikelihoodRecruitCurve(magForces(:,ii),stdForces(:,ii),params(:,ii));
        end
    else
       % Nonlinear least squares estimation of sigmoid paramters
       sigParams = fit_sigmoid(magForces,params); 
    end

    % Plot curves
    plot_recruit_curves(out_struct,magForces,stdForces,magDir,stdDir,params,params2,1:length(vecGood),'r');
else
    sigParams = rcurve.sigParams(:,vecGood);
end
plot_sigmoid_MLE(sigParams,params,vecGood,'k');

%% Form mapping from muscle activation to endpoint force
maxAMPs = max(params);
maxFmusc = zeros(nmusc,1);
A = zeros(2,nmusc); Aold = A;
avgangle = zeros(1,nmusc);
for ii = 1:nmusc
    % Determine maximum muscle force for maximal stimulation
    maxFmusc(ii) = eval_sigmoid_MLE(sigParams(:,ii),maxAMPs(ii));
    
    % Determine average angle of force vector
    logicvec = stdDir(:,ii) < 30*pi/180 & magForces(:,ii) > 0.1;
    avgangle(ii) = mean(magDir(logicvec,ii));
    keepLogic(ii).vec = logicvec;
    if isnan(avgangle(ii))
        avgangle(ii) = mean(magDir(:,ii));    
    end
    % Determine normalized matrix to map stimulation to force output
    A(1,ii) = cos(avgangle(ii));
    A(2,ii) = sin(avgangle(ii));
    Aold(:,ii) = A(:,ii);

    % Scale A by max force of each muscle
    A(:,ii) = A(:,ii)*maxFmusc(ii);
    
    % Plot avg angle
    figure(vecGood(ii)+10); subplot(2,1,2); hold on;
    plot(params(:,ii),180/pi*repmat(avgangle(ii),size(params,1),1),'k-');
    plot(params(logicvec,ii),180/pi*magDir(logicvec,ii),'go')
end
% avgangle(isnan(avgangle)) = mean(magDir(:,isnan(avgangle)));

%% Re-do fit to data excluding data from forces not used to compute fDir
if rcurve.mle_cond
    % MLE estimation of sigmoid parameters
    sigParams = zeros(4,nmusc);
    for ii = 1:nmusc
        logictemp = keepLogic(ii).vec;
        logicind = find(~logictemp);
        logicvec = true(size(logictemp));
        logicvec(logicind(logicind>5)) = false;
        keepLogicSig(ii).logicvec = logicvec;
        sigParams(:,ii) = fitMaxLikelihoodRecruitCurve(magForces(logicvec,ii),stdForces(logicvec,ii),params(logicvec,ii));
    end
end

% Plot curves
% plot_recruit_curves(out_struct,magForces,stdForces,magDir,stdDir,params,params2,vecGood,'r');
plot_sigmoid_MLE(sigParams,params,vecGood,'g');

%% Determine minimum muscle forces
minAMPs = min(params);
minFmusc = zeros(nmusc,1);
for ii = 1:nmusc
    minFmusc(ii) = eval_sigmoid_MLE(sigParams(:,ii),minAMPs(ii));
end
xMin = minFmusc./maxFmusc;
xMin(xMin<0) = 0;

%% Compute convex hull of all forces = FFS
% level_act = 0.75;
tj = 1; clear x y;
for ii = 1:nmusc % number of muscles
    C = nchoosek(1:nmusc,ii);
    for jj = 1:size(C,1) % number of combinations
           x(tj) = sum(A(1,C(jj,:)));
           y(tj) = sum(A(2,C(jj,:)));
           x2(tj) = sum(level_act*A(1,C(jj,:)));
           y2(tj) = sum(level_act*A(2,C(jj,:)));
           tj = tj + 1;
    end 
end
x(tj) = 0; y(tj) = 0;
x2(tj) = 0; y2(tj) = 0;
k = convhull(x,y);
k2 = convhull(x2,y2);
hFFS = figure('Name','FFS Plot Window','NumberTitle','off');
plot(x(k),y(k),'r'); hold on;
plot(x,y,'b+');
plot(x2(k2),y2(k2),'g'); 

%% Automatic or manual
% Construct a questdlg with three options
choice = questdlg('Would you like to use previous control points?', ...
'Old or new control points', ...
'Yes','No','No');
% Handle response
switch choice
    case 'Yes'
        % load previous control points
        load('control_points');
        plot(ctrlPts(:,1),ctrlPts(:,2),'m*')
    case 'No'
        % Select control points
        if auto == 1; % 0=manual
            % Automatically choose points within FFS
            % based on number of points, generate the discretized mesh - make there be
            % 5 times the number of meshpoints as control points, equally spaced in x
            % and y
            numFx = lower(sqrt(num_points*50));
            numFy = numFx;

            % generate grid pattern
            maxXgrid = max(x2(k2)); minXgrid = min(x2(k2));
            maxYgrid = max(y2(k2)); minYgrid = min(y2(k2));
            xrange = minXgrid:(maxXgrid-minXgrid)/numFx:maxXgrid;
            yrange = minYgrid:(maxYgrid-minYgrid)/numFy:maxYgrid;
            [xMesh,yMesh] = meshgrid(xrange,yrange);

            % determine if grid points are within FFS
            IN = inpolygon(xMesh,yMesh,x2(k2),y2(k2));
            meshXin = xMesh(IN);
            meshYin = yMesh(IN);

            % plot only those points within FFS on FFS figure
            figure(hFFS); hold on;
            plot(meshXin,meshYin,'g*')

            % randomly choose subset of points to control to within FFS
            z = randperm(numel(meshXin)); % this well generate random arrangement of indices of m
            ctrlPts = zeros(num_points,2);
            ctrlPts(:,1) = meshXin(z(1:num_points));
            ctrlPts(:,2) = meshYin(z(1:num_points));
            save('control_points','ctrlPts');
            figure(hFFS); hold on;
            plot(ctrlPts(:,1),ctrlPts(:,2),'m*')

        else
            % Manually select points from figure
            figure(hFFS)
            [ctrlPts(:,1),ctrlPts(:,2)] = ginput(num_points);
            save('control_points','ctrlPts');
            figure(hFFS); hold on;
            plot(ctrlPts(:,1),ctrlPts(:,2),'m*')
        end
end

%% User dialog to press OK to continue after selecting FFS points
hwarn = warndlg('Press OK to continue','FFS points selected...');
uiwait(hwarn);

%% compute optimal activation levels for each force vector, invert
% recruitment curves to determine stim parameters for each muscle
act = zeros(nmusc,num_points);
lb = zeros(nmusc,1);
ub = ones(nmusc,1);
logicUb = ub<xMin; ub(logicUb) = xMin(logicUb);
Af = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];

x0 = ones(nmusc,1);
paramsOPTIMAL = zeros(nmusc,num_points);

% Determine names of muscles that are used for control
options = optimset('Display','on','Algorithm','interior-point');
clc;
for ii = 1:num_points
    % Optimal activation levels
    Fdes = ctrlPts(ii,:);
%     act(:,ii) = fmincon(@(x)fun_des_force(x,A,Fdes),x0,[],[],A,Fdes',xMin,ub,[],options);
    act(:,ii) = fmincon(@(x)fun_des_force(x,maxFmusc,avgangle,Fdes',xMin,c),x0,Af,b,Aeq,beq,lb,ub,nonlcon,options);
    
    % Invert recruitment curve, one muscle at a time
    fMusc = act(:,ii).*maxFmusc(:);
    for jj = 1:nmusc
        if act(jj,ii)<xMin(jj)
            paramsOPTIMAL(jj,ii) = 0;
        else
            delta = sigParams(2,jj);
            alpha = sigParams(3,jj);
            beta = sigParams(4,jj);
            fMaxP = sigParams(1,jj);
            paramsOPTIMAL(jj,ii) = (-log((1-delta)/(fMusc(jj)/fMaxP-delta)-1) + beta)/alpha; 
            if isnan(paramsOPTIMAL(jj,ii)) || ~isreal(paramsOPTIMAL(jj,ii)) || paramsOPTIMAL(jj,ii)<0
                paramsOPTIMAL(jj,ii) = 0;
            end
        end
        
        % Display current amplitude (paramsOPTIMAL) for each muscle
        fprintf('Target %2g, Muscle: %3s, amps: %2.3g\n',ii,out_struct.emg_labels{vecGood(jj)},paramsOPTIMAL(jj,ii));
    end
    fprintf('\n\n')
end

%% Check to see how forces align with prediction
hOptFChck = figure('Name','Optimal Forces Check Window','NumberTitle','off'); hold on;
errDist = zeros(num_points,1);
for ii = 1:num_points
    % re-initialize for each force vector
    fX = zeros(nmusc,1); fY = fX; fXlast = 0; fYlast = 0;
    fXYu = zeros(2,nmusc); fXYulast = [0;0];
    
    Fdes = ctrlPts(ii,:);
    
    % loop through muscles to evaluate individual force contribution
    for jj = 1:nmusc
        if paramsOPTIMAL(jj,ii) ~= 0 && paramsOPTIMAL(jj,ii)>1.01*minAMPs(jj)
            forceOut = eval_sigmoid_MLE(sigParams(:,jj),paramsOPTIMAL(jj,ii));
            fX(jj) = forceOut*Aold(1,jj);
            fY(jj) = forceOut*Aold(2,jj);
        else
            fX(jj) = 0;
            fY(jj) = 0;
        end
        plot([fXlast fXlast+fX(jj)],[fYlast fYlast+fY(jj)],'-.r*');
        fXlast = fXlast + fX(jj);
        fYlast = fYlast + fY(jj);

        % straight from optimization - activations and A matrix
        actTemp = zeros(size(act(:,ii)));
        actTemp(jj) = act(jj,ii);
        fXYu(:,jj) = A*actTemp;
        plot([fXYulast(1) fXYulast(1)+fXYu(1,jj)],[fXYulast(2) fXYulast(2)+fXYu(2,jj)],':gs')
%         text(fXYulast(1)+fXYu(1,jj),fXYulast(2)+fXYu(2,jj),out_struct.emg_labels{ind2(jj)})
        fXYulast = fXYulast + fXYu(:,jj);   
    end
    plot([0 Fdes(1)],[0 Fdes(2)],'-ko');
       
    % compute distance error between desired force and actual force
    errDist(ii) = sqrt((Fdes(1)-fXlast)^2+(Fdes(2)-fYlast)^2);
end
[~,ind] = max(sqrt(sum(ctrlPts.^2)));
text('Position',[ctrlPts(ind,1), ctrlPts(ind,2), 0],'String','\color{red}From sigmoids \color{black}, \color{green}From optimizations (A) \color{black}, Desired')'

%% User dialog to press OK to continue after selecting FFS points
hwarn = warndlg('Press OK to continue','Opt ctrl check...');
uiwait(hwarn);

%% Combine all variables into a structure for output
optctrlOUT.errDist = errDist;
optctrlOUT.ctrlPts = ctrlPts;
optctrlOUT.paramsOPTIMAL = paramsOPTIMAL;
optctrlOUT.act = act;
optctrlOUT.indorig = vecGood;
optctrlOUT.muscles = out_struct.emg_labels;
optctrlOUT.subsetMuscInd = vecGood;
optctrlOUT.timewindow = time_window;
optctrlOUT.level_act = level_act;
optctrlOUT.avgangle = avgangle;
optctrlOUT.keepLogic = keepLogicSig;
optctrlOUT.sigParams = sigParams;
optctrlOUT.c = c;

