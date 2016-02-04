%
% Compares neural spaces across tasks, also doing within trial comparisons.
% Within trial comparisons consist in splitting the data in two, and
% computing the angle. If one of the BDFs is the concatenation of the rest,
% it won't be split in two, but angles w.r.t. it will still be calcualted.
% This function is just an extension of comp_neural_spaces that first
% splits each trial BDF in half.
%
%   function [angles, dim_red_FR, smoothed_FR ] = within_trial_comp_neural_spaces( ...
%                           bdf, neural_chs, nbr_eigenvals, labels, varargin )
%   
% Inputs (opt):             [defaults]
%       bdf                 : array of BDFs
%       neural_chs          : neural channels that will be included in the
%                               analysis
%       nbr_eigenvals       : number of dimensions of the reduced neural
%                               space
%       labels              : labels describing each BDF
% (Parameters Gaussian Kernel)
%       (bin_width)         : [0.05] bin width (s)
%       (gauss_SD)          : [5] SD Gaussian Kernel
%       (gauss_width)       : [0.05] width Gaussian kernel (s)
%
% Outputs:  
%       angles:             : struct with fields 'data', (angle between
%                               neural spaces) and 'labels' (defining the
%                               angles) 
%       dim_red_FR:         : struct of matrices with the PCA-transformed FRs
%                               for each BDF
%       smoothed_FR:        : struct of amtrices with the smoothed FRs.
%                               Smoothing is performed by convolving a
%                               Gaussian kernel with the binned FRs. The
%                               parameters are the defaults in
%                               'gaussian_smoothing'
% 

function [angles, dim_red_FR, smoothed_FR ] = within_trial_comp_neural_spaces( bdf, neural_chs, nbr_eigenvals, labels, varargin )


% input parameters
if nargin == 7
    bin_width           = varargin{1};
    gauss_SD            = varargin{2};
    gauss_width         = varargin{3};
end

% create matrix with selected neural channels
nbr_bdfs                = length(bdf);
discard_neurons         = setdiff(1:96, neural_chs);


% --------------
% Split the trial BDFs in two

% split the BDFs in two. If one of them is the concatenation of all the
% trials, it won't be split
trial_bdf_indx          = 1:nbr_bdfs;
for i = 1:nbr_bdfs
    if strcmp(bdf(i).meta.bdf_info(1:6),'merged')
        conc_bdf_indx   = i;
        trial_bdf_indx(i) = [];
    end
end

% Split trial BDFs in two halves
for i = 1:length(trial_bdf_indx)
    new_dur             = floor(bdf(trial_bdf_indx(i)).meta.duration/2);
    split_bdf(2*(i-1)+1) = crop_bdf(bdf(trial_bdf_indx(i)),new_dur);
    split_bdf(2*i)      = crop_bdf(bdf(trial_bdf_indx(i)),new_dur,new_dur*2);
    % update labels
    split_labels{2*(i-1)+1} = labels{i};
    split_labels{2*i}   = [labels{i} '_2']; 
end

% Add the concatenated bdf, it exists
if exist('conc_bdf_indx','var')
    split_bdf(length(split_bdf)+1) = bdf(conc_bdf_indx);
    split_labels{length(split_bdf)} = labels{conc_bdf_indx};
end


% --------------
% Smooth FRs, do PCA and compare angles between neural spaces
if nargin == 4
    [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( split_bdf, ...
                                    neural_chs, nbr_eigenvals, split_labels );
elseif nargin == 7
    [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( split_bdf, ...
                                    neural_chs, nbr_eigenvals, split_labels, ...
                                    bin_width, gauss_SD, gauss_width );
end