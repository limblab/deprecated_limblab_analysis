%
% This is a wrapper of comp_neural_spaces_fcn_dim that before looks for the
% closest eigenvectors for dimensions 1:dims_hyper_in_orig
%

function [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim_finding_closest( bdf, ...
                                neural_chs, dims_hyper_in_orig, labels, method, varargin ) 
                            

% input parameters
if nargin == 8
    bin_width               = varargin{1};
    gauss_SD                = varargin{2};
    transform               = varargin{3};
elseif nargin == 7
    smoothed_FR             = varargin{1};
    dim_red_FR              = varargin{2};
    
    % check dimensions are consistent
    if length(bdf) ~= length(smoothed_FR),error('smoothed_FR has wrong size'),end
    if length(bdf) ~= length(dim_red_FR),error('dim_red_FR has wrong size'),end
end


% var with nbr of bdfs (tasks)
if ~isempty(bdf)
    nbr_bdfs                = length(bdf);
else
    nbr_bdfs                = length(dim_red_FR);
end

% neural channels to be discarded
if ~isempty(neural_chs)
    discard_neurons         = setdiff(1:length(bdf(1).units), neural_chs);
end


% -------------------------------------------------------------------------
% smooth firing rates and do PCAs --if not passed as arguments
if ~exist('smoothed_FR','var')
    for i = 1:nbr_bdfs
        if nargin == 5
%            smoothed_FR{i}  = gaussian_smoothing( bdf(i) ); %#ok<AGROW>
            smoothed_FR{i}  = gaussian_smoothing2( bdf(i) ); %#ok<AGROW>
        elseif nargin == 8
%             smoothed_FR{i}  = gaussian_smoothing( bdf(i), bin_width, ...
%                                         gauss_SD, gauss_width ); %#ok<AGROW>
            smoothed_FR{i}  = gaussian_smoothing( bdf(i), transform, ...
                                         bin_width, gauss_SD ); %#ok<AGROW>
        end
        dim_red_FR{i}       = dim_reduction( smoothed_FR{i}, method, ...
                                        discard_neurons ); %#ok<AGROW>
    end
end


% -------------------------------------------------------------------------
% find closest eigenvector for each dimension
% Do until n = N - 1
[~, dim_min_angle]          = find_closest_neural_hyperplane_all( dim_red_FR, 1:dims_hyper_in_orig-1, labels );


% compare hyperplanes for increasing number of vectors, re-ordering the
% components so as to minimize the angle between pairs of eigenvectors
[angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim( bdf, neural_chs, dim_min_angle, ...
                                    labels, method, smoothed_FR, dim_red_FR );


% add method for computing the angles to the struct
angles.method               = 'min_angle';
                                