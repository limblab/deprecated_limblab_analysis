%
% Find the eigenvectors in task 2 that are most similar (smallest angle) to
% certain eigenvectors in task 1 (orig).
%
%   function [angle, dim_min_angle] = find_closest_hyperplane( eigenv_orig, ...
%                                       eigenv_2, dims_hyper_in_orig )
%
% Inputs:
%   eigenv_orig             : matrix with eigenvectors defining the
%                               original hyperspace (in columns)
%   eigenv_2                : matrix with the eigenvectors you want to
%                               match (find smallest angle)
%   dims_hyper_in_orig      : the dimensions in the original space you want
%                               to match (scalar or matrix). Do 'all' for
%                               all the eigenvectors
%
% Outputs:
%   angle                   : the angle (rad) between the most similar
%                               eigenvector and the original eigenvector  
%   dim_min_angle           : the dimension which eigenvector minimizes the
%                               angle with the original eigenvector 
%

function [angle, dim_min_angle] = find_closest_hyperplane( eigenv_orig, eigenv_2, dims_hyper_in_orig )


% read inputs
if ischar(dims_hyper_in_orig)
    if strcmp(dims_hyper_in_orig,'all')
        nbr_dims_hyper_in_orig = size(eigenv_orig,1);
        dims_hyper_in_orig  = 1:nbr_dims_hyper_in_orig;
    end
else
    nbr_dims_hyper_in_orig  = length(dims_hyper_in_orig);
end

nbr_dims_orig       = size(eigenv_orig,1);


% preallocate matrices
all_angles              = zeros(nbr_dims_orig,nbr_dims_hyper_in_orig);
dim_min_angle           = zeros(1,nbr_dims_hyper_in_orig);
angle                   = zeros(1,nbr_dims_hyper_in_orig);

% do for each of the eigenv_orig
for i = 1:nbr_dims_hyper_in_orig
    % calculate angles between each of the eigenv_2 and the eigenv_orig we
    % are looking at
    for ii = 1:nbr_dims_orig
        all_angles(ii,i) = subspace(eigenv_2(:,ii),eigenv_orig(:,...
                            dims_hyper_in_orig(i)));
    end
end

% find the eigenv_2 that forms the minimum angle with each of the
% eigenv_orig 
for i = 1:nbr_dims_hyper_in_orig
    [angle(i), dim_min_angle(i)] = min(all_angles(:,i));
end