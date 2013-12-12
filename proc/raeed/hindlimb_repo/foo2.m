% foo2

global activity_unc;
global activity_con;
global asg rsg;
global segments;

plotflag = true;

%% First, set up our neurons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rand('state', 692006);
% randn('state', 692006);
% neurons = random('Normal', 0, 1, 100, 8);
% rng('default')
% neurons = random('Uniform', 0, 10, 100, 8);

% neurons(1,:) = [0 0 0 0 10 0 0 0];

%% %%%%
% Get endpoint positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_positions = 100;

mtp = mp(:,segments(end,end));

[a,r]=cart2pol(mtp(1), mtp(2));

% get polar points
rs = linspace(-4,-0.5,10) + r;
%rs = r;
as = pi/16 * linspace(-2,4,10) + a;
%as = a;

[rsg, asg] = meshgrid(rs, as);
polpoints = [reshape(rsg,[1,num_positions]); reshape(asg,[1,num_positions])];

[x, y] = pol2cart(polpoints(2,:), polpoints(1,:));
endpoint_positions = [x;y] + repmat(mp(:,1),1,num_positions); % offset by the point where the hip is rotating


%% %%%%%%%%%%%
% Find kinematics of limb in endpoint positions
%%%%%%%%%%%
[joint_angles,muscle_lengths,scaled_lengths] = find_kinematics(endpoint_positions,plotflag);
joint_angles_unc = joint_angles{1};
joint_angles_con = joint_angles{2};
muscle_lengths_unc = muscle_lengths{1};
muscle_lengths_con = muscle_lengths{2};
scaled_lengths_unc = scaled_lengths{1};
scaled_lengths_con = scaled_lengths{2};

% calculate neural activity
num_sec = 4;
activity_unc = get_activity(neurons,scaled_lengths_unc,num_sec);
activity_con = get_activity(neurons,scaled_lengths_con,num_sec);

%% %%%%%%%%%%%%%%%%%%%%
% Calculate change in mean firing rates
%%%%%%%%%%%%%%%%%%%%%%%%%

yc = [];
yu = [];

residuals_con = [];
residuals_unc = [];

VAF_con = [];
VAF_unc = [];
VAF_cart_con = [];
VAF_cart_unc = [];

zerod_ep = endpoint_positions' - repmat(mean(endpoint_positions'),length(endpoint_positions'),1);

Y = [ones(length(zerod_ep),1) zerod_ep];

x1 = reshape(rsg, 1, num_positions);
x2 = reshape(asg, 1, num_positions);
X = [ones(size(x1'))  x1'  x2'];

pol_fit_con = cell(length(neurons),1);
pol_fit_unc = cell(length(neurons),1);
cart_fit_con = cell(length(neurons),1);
cart_fit_unc = cell(length(neurons),1);
joint_fit_con = cell(length(neurons),1);
joint_fit_unc = cell(length(neurons),1);

pol_fit_full = cell(length(neurons),1);

for i=1:length(neurons)
    ac = activity_con(i,:)';
    au = activity_unc(i,:)';
    
    pol_fit_con{i} = LinearModel.fit([x1' x2'],ac);
    pol_fit_unc{i} = LinearModel.fit([x1' x2'],au);
    
    pol_fit_full{i} = LinearModel.fit([x1' x2' zeros(num_positions,3); x1' x2' ones(num_positions,1) x1' x2'],[au;ac]);
    
    cart_fit_con{i} = LinearModel.fit(zerod_ep,ac);
    cart_fit_unc{i} = LinearModel.fit(zerod_ep,au);
    
    temp_c = cart_fit_con{i}.Coefficients.Estimate;
    temp_u = cart_fit_unc{i}.Coefficients.Estimate;
    yc = [yc temp_c];
    yu = [yu temp_u];
    
    VAF_con = [VAF_con pol_fit_con{i}.Rsquared.Ordinary];
    VAF_unc = [VAF_unc pol_fit_unc{i}.Rsquared.Ordinary];
    VAF_cart_con = [VAF_cart_con cart_fit_con{i}.Rsquared.Ordinary];
    VAF_cart_unc = [VAF_cart_unc cart_fit_unc{i}.Rsquared.Ordinary];
    
    % do joint regressions
    joint_fit_con{i} = LinearModel.stepwise(joint_angles_con,ac,'linear', 'upper', 'linear', 'PRemove', 0.1, 'PEnter', 0.01);
    joint_fit_unc{i} = LinearModel.stepwise(joint_angles_unc,au,'linear', 'upper', 'linear', 'PRemove', 0.1, 'PEnter', 0.01);
    
    % check if they're the same
%     joint_comp = strcmp(joint_fit_con{i}.PredictorNames,joint_fit_unc{i}.PredictorNames);
%     joint_same(i) = (sum(joint_comp)/length(joint_comp) == 1);
end

% Get t-stat
% sterr = std([ac;au]);
% %usterr = std(au)./sqrt(100);
% t_stat = max( abs(cc-uu)/sterr );
% 
% %paired t-test

%% Do a one way ANOVA of each neuron
p_annova = check_tuning(activity_unc);

%% Get t-statistic for change across conditions (max change of coefficients)
[tStat_neuron,pVal_neuron] = find_extrinsic_stats(pol_fit_full);

% figure out how many just change in baseline
% Get t-statistic for change across conditions (max change of coefficients)
% baseline_change_idx = [];
% for i = 1:length(pol_fit_full)
%     pVal = pol_fit_full{i}.Coefficients.pValue(4:end);
%     if(pVal(1)<0.01 && pVal
% end

%% Get prefered directions
ycpd = atan2(yc(3,:),yc(2,:));
yupd = atan2(yu(3,:),yu(2,:));

cosdthetay = cos(ycpd-yupd);


%% %%%%%%%%%%% Draw plots of leg positions in joint space
if(plotflag)
    figure
    plot3(joint_angles_unc(:,1)', joint_angles_unc(:,2)', joint_angles_unc(:,3)', 'bo');
    axis square; grid on;
    % axis([0 1.5 0 1.5 0 1]);
    %axis([-1.5 1.5 -1.5 1.5 0 3]);
    view([-60 40]);
    xlabel('hip');
    ylabel('knee');
    zlabel('ankle');
    title('Unconstrained')

    figure
    plot3(joint_angles_con(:,1)', joint_angles_con(:,2)', joint_angles_con(:,3)', 'bo');
    axis square; grid on;
    % axis([0 1.5 0 1.5 0 1]);
    %axis([-1.5 1.5 -1.5 1.5 0 3]);
    view([-60 40]);
    xlabel('hip');
    ylabel('knee');
    zlabel('ankle');
    title('Constrained')

    disp('unc corrcoef')
    corrcoef(joint_angles_unc)

    disp('con corrcoef')
    corrcoef(joint_angles_con)

    %% display R^2 and preferred direcction shift plot
    figure
    plot3(VAF_unc,VAF_con, cosdthetay, '.')
    grid on
    xlabel('unconstrained')
    ylabel 'constrained'
    zlabel 'cosdthetay'
    axis([0 1 0 1 -1 1])
end