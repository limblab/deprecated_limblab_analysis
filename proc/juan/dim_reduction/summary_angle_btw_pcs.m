%
% Compute angles between manifolds from different tasks for the number of
% hyperplane (manifolds) dimensions, defined either based on the ranking of
% the associated eigenvalues or as a set of specific eigenvectors for each
% task and pair
%
%   function [angle_mtrx, angle_lbls] = summary_angle_btw_pcs( dim_red_FR,
%                               nbr_eigenvectors, labels, varargin )  
%
% Inputs (opt)              : [defaults]
%       dim_red_FR          : array of structs with fields:
%       	w               : weights PCA decomposition
%           eigen           : eigenvalues of w
%           scores          : result of applying w to smoothed_FR
%           t_axis          : time axis for scores
%           chs             : neural channels included in the analysis
%       eigenvectors        : nbr. of eigenvectors (dims.) that will be
%                               used in the analysis [scalar], OR N-D array
%                               with the eigenvectors that define the
%                               hyperplane that will be analyzed for each
%                               task (fields in dim_red_FR), OR cell array
%                               with size nbr-of-BDFs -by-
%                               nbr-of-BDFs, with each element being an
%                               array of size N-by-2. N is the eigenvectors
%                               that will define the hyperplanes that will
%                               be compared in space 1 and 2 (first and
%                               second cols respectively). 
%                               -~> Can be computed with
%                               find_closest_hyperplane_all.m
%       labels:             : cell array with labels for each trial
%       (show_plots)        : [false] show plot that compares the eigenvals
%                               for each pair of spaces
%       (reverse_yn)        : [false] instead of looking for the invectors
%                               in task i+p that are closest to the
%                               eigenvectors in task i (i = 1:nbr. of
%                               tasks), look for the eigenvectors in task i
%                               that are closest to the eigenvectors in
%                               task i+p. The core of the idea is to do
%                               both and compare
%
% Outputs:
%       angle_mtrx          : symmetric matrix with the angle between each
%                               possible pair of hyperplanes (tasks)
%       angle_lbls          : labels that describe the trials in angle_mtrx
%


function [angle_mtrx, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, ...
                            eigenvectors, labels, varargin ) 

                        
% -------------------------------------------------------------------------
% read input options


if nargin >= 4
    show_plots              = varargin{1};
else
    show_plots              = true;
end

if nargin == 5
    reverse_yn              = varargin{2};
else
    reverse_yn              = false;
end


% -------------------------------------------------------------------------
% retrieve how the manifolds will be compared


nbr_spaces                  = length(dim_red_FR);


% if eigenvectors is a SCALAR, it defines the dimensionality of the
% hyperplanes (manifolds) that will be compared
if isscalar(eigenvectors)
    nbr_eigenvectors        = eigenvectors;

% if eigenvectors is a CELL it defines, for each pair of tasks, the
% eigenvectors that define each of the manifolds
elseif iscell(eigenvectors)
    
    % check that the cell with the eigenvector order has the right
    % dimension --it should be if it was computed with find_closest_all.m
    % but just in case
    if numel(eigenvectors) ~= nbr_spaces^2
        error('eigenvectors needs to be a cell of dimensions nbr of tasks-by-nbr of tasks');        
    end
    % store dimensionality of the hyperplanes
    if ~reverse_yn
        nbr_eigenvectors    = size(eigenvectors{1,2},1);
    else
        nbr_eigenvectors    = size(eigenvectors{2,1},1);
    end
% if eigenvectors is a MATRIX it defines, for the pair of tasks, the
% eigenvectors that define each of the manifolds
elseif ismatrix(eigenvectors)
   % check that the dimensions are right
    if size(eigenvectors,2) ~= nbr_spaces
        error('eigenvectors needs to have dimensions nbr_eigenvects-by-nbr_of_tasks');        
    end
    % store dimensionality of the hyperplanes
    if ~reverse_yn
        nbr_eigenvectors    = size(eigenvectors,1);
    else
        nbr_eigenvectors    = size(eigenvectors,2);
    end
end


% -------------------------------------------------------------------------
% Compute angles between hyperplanes


% preallocate matrices
angle_mtrx                  = zeros(nbr_spaces,nbr_spaces);
angle_lbls                  = cell(nbr_spaces);


% calculate angle between all possible combinations of tasks and for all
% the specified manifold dimensionality 
for i = 1:(nbr_spaces-1)
    
    for j = (i+1):nbr_spaces
        
        % if eigenvectors is the number of dimensions [scalar]
        if isscalar(eigenvectors)
            angle_mtrx(i,j) = angle_btw_pcs( dim_red_FR{i}.w, dim_red_FR{j}.w, ...
                                nbr_eigenvectors, show_plots );
        
        % if eigenvectors is a cell with the pairs of eigenvectors that
        % define the manifold for this pair of tasks
        elseif iscell(eigenvectors)
            if ~reverse_yn
                angle_mtrx(i,j) = angle_btw_pcs( dim_red_FR{i}.w, dim_red_FR{j}.w, ...
                                eigenvectors{i,j}, show_plots );
            else
                angle_mtrx(j,i) = angle_btw_pcs( dim_red_FR{j}.w, dim_red_FR{i}.w, ...
                                eigenvectors{j,i}, show_plots );
            end
        % if eigenvectors is a matrix
        elseif ismatrix(eigenvectors)
            if ~reverse_yn
                angle_mtrx(i,j) = angle_btw_pcs( dim_red_FR{i}.w, dim_red_FR{j}.w, ...
                                eigenvectors(:,[i j]), show_plots );
            else
                angle_mtrx(j,i) = angle_btw_pcs( dim_red_FR{j}.w, dim_red_FR{i}.w, ...
                                eigenvectors(:,[j i]), show_plots );
            end
        end
        % store task labels
        if ~reverse_yn
            angle_lbls{i,j}     = [labels(i) labels(j)];
        else
            angle_lbls{j,i}     = [labels(j) labels(i)];
        end
    end
end


% % make the angle labels and angle results matrices symmetrical
% 
% if ~reverse_yn
%     % fill the last row of the angle_mtrx with zeros, to make it square
%     angle_mtrx(nbr_spaces,1:nbr_spaces) = 0;
%     for i = 1:nbr_spaces
%         angle_lbls{nbr_spaces,i} = [];
%     end
% else
%     % fill the last column of the angle_mtrx with zeros, to make it square
%     angle_mtrx(1:nbr_spaces,nbr_spaces) = 0;
%     for i = 1:nbr_spaces
%         angle_lbls{i,nbr_spaces} = [];
%     end    
% end
    
% fill the lower diagonal so it is mirrored
angle_mtrx                  = angle_mtrx + angle_mtrx';


% -------------------------------------------------------------------------
% summary plot
if show_plots
    figure,imagesc(rad2deg(angle_mtrx))
    set(gca,'FontSize',14)
    set(gca,'Xtick',1:nbr_spaces,'XTickLabel',labels)
    set(gca,'Ytick',1:nbr_spaces,'YTickLabel',labels)
    title(['angle between ' num2str(nbr_eigenvectors) '-D neural spaces (deg)'])
    colorbar('FontSize',14), caxis([0 90])
end
