%
% Sorts sets of pairs of eigenvectors according to the direction of minimum
% angle
%
%   function [angles_rs, dim_min_angle_rs]  = resort_eigenv_similarity( angles_fc, dim_min_angle, last_dim )
%  
% Inputs (opt)      : [default]
%   angles          : cell array with angles between eigenvectors. These
%                       pairs of eigenvectors (their ranking in each of the
%                       spaces based on the standard eigenvalue sorting is
%                       defined in the corresponding field of
%                       'dim_min_angle'
%   dim_min_angle   : cell array with the eigenvectors in space 1 and 2
%                       that describe the angle defined in 'angles'
%   last_dim        : the last dimension (eigenvector number) the function
%                       will look at
%
% Outputs:
%   angles_rs       : cell array with resorted angles
%   dim_min_angle_rs : cell array with resorted eigenvector numbers
%

function [angles_rs, dim_min_angle_rs]  = resort_eigenv_similarity( angles, dim_min_angle, last_dim, varargin )


% read nbr of tasks
nbr_bdfs            = size(angles,2);

% matrix with all possible pairs of tasks
comb_bdfs           = nchoosek(1:nbr_bdfs,2);

nbr_comb_bdfs       = size(comb_bdfs,1);


% preallocate return structs
angles_rs           = cell(nbr_bdfs,nbr_bdfs);
dim_min_angle_rs    = cell(nbr_bdfs,nbr_bdfs);

for i = 1:nbr_comb_bdfs
    indx_1          = comb_bdfs(i,1);
    indx_2          = comb_bdfs(i,2);
    [tmp_ang, temp_indx]    = sort(angles{indx_1,indx_2}(1:last_dim));
    angles_rs{indx_1,indx_2} = tmp_ang;
    dim_min_angle_rs{indx_1,indx_2} = dim_min_angle{indx_1,indx_2}(temp_indx,:);
end