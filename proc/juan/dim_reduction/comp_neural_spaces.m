% 
% Compare neural spaces across trials (BDFs) by calculating the angle
% between hyperplanes containing the N-dimensional reduced FRs.
%
%   function [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( bdf, ...
%                           neural_chs, nbr_eigenvals, labels, varargin )
%
% Inputs (opt):             [defaults]
%       bdf                 : array of BDFs
%       neural_chs          : neural channels that will be included in the
%                               analysis
%       eigenvectors        : nbr. of eigenvectors (dims.) that will be
%                               used in the analysis [scalar], or
%                             N-D array with the eigenvectors that define
%                             the hyperplane that will be analyzed for each
%                             task (fields in dim_red_FR)
%       labels              : labels describing each BDF
% (Parameters Gaussian Kernel)
%       (bin_width)         : [0.05] bin width (s)
%       (gauss_SD)          : [5] SD Gaussian Kernel
%       (gauss_width)       : [0.05] width Gaussian kernel (s)
% (Pass smoothed FRs and dimensionality-reduced firing rates if available,
% instead of computing them in the function) 
%       (smoothed_FR)       : array of smoothed_FRs, one per BDF
%       (dim_red_FR)        : array of PCA-processed FRs
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

function [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( bdf, neural_chs, eigenvectors, labels, varargin )


% input parameters
if nargin == 7
    bin_width           = varargin{1};
    gauss_SD            = varargin{2};
    gauss_width         = varargin{3};
elseif nargin == 6
    smoothed_FR         = varargin{1};
    dim_red_FR          = varargin{2};
    
    % check that dimensions are consistent
    if ~isempty(bdf)
        if length(bdf) ~= length(smoothed_FR),error('smoothed_FR has wrong size'),end
        if length(bdf) ~= length(dim_red_FR),error('dim_red_FR has wrong size'),end
    else
        if length(dim_red_FR) ~= length(smoothed_FR),error('smoothed_FR or dim_red_FR has wrong size'),end
    end
end

% check dimensions are consistent
if ~isempty(bdf)
    if length(bdf) ~= length(labels),error('labels has wrong size'),end
else
    if length(dim_red_FR) ~= length(labels),error('labels has wrong size'),end
end


% create matrix with selected neural channels
if ~isempty(bdf)
    nbr_bdfs            = length(bdf);
    discard_neurons     = setdiff(1:length(bdf(1).units), neural_chs);
else
    nbr_bdfs            = length(dim_red_FR);
end


% retrieve input parameter eigenvectors
if isscalar(eigenvectors)
    % will compute the angle between hyperplanes in the space defined by
    % the first 'eigenvectors' (renamed nbr_eigenvals)
    nbr_eigenvectors     = eigenvectors;
elseif ismatrix(eigenvectors)
    % will compute the angle between hyperplanes in a space of dimensions
    % equal to the number of rows in eigenvectors, using, for each of them,
    % the eigenvectors specified in the respective column
    nbr_eigenvectors     = size(eigenvectors,1);
    % check if the nbr of cols matches the number of tasks (bdfs)
    if size(eigenvectors,2) ~= nbr_bdfs
        error('eigenvectors needs to have dimensions nbr_eigenvects-by-nbr_of_tasks');        
    end
end


% -------------------------------------------------------------------------
% smooth firing rates and do PCAs --if not passed as arguments
if ~exist('smoothed_FR','var')
    for i = 1:nbr_bdfs
        if nargin == 4
            smoothed_FR{i}  = gaussian_smoothing( bdf(i) ); %#ok<AGROW>
        elseif nargin == 7
            smoothed_FR{i}  = gaussian_smoothing( bdf(i), bin_width, ...
                                        gauss_SD, gauss_width ); %#ok<AGROW>
        end
        dim_red_FR{i}       = dim_reduction( smoothed_FR{i}, 'pca', ...
                                        discard_neurons ); %#ok<AGROW>
    end
end


% -------------------------------------------------------------------------
% plot variances per component for each trial
% nbr PCA components in the plot
if nbr_eigenvectors < 20
    nbr_comps_max      = 20;
elseif nbr_eigenvectors < 30
    nbr_comps_max      = 30;
elseif nbr_eigenvectors < 40
    nbr_comps_max      = 40;
else
    nbr_comps_max      = length(dim_red_FR{1}.eigen);
end

figure('units','normalized','outerposition',[0 0 1 1]),
for i = 1:nbr_bdfs
    subplot(2,nbr_bdfs,i),bar(dim_red_FR{i}.eigen/sum(dim_red_FR{i}.eigen)),
    set(gca,'TickDir','out'),set(gca,'FontSize',18),xlim([0 nbr_comps_max+1]),
    hold on, bar(dim_red_FR{i}.eigen(1:nbr_eigenvectors)/sum(dim_red_FR{i}.eigen),'r'), 
    title(labels{i}), ylim([0 0.25])
    
    subplot(2,nbr_bdfs,i+nbr_bdfs),bar(cumsum(dim_red_FR{i}.eigen)/sum(dim_red_FR{i}.eigen)),
    set(gca,'TickDir','out'),set(gca,'FontSize',18),xlabel('comp. nbr.'),xlim([0 nbr_comps_max+1]),
    hold on, bar(nbr_eigenvectors,sum(dim_red_FR{i}.eigen(1:nbr_eigenvectors))/sum(dim_red_FR{i}.eigen),'r'), 
    title(labels{i}), ylim([0 1])
    if i == 1
        subplot(2,nbr_bdfs,i), ylabel('% norm. variance per comp.')
        subplot(2,nbr_bdfs,i+nbr_bdfs), ylabel('% cum. explained norm. variance')
    end
end


% -------------------------------------------------------------------------
% compute angles between the neural spaces
if isscalar(eigenvectors)
    % in a hyperspace defined by the first nbr_eigenvectors eigenvectors
    [angle_mtrx, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, nbr_eigenvectors, labels, false );
else
    % in a hyperspace defined by specific eigenvectors for each task
    [angle_mtrx, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, eigenvectors, labels, false );
end


% -------------------------------------------------------------------------
% create return struct
angles.data             = angle_mtrx;
angles.labels           = angle_lbls;
