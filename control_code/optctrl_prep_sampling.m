function [optctrlOUT,rcurve] = optctrl_prep_sampling(pathname,filename,fname_calmat,num_points,auto,time_window,level_act,vecGood,c,rcurve)

%% Offline Processing during Experiment

%% Construct recruitment curve using 1 or more saved files
rcurveFile = cell(length(filename),1);
if isempty(rcurve)
    for nf = 1:length(filename)
        load(strcat(pathname{nf},filename{nf}));                % loads out_struct from amplitude modulation
        calMat = load(fname_calmat); calMat = calMat';          % loads calibration matrix

        % Plot recruitment curves and save sigmoid parameters
        saveFilename = strcat(pathname{nf},'recruit_sigmoid');
        is_mle = 1;
        [rcurve,fname_rcurve] = plot_rec_curves_StimDAQ_sampling(out_struct,calMat.calMat,out_struct.emg_enable,time_window,is_mle,saveFilename,vecGood);
        rcurveFile{nf} = fname_rcurve;
    end
else
    rcurveFile = filename;
    out_struct.emg_labels = {'1','2','3','4','5','6','7','8','9','10'};
%     % Plot curves
%     out_struct.freq = 70;
%     out_struct.emg_labels = {'1','2','3','4','5','6','7','8','9','10'};
%     out_struct.is_channel_modulated = vecGood;
%     out_struct.mode = 'mod_amp';
%     rcurve = fitUsingSampling(rcurve,vecGood);
end

%% User dialog to press OK to continue with plotting fits to rcurves
hwarn = warndlg('Press OK to continue','Plot rcurve fits...');
uiwait(hwarn);

%% Compile data from all recruitment curve files into one large file
nmusc = length(vecGood);

params = []; params2 = []; forceCloud.fX = []; forceCloud.fY = []; magDir = []; stdDir = [];
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
       forceCloud.fX = [forceCloud.fX; rcurve.forceCloud(:,vecGood).fX];
       forceCloud.fY = [forceCloud.fY; rcurve.forceCloud(:,vecGood).fY];
       magDir = [magDir; rcurve.dirForce(:,vecGood)];
       stdDir = [stdDir; rcurve.stdDir(:,vecGood)];
       rcurve.amps = params;
       rcurve.forceCloud = forceCloud;
   end
end

if length(rcurveFile) > 1
    % Fit using sampling
    rcurve = fitUsingSampling(rcurve,1:length(vecGood));   
end
plot_sigmoids_sampling(rcurve,vecGood);

%% Compute variance at each current for each muscle
S = rcurve.S;
opts.TOOLBOX_HOME=pwd;
addpath(genpath(opts.TOOLBOX_HOME));
tc_func_name = 'sigmoid';
% numMuscStd = length(vecGood);
% numPtsStd = length(rcurve.x1(:,ii));
% numRcs = length(S(1).P1);
% fout = zeros(length(1:50:numPtsStd),numRcs,numMuscStd);
% for ii = 1:numMuscStd
%    for jj = 1:50:numPtsStd
%       xIN = rcurve.x1(jj,ii);
%       for kk = 1:numRcs
%           % Compute force output across all sampled recruitment curves
%           fout(jj,kk,ii) = getTCval(xIN,tc_func_name,[S(ii).P1(kk) S(ii).P2(kk) S(ii).P3(kk) S(ii).P4(kk)]);
%       end
%    end
% end

stdM = approx_rcurve_var(rcurve,vecGood);
obsN = get_obs_noise(rcurve.amps,rcurve.stdForce(:,vecGood));

%% Form mapping from muscle activation to endpoint force
maxAMPs = max(params);
maxFmusc = zeros(nmusc,1);
A = zeros(2,nmusc); Aold = A;
avgangle = zeros(1,nmusc); stdangle = avgangle;
for ii = 1:nmusc
    % Determine maximum muscle force for maximal stimulation
    maxFmusc(ii) = getTCval(maxAMPs(ii),tc_func_name,[S(ii).P1_median S(ii).P2_median S(ii).P3_median S(ii).P4_median]);
    
    % Determine average angle of force vector
    %magF = mean(sqrt(forceCloud(:,ii).fX.^2 + forceCloud(:,ii).fY.^2));
    logicvec = stdDir(:,ii) < 30*pi/180;% & magF > 0.1;
    avgangle(ii) = mean(magDir(logicvec,ii));
    stdangle(ii) = std(magDir(logicvec,ii));
    keepLogic(ii).vec = logicvec;
    if isnan(avgangle(ii))
        avgangle(ii) = mean(magDir(:,ii)); 
        stdangle(ii) = std(magDir(:,ii));
    end
    % Determine normalized matrix to map stimulation to force output
    A(1,ii) = cos(avgangle(ii));
    A(2,ii) = sin(avgangle(ii));
    Aold(:,ii) = A(:,ii);
    
    % Scale A by max force of each muscle
    A(:,ii) = A(:,ii)*maxFmusc(ii);
    
    %plot avg angle
    figure(vecGood(ii)+10); subplot(2,1,2); hold on;
    plot(params(:,ii),180/pi*magDir(:,ii),'r.');
    errorbar(params(:,ii),180/pi*magDir(:,ii),stdDir(:,ii),'Color','r','LineStyle','none');
    plot(params(:,ii),180/pi*repmat(avgangle(ii),size(params,1),1),'k-');
    plot(params(logicvec,ii),180/pi*magDir(logicvec,ii),'go')
end

%% Manually select muscles, if desired
% vecGood = [1:6];
% A = A(:,vecGood);
% nmusc = length(vecGood);

%%
minAMPs = min(params);
minFmusc = zeros(nmusc,1);
for ii = 1:nmusc
    minFmusc(ii) = getTCval(minAMPs(ii),tc_func_name,[S(ii).P1_median S(ii).P2_median S(ii).P3_median S(ii).P4_median]);
end
xMin = minFmusc./maxFmusc;
xMin(xMin<0) = 0;
xMin(xMin>0.99) = 0.98;

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

%%
S = rcurve.S(:); %
stim = rcurve.x1(:,:); %
stdM = stdM(:,:); %
mDir = avgangle;

%% compute optimal activation levels for each force vector, invert
% recruitment curves to determine stim parameters for each muscle
act = zeros(nmusc,num_points);
lb = zeros(nmusc,1);
ub = ones(nmusc,1);
% logicUb = ub<xMin;
% ub(logicUb) = xMin(logicUb);
x0 = ones(nmusc,1);
Aineq = [];%[eye(nmusc);-eye(nmusc)];
bineq = [];%[ones(nmusc,1);xMin];
paramsOPTIMAL = zeros(nmusc,num_points);
Aeq = [];
beq = [];

% Determine names of muscles that are used for control
ind2 = vecGood;
options = optimset('Display','on','Algorithm','interior-point','MaxFunEvals',1e5,'MaxIter',1e5,'TolFun',1e-10,'TolCon',1e-10,'TolX',1e-16); 
for ii = 1:num_points
    % Optimal activation levels
    Fdes = ctrlPts(ii,:);
    
%     act(:,ii) = fmincon(@(x)fun_des_force(x,A,Fdes),x0,[],[],A,Fdes',xMin,ub,[],options);
    act(:,ii) = fmincon(@(x)fun_des_force_sampling(x,S,maxFmusc,mDir,Fdes',stim,stdM,obsN,xMin,c),x0,Aineq,bineq,Aeq,beq,xMin,ub,[],options);
%     act(:,ii) = fmincon(@(x)fun_des_force_sampling_v2(x,S,maxFmusc,mDir,Fdes',stim,stdM,obsN,xMin,stdangle,c),x0,Aineq,bineq,A,Fdes',xMin,ub,[],options);

    % Invert recruitment curve, one muscle at a time
    fMusc = act(:,ii).*maxFmusc(:);
    for jj = 1:nmusc
        paramsOPTIMAL(jj,ii) = invert_rcurve_sampling(fMusc(jj),rcurve.S(jj));
%         paramsOPTIMAL(act(:,ii)<1.01*xMin,ii) = 0;
        if (paramsOPTIMAL(jj,ii)<0) 
            paramsOPTIMAL(jj,ii) = 0;
        end
        
        % Display current amplitude (paramsOPTIMAL) for each muscle
        fprintf('Target %2g, Muscle: %3s, amps: %2.3g\n',ii,out_struct.emg_labels{ind2(jj)},paramsOPTIMAL(jj,ii));
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
        if paramsOPTIMAL(jj,ii) ~= 0 %&& paramsOPTIMAL(jj,ii)>1.01*minAMPs(jj)
            forceOut = eval_sigmoid_sampling(rcurve.S(jj),paramsOPTIMAL(jj,ii));
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
optctrlOUT.keepLogic = keepLogic;
optctrlOUT.sigParams = rcurve;
optctrlOUT.costweigths = c;

