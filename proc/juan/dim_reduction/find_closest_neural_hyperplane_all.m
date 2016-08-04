%
% Wrapper function to find the closest dimensions across tasks.
%
%   function [angle, dim_min_angle] = find_closest_hyperplane_all( dim_red_FR, dims_hyper_in_orig )
%
% Inputs (opt):         : [default]
%   dim_red_FR          : array of PCA-processed FRs
%   dims_hyper_in_orig  : the dimensions in the original space you want
%                           to match (scalar or matrix). Do 'all' for
%                           all the eigenvectors
%   (labels)            : [''] labels that define each task. If passed, it
%                           will plot the relative order of the pairs of
%                           most similar eigenvectors for all pairs of
%                           tasks
%   (reverse_yn)    : [false] instead of looking for the invectors in task
%                       i+p that are closest to the eigenvectors in task i
%                       (i = 1:nbr. of tasks), look for the eigenvectors in
%                       task i that are closest to the eigenvectors in task
%                       i+p. The core of the idea is to do both and compare
%
%   
% Outpus:
%   angle               : cell array with the angle between hyperspaces. It
%                           has dimension nbr-of-taks-by-nbr-of-tasks (dim_red_FR) 
%   dim_min_angle       : cell array with the eigenvector in hyperspace #2
%                           that minimize the angle with eigenvectors in
%                           the original hyperspace 
%   diff_ranking        : metric that quantifies the difference in
%                           eigenvector across hyperspaces
%   

function [angle, dim_min_angle, diff_ranking] = find_closest_neural_hyperplane_all( ...
                    dim_red_FR, dims_hyper_in_orig, varargin )


% read inputs
if nargin >= 3
    labels          = varargin{1};
end

if nargin == 4
    reverse_yn      = varargin{2};
else
    reverse_yn      = false;
end


nbr_bdfs            = length(dim_red_FR);

% matrix with all possible pairs of tasks
comb_bdfs           = nchoosek(1:nbr_bdfs,2);

% reverse, if specified
if reverse_yn
    comb_bdfs       = fliplr(comb_bdfs);
end

nbr_comb_bdfs       = size(comb_bdfs,1);

% define cells for storing the results
angle               = cell(nbr_bdfs);
dim_min_angle       = cell(nbr_bdfs);


% Look for the closest hyperplane
for i = 1:nbr_comb_bdfs
    [ang, dim_m_ang] = find_closest_hyperplane( dim_red_FR{comb_bdfs(i,1)}.w, ...
                            dim_red_FR{comb_bdfs(i,2)}.w, dims_hyper_in_orig );
    
    % store values in return cells 
    angle{comb_bdfs(i,1),comb_bdfs(i,2)} = ang;
    % for the eigenvector that defines the minimum angle also include the
    % eigevenctors in the original space
    dim_min_angle{comb_bdfs(i,1),comb_bdfs(i,2)} = [dims_hyper_in_orig; dim_m_ang]';
end


% -------------------------------------------------------------------------

% check that the same eigenvector in task 2 hasn't been found to be closest
% to two or more different eigenvectors in task 1
for i = 1:nbr_comb_bdfs
    if numel(unique(dim_min_angle{comb_bdfs(i,1),comb_bdfs(i,2)}(:,2))) < length(dims_hyper_in_orig)
        warning(['repeated closest eigevenctors when comparing tasks ' ...
                num2str(comb_bdfs(i,1)) ' and ' num2str(comb_bdfs(i,2))]);
    end
end


% -------------------------------------------------------------------------

% now estimate how similar is the ranking of the PCs across tasks
% this code estimates the "distance" as the sum of the absolute difference
% in ranking, divided by the number of dimensions we look at
diff_ranking            = zeros(1,nbr_comb_bdfs);
for i = 1:nbr_comb_bdfs
    diff_ranking(i)     = sum( abs( dim_min_angle{comb_bdfs(i,1),comb_bdfs(i,2)}(:,2) - ...
                            dim_min_angle{comb_bdfs(i,1),comb_bdfs(i,2)}(:,1) ) );
end

% -------------------------------------------------------------------------

if exist('labels','var')
    clrs_plot           = jet(size(comb_bdfs,1));

    legends_plot        = cell(size(comb_bdfs,1),1);
    for i = 1:size(legends_plot,1)
        legends_plot{i} = [labels{comb_bdfs(i,1)} ' vs. ' labels{comb_bdfs(i,2)}];
    end

    figure('units','normalized','outerposition',[1/3 1/3 2/3 2/3]),
    subplot(121),hold on
    for i = 1:nbr_comb_bdfs
        plot(dim_min_angle{comb_bdfs(i,1),comb_bdfs(i,2)}(:,1), ...
            dim_min_angle{comb_bdfs(i,1),comb_bdfs(i,2)}(:,2),'color',clrs_plot(i,:),...
            'linewidth',2);
    end
    plot([0 dims_hyper_in_orig(end)+1],[0 dims_hyper_in_orig(end)+1],'.-','color',[0.6 0.6 0.6])
    set(gca,'TickDir','out'),set(gca,'FontSize',14),
    xlim([0 dims_hyper_in_orig(end)+1]),ylim([0 dims_hyper_in_orig(end)+1])
    xlabel('eigenvector in task 1'),ylabel('closest eigenvector in task 2')
    legend(legends_plot,'Location','northwest','FontSize',14)
    
    subplot(122),hold on
    for i = 1:nbr_comb_bdfs
        bar(i,diff_ranking(i),'FaceColor',clrs_plot(i,:))
    end
    set(gca,'TickDir','out'),set(gca,'FontSize',14),
    xlim([0 nbr_comb_bdfs+1])
    ylabel('ranking difference across tasks')
    set(gca,'XTick',1:nbr_comb_bdfs) 
    set(gca,'XTickLabels',legends_plot)
    set(gca,'XTickLabelRotation',45)
end
