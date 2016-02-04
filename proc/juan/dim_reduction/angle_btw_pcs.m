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
%                               dimensions of the neural space 
%       (show_plots)        : [false] show plot that compares the eigenvals
%                               for each pair of spaces
%

function angle = angle_btw_pcs( basis_1, basis_2, varargin ) 

% read input parameters
if nargin >= 3
    % read number eigenvalues to define the hyperplane
    nbr_dims            = varargin{1};
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
    show_plot            = true;
end


% calculate angle between hyperplanes
angle                   = subspace(basis_1(:,1:nbr_dims),basis_2(:,1:nbr_dims));


% plot the relationship between eigenvalues and the angle
if show_plot
    figure, plot(basis_1(:,1:nbr_dims),basis_2(:,1:nbr_dims),'ob', 'markersize', 12)
    set(gca,'TickDir','out'), set(gca,'FontSize',14);
    xlabel('eigen values space 1','Fontsize',14);
    ylabel('eigen values space 2','Fontsize',14);
    title(['angle between hyperplanes: ' num2str(rad2deg(angle)) ' deg']);
end