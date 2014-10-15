function [P, vaf_P, fixed_params] = plot_optim_lambda_results(iter_params,vaf)

% plot_optim_lambda_results
% typically, iter_params are [L1 L2 L3 LR];

p_i  = 2;% index of the parameter in iter_params to plo on x axis
p1_i = 3;
p2_i = 4;

% parameter on x axis
P = unique(iter_params(:,p_i));
% fixed parameters for each curve:
P1 = unique(iter_params(:,p1_i));
P2 = unique(iter_params(:,p2_i));
% emgs idex in vaf matrix
emg_vec = 1:9;


% % % colors
% % cm = colormap;
% % num_groups = length(P);
% % line_colors = cm((0:num_groups-1)*(size(cm,1)/num_groups)+1,:);


fixed_params = [];

for p1 = 1:length(P1)
    for p2 = 1:length(P2)
        fixed_params = [fixed_params; P1(p1) P2(p2)];
    end
end

figure;
vaf_P = nan(length(P),length(P1)*length(P2));
for p = 1:length(P)
    for i = 1:length(P1)*length(P2)
         tmp_vaf = mean(vaf(  iter_params(:,p_i)== P(p) & ...
                                iter_params(:,p1_i)==fixed_params(i,1) & ...
                                iter_params(:,p2_i)==fixed_params(i,2) , emg_vec),2)';
        if ~isempty(tmp_vaf)                   
            vaf_P(p,i) = tmp_vaf;
        end
    end
end

plot(P,vaf_P);
