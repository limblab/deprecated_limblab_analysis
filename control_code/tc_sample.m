function S=tc_sample(x,y,tc_func_name,prob_model_name,opts)
% TC_SAMPLE Perform sampling using the given tuning curve function and 
% probability model.
%
% x                A vector of independent variable values
% y                A vector of measured responses, of the same length as x
% tc_func_name     The name of the tuning curve function to use; one of
%                  'constant', 'linear', 'gaussian', 'circular_gaussian',
%                  'sigmoid'
% prob_model_name  The name of the probability model which is assumed to
%                  generate the observations; one of 'poisson',
%                  'negative_binomial', 'add_normal', 'mult_normal'
% opts             Other options 

if ~isfield(opts,'TOOLBOX_HOME')
   error('opts.TOOLBOX_HOME is not set!');
end
TOOLBOX_HOME=opts.TOOLBOX_HOME;
% addpath(genpath([TOOLBOX_HOME,'/matlab']));
fid=fopen('jar_list.txt');
temp=textscan(fid,'%s');
fclose(fid);
temp=temp{1};
jar_list={};
for i=1:length(temp)
    jar_list{i}=[TOOLBOX_HOME,'/lib/',temp{i}];
end
javaclasspath(jar_list);

fid=fopen('import_list.txt');
temp=textscan(fid,'%s');
fclose(fid);
temp=temp{1};
import_list={};
for i=1:length(temp)
   import(temp{i});
end

% Set up default options
if nargin == 4
   opts={};
end
if ~isfield(opts,'burnin_samples') opts.burnin_samples=5000; end;
if ~isfield(opts,'num_samples') opts.num_samples=10000; end;
if ~isfield(opts,'sample_period') opts.sample_period=100; end;


% Create the model
sdk = TCModelUtils.createEmptyTCModel();

% Initialize with the appropriate probability model
collect_p_llhds = 0;
collect_p5 = 0;
constrain_positive=0;
switch lower(prob_model_name)
   case {'poiss','poisson'}
       TCModelUtils.configureProbabilityModel(sdk,'poisson');
       constrain_positive=1;
   case {'negative_binomial','neg_binom'}
       TCModelUtils.configureProbabilityModel(sdk,'negative_binomial');
       constrain_positive=1;
   case 'add_normal'
       TCModelUtils.configureProbabilityModel(sdk,'add_normal');
       collect_p_llhds = 1;
   case 'mult_normal'
       TCModelUtils.configureProbabilityModel(sdk,'mult_normal');
       collect_p_llhds = 1;
   otherwise
       error([' The probability model ',prob_model_name,' is not recognized']);
end

% Initialize with the appropriate TC function
min_x_diff=min(diff(unique(x)));
min_y=min(y);
max_y=max(y);
spread=max_y-min_y;
switch lower(tc_func_name)
   case 'constant'
       TCModelUtils.configureTCFunc(sdk, 'Constant');
       if constrain_positive==1
           setup_prior(sdk,1,'uniform',mean(y),0,max_y*2,opts);
       else
           setup_prior(sdk,1,'uniform',mean(y),min_y-spread,max_y+spread,opts);
       end
   case 'linear'
       TCModelUtils.configureTCFunc(sdk, 'Linear');
       setup_prior(sdk,1,'uniform',mean(y),min_y,max_y,opts);
       setup_prior(sdk,2,'uniform',0,-10*spread/(max(x)-min(x)),10*spread/(max(x)-min(x)),opts);
   case 'gaussian'
       TCModelUtils.configureTCFunc(sdk, 'Gaussian');
       if constrain_positive==1
           setup_prior(sdk,1,'uniform',mean(y),0,max_y*2,opts);
       else
           setup_prior(sdk,1,'uniform',mean(y),min_y-spread,max_y+spread,opts);
       end
       setup_prior(sdk,2,'uniform',spread,0,2*spread,opts);
       setup_prior(sdk,3,'uniform',mean(x),min(x),max(x),opts);
       setup_prior(sdk,4,'uniform',min_x_diff,min_x_diff/2,max(x)-min(x),opts);
   case 'circular_gaussian_360'
       TCModelUtils.configureTCFunc(sdk, 'CircularGaussian360');
       if constrain_positive==1
           setup_prior(sdk,1,'uniform',mean(y),0,max_y*2,opts);
       else
           setup_prior(sdk,1,'uniform',mean(y),min_y-spread,max_y+spread,opts);
       end
       setup_prior(sdk,2,'uniform',spread,0,2*spread,opts);
       setup_prior(sdk,3,'uniform',180,0,360,opts);
       setup_prior(sdk,4,'uniform',min_x_diff,min_x_diff/2,90,opts);
   case 'circular_gaussian_180'
       TCModelUtils.configureTCFunc(sdk, 'CircularGaussian180');
       if constrain_positive==1
           setup_prior(sdk,1,'uniform',mean(y),0,max_y*2,opts);
       else
           setup_prior(sdk,1,'uniform',mean(y),min_y-spread,max_y+spread,opts);
       end
       setup_prior(sdk,2,'uniform',spread,0,2*spread,opts);
       setup_prior(sdk,3,'uniform',90,0,180,opts);
       setup_prior(sdk,4,'uniform',min_x_diff,min_x_diff/2,90,opts);
   case 'direction_selective_circular_gaussian'
       TCModelUtils.configureTCFunc(sdk, 'DirectionSelectiveCircularGaussian');
       setup_prior(sdk,1,'uniform',5,0,100,opts);
       setup_prior(sdk,2,'uniform',5,0,100,opts);
       setup_prior(sdk,3,'uniform',90,0,180,opts);
       setup_prior(sdk,4,'uniform',min_x_diff,min_x_diff/2,90,opts);
       setup_prior(sdk,5,'uniform',5,0,100,opts);
       collect_p5 = 1;
   case 'sigmoid'
       TCModelUtils.configureTCFunc(sdk, 'Sigmoid');
       setup_prior(sdk, 1,'uniform',0,-10,10,opts);
       %setup_prior(sdk, 2,'normal',5,0,100,opts);
       setup_prior(sdk, 2,'uniform',0,-10,10,opts);
       setup_prior(sdk, 3,'uniform',0,-10,10,opts);
       setup_prior(sdk, 4,'uniform',0,-10,30,opts);
   case 'velocity_tuning_1'
       TCModelUtils.configureTCFunc(sdk, 'VelocityTuning1');
       TCModelUtils.setupParameterWithUniformPrior(sdk,1,.1,0,1);
       TCModelUtils.setupParameterWithUniformPrior(sdk,2,.1,0,1);
       TCModelUtils.setupParameterWithUniformPrior(sdk,3,-1,-5,0);
       TCModelUtils.setupParameterWithUniformPrior(sdk,4, 1,0,5);
       TCModelUtils.setupParameterWithUniformPrior(sdk,5,.5,.25,2);
       collect_p5 = 1;
   case 'rectifiedcosine'
%        rectifiedCosine(double x, double b, double a, double x0, double c)
%        keyboard
       TCModelUtils.configureTCFunc(sdk, 'RectifiedCosine');
       TCModelUtils.setupParameterWithUniformPrior(sdk,1,mean(y),min_y-spread,max_y+spread);
       TCModelUtils.setupParameterWithUniformPrior(sdk,2,spread,0,2*spread);
       TCModelUtils.setupParameterWithUniformPrior(sdk,3,pi,0,2*pi);
       TCModelUtils.setupParameterWithUniformPrior(sdk,4,1,0.9,1.1);
%        setup_prior(sdk,1,'uniform',mean(y),min_y-spread,max_y+spread,opts);
%        setup_prior(sdk,2,'uniform',spread,0,2*spread,opts);
%        setup_prior(sdk,3,'uniform',90,0,180,opts);
%        setup_prior(sdk,4,'uniform',1,1,1,opts); % freq
   case 'positivecosine'
%        rectifiedCosine(double x, double b, double a, double x0, double c)
%        keyboard
       TCModelUtils.configureTCFunc(sdk, 'PositiveCosine');
       TCModelUtils.setupParameterWithUniformPrior(sdk,1,mean(y),max(min_y-spread,0.001),max_y+spread);
       if (mean(y)-spread/2)>0
           TCModelUtils.setupParameterWithUniformPrior(sdk,2,spread/2,0,2*spread);
       else
           TCModelUtils.setupParameterWithUniformPrior(sdk,2,mean(y),0,2*spread);
       end
       TCModelUtils.setupParameterWithUniformPrior(sdk,3,pi,0,2*pi);
       TCModelUtils.setupParameterWithUniformPrior(sdk,4,1,0.999,1.001);
%        setup_prior(sdk,1,'uniform',mean(y),min_y-spread,max_y+spread,opts);
%        setup_prior(sdk,2,'uniform',spread,0,2*spread,opts);
%        setup_prior(sdk,3,'uniform',90,0,180,opts);
%        setup_prior(sdk,4,'uniform',1,1,1,opts); % freq
   otherwise
       error(['The TC function ',tc_func_name,' is not recognized']);
end

% Add data to the model
TCModelUtils.addData(sdk, x, y);

% Perform burnin and sampling
burninEngine = WalkUtils.burninWalk(sdk, opts.burnin_samples);
disp('Burnin');
burninEngine.go();
sdk=burninEngine.getSDK();

observer = WalkUtils.attachObserver(sdk, opts.sample_period);
samplingEngine = WalkUtils.samplingWalk(sdk, opts.num_samples);
disp('Sampling');
samplingEngine.go();
sdk=samplingEngine.getSDK();

% Collect samples and statistics

S.P1=WalkUtils.getP1Values(observer);
lo=round(length(S.P1)*.025);
hi=round(length(S.P1)*.975);
S.P1_median=median(S.P1);
P1sort=sort(S.P1);
S.P1_CI=[P1sort(lo) P1sort(hi)];

S.P2=WalkUtils.getP2Values(observer);
S.P2_median=median(S.P2);
P2sort=sort(S.P2);
S.P2_CI=[P2sort(lo) P2sort(hi)];

S.P3=WalkUtils.getP3Values(observer);
S.P3_median=median(S.P3);
P3sort=sort(S.P3);
S.P3_CI=[P3sort(lo) P3sort(hi)];

S.P4=WalkUtils.getP4Values(observer);
S.P4_median=median(S.P4);
P4sort=sort(S.P4);
S.P4_CI=[P4sort(lo) P4sort(hi)];

if collect_p5
   S.P5=WalkUtils.getP5Values(observer);
   S.P5_median=median(S.P5);
   P5sort=sort(S.P5);
   S.P5_CI=[P5sort(lo) P5sort(hi)];
end

if collect_p_llhds
   S.PLlhd=WalkUtils.getPLlhdValues(observer);
   S.PLlhd_median=median(S.PLlhd);
   PLlhdsort=sort(S.PLlhd);
   S.PLlhd_CI=[PLlhdsort(lo) PLlhdsort(hi)];
end

S.log_prior=WalkUtils.getPriorValues(observer);
S.log_llhd=WalkUtils.getLlhdValues(observer);
S.log_post=S.log_prior+S.log_llhd;

   function setup_prior(sdk, paramnum, priortype, initval, hp1, hp2, opts)

   fid=fopen('import_list.txt');
   temp=textscan(fid,'%s');
   fclose(fid);
   temp=temp{1};
   import_list={};
   for i=1:length(temp)
       import(temp{i});
   end

   if isfield(opts,'prior')
       if paramnum <= length(opts.prior) & ~isempty(opts.prior(paramnum).type)
           priortype=opts.prior(paramnum).type;
           hp1=opts.prior(paramnum).hp1;
           hp2=opts.prior(paramnum).hp2;
           initval=opts.prior(paramnum).initval;
           disp(['Param ',num2str(paramnum),' using ',priortype,' prior']);
       end
   end

   switch priortype
       case 'uniform'
           TCModelUtils.setupParameterWithUniformPrior(sdk,paramnum,initval,hp1,hp2);
       case 'normal'
           TCModelUtils.setupParameterWithNormalPrior(sdk,paramnum,initval,hp1,hp2);

   end