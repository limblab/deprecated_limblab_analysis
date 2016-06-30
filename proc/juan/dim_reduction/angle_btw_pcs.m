%
% Angle between neural spaces defined by the eigenvalues of their
% covariance matrices. 
%
%   function angle = angle_btw_pcs( basis_1, basis_2, varargin ) 
%
% Inputs (opt)              : [defaults]
%       basis_1             : eigenvectors that define hyperplane #1
%       basis_2             : eigenvectors that define hyperplane #2
%       (nbr_dims)          : [min(size(eigen_1,eigen_2))] number of
%                               dimensions of the neural space [scalar], or
%                             2-D array with the eigenvectors in basis 1
%                             (1st col) and basis 2 (2nd col) which angle
%                             will be calculated
%       (show_plots)        : [false] show plot that compares the eigenvals
%                               for each pair of spaces
%

function angle = angle_btw_pcs( basis_1, basis_2, varargin ) 

% read input parameters

if nargin >= 3
    % argument 3 can be a vector or an array
    if isscalar(varargin{1})
        nbr_dims        = varargin{1};
    elseif ismatrix(varargin{1})
        nbr_dims        = size(varargin{1},1);
        eigenvs_1       = varargin{1}(:,1);
        eigenvs_2       = varargin{1}(:,2);
    end
else
    % if not specified, calculate the angle between the hyperplane in the
    % space with the minimum common nbr. of dimensions
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
% plot the relationship between eigenvalues and the angle
if show_plot
    figure, plot(basis_1(:,1:nbr_dims),basis_2(:,1:nbr_dims),'marker','o',...
        'markersize', 12, 'linestyle','none')
    set(gca,'TickDir','out'), set(gca,'FontSize',14);
    xlabel('eigen values space 1','Fontsize',14);
    ylabel('eigen values space 2','Fontsize',14);
    title(['angle between hyperplanes: ' num2str(rad2deg(angle)) ' deg']);
end