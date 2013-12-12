function cost = ep_costfunc(weights, endpoint_positions, scaled_lengths_unc, scaled_lengths_con)

global rsg asg;

    num_positions = length(endpoint_positions');

    % compute cost for the weights of one neuron

    num_sec = 1000;
    [~,activity_unc] = get_activity(weights',scaled_lengths_unc,num_sec);
    [~,activity_con] = get_activity(weights',scaled_lengths_con,num_sec);
    
%     % find polar fit
%     x1 = reshape(rsg, 1, num_positions);
%     x2 = reshape(asg, 1, num_positions);
%     
%     pol_fit_full{1} = LinearModel.fit([x1' x2' zeros(num_positions,3); x1' x2' ones(num_positions,1) x1' x2'],[activity_unc';activity_con']);
% 
%     % find pvalues for change across constraint conditions
%     [tstat,pval] = find_extrinsic_stats(pol_fit_full);
    
    % next, find change in preferred direction
    zerod_ep = endpoint_positions' - repmat(mean(endpoint_positions'),length(endpoint_positions'),1);
    Y = [ones(length(zerod_ep),1) zerod_ep];

    ac = activity_con';
    au = activity_unc';

    yc = Y\ac;
    yu = Y\au;

    % get real preferred directions
    ycpd = atan2(yc(3,:),yc(2,:));
    yupd = atan2(yu(3,:),yu(3,:));

    cosdthetay = cos(ycpd-yupd);
    
    ep_cost = 1-cosdthetay;
    
    cost = sum(ep_cost);

%     cost = 1-pval+sum(ep_cost);
end