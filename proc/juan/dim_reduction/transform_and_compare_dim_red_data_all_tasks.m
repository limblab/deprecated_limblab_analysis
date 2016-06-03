%
%   comp_nbr                : 1-D vector with the components that will be
%                               compared, or,
%                             2-D vector that established which transformed
%                             dimensions in 'within' will be compared to
%                             which dimensions in 'across'

function pc_proj_across_tasks = transform_and_compare_dim_red_data_all_tasks( dim_red_FR, ...
                    smoothed_FR, labels, neural_chs, comp_nbr, mode, varargin )
    
                
% read inputs
plot_yn                 = true;
if nargin == 7
    plot_yn             = varargin{1};
end
                
                
% number of tasks
nbr_bdfs                = length(dim_red_FR);
% number of total dimenions in the space (neural chs)
nbr_dims_space          = length(dim_red_FR{1}.eigen);

% possibnle combinations of tasks
comb_bdfs               = nchoosek(1:nbr_bdfs,2);
nbr_comb_bdfs           = size(comb_bdfs,1);


for i = 1:nbr_comb_bdfs
    
    bdf_1               = comb_bdfs(i,1);
    bdf_2               = comb_bdfs(i,2);
    
    switch mode
        
        case 'ranking'
            pc_proj_across_tasks(i) = transform_and_compare_dim_red_data( dim_red_FR, ...
                            smoothed_FR, labels, neural_chs, bdf_1, ...
                            bdf_2, comp_nbr );
             
        case 'min_angle'
            [~, dim_min_angle] = find_closest_hyperplane( dim_red_FR{bdf_1}.w, ...
                            dim_red_FR{bdf_2}.w, 1:nbr_dims_space );
            
            % 2-D matrix with dimensions in original space, and matching
            % dimensions in the second space
            eigenv_pairs                        = [1:nbr_dims_space;dim_min_angle];
            
            % truncate to the number of dimensions we want
            eigenv_pairs(:,comp_nbr+1:end)      = [];
            
            % compare within and across projections
            pc_proj_across_tasks(i) = transform_and_compare_dim_red_data( dim_red_FR, ...
                            smoothed_FR, labels, neural_chs, bdf_1, ...
                            bdf_2, eigenv_pairs', plot_yn );
               
            clear eigenv_pairs
    end
end

