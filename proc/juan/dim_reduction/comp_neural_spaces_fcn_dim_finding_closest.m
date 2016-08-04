%
% A wrapper of comp_neural_spaces_fcn_dim that looks for the eigenvectors
% in hyperplane 2 that are closest (define the smallest angle) which each
% dimension of hyperplane 1, for dimensions 1:dims_hyper_in_orig before it
% computes the angle. By default, the function will also look for the
% eigenvectors in hyperplane 1 that are closest to each eigenvector in
% hyperplane 2, for the same dimensions, and compute the mean and SD
% angle. This is to avoid ranking according to one arbitrarily selected
% task
%
%   function [angles, dim_red_FR, smoothed_FR empir_angle_dist] = comp_neural_spaces_fcn_dim_finding_closest( ...
%           bdf, neural_chs, dims_hyper_in_orig, labels, method, varargin ) 
%
% Inputs (opt)          : [default]
%   bdf                 : struct with BDFs. Function will calculate the
%                           angle between the hyperplanes from all possible
%                           pairs of tasks
%   neural_chs          : neural channels to be used for the analysis.
%                           Relevant if the fcn has to compute the
%                           hyperplane, which is done using dim_reduction.m
%   dims_hyper_in_orig  : dimensions in hyperplane 1 that will be used to
%                           define the hyperplanes (function will compare
%                           hyperplanes with dimensionality
%                           1:dims_hyper_in_orig 
%   labels              : cell array that defines the labels for each task
%   method              : dimensionality reduction method ('pca','fa').
%                           Only used if the function has to compute them
%   (smoothed_FR)       : [] cell array of smoothed firing rates (computed 
%                           using gaussian_smoothing2.m)                            
%   (dim_red_FR)        : [] cell array of dimensionally-reduced FRs
%                           (computed using dim_reduction.m)
%   (bin_width)         : [] bin size. Only used if user doesn't pass
%                           smoothed_FR and the function has to compute
%                           them
%   (gauss_SD)          : [] SD of the Gaussian kernel used for smoothing.
%                           Only used if user doesn't pass smoothed_FR and
%                           the function has to compute them
%   (transform)         : [] 'sqrt' or 'none': transformation applied on
%                           the binned FRs. Only used if user doesn't pass
%                           smoothed_FR and the function has to compute
%                           them 
%   (resort_eigenv)     : [false] bool that tells the function to resort
%                           all pairs of eigenvectors not by the variance
%                           of the first task, but based on the angle
%                           between pairs (from smallest to largest) 
%   (last_dim)          : last dimension for resort_eigenv
%
% Outputs (opt):
%   angles              : cell array with angles between hyperplanes of
%                           dimensionality 1:dims_hyper_in_orig for all
%                           pairs of tasks
%   (dim_red_FR)        : dim_red_FR for each BDF, if the function has to
%                           compute them
%   (smoothed_FR)       : smoothed_FR, if the function has to compute them
%   (empir_angle_dist)  : empirical distributions of angles between
%                           hyperplanes, used to assess significance
%
% Usage:
%   function [angles, dim_red_FR, smoothed_FR, empir_angle_dist ] = ...
%           comp_neural_spaces_fcn_dim_finding_closest( bdf, neural_chs,...
%           dims_hyper_in_orig, labels, method ) 
%   function [angles, dim_red_FR, smoothed_FR, empir_angle_dist ] = ...
%           comp_neural_spaces_fcn_dim_finding_closest( bdf, neural_chs,...
%           dims_hyper_in_orig, labels, method, smoothed_FR)
%   function [angles, dim_red_FR, smoothed_FR, empir_angle_dist ] = ...
%           comp_neural_spaces_fcn_dim_finding_closest( bdf, neural_chs,...
%           dims_hyper_in_orig, labels, method, smoothed_FR, dim_red_FR )
%   function [angles, dim_red_FR, smoothed_FR, empir_angle_dist ] = ...
%           comp_neural_spaces_fcn_dim_finding_closest( bdf, neural_chs,...
%           dims_hyper_in_orig, labels, method, bin_width, gauss_SD, ...
%           transform )  
%   function [angles, dim_red_FR, smoothed_FR, empir_angle_dist ] = ...
%           comp_neural_spaces_fcn_dim_finding_closest( bdf, neural_chs,...
%           dims_hyper_in_orig, labels, method, smoothed_FR, dim_red_FR,
%           resort_eigenv, last_dim )  
%
%
% Notes/ToDo's:
%   - make 'method' an optional argument
%   - code needs to be cleaned out



function [angles, dim_red_FR, smoothed_FR, empir_angle_dist ] = ...
            comp_neural_spaces_fcn_dim_finding_closest( bdf, neural_chs,...
            dims_hyper_in_orig, labels, method, varargin ) 
                            

        
% -------------------------------------------------------------------------
% path and file with empirical distributions of angles, for assessing
% orthogonality 
%
% ~-~-> ToDo: turn into a parameter


empir_angle_dist_file       = '/Users/juangallego/Documents/NeuroPlast/Data/_Dimensionality reduction/_control analyses/empirical angle distribution all datasets.mat';

        
% -------------------------------------------------------------------------
% read input parameters


if nargin == 6
    smoothed_FR             = varargin{1};
elseif nargin == 7
    smoothed_FR             = varargin{1};
    dim_red_FR              = varargin{2};
    % check dimensions are consistent
    if ~isempty(bdf)
        if length(bdf) ~= length(smoothed_FR),error('smoothed_FR has wrong size'),end
        if length(bdf) ~= length(dim_red_FR),error('dim_red_FR has wrong size'),end
    else
        if length(smoothed_FR) ~= length(dim_red_FR),error('dim_red_FR and smoothed_FR have different sizes'),end
    end
elseif nargin == 8
    bin_width               = varargin{1};
    gauss_SD                = varargin{2};
    transform               = varargin{3};    
elseif nargin == 9
    smoothed_FR             = varargin{1};
    dim_red_FR              = varargin{2};
    % define the last dimension we'll look at: this assumes that we don't
    % care for all the dimensions of the neural space but only a few  
    resort_eigenv           = varargin{3};
    last_dim                = varargin{4};
end


% check that dimensions are consistent
if nargin == 7 || nargin == 9
    if ~isempty(bdf)
        if length(bdf) ~= length(smoothed_FR),error('smoothed_FR has wrong size'),end
        if length(bdf) ~= length(dim_red_FR),error('dim_red_FR has wrong size'),end
    else
        if length(smoothed_FR) ~= length(dim_red_FR),error('dim_red_FR and smoothed_FR have different sizes'),end
    end
end

% if don't have passed the option to resort the eigenvectors by
% similarity, set the flag to false
if ~exist('resort_resort_eigenv','var')
    resort_eigenv           = false;
end


% -------------------------------------------------------------------------
% Some definitions


% Nbr of BDFs (tasks)
if ~isempty(bdf)
    nbr_bdfs                = length(bdf);
else
    nbr_bdfs                = length(dim_red_FR);
end

% neural channels to be discarded
if ~isempty(neural_chs)
    discard_neurons         = setdiff(1:length(bdf(1).units), neural_chs);
end

% Nbr of neural channels
if ~isempty(neural_chs)
    nbr_neural_chs          = numel(neural_chs);
else
    if ~isempty(bdf)
        nbr_neural_chs      = length(bdf(1).units);
    else
        nbr_neural_chs      = length(dim_red_FR{1}.chs);
    end
end


% -------------------------------------------------------------------------
% Preprocessing 
%
% ~-~-> optional, the function allows passing the PCA- or FA-reduced data)
%


% Smooth firing rates
if ~exist('smoothed_FR','var')
    for i = 1:nbr_bdfs
        if nargin == 5
            smoothed_FR{i}  = gaussian_smoothing2( bdf(i) ); %#ok<AGROW>
        elseif nargin == 8 && exist('bin_width','var')
            smoothed_FR{i}  = gaussian_smoothing2( bdf(i), transform, ...
                                         bin_width, gauss_SD ); %#ok<AGROW>
%             error('this option is not compatible yet with the new gaussian smoothing function');
        end
    end
end

% Do dimensionality reduction
if ~exist('dim_red_FR','var')
    for i = 1:nbr_bdfs
        dim_red_FR{i}       = dim_reduction( smoothed_FR{i}, method, ...
                                    discard_neurons ); %#ok<AGROW>
    end
end


% -------------------------------------------------------------------------
% Load or compute distribution randomly generated manifolds, to assess the
% meaning of the angles computed below
%

empir_angle_dist_all        = load(empir_angle_dist_file);
if isempty(find(empir_angle_dist_all.space_dim == nbr_neural_chs,1))
    disp('calculating random distribution 1:n-1 dimensional manifolds in n-dimensional neural space');
    [empir_angle_dist, angles_non_rand] = empirical_angle_distribution( numel(neural_chs), ...
                                1:numel(neural_chs), 10000 );
else
    angles_non_rand         = empir_angle_dist_all.angle_non_orth{...
                                find(empir_angle_dist_all.space_dim == nbr_neural_chs,1)};
end


% -------------------------------------------------------------------------
% Compute the angle between manifolds
%
% ~-~-> this will be done twice, using each manifold (task) as 'reference'
% to compare the angle between each of the other manifolds [see below]
%


% Find the closest eigenvector in task i+p (p>1) to each eigenvector in
% task i. Do until n = N - 1
[angles_fc, dim_min_angle]  = find_closest_neural_hyperplane_all( dim_red_FR, ...
                                1:dims_hyper_in_orig-1, labels );


% Choose whether to resort the eigenvectors so they are not ranked by the
% eigenvalues of the first task but rather by similarity. Don't do by
% default
% ~-~-> likely to be deleted in newer versions of the code
if resort_eigenv
    [~, dim_min_angle]      = resort_eigenv_similarity( angles_fc, dim_min_angle, last_dim );
end

% compare hyperplanes for increasing hyperplane dimensionality, re-ordering
% the eigenvectors so as to minimize the angle between pairs according to
% dim_min_angle
angles                      = comp_neural_spaces_fcn_dim( bdf, neural_chs, dim_min_angle, ...
                                    labels, method, angles_non_rand, smoothed_FR, dim_red_FR );

                                
% Do again finding the closest eigenvector in task i-p (p>1) to each
% eigenvector in task i
[angles_fc_rev, dim_min_angle_rev] = find_closest_neural_hyperplane_all( dim_red_FR, ...
                                1:dims_hyper_in_orig-1, labels, true );

angles_rev                  = comp_neural_spaces_fcn_dim( bdf, neural_chs, dim_min_angle_rev, ...
                                    labels, method, angles_non_rand, smoothed_FR, ...
                                    dim_red_FR, false, true );


                                
% -------------------------------------------------------------------------
% Define output variables


% add method for computing the angles to the struct
angles.method               = 'min_angle';
                                