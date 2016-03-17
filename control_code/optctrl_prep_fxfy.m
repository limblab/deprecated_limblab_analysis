function [optctrlOUT,rcurve] = optctrl_prep_fxfy(pathname,filename,fname_calmat,num_points,auto,time_window,level_act,vecGood,c)

%% Offline Processing during Experiment

%% Construct recruitment curve using 1 or more saved files
rcurveFile = cell(length(filename),1);
for nf = 1:length(filename)
    load(strcat(pathname{nf},filename{nf}));                % loads out_struct from amplitude modulation
    calMat = load(fname_calmat); calMat = calMat';          % loads calibration matrix
    
    % Plot recruitment curves and save sigmoid parameters
    saveFilename = strcat(pathname{nf},'recruit_sigmoid');
    is_mle = 1;
    [~,rcurve,fname_rcurve] = plot_rec_curves_StimDAQ_fxfy(out_struct,calMat.calMat,out_struct.emg_enable,time_window,is_mle,saveFilename,vecGood);
    rcurveFile{nf} = fname_rcurve;
end

%% User dialog to press OK to continue with plotting fits to rcurves
hwarn = warndlg('Press OK to continue','Plot rcurve fits...');
uiwait(hwarn);

%% Compile data from all recruitment curve files into one large file
nmusc = length(vecGood);

params = []; params2 = []; magFx = []; stdFx = []; magFy = []; stdFy = [];
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
       magFx = [magFx; rcurve.magFx(:,vecGood)];
       stdFx = [stdFx; rcurve.stdFx(:,vecGood)];
       magFy = [magFy; rcurve.magFy(:,vecGood)];
       stdFy = [stdFy; rcurve.stdFy(:,vecGood)];
   end
end

if length(rcurveFile) > 1
    if rcurve.mle_cond
        % MLE estimation of sigmoid parameters
        sigParams = zeros(8,nmusc);
    %     sigParamsD = zeros(4,size(params,2));
        for ii = 1:nmusc
            sigParams(1:4,ii) = fitMaxLikelihoodRecruitCurve(magFx(:,ii),stdFx(:,ii),params(:,ii));
            sigParams(5:8,ii) = fitMaxLikelihoodRecruitCurve(magFy(:,ii),stdFy(:,ii),params(:,ii));
        end
    else
       % Nonlinear least squares estimation of sigmoid paramters
       sigParams = fit_sigmoid(magForces,params); 
    end
    % Plot curves
    plot_recruit_curves_fxfy(out_struct,magFx,stdFx,params,params2,vecGood,'r','Fx');
    plot_recruit_curves_fxfy(out_struct,magFy,stdFy,params,params2,vecGood,'g','Fy');
    

else
    % Use parameters from previous fit
    sigParams = rcurve.sigParams(:,vecGood);
end
plot_sigmoid_MLE_fxfy(sigParams(1:4,:),params,vecGood,'k');
plot_sigmoid_MLE_fxfy(sigParams(5:8,:),params,vecGood,'b');

%% Determine the max and minimum force produced by each muscle - according to sigmoids!
minAMPs = min(params); maxAMPs = max(params);
maxFmusc = zeros(nmusc,2); minFmusc = zeros(nmusc,2);
for ii = 1:nmusc
    minFmusc(ii,1) = eval_sigmoid_MLE(sigParams(1:4,ii),minAMPs(ii));
    minFmusc(ii,2) = eval_sigmoid_MLE(sigParams(5:8,ii),minAMPs(ii));
    maxFmusc(ii,1) = eval_sigmoid_MLE(sigParams(1:4,ii),maxAMPs(ii));
    maxFmusc(ii,2) = eval_sigmoid_MLE(sigParams(5:8,ii),maxAMPs(ii));
end
xMin = minFmusc./maxFmusc;
xMin(xMin<0) = 0;

%% Form mapping from muscle activation to endpoint force
A = zeros(2,nmusc); Aold = A;
for ii = 1:nmusc
    A(1,ii) = maxFmusc(ii,1); % Fx
    A(2,ii) = maxFmusc(ii,2); % Fy
    % Divide A by norm to get unit vectors
    Aold(:,ii) = A(:,ii)/norm(A(:,ii));
end

%% Compute convex hull of all forces = approximation to FFS
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

% Include (0,0)
x(tj) = 0; y(tj) = 0;
x2(tj) = 0; y2(tj) = 0;

% Generate convex sums
k = convhull(x,y);
k2 = convhull(x2,y2);

% Plot resulting FFS
hFFS = figure('Name','FFS Plot Window','NumberTitle','off');
plot(x(k),y(k),'r'); hold on;
plot(x,y,'b+');
plot(x2(k2),y2(k2),'g'); 

%% Automatic or manual
if auto == 1; % 0=manual
    % Automatically choose points within FFS
    % based on number of points, generate the discretized mesh - make there be
    % 5 times the number of meshpoints as control points, equally spaced in x
    % and y
    numFx = lower(sqrt(num_points*20));
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

    figure(hFFS); hold on;
    plot(ctrlPts(:,1),ctrlPts(:,2),'m*')

else
    % Manually select points from figure
    figure(hFFS)
    [ctrlPts(:,1),ctrlPts(:,2)] = ginput(num_points);
    figure(hFFS); hold on;
    plot(ctrlPts(:,1),ctrlPts(:,2),'m*')
end

%% User dialog to press OK to continue after selecting FFS points
hwarn = warndlg('Press OK to continue','FFS points selected...');
uiwait(hwarn);

%% compute optimal activation levels for each force vector, invert
% recruitment curves to determine stim parameters for each muscle
lb = zeros(nmusc,1);
ub = maxAMPs;%ones(nmusc,1);
Af = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];

x0 = ones(nmusc,1);
xOpt = zeros(nmusc,num_points);

% Determine names of muscles that are used for control
ind2 = vecGood;
% options = optimset('Display','off','Algorithm','active-set'); clc;
options = optimset('Display','final-detailed','Algorithm','interior-point');%,'MaxFunEvals',1e5,'MaxIter',1e5,'TolFun',1e-10,'TolCon',1e-10,'TolX',1e-16); clc;

for ii = 1:num_points
    % Optimal activation levels
    Fdes = ctrlPts(ii,:);
%         xOpt(:,ii) = fmincon(@(x)fun_des_force(x),x0,[],[],[],[],lb,ub,@(x)mynonlincon(x,sigParams,Fdes,nmusc,minAMPs),options);
    xOpt(:,ii) =  fmincon(@(x)fun_des_force_fxfy(x,sigParams,Fdes,nmusc,minAMPs,c),x0,Af,b,Aeq,beq,lb,ub,nonlcon,options);

    for jj = 1:nmusc     
        % Display current amplitude (paramsOPTIMAL) for each muscle
        fprintf('Target %2g, Muscle: %3s, amps: %2.3g\n',ii,out_struct.emg_labels{ind2(jj)},xOpt(jj,ii));
    end
    fprintf('\n\n')
end

%% Check to see how forces align with prediction
hOptFChck = figure('Name','Optimal Forces Check Window','NumberTitle','off'); hold on;
errDist = zeros(num_points,1);
for ii = 1:num_points
    % re-initialize for each force vector
    fX = zeros(nmusc,1); fY = fX; fXlast = 0; fYlast = 0;    
    Fdes = ctrlPts(ii,:);
    
    % loop through muscles to evaluate individual force contribution
    for jj = 1:nmusc
        if xOpt(jj,ii) ~= 0
            fX(jj) = find_forces_fxfy(xOpt(jj,ii),sigParams(1:4,jj),minAMPs(jj));
            fY(jj) = find_forces_fxfy(xOpt(jj,ii),sigParams(5:8,jj),minAMPs(jj));
        else
            fX(jj) = 0;
            fY(jj) = 0;
        end
        plot([fXlast fXlast+fX(jj)],[fYlast fYlast+fY(jj)],'-.r*');
        fXlast = fXlast + fX(jj);
        fYlast = fYlast + fY(jj);
    end
    plot([0 Fdes(1)],[0 Fdes(2)],'-ko');
       
    % compute distance error between desired force and actual force
    errDist(ii) = sqrt((Fdes(1)-fXlast)^2+(Fdes(2)-fYlast)^2);
end
[~,ind] = max(sqrt(sum(ctrlPts.^2)));
text('Position',[ctrlPts(ind,1), ctrlPts(ind,2), 0],'String','\color{red}From sigmoids \color{black},\color{black} Desired');

%% User dialog to press OK to continue after selecting FFS points
hwarn = warndlg('Press OK to continue','Opt ctrl check...');
uiwait(hwarn);

%% Combine all variables into a structure for output
optctrlOUT.errDist = errDist;
optctrlOUT.ctrlPts = ctrlPts;
optctrlOUT.paramsOPTIMAL = xOpt;
optctrlOUT.act = [];
optctrlOUT.indorig = vecGood;
optctrlOUT.muscles = out_struct.emg_labels;
optctrlOUT.subsetMuscInd = vecGood;
optctrlOUT.timewindow = time_window;
optctrlOUT.level_act = level_act;
optctrlOUT.sigParams = sigParams;
optctrlOUT.c = c;
