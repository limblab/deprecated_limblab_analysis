%
% Elucidate contribution of each neural channel to each of the PCs
%

function [pc_weights_across_tasks, participation_index] = neuron_contribution_to_pcs( dim_red_FR, varargin )


% get all combinations of tasks, dimensionality of the space and nbr of
% tasks
comb_tasks                      = nchoosek(1:length(dim_red_FR),2);
nbr_comb_tasks                  = size(comb_tasks,1);
nbr_dims                        = length(dim_red_FR{1}.eigen);
nbr_tasks                       = length(dim_red_FR);


% read inputs

% check if the user has passed the closest eigenvectors, in the format
% given by find_closest_hyperplane.m
if nargin >= 2 && ~isempty(varargin{1})
    closest_eigenv              = varargin{1};
% if not, the function will just order them based on the eigenvals
else
    closest_eigenv              = cell(length(dim_red_FR));
    aux_closest_eigenv          = zeros(nbr_dims,2);
    aux_closest_eigenv(:,1)     = 1:nbr_dims;
    aux_closest_eigenv(:,2)     = 1:nbr_dims;
    for i = 1:nbr_comb_tasks
        closest_eigenv{comb_tasks(i,1),comb_tasks(i,2)} = aux_closest_eigenv;
    end
    clear aux_closest_eigenv;
    
    plot_yn                     = false;
end

if nargin == 3
    plot_yn                     = varargin{2};
end


% ------------------------------------------------------------------------
% 1. calculate the distance between eigenvectors in Euclidean space for
% each combination of tasks

dist_eigenv                     = cell(length(dim_red_FR));

% calculate distance between weights assigned to each neural channel for each
% pair of tasks
for i = 1:size(comb_tasks,1)
    for j = 1:size(dim_red_FR{1}.w,1)
        eigenv_1                = dim_red_FR{comb_tasks(i,1)}.w(:,j);
        eigenv_2                = dim_red_FR{comb_tasks(i,2)}.w(:,...
                                    closest_eigenv{comb_tasks(i,1),...
                                    comb_tasks(i,2)}(j,2));
        aux_dist                = norm(eigenv_1-eigenv_2,2);
        dist_eigenv{comb_tasks(i,1),comb_tasks(i,2)}(j) = aux_dist;
    end
end

clear aux_dist;


% ------------------------------------------------------------------------
% 2. calculate mean and SD of the PC weight for each neuron

% mean_ and SD_eigenv_weights has dimensions N x D where N is the number
% of neurons and D the number of dimensions
mean_eigenv_weights             = zeros(nbr_dims,nbr_dims);
std_eigenv_weights              = zeros(nbr_dims,nbr_dims);
for n = 1:nbr_dims
    % get the weights of neural channel 'd' onto each eigenvector
    aux_weights                 = cellfun(@(x) x.w(n,:),dim_red_FR,...
                                    'UniformOutput',false);
    aux_weights_mtrx            = cell2mat(aux_weights');
    % take the absolute value of the weights
    aux_weights_mtrx            = abs(aux_weights_mtrx);
    % compute the mean and SD
    mean_eigenv_weights(n,:)    = mean(aux_weights_mtrx);
    std_eigenv_weights(n,:)     = std(aux_weights_mtrx);
end



% ------------------------------------------------------------------------
% 3. "Participation index"

% Weight of each neuron on each eigenvector, divided by the sum of the
% weights of all neurons to that eigenvector, and weighed by the eigenvalue
% associated to that eigenvector

% cell to store results
participation_index             = cell(1,length(dim_red_FR));

% matrix to temporarily store participation index
particp_indx_array              = zeros(nbr_dims);
for t = 1:nbr_tasks
   for n = 1:nbr_dims
       sum_weights              = sum(abs(dim_red_FR{t}.w(:,n)));
       for c = 1:nbr_dims
           particp_indx_array(c,n) = abs(dim_red_FR{t}.w(c,n))...
               /sum_weights * dim_red_FR{t}.eigen(n);
       end
   end
   participation_index{t}.data  = particp_indx_array;
   clear particp_indx_array;
end

% Cumulative version: sum along the all the dimensions, so we'll get a
% single number that is the sum of the contribution of neuron to each
% eigenvector weighed by the eigenvalue
for t = 1:nbr_tasks
    participation_index{t}.summed = sum(participation_index{t}.data,2);
end


% % ------------------------------------------------------------------------
% % 4. do a histogram of the distribution of weights
% nbr_dims_plot                   = 5;
% rs_plot                         = floor(sqrt(nbr_tasks));
% cs_plot                         = nbr_tasks / nbr_rows_plot;
% cols_plot                       = jet(nbr_tasks);
% 
% for e = 1:nbr_dims_plot
%     figure, hold on
%     for t = 1:nbr_tasks
%         subplot(rs_plot,cs_plot,t), histogram(dim_red_FR{t}.w(:,e),'BinWidth',0.05,...
%             'FaceColor',cols_plot(t,:))
%         set(gca,'TickDir','out'),set(gca,'FontSize',14)
%         legend(labels(t),'FontSize',14)
%         if t > (rs_plot-1)*cs_plot
%             xlabel('eigenv weight','FontSize',14)
%         end
%         if mod(t,cs_plot+1) == 0 || t == 1
%             ylabel('counts','FontSize',14)
%         end
%         if t == 1
%             title(['eigenvector ' num2str(e)])
%         end
%     end
% end

% return variables
pc_weights_across_tasks.mean_eigenv_weights     = mean_eigenv_weights;
pc_weights_across_tasks.std_eigenv_weights      = std_eigenv_weights;
pc_weights_across_tasks.dist_eigenv             = dist_eigenv;


% ------------------------------------------------------------------------
% PLOTS

if plot_yn

% plot mean and SD of the eigenv weights
figure('units','normalized','outerposition',[0 1/6 1 2/3])
subplot(121),
imagesc(1:nbr_dims,1:nbr_dims,mean_eigenv_weights)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
ylabel('neural ch','FontSize',14)
xlabel('eigenv nbr','FontSize',14)
title('mean weight')
colorbar;
subplot(122),
imagesc(1:nbr_dims,1:nbr_dims,std_eigenv_weights)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
ylabel('neural ch','FontSize',14)
xlabel('eigenv nbr','FontSize',14)
title('SD weight')
colorbar;
 
% % scatter plot of the weights assigned to each neuron for each eigenvector
% % and pair of tasks 
% 
% cols_plot                       = jet(nbr_tasks-1);
% 
% for e = 1:nbr_dims_plot
%     figure, hold on
%     for i = 2:nbr_tasks
%         plot(dim_red_FR{1}.w(:,e),dim_red_FR{i}.w(:,...
%             closest_eigenv{1,i}(e,2)),'o','color',cols_plot(i-1,:));
%     end
%     set(gca,'TickDir','out'),set(gca,'FontSize',14)
%     xlabel(['weights ' labels{1}]), ylabel('weights other tasks')
%     title(['eigenvector ' num2str(e)])
%     legend(labels(2:4),'FontSize',14)
% end


% % plot the weight for each neuron for each dimension, for each task
% neural_ch                     = 1;
%
% figure,
% hold on
% for i = 1:nbr_tasks
%     plot(abs(dim_red_FR{i}.w(neural_ch,:)),'LineWidth',2,'Color',cols_plot(i,:)); 
% end
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% xlabel('dimenion nbr','FontSize',14)
% ylabel('weight','FontSize',14)
% legend(labels,'FontSize',14)

end