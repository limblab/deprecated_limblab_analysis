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
%       angles_non_rand     : the minimum angle between two randomly
%                               generated manifolds of dimensionality p (in
%                               a space of 'neural_chs' dimensions) that
%                               will be obtained by chance with a certain
%                               probability (normally P <0.01). If not
%                               passed, the function will calculate the
%                               angles out of a distribution of 10,000
%                               randomly generated angles
% (Parameters Gaussian Kernel)
%       (bin_width)         : [0.05] bin width (s)
%       (gauss_SD)          : [5] SD Gaussian Kernel
%       (gauss_width)       : [0.05] width Gaussian kernel (s)
%       (plot_all_yn)       : [true] plot angle between hyperplanes for n =
%                               1:N-1
% (Pass smoothed FRs and dimensionality-reduced firing rates if available,
% instead of computing them in the function) 
%       (smoothed_FR)       : array of smoothed_FRs, one per BDF
%       (dim_red_FR)        : array of PCA-processed FRs
% (Compute angle between task i and tasks i-p p>0 ??it only makes sense
% when the user passes the pairs of "matching" eigenvectors, in case these
% were computed this way)  
%       (reverse_yn)        : [false] instead of looking for the invectors
%                               in task i+p that are closest to the
%                               eigenvectors in task i (i = 1:nbr. of
%                               tasks), look for the eigenvectors in task i
%                               that are closest to the eigenvectors in
%                               task i+p. The core of the idea is to do
%                               both and compare
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
% Usage:
%   function [angles, dim_red_FR, smoothed_FR] = comp_neural_spaces_fcn_dim( ...
%       bdf, neural_chs, eigenvectors, labels, method, angles_non_rand )
%   function [angles, dim_red_FR, smoothed_FR] = comp_neural_spaces_fcn_dim( ...
%       bdf, neural_chs, eigenvectors, labels, method, angles_non_rand, ...
%       smoothed_FR, dim_red_FR ) 
%   function [angles, dim_red_FR, smoothed_FR] = comp_neural_spaces_fcn_dim( ...
%       bdf, neural_chs, eigenvectors, labels, method, angles_non_rand, ...
%       smoothed_FR, dim_red_FR, plot_all_yn ) 
%   function [angles, dim_red_FR, smoothed_FR] = comp_neural_spaces_fcn_dim( ...
%       bdf, neural_chs, eigenvectors, labels, method, angles_non_rand, ...
%       smoothed_FR, dim_red_FR, plot_all_yn, reverse_yn ) 
%   function [angles, dim_red_FR, smoothed_FR] = comp_neural_spaces_fcn_dim( ...
%       bdf, neural_chs, eigenvectors, labels, method, angles_non_rand, ...
%       bin_width, gauss_SD, gauss_width ) 
%   function [angles, dim_red_FR, smoothed_FR] = comp_neural_spaces_fcn_dim( ...
%       bdf, neural_chs, eigenvectors, labels, method, angles_non_rand, ...
%       bin_width, gauss_SD, gauss_width, plot_all_yn ) 
%


function [angles, dim_red_FR, smoothed_FR ] = ...
            comp_neural_spaces_fcn_dim( bdf, neural_chs, eigenvectors, ...
            labels, method, angles_non_rand, varargin )


% -------------------------------------------------------------------------
% read input parameters


if nargin == 10
    if ~islogical(varargin{3})
        bin_width           = varargin{1};
        gauss_SD            = varargin{2};
        gauss_width         = varargin{3};  
        plot_all_yn         = varargin{4};    
    else
        smoothed_FR         = varargin{1};
        dim_red_FR          = varargin{2};
        plot_all_yn         = varargin{3};
        reverse_yn          = varargin{4};
    end
elseif nargin == 9
    if ~islogical(varargin{3})
        bin_width           = varargin{1};
        gauss_SD            = varargin{2};
        gauss_width         = varargin{3};  
    else
        smoothed_FR         = varargin{1};
        dim_red_FR          = varargin{2};
        plot_all_yn         = varargin{3};
    end
elseif nargin == 8
    smoothed_FR             = varargin{1};
    dim_red_FR              = varargin{2};    
    % check that dimensions are consistent
    if length(bdf) ~= length(smoothed_FR),error('smoothed_FR has wrong size'),end
    if length(bdf) ~= length(dim_red_FR),error('dim_red_FR has wrong size'),end
end

% Set reverse_yn to false, if not passed
if ~exist('reverse_yn','var')
    reverse_yn              = false;
end

% Set plotting flag to not plotting, if not specified
if ~exist('plot_all_yn','var')
    plot_all_yn             = false;
end

% Check that dimensions are consistent --to avoid screwing up with the
% labels and getting an error after all the calculations
if ~isempty(bdf)
    if length(bdf) ~= length(labels),error('labels has wrong size'),end
else
    if length(dim_red_FR) ~= length(labels),error('labels has wrong size'),end
end

% % Read empirical number of dimensions, calculate if unavailable
% if isempty(angles_non_rand)
%     disp('calculating empirical angle distribution with 10,000 samples')
%     [~, angles_non_rand] = empirical_angle_distribution( numel(neural_chs), ...
%         1:numel(neural_chs), 10000 );
% end


% -------------------------------------------------------------------------
% Some definitions


% Get nbr of bdfs (tasks)
if ~isempty(bdf)
    nbr_bdfs                = length(bdf);
else
    nbr_bdfs                = length(dim_red_FR);
end

% Set neural channels to discard for the analysis
if ~isempty(neural_chs)
    discard_neurons         = setdiff(1:length(bdf(1).units), neural_chs);
end


% -------------------------------------------------------------------------
% Check if user wants to compare the angle between two manifolds, or two
% sets of manifolds defined by sequences of n eigenvectors (in this case
% the function will compare the angle between manifolds of dimension 1:n
% taking the eigenvectors in the order that is specified in 'eigenvectors')


% Retrieve input parameter eigenvectors can be a scalar
if isscalar(eigenvectors)
    % will compute the angle between hyperplanes in the space defined by
    % the first 'eigenvectors' (renamed nbr_eigenvals)
    nbr_eigenvectors        = eigenvectors;
elseif iscell(eigenvectors)
    % will compute the angle between hyperplanes in a space of dimension N,
    % with N being the number of elements in each field of a cell array of
    % size nbr-of-bdfs-by-nbr-of-bdfs
    
    % retrieve number of dimensions for the hyperplanes
    if ~reverse_yn
        nbr_eigenvectors    = size(eigenvectors{1,2},1);
    else
        nbr_eigenvectors    = size(eigenvectors{2,1},1);
    end
    % check that the cell with the eigenvector order has the right
    % dimension --it should be if it was computed with find_closest_all.m
    % but just in case
    if numel(eigenvectors) ~= nbr_bdfs^2
        error('eigenvectors needs to be a cell of dimensions nbr of tasks-by-nbr of tasks');        
    end
end


% -------------------------------------------------------------------------
% Preprocessing 
%
% ~-~-> optional, the function allows passing the PCA- or FA-reduced data)
%


% smooth firing rates and do PCA
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
% compute angles between the neural spaces


% define the pairs of hyperplanes that have to be compared --this is all
% pairs of tasks
pairs_hyperplanes           = nchoosek(1:nbr_bdfs,2);

% "reverse" this pairs; i.e. compute the angles between task i and task i-p
% (p>1)
% ~-~-> this makes sense only if the eigenvectors are passed in this
% sequence, which is useful to compute the angles between all pairs of
% manifolds taking each of them as reference
if reverse_yn
    pairs_hyperplanes       = fliplr(pairs_hyperplanes);
end


% when the user passed the dimensionality of the manifolds to be compared
% (eigenvetors is scalar)
% ~-~-> compute angles between hyperplanes of dimension 1:N with
% eigenvectors in each task ranked based on their eigenvalues 
if isscalar(eigenvectors)
    % preallocate matrix for storing the results
    angle_mtrx              = zeros(nbr_bdfs,nbr_bdfs,eigenvectors);
    for i = 1:nbr_eigenvectors
        [angle, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, i, labels, false );
        angle_mtrx(:,:,i)   = angle;
    end    
% if the user passed a cell with fields that specify the eigenvector 'e_j'
% from task 'i+1' that has to be compared to the eigenvector 'e_k' from
% task 'i', for i = 1:N, and j,k belonging to 1:N
elseif iscell(eigenvectors)
    % preallocate matrix for storing the results --the third dimension is
    % defined as the max of two fields in the cell array for the case in
    % which task combinations are reversed
    angle_mtrx              = zeros(nbr_bdfs,nbr_bdfs,...
        max(size(eigenvectors{1,2},1),size(eigenvectors{2,1},1)));
    for i = 1:nbr_eigenvectors
        
        % to create a temp cell array to contain the eigenvectors
        temp_eigenv         = cell(nbr_bdfs);
        for ii = 1:size(pairs_hyperplanes,1)
            indx_1          = pairs_hyperplanes(ii,1);
            indx_2          = pairs_hyperplanes(ii,2);
            temp_eigenv{indx_1,indx_2}  = eigenvectors{indx_1,indx_2}(1:...
                                            i,:);
        end
        % in a hyperspace defined by specific eigenvectors for each task
        [angle, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, temp_eigenv, labels, false, reverse_yn );
        % create a 3D matrix to store the angles
        angle_mtrx(:,:,i)   = angle;
    end
end



% -------------------------------------------------------------------------
% plot variance as number of function of components for each task
% (optional)


if plot_all_yn
    % nbr PCA components in the plot
    if nbr_eigenvectors < 20
        nbr_comps_max       = 20;
    elseif nbr_eigenvectors < 30
        nbr_comps_max       = 30;
    elseif nbr_eigenvectors < 40
        nbr_comps_max       = 40;
    else
        nbr_comps_max       = length(dim_red_FR{1}.eigen);
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
end


% -------------------------------------------------------------------------
% Plot angle as function of manifold dimensionality


% create a vector to give each trace a different color
cols_plot                   = parula(size(pairs_hyperplanes,1));
% cell with legend
legends_plot                = cell(size(pairs_hyperplanes,1),1);
for i = 1:size(pairs_hyperplanes,1)
    legends_plot{i}         = [labels{pairs_hyperplanes(i,1)} ' vs. ' labels{pairs_hyperplanes(i,2)}];
end
legends_plot{length(legends_plot)+1} = 'randomness th. (P<0.01)';

figure,hold on
for i = 1:size(pairs_hyperplanes,1)
    plot(rad2deg(squeeze(angle_mtrx(pairs_hyperplanes(i,1),pairs_hyperplanes(i,2),:))),'linewidth',2,'color',cols_plot(i,:))
end
plot(angles_non_rand,'color',[.5 .5 .5],'linewidth',2,'linestyle','-.')
% add orthogonality threshold (P<0.001, from Kobak et al., eLife, 2016)
% orth_thr                    = rad2deg(acos(3.3/sqrt(size(dim_red_FR{1}.w,1))));
% plot([1,size(angle_mtrx,3)],[orth_thr,orth_thr],'-.','color',[.5 .5 .5],'linewidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend(legends_plot,'Location','SouthEast','FontSize',14)
xlabel('nbr. dimensions'),ylabel('angle (deg)'),ylim([0 90])
xlim([0 25])

                                
% -------------------------------------------------------------------------
% Define output variables


angles.data                 = angle_mtrx;
angles.labels               = angle_lbls;

% add method for computing the angles to the struct
if isscalar(eigenvectors)
    angles.method           = 'eigen_ranking';
else 
    angles.method           = 'min_angle';
end


