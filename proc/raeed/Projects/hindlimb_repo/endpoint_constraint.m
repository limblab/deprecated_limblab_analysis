function [C,Ceq] = endpoint_constraint(angles,endpoint,base_leg)
% constraint to match endpoint
legpts = get_legpts(base_leg,angles);
current_ep = legpts(:,base_leg.segment_idx(end,end));

C = [];
Ceq = sum((current_ep-endpoint).^2);