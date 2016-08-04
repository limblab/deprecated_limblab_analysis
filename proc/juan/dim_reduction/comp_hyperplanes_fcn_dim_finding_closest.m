%
% Compares angles between two hyperplanes as function of the number of
% dimensions
%
% Inputs (opt)              : [default]
%   eigenv_1                : matrix with the eigenvectors that define
%                               hyperspace #1 in columns
%   eigenv_2                : matrix with the eigenvectors that define
%                               hyperspace #2 in columns
%   dims_hyper_in_1         : eigenvectors in hyperspace #1 that will be
%                               considered in the analysis. Do 'all' for
%                               all the eigenvectors
% 
% Outputs
%   angles                  : matrix with angles between hyperspaces for
%                               the dimensions specified in 'dims_hyper_in_1'
%   dim_min_angle           : eigenvector in hyperspace #2 that describes
%                               the minimum angle with the corresponding
%                               eigenvector of hyperspace #1
%

function [angles, dim_min_angle] = comp_hyperplanes_fcn_dim_finding_closest( eigenv_1, ...
                                eigenv_2, dims_hyper_in_1 ) 

                            
% which dimensions are we looking at?
if ischar(dims_hyper_in_1)
    if strcmp(dims_hyper_in_1,'all')
        dims_hyper_in_1         = 1:size(eigenv_1,1)-1;
    end
end

% check if dimensions are consistent
if size(eigenv_1,1) ~= size(eigenv_2,1)
    error('eigenvectors are from hyperspaces with different dimensionality')
end

% % eigenvector elements to be discarded
% if ~isempty(eigenv_elems)
%     discard_elems           = setdiff(1:size(eigenv_1,1), eigenv_elems);
% end

% -------------------------------------------------------------------------
% find closest eigenvector for each dimension
% Do until n = N - 1
[angles, dim_min_angle]         = find_closest_hyperplane( eigenv_1, eigenv_2, ...
                                dims_hyper_in_1 );
                                