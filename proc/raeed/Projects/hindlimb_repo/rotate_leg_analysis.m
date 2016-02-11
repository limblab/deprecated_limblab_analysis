%% load neurons from old file
load('C:\Users\rhc307\Box Sync\Research\Cat hindlimb\Data\sim_10000neuron_20151011.mat','neurons');

%% %%%%
% Get endpoint positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base_leg = get_baseleg;

num_positions = 100;

mp = get_legpts(base_leg,[pi/4 -pi/4 pi/6]);
mtp = mp(:,base_leg.segment_idx(end,end));

[a_cent,r_cent]=cart2pol(mtp(1), mtp(2));

% get rotated workspace middles
rotation = 15/180*pi;
r_forw = r_cent;
r_back = r_cent;
a_forw = a_cent+rotation;
a_back = a_cent-rotation;

% get polar points
rs_cent = linspace(-4,-0.5,10) + r_cent;
rs_forw = linspace(-4,-0.5,10) + r_forw;
rs_back = linspace(-4,-0.5,10) + r_back;
%rs = r;
as_cent = pi/16 * linspace(-2,4,10) + a_cent;
as_forw = pi/16 * linspace(-2,4,10) + a_forw;
as_back = pi/16 * linspace(-2,4,10) + a_back;
%as = a;

[rsg_cent, asg_cent] = meshgrid(rs_cent, as_cent);
polpoints_cent = [reshape(rsg_cent,[1,num_positions]); reshape(asg_cent,[1,num_positions])];
[rsg_forw, asg_forw] = meshgrid(rs_forw, as_forw);
polpoints_forw = [reshape(rsg_forw,[1,num_positions]); reshape(asg_forw,[1,num_positions])];
[rsg_back, asg_back] = meshgrid(rs_back, as_back);
polpoints_back = [reshape(rsg_back,[1,num_positions]); reshape(asg_back,[1,num_positions])];

[x_cent, y_cent] = pol2cart(polpoints_cent(2,:), polpoints_cent(1,:));
endpoint_positions_cent = [x_cent;y_cent];
[x_forw, y_forw] = pol2cart(polpoints_forw(2,:), polpoints_forw(1,:));
endpoint_positions_forw = [x_forw;y_forw];
[x_back, y_back] = pol2cart(polpoints_back(2,:), polpoints_back(1,:));
endpoint_positions_back = [x_back;y_back];

clear mp
clear mtp
clear rotation
clear rs*
clear as*
clear polpoints*
clear x_*
clear y_*
clear num_positions

%% %%%%%%%%%%%
% Find kinematics of limb in endpoint positions
%%%%%%%%%%%
plotflag = true;

[~,~,scaled_lengths_cent] = find_kinematics(base_leg,endpoint_positions_cent,plotflag);
scaled_lengths_cent = scaled_lengths_cent{1};

[~,~,scaled_lengths_forw] = find_kinematics(base_leg,endpoint_positions_forw,plotflag);
scaled_lengths_forw = scaled_lengths_forw{1};

[~,~,scaled_lengths_back] = find_kinematics(base_leg,endpoint_positions_back,plotflag);
scaled_lengths_back = scaled_lengths_back{1};

% calculate neural activity
num_sec = 2;
activity_cent = get_activity(neurons,scaled_lengths_cent,num_sec);
activity_forw = get_activity(neurons,scaled_lengths_forw,num_sec);
activity_back = get_activity(neurons,scaled_lengths_back,num_sec);

clear scaled_lengths*
clear num_sec
clear plotflag

%% %%%%%%%%%%%%%%%%%%%%
% Find Cartesian fits from rotating 13 deg forwards and backwards
%%%%%%%%%%%%%%%%%%%%%%%%%

[endpoint_zero_cent(1),endpoint_zero_cent(2)] = pol2cart(a_cent,r_cent);
[endpoint_zero_forw(1),endpoint_zero_forw(2)] = pol2cart(a_forw,r_forw);
[endpoint_zero_back(1),endpoint_zero_back(2)] = pol2cart(a_back,r_back);

zerod_ep_cent = endpoint_positions_cent' - repmat(endpoint_zero_cent,length(endpoint_positions_cent'),1);
zerod_ep_forw = endpoint_positions_forw' - repmat(endpoint_zero_forw,length(endpoint_positions_forw'),1);
zerod_ep_back = endpoint_positions_back' - repmat(endpoint_zero_back,length(endpoint_positions_back'),1);

cart_fit_cent = cell(length(neurons),1);
cart_fit_forw = cell(length(neurons),1);
cart_fit_back = cell(length(neurons),1);

y_cent = zeros(3,length(neurons));
y_forw = zeros(3,length(neurons));
y_back = zeros(3,length(neurons));

VAF_cart_cent = zeros(1,length(neurons));
VAF_cart_forw = zeros(1,length(neurons));
VAF_cart_back = zeros(1,length(neurons));

for i=1:length(neurons)
    act_cent = activity_cent(i,:)';
    act_forw = activity_forw(i,:)';
    act_back = activity_back(i,:)';
    
    cart_fit_cent{i} = LinearModel.fit(zerod_ep_cent,act_cent);
    cart_fit_forw{i} = LinearModel.fit(zerod_ep_forw,act_forw);
    cart_fit_back{i} = LinearModel.fit(zerod_ep_back,act_back);
    
    temp_cent = cart_fit_cent{i}.Coefficients.Estimate;
    temp_forw = cart_fit_forw{i}.Coefficients.Estimate;
    temp_back = cart_fit_back{i}.Coefficients.Estimate;
    y_cent(:,i) = temp_cent;
    y_forw(:,i) = temp_forw;
    y_back(:,i) = temp_back;
    
    VAF_cart_cent(i) = cart_fit_cent{i}.Rsquared.Ordinary;
    VAF_cart_forw(i) = cart_fit_forw{i}.Rsquared.Ordinary;
    VAF_cart_back(i) = cart_fit_back{i}.Rsquared.Ordinary;
end

y_cent_pd = atan2(y_cent(3,:),y_cent(2,:));
y_forw_pd = atan2(y_forw(3,:),y_forw(2,:));
y_back_pd = atan2(y_back(3,:),y_back(2,:));

clear i
clear temp_*
clear act_*

%% Find change in PDs

rotation = 15;

% Find all changes
dPD_forw_back = 180/pi*remove_wrap(y_forw_pd-y_back_pd);
dPD_forw = 180/pi*remove_wrap(y_forw_pd-y_cent_pd);
dPD_back = 180/pi*remove_wrap(y_back_pd-y_cent_pd);

% Find good points
VAF_cutoff = 0.4;
good_points = VAF_cart_cent>VAF_cutoff & VAF_cart_forw>VAF_cutoff & VAF_cart_back>VAF_cutoff;

figure;
hist(dPD_forw(good_points),20)
hold on
plot(repmat(median(dPD_forw(good_points)),2,1),get(gca,'ylim'),'c--')
plot(repmat(rotation,2,1),get(gca,'ylim'),'r-.')
plot([0 0],get(gca,'ylim'),'k-')
hold off
set(gca,'tickdir','out','box','off')
xlabel 'Change in PD'
ylabel 'Number of neurons in bin'
title 'Forward - Center'

figure;
hist(dPD_back(good_points),20)
hold on
plot(repmat(median(dPD_back(good_points)),2,1),get(gca,'ylim'),'c--')
plot(repmat(-rotation,2,1),get(gca,'ylim'),'r-.')
plot([0 0],get(gca,'ylim'),'k-')
hold off
set(gca,'tickdir','out','box','off')
xlabel 'Change in PD'
ylabel 'Number of neurons in bin'
title 'Backward - Center'

figure;
hist(dPD_forw_back(good_points),20)
hold on
plot(repmat(median(dPD_forw_back(good_points)),2,1),get(gca,'ylim'),'c--')
plot(repmat(2*rotation,2,1),get(gca,'ylim'),'r-.')
plot([0 0],get(gca,'ylim'),'k-')
hold off
set(gca,'tickdir','out','box','off')
xlabel 'Change in PD'
ylabel 'Number of neurons in bin'
title 'Forward - Backward'

clear VAF_cutoff
clear rotation
