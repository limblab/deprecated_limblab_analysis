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
figure(23);
plot(x(k),y(k),'r'); hold on;
plot(x,y,'b+');
plot(x2(k),y2(k),'g'); 


%% choose desired force within FFS and find optimal activation levels
Fdes = [0.5,0];
f = ones(nmusc,1);
lb = zeros(nmusc,1);
ub = ones(nmusc,1);
logicUb = ub<xMin;
ub(logicUb) = xMin(logicUb);
x0 = zeros(nmusc,1);
act = fmincon(@(x)fun_des_force(x,A,Fdes),x0,[],[],A,Fdes',xMin,ub);
% act = fmincon(@(x)fun_des_force(x,A,Fdes),x0,[],[],[],[],xMin,ub);

%% invert recruitment curves to determine stim parameters for each muscle
fMusc = act.*maxFmusc(vecGood);
paramsOPTIMAL = zeros(nmusc,1);
for ii = 1:nmusc
    delta = sigParams(2,vecGood(ii));
    alpha = sigParams(3,vecGood(ii));
    beta = sigParams(4,vecGood(ii));
    fMaxP = sigParams(1,vecGood(ii));
    paramsOPTIMAL(ii) = (1/alpha)*(-log((1-delta)/(fMusc(ii)/fMaxP-delta)-1)+beta);%(-log((1-params(2,ii))/(fMusc(ii)/params(1,ii)-params(2,ii))-1) + params(4,ii))/params(3,ii); 
end
% paramsOPTIMAL(~isreal(paramsOPTIMAL)) = 0;
ind = find(out_struct.is_channel_modulated>0);
ind2 = ind(vecGood);
fprintf('\n\n');
for ii = 1:nmusc
    fprintf('Muscle: %s, amps: %g\n',out_struct.emg_labels{ind2(ii)},paramsOPTIMAL(ii));
end
% paramsOPTIMAL

%% Check to see how forces align with prediction
figure; hold on;
fX = zeros(nmusc,1); fY = fX; fXlast = 0; fYlast = 0;
fXYu = zeros(2,nmusc); fXYulast = [0;0];
for ii = 1:nmusc
    if paramsOPTIMAL(ii) ~= 0
        forceOut = eval_sigmoid_MLE(sigParams(:,vecGood(ii)),paramsOPTIMAL(ii));
        fX(ii) = forceOut*Aold(1,vecGood(ii));
        fY(ii) = forceOut*Aold(2,vecGood(ii));
    else
        fX(ii) = 0;
        fY(ii) = 0;
    end
    plot([fXlast fXlast+fX(ii)],[fYlast fYlast+fY(ii)],'r*');
    fXlast = fXlast + fX(ii);
    fYlast = fYlast + fY(ii);
    
    % straight from optimization - activations and A matrix
    actTemp = zeros(size(act));
    actTemp(ii) = act(ii);
    fXYu(:,ii) = A*actTemp;
    plot([fXYulast(1) fXYulast(1)+fXYu(1,ii)],[fXYulast(2) fXYulast(2)+fXYu(2,ii)],'g')
    text(fXYulast(1)+fXYu(1,ii),fXYulast(2)+fXYu(2,ii),out_struct.emg_labels{ind2(ii)})
    fXYulast = fXYulast + fXYu(:,ii);   
end
plot([0 Fdes(1)],[0 Fdes(2)],'k');