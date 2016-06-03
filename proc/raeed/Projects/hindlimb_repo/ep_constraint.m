function [c,ceq] = ep_constraint(weights, endpoint_positions, scaled_lengths_unc, scaled_lengths_con)
% compute cost for the weights of one neuron
global rsg asg;

num_positions = length(endpoint_positions');

    % compute cost for the weights of one neuron
    num_sec = 1000;
    [~,activity_unc] = get_activity(weights',scaled_lengths_unc,num_sec);
    [~,activity_con] = get_activity(weights',scaled_lengths_con,num_sec);
    
    % find polar fit
    x1 = reshape(rsg, 1, num_positions);
    x2 = reshape(asg, 1, num_positions);
    
    pol_fit_full{1} = LinearModel.fit([x1' x2' zeros(num_positions,3); x1' x2' ones(num_positions,1) x1' x2'],[activity_unc';activity_con']);
    pol_fit_con = LinearModel.fit([x1' x2'],activity_con');
    pol_fit_unc = LinearModel.fit([x1' x2'],activity_unc');
    
    % find pvalues for change across constraint conditions
    [tstat,pval] = find_extrinsic_stats(pol_fit_full);
    

    % next, find change in preferred direction
%     zerod_ep = endpoint_positions' - repmat(mean(endpoint_positions'),length(endpoint_positions'),1);
%     Y = [ones(length(zerod_ep),1) zerod_ep];
% 
%     ac = activity_con';
%     au = activity_unc';
% 
%     yc = Y\ac;
%     yu = Y\au;
% 
%     % calculate SSE
%     res_con_temp = (ac-Y*yc)'*(ac-Y*yc);
%     res_unc_temp = (au-Y*yu)'*(au-Y*yu);
%     
%     % find variance accounted for
%     mean_ac = mean(ac);
%     mean_au = mean(au);
%     % find sum of squared deviations from mean
%     ss_tot_con = (ac-mean_ac)'*(ac-mean_ac);
%     ss_tot_unc = (au-mean_au)'*(au-mean_au);
    
%     r2_con = 1-res_con_temp/ss_tot_con;
%     r2_unc = 1-res_unc_temp/ss_tot_unc;

    r2_con = pol_fit_con.Rsquared.Ordinary;
    r2_unc = pol_fit_unc.Rsquared.Ordinary;

%     c = 1.6-r2_con-r2_unc;
%     c = [0.8-r2_con;0.8-r2_unc];
    c = [0.8-r2_con;0.8-r2_unc;0.01-pval];
    ceq = [];
end