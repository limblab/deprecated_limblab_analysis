%% load neurons from old file
load('/home/raeed/Dropbox/Research/cat hindlimb/Data/sim_10000neuron_20151011.mat')

%% %%%%%%%%%%%%%%%%%%%%
% Find Cartesian fits for each half workspace
%%%%%%%%%%%%%%%%%%%%%%%%%

% get indices for each workspace
left_inds = repmat(1:5,10,1)+repmat(0:10:90,5,1)';
right_inds = repmat(6:10,10,1)+repmat(0:10:90,5,1)';
left_inds = left_inds(:);
right_inds = right_inds(:);

endpoint_zero_left = mean(endpoint_positions(:,left_inds),2)';
endpoint_zero_right = mean(endpoint_positions(:,right_inds),2)';

zerod_ep_left = endpoint_positions(:,left_inds)' - repmat(endpoint_zero_left,length(endpoint_positions(:,left_inds)'),1);
zerod_ep_right = endpoint_positions(:,right_inds)' - repmat(endpoint_zero_right,length(endpoint_positions(:,right_inds)'),1);

cart_fit_left = cell(length(neurons),1);
cart_fit_right = cell(length(neurons),1);

y_left = zeros(3,length(neurons));
y_right = zeros(3,length(neurons));

VAF_cart_left = zeros(1,length(neurons));
VAF_cart_right = zeros(1,length(neurons));

for i=1:length(neurons)
    act_left = activity_unc(i,left_inds)';
    act_right = activity_unc(i,right_inds)';
    
    cart_fit_left{i} = LinearModel.fit(zerod_ep_left,act_left);
    cart_fit_right{i} = LinearModel.fit(zerod_ep_right,act_right);
    
    temp_left = cart_fit_left{i}.Coefficients.Estimate;
    temp_right = cart_fit_right{i}.Coefficients.Estimate;
    y_left(:,i) = temp_left;
    y_right(:,i) = temp_right;
    
    VAF_cart_left(i) = cart_fit_left{i}.Rsquared.Ordinary;
    VAF_cart_right(i) = cart_fit_right{i}.Rsquared.Ordinary;
end

y_left_pd = atan2(y_left(3,:),y_left(2,:));
y_right_pd = atan2(y_right(3,:),y_right(2,:));

clear i
clear temp_*
clear act_*

%% Find change in PDs

rotation = atan2d(endpoint_zero_right(2),endpoint_zero_right(1)) - atan2d(endpoint_zero_left(2),endpoint_zero_left(1));

% Find all changes
dPD = 180/pi*remove_wrap(y_right_pd-y_left_pd);

% Find good points
VAF_cutoff = 0.4;
good_points = VAF_cart_left>VAF_cutoff & VAF_cart_right>VAF_cutoff;

figure;
hist(dPD(good_points),20)
hold on
plot(repmat(median(dPD(good_points)),2,1),get(gca,'ylim'),'c--')
plot(repmat(rotation,2,1),get(gca,'ylim'),'r-.')
plot([0 0],get(gca,'ylim'),'k-')
hold off
set(gca,'tickdir','out','box','off')
xlabel 'Change in PD'
ylabel 'Number of neurons in bin'
title 'Right - Left'

clear VAF_cutoff
clear rotation
