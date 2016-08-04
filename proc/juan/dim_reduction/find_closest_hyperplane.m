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
%   (no_warn)               : [true] don't give warnings if the closest
%                               eigenvector for eigenvector P was also the
%                               closest for dimension N with N < P
%                               (dimensions ranked according to their
%                               eigenvals)  
%
% Outputs:
%   angle                   : the angle (rad) between the most similar
%                               eigenvector and the original eigenvector  
%   dim_min_angle           : the dimension which eigenvector minimizes the
%                               angle with the original eigenvector 
%

function [angle, dim_min_angle] = find_closest_hyperplane( eigenv_orig, eigenv_2, dims_hyper_in_orig, varargin )


% read inputs

% which dimensions are we looking at?
if ischar(dims_hyper_in_orig)
    if strcmp(dims_hyper_in_orig,'all')
        nbr_dims_hyper_in_orig = size(eigenv_orig,1);
        dims_hyper_in_orig  = 1:nbr_dims_hyper_in_orig;
    end
else
    nbr_dims_hyper_in_orig  = length(dims_hyper_in_orig);
end

% set warning for repeated closest eigenvectors
no_warn             = true;
if nargin == 4
    no_warn         = varargin{1};
end


% changed from size(eigenv_orig,1) to size(eigenv_orig,2) so it works with
% hyperplanes in hyperspaces, not only with entire hyperspaces 
nbr_dims_orig       = size(eigenv_orig,2);


% preallocate matrices for storing intermediate and final results
all_angles          = zeros(nbr_dims_orig,nbr_dims_hyper_in_orig);
dim_min_angle       = zeros(1,nbr_dims_hyper_in_orig);
angle               = zeros(1,nbr_dims_hyper_in_orig);


% calculate the angles between eigenv to find the closest ones
for i = 1:nbr_dims_hyper_in_orig
    % calculate angles between each of the eigenv_2 and the eigenv_orig we
    % are looking at
    for ii = 1:nbr_dims_orig
        all_angles(ii,i) = subspace(eigenv_2(:,ii),eigenv_orig(:,...
                            dims_hyper_in_orig(i)));
    end
end


% find the eigenv_2 that forms the minimum angle with each of the
% eigenv_orig, making sure it will be unique, i.e. that it won't be the
% same as for a higher order dimension

% flag for the search
look_flag               = true;

for i = 1:nbr_dims_hyper_in_orig
    % do until we find a unique closest eigenvector
    while look_flag
        [ang, dim_min]  = min(all_angles(:,i));

        if ~isempty(find(dim_min_angle==dim_min,1))
            if ~no_warn
                warning(['the closest eigevenctor to eigenvector ' ...
                    num2str(dims_hyper_in_orig(i)) ...
                    ' already was the closest to a higher order '...
                    'eigenvector --the second closest will be taken']);
            end
            % dirty fix: make the minimum angle that had already been
            % chosen as closest eigenvector to a higher order one
            % orthogonal, and look for the next closest eigevenctor
            all_angles(dim_min,i) = pi;
        else
            look_flag   = false;
        end
    end
    
    angle(i)            = ang;
    dim_min_angle(i)    = dim_min;
    
    look_flag           = true;
end