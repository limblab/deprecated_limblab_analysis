%% Offline Processing during Experiment

%% Construct recruitment curve using 1 or more saved files
filename = 'C:\Documents and Settings\Tony\My Documents\FNS Stimulator\new stim-daq modified daq\06-Jan-2011 isometric data\';
rcurve_data = 'recruit_train_03';
time_window = [350 550];
load(strcat(cd,'\',strcat('06-Jan-2011',' isometric data\',rcurve_data)));
calMat = load(strcat('06-Jan-2011',' isometric data\cal_mat_06-Jan-2011'));
calMat = calMat';
saveFilename = strcat(cd,'\',strcat('06-Jan-2011',' isometric data'),'\recruit_sigmoid');
is_mle = 1;
[mle_cond,rcurve] = plot_rec_curves_StimDAQ(out_struct,calMat.calMat,out_struct.emg_enable,time_window,is_mle,saveFilename);

%%
rcurveFile{1} = 'recruit_sigmoid_03';
% rcurveFile{2} = 'recruit_sigmoid_02';

%% Compile data from all recruitment curve files into one large file
params = []; forces = []; magForces = []; stdForces = []; magDir = []; stdDir = [];
for ii = 1:length(rcurveFile)
   load(fullfile(filename,rcurveFile{ii}));
   if length(rcurve.forceCloud(1,1).fX) < 5
       type = 'train';
   else
       type = 'pulse';
   end
   if strcmp(rcurve.mode,'mod_amp')
       params = [params; rcurve.amps];
   else
       params = [params; rcurve.pws];
   end
%    forces = [forces; rcurve.calibForces];
   magForces = [magForces; rcurve.magForce];
   stdForces = [stdForces; rcurve.stdForce];
   magDir = [magDir; rcurve.dirForce];
   stdDir = [stdDir; rcurve.stdDir];
end

if rcurve.mle_cond
    % MLE estimation of sigmoid parameters
    sigParams = zeros(4,size(params,2));
%     sigParamsD = zeros(4,size(params,2));
    for ii = 1:size(params,2)
        sigParams(:,ii) = fitMaxLikelihoodRecruitCurve(magForces(:,ii),stdForces(:,ii),params(:,ii));
    end
else
   % Nonlinear least squares estimation of sigmoid paramters
   sigParams = fit_sigmoid(magForces,params); 
end

% Plot curves
plot_recruit_curves(out_struct,magForces,stdForces,params,params,'r');
plot_sigmoid_MLE(sigParams,params,'k');
% plot_recruit_curves(out_struct,magDir,stdDir,params,params,'r');
% plot_sigmoid_MLE(sigParamsD,params,'k');

%% Form mapping from muscle activation to endpoint force
nmusc = size(params,2);
maxAMPs = max(params);
maxFmusc = zeros(nmusc,1);
A = zeros(2,nmusc); Aold = A;
for ii = 1:nmusc
    maxFmusc(ii) = eval_sigmoid_MLE(sigParams(:,ii),maxAMPs(ii));
    A(1,ii) = cos(mean(magDir(6:end,ii)));
    A(2,ii) = sin(mean(magDir(6:end,ii)));
    Aold(:,ii) = A(:,ii);
    % Scale A by max force of each muscle
    A(:,ii) = A(:,ii)*maxFmusc(ii);
end

%% Manually select muscles, if desired
vecGood = [1 3:8]; %1:size(A,2);
A = A(:,vecGood);
nmusc = length(vecGood);

%%
minAMPs = min(params);
minFmusc = zeros(nmusc,1);
for ii = 1:nmusc
    minFmusc(ii) = eval_sigmoid_MLE(sigParams(:,vecGood(ii)),minAMPs(vecGood(ii)));
end
xMin = minFmusc./maxFmusc(vecGood);
xMin(xMin<0) = 0;
%% Compute convex hull of all forces = FFS
level_act = 0.75;
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
auto = 1; % 0=manual

%% Choose points within FFS
num_points = 10;

% based on number of points, generate the discretized mesh - make there be
% 5 times the number of meshpoints as control points, equally spaced in x
% and y
numFx = lower(sqrt(num_points*5));
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

%% compute optimal activation levels for each force vector, invert
% recruitment curves to determine stim parameters for each muscle
act = zeros(nmusc,num_points);
lb = zeros(nmusc,1);
ub = ones(nmusc,1);
logicUb = ub<xMin;
ub(logicUb) = xMin(logicUb);
x0 = zeros(nmusc,1);

paramsOPTIMAL = zeros(nmusc,num_points);

% Determine names of muscles that are used for control
ind = find(out_struct.is_channel_modulated>0);
ind2 = ind(vecGood);
options = optimset('Display','off','Algorithm','active-set');
clc;
for ii = 1:num_points
    % Optimal activation levels
    Fdes = ctrlPts(ii,:);
%     act(:,ii) = fmincon(@(x)fun_des_force(x,A,Fdes),x0,[],[],A,Fdes',xMin,ub,[],options);
    act(:,ii) = fmincon(@(x)fun_des_force(x,A,Fdes),x0,[],[],A,Fdes',lb,ub,[],options);
    
    % Invert recruitment curve, one muscle at a time
    fMusc = act(:,ii).*maxFmusc(vecGood);
    for jj = 1:nmusc
        delta = sigParams(2,vecGood(jj));
        alpha = sigParams(3,vecGood(jj));
        beta = sigParams(4,vecGood(jj));
        fMaxP = sigParams(1,vecGood(jj));
        paramsOPTIMAL(jj,ii) = (1/alpha)*(-log((1-delta)/(fMusc(jj)/fMaxP-delta)-1)+beta);
        paramsOPTIMAL(act(:,ii)<1.01*xMin,ii) = 0;
        
        % Display current amplitude (paramsOPTIMAL) for each muscle
        fprintf('Target %2g, Muscle: %3s, amps: %2.3g\n',ii,out_struct.emg_labels{ind2(jj)},paramsOPTIMAL(jj,ii));
    end
    fprintf('\n\n')
end

%% Check to see how forces align with prediction
hOptFChck = figure('Name','Optimal Forces Check Window','NumberTitle','off'); hold on;
fX = zeros(nmusc,1); fY = fX; fXlast = 0; fYlast = 0;
fXYu = zeros(2,nmusc); fXYulast = [0;0];
errDist = zeros(num_points,1);
for ii = 1:num_points
    % re-initialize for each force vector
    fX = zeros(nmusc,1); fY = fX; fXlast = 0; fYlast = 0;
    fXYu = zeros(2,nmusc); fXYulast = [0;0];
    
    Fdes = ctrlPts(ii,:);
    
    % loop through muscles to evaluate individual force contribution
    for jj = 1:nmusc
        if paramsOPTIMAL(jj,ii) ~= 0
            forceOut = eval_sigmoid_MLE(sigParams(:,vecGood(jj)),paramsOPTIMAL(jj,ii));
            fX(jj) = forceOut*Aold(1,vecGood(jj));
            fY(jj) = forceOut*Aold(2,vecGood(jj));
        else
            fX(jj) = 0;
            fY(jj) = 0;
        end
        plot([fXlast fXlast+fX(jj)],[fYlast fYlast+fY(jj)],'r*');
        fXlast = fXlast + fX(jj);
        fYlast = fYlast + fY(jj);

        % straight from optimization - activations and A matrix
        actTemp = zeros(size(act(:,ii)));
        actTemp(jj) = act(jj,ii);
        fXYu(:,jj) = A*actTemp;
        plot([fXYulast(1) fXYulast(1)+fXYu(1,jj)],[fXYulast(2) fXYulast(2)+fXYu(2,jj)],'g')
%         text(fXYulast(1)+fXYu(1,jj),fXYulast(2)+fXYu(2,jj),out_struct.emg_labels{ind2(jj)})
        fXYulast = fXYulast + fXYu(:,jj);   
    end
    plot([0 Fdes(1)],[0 Fdes(2)],'k');
    
    % compute distance error between desired force and actual force
    errDist(ii) = sqrt((Fdes(1)-fXlast)^2+(Fdes(2)-fYlast)^2);
end
