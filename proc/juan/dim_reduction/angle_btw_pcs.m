%
% Angle between p-dimensional manifolds (hyperplanes) in an n-dimensional
% neural space (p<n)
%
%   function angle = angle_btw_pcs( basis_1, basis_2, varargin ) 
%
% Inputs (opt)              : [defaults]
%       basis_1             : eigenvectors that define hyperplane #1
%       basis_2             : eigenvectors that define hyperplane #2
%       (nbr_dims)          : [min(size(eigen_1,eigen_2))] dimensionality
%                               of the manifold [scalar], or 2-D array with
%                               the indexes of the eigenvectors in basis 1
%                               (1st col) and basis 2 (2nd col) which angle
%                               will be calculated [2-d array]
%       (show_plots)        : [false] show plot that compares the eigenvals
%                               for each pair of spaces
%
% Output:
%       angle               : angle between manifolds (deg)
%
%

function angle = angle_btw_pcs( basis_1, basis_2, varargin ) 


% -------------------------------------------------------------------------
% read input parameters


% define the manifolds whose angles we want to compute
if nargin >= 3
    % if varargin{1} is a scalar, it defines the dimensionality of the
    % manifold
    if isscalar(varargin{1})
        nbr_dims        = varargin{1};
    % if varargin{1} is a 2-d matrix, each of the columns represents the
    % index of the eigenvectors in basis_1 and basis_2 that will be used to
    % define the hyperplanes whose angle will be computed
    elseif ismatrix(varargin{1})
        nbr_dims        = size(varargin{1},1);
        eigenvs_1       = varargin{1}(:,1);
        eigenvs_2       = varargin{1}(:,2);
    end
else
    % if not specified, calculate the angle between the hyperplanes with
    % the minimum common dimensionality --note that this is not a
    % requirement of the subspace function, though
    nbr_dims            = length(basis_1);
    if length(basis_1) ~= length(basis_2)
        warning('length(basis_1) ~= length(basis_2) -- nbr. eigenvals will be cropped to the minimum');
        nbr_dims        = min( length(basis_1), length(basis_2) );
    end
end

if nargin == 4
    show_plot            = varargin{2}; 
else
    show_plot            = false;
end


% ------------------------------------------------------------------------
% calculate angle between hyperplanes


if exist('eigenvs_1','var')
    angle               = subspace(basis_1(:,eigenvs_1),basis_2(:,eigenvs_2));
else
    angle               = subspace(basis_1(:,1:nbr_dims),basis_2(:,1:nbr_dims));
end


% ------------------------------------------------------------------------
% plot the relationship between eigenvector coefficients --not very useful


if show_plot
    figure, plot(basis_1(:,1:nbr_dims),basis_2(:,1:nbr_dims),'marker','o',...
        'markersize', 12, 'linestyle','none')
    set(gca,'TickDir','out'), set(gca,'FontSize',14);
    xlabel('eigen values space 1','Fontsize',14);
    ylabel('eigen values space 2','Fontsize',14);
    title(['angle between hyperplanes: ' num2str(rad2deg(angle)) ' deg']);
end