% 
% Compare neural spaces across trials (BDFs) by calculating the angle
% between hyperplanes containing the N-dimensional reduced FRs.
%
%   function [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( bdf, ...
%                           neural_chs, nbr_eigenvals, labels, varargin )
%
%
% Syntax:
%
% 
%
% Inputs (opt):             [defaults]
%       bdf                 : array of BDFs. Can be empty if passing
%                               optional inputs smoothed_FR and dim_red_FR
%       neural_chs          : neural channels that will be included in the
%                               analysis. If empty, all channels will be
%                               included
%       eigenvectors        : nbr. of eigenvectors (dims.) that will be
%                               used in the analysis [scalar], or
%                               cell array with size nbr-of-BDFs -by-
%                               nbr-of-BDFs, with each element being an
%                               array of size N-by-2. N is the eigenvectors
%                               that will define the hyperplanes that will
%                               be compared in space 1 and 2 (first and
%                               second cols respectively). 
%                               -~> Can be computed with
%                               find_closest_hyperplane_all.m
%       labels              : labels describing each BDF (cell array)
%       method              : 'var_order' will compute the angle between
%                               hyperplanes with increasing number of
%                               dimensions, ordering the eigenvectors by
%                               variance. 'closest' will look for the
%                               closest eigenvectors and order them based
%                               on that
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

function [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim( bdf, ...
                                neural_chs, eigenvectors, labels, method, varargin )


% input parameters
if nargin == 8
    bin_width               = varargin{1};
    gauss_SD                = varargin{2};
    gauss_width             = varargin{3};
elseif nargin == 7
    smoothed_FR             = varargin{1};
    dim_red_FR              = varargin{2};
    
    % check dimensions are consistent
    if length(bdf) ~= length(smoothed_FR),error('smoothed_FR has wrong size'),end
    if length(bdf) ~= length(dim_red_FR),error('dim_red_FR has wrong size'),end
end

% check that dimensions are consistent --to avoid screwing up with the
% labels and getting an error after all the calculations
if ~isempty(bdf)
    if length(bdf) ~= length(labels),error('labels has wrong size'),end
else
    if length(dim_red_FR) ~= length(labels),error('labels has wrong size'),end
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


% retrieve input parameter eigenvectors
if isscalar(eigenvectors)
    % will compute the angle between hyperplanes in the space defined by
    % the first 'eigenvectors' (renamed nbr_eigenvals)
    nbr_eigenvectors        = eigenvectors;
elseif iscell(eigenvectors)
    % will compute the angle between hyperplanes in a space of dimension N,
    % with N being the number of elements in each field of a cell array of
    % size nbr-of-bdfs-by-nbr-of-bdfs
    
    % retrieve number of dimensions for the hyperplanes
    nbr_eigenvectors        = size(eigenvectors{1,2},1);
    % check that the cell with the eigenvector order has the right
    % dimension --it should be if it was computed with find_closest_all.m
    % but just in case
    if numel(eigenvectors) ~= nbr_bdfs^2
        error('eigenvectors needs to be a cell of dimensions nbr of tasks-by-nbr of tasks');        
    end
end


% -------------------------------------------------------------------------
% smooth firing rates and do PCAs --if not passed as arguments
if ~exist('smoothed_FR','var')
    for i = 1:nbr_bdfs
        if nargin == 5
            smoothed_FR{i}  = gaussian_smoothing( bdf(i) ); %#ok<AGROW>
        elseif nargin == 8
            smoothed_FR{i}  = gaussian_smoothing( bdf(i), bin_width, ...
                                        gauss_SD, gauss_width ); %#ok<AGROW>
        end
        dim_red_FR{i}       = dim_reduction( smoothed_FR{i}, method, ...
                                        discard_neurons ); %#ok<AGROW>
    end
end


% -------------------------------------------------------------------------
% plot variances per component for each trial
% nbr PCA components in the plot
if nbr_eigenvectors < 20
    nbr_comps_max           = 20;
elseif nbr_eigenvectors < 30
    nbr_comps_max           = 30;
elseif nbr_eigenvectors < 40
    nbr_comps_max           = 40;
else
    nbr_comps_max           = length(dim_red_FR{1}.eigen);
end

figure('units','normalized','outerposition',[0 0 1 1]),
for i = 1:nbr_bdfs
    subplot(2,nbr_bdfs,i),bar(dim_red_FR{i}.eigen/sum(dim_red_FR{i}.eigen)),
    set(gca,'TickDir','out'),set(gca,'FontSize',18),xlim([0 nbr_comps_max+1]),
%    hold on, bar(dim_red_FR{i}.eigen(1:nbr_eigenvectors)/sum(dim_red_FR{i}.eigen),'r'), 
    title(labels{i}), ylim([0 0.25])
    
    subplot(2,nbr_bdfs,i+nbr_bdfs),bar(cumsum(dim_red_FR{i}.eigen)/sum(dim_red_FR{i}.eigen)),
    set(gca,'TickDir','out'),set(gca,'FontSize',18),xlabel('comp. nbr.'),xlim([0 nbr_comps_max+1]),
%    hold on, bar(nbr_eigenvectors,sum(dim_red_FR{i}.eigen(1:nbr_eigenvectors))/sum(dim_red_FR{i}.eigen),'r'), 
    title(labels{i}), ylim([0 1])
    if i == 1
        subplot(2,nbr_bdfs,i), ylabel('% norm. variance per comp.')
        subplot(2,nbr_bdfs,i+nbr_bdfs), ylabel('% cum. explained norm. variance')
    end
end


% -------------------------------------------------------------------------
% compute angles between the neural spaces

% pairs of hyperplanes that have been compared
pairs_hyperplanes           = nchoosek(1:nbr_bdfs,2);
    
if isscalar(eigenvectors)
    % in a hyperspace defined by the first nbr_eigenvectors eigenvectors
    angle_mtrx              = zeros(nbr_bdfs,nbr_bdfs,eigenvectors);
    for i = 1:nbr_eigenvectors
        [angle, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, i, labels, false );
        angle_mtrx(:,:,i)   = angle;
    end
    
elseif iscell(eigenvectors)
    
    for i = 1:nbr_eigenvectors
        % we need to create a temp cell array in which 
        temp_eigenv         = cell(nbr_bdfs);
        for ii = 1:size(pairs_hyperplanes,1)
            indx_1          = pairs_hyperplanes(ii,1);
            indx_2          = pairs_hyperplanes(ii,2);
            temp_eigenv{indx_1,indx_2}  = eigenvectors{indx_1,indx_2}(1:...
                                            i,:);
        end
        
        % in a hyperspace defined by specific eigenvectors for each task
        [angle, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, temp_eigenv, labels, false );
        angle_mtrx(:,:,i)   = angle;
    end
end


% -------------------------------------------------------------------------
% figure with angle as function dimensions

% create a vector to give each trace a different color
cols_plot                   = jet(size(pairs_hyperplanes,1));
% cell with legend
legends_plot                = cell(size(pairs_hyperplanes,1),1);
for i = 1:size(pairs_hyperplanes,1)
    legends_plot{i}         = [labels{pairs_hyperplanes(i,1)} ' vs. ' labels{pairs_hyperplanes(i,2)}];
end

figure,hold on
for i = 1:size(pairs_hyperplanes,1)
    plot(rad2deg(squeeze(angle_mtrx(pairs_hyperplanes(i,1),pairs_hyperplanes(i,2),:))),'linewidth',2,'color',cols_plot(i,:))
end
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend(legends_plot,'Location','SouthEast','FontSize',14)
xlabel('nbr. dimensions'),ylabel('angle (deg)'),ylim([0 90])


% -------------------------------------------------------------------------
% create return struct
angles.data                 = angle_mtrx;
angles.labels               = angle_lbls;

% add method for computing the angles to the struct
angles.method               = 'eigen_ranking';

