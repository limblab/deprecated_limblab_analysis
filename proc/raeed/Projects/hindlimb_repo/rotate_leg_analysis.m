%% %%%%%%%%%%%%%%%%%%%%
% Find Cartesian fits from rotating 13 deg forwards and backwards
%%%%%%%%%%%%%%%%%%%%%%%%%

y_forw = [];
y_back = [];

VAF_cart_forw = [];
VAF_cart_back = [];

rotation = 13/180*pi;

endpoint_zero = mean(endpoint_positions,2)';
[pol_th,pol_r] = cart2pol(endpoint_zero(1),endpoint_zero(2));
[endpoint_zero_forw(1),endpoint_zero_forw(2)] = pol2cart(pol_th+rotation,pol_r);
[endpoint_zero_back(1),endpoint_zero_back(2)] = pol2cart(pol_th-rotation,pol_r);

zerod_ep_forw = endpoint_positions' - repmat(endpoint_zero_forw,length(endpoint_positions'),1);
zerod_ep_back = endpoint_positions' - repmat(endpoint_zero_back,length(endpoint_positions'),1);

Y_forw = [ones(length(zerod_ep_forw),1) zerod_ep_forw];
Y_back = [ones(length(zerod_ep_back),1) zerod_ep_back];

cart_fit_forw = cell(length(neurons),1);
cart_fit_back = cell(length(neurons),1);

for i=1:length(neurons)
    au = activity_unc(i,:)';
    
    cart_fit_forw{i} = LinearModel.fit(zerod_ep_forw,au);
    cart_fit_back{i} = LinearModel.fit(zerod_ep_back,au);
    
    temp_forw = cart_fit_forw{i}.Coefficients.Estimate;
    temp_back = cart_fit_back{i}.Coefficients.Estimate;
    y_forw = [y_forw temp_forw];
    y_back = [y_back temp_back];
    
    VAF_cart_forw = [VAF_cart_forw cart_fit_forw{i}.Rsquared.Ordinary];
    VAF_cart_back = [VAF_cart_back cart_fit_back{i}.Rsquared.Ordinary];
end

y_forw_pd = atan2(y_forw(3,:),y_forw(2,:));
y_back_pd = atan2(y_back(3,:),y_back(2,:));

%% Find change in PDs

figure;
hist(y_forw_pd-yupd)
