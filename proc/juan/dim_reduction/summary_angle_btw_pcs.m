%
% Summarize dimensionality reduction results for a session.
%
%   function [angle_mtrx, angle_lbls] = summary_angle_btw_pcs( dim_red_FR,
%                               nbr_eigenvectors, labels, varargin )  
%
% Inputs (opt)              : [defaults]
%       dim_red_FR          : array of structs with fields:
%       	w               : weights PCA decomposition (cov matrix)
%           eigen           : eigenvalues of w
%           scores          : result of applying w to smoothed_FR
%           t_axis          : time axis for scores
%           chs             : neural channels included in the analysis
%       eigenvectors        : nbr. of eigenvectors (dims.) that will be
%                               used in the analysis [scalar], or
%                             N-D array with the eigenvectors that define
%                             the hyperplane that will be analyzed for each
%                             task (fields in dim_red_FR)
%       labels:             : cell array with labels for each trial
%       (show_plots)        : [false] show plot that compares the eigenvals
%                               for each pair of spaces
%
% Outputs:
%       angle_mtrx          : symmetric matrix with the angle between each
%                               possible pair of hyperplanes (tasks)
%       angle_lbls          : labels that describe the trials in angle_mtrx
%


function [angle_mtrx, angle_lbls] = summary_angle_btw_pcs( dim_red_FR, ...
                            eigenvectors, labels, varargin ) 


% read input options
if nargin == 4
    show_plots              = varargin{1};
else
    show_plots              = true;
end

nbr_spaces                  = length(dim_red_FR);

if isscalar(eigenvectors)
    nbr_eigenvectors        = eigenvectors;
elseif ismatrix(eigenvectors)
   % check that the dimensions are right
    if size(eigenvectors,2) ~= nbr_spaces
        error('eigenvectors needs to have dimensions nbr_eigenvects-by-nbr_of_tasks');        
    end
    % store dimensionality of the space
    nbr_eigenvectors        = size(eigenvectors,1);
end


% -------------------------------------------------------------------------
% Compute angles between hyperplanes


% preallocate matrices
angle_mtrx                  = zeros(nbr_spaces,nbr_spaces);
angle_lbls                  = cell(nbr_spaces);


% calculate angle between all possible combinatinos of hyperplanes. Store
% angles and labels 
for i = 1:(nbr_spaces-1)
    for j = (i+1):(nbr_spaces)
        % if eigenvectors is the number of dimensions [scalar]
        if isscalar(eigenvectors)
            angle_mtrx(i,j) = angle_btw_pcs( dim_red_FR{i}.w, dim_red_FR{j}.w, ...
                                nbr_eigenvectors, show_plots );
        % if eigenvectors is a matrix with the eigenvectors from each task
        % that define the hyperplanes which angles will be computed
        elseif ismatrix(eigenvectors)
            angle_mtrx(i,j) = angle_btw_pcs( dim_red_FR{i}.w, dim_red_FR{j}.w, ...
                                eigenvectors(:,[i j]), show_plots );
        end
        angle_lbls{i,j}     = [labels(i) labels(j)];
    end
end


% make the matrix symmetrical

% fill the last row with zeros
angle_mtrx(nbr_spaces,1:nbr_spaces) = 0;
for i = 1:nbr_spaces
    angle_lbls{nbr_spaces,i} = [];
end

% fill the lower diagonal so it is mirrored
angle_mtrx                  = angle_mtrx + angle_mtrx';


% -------------------------------------------------------------------------
% summary plot
figure,imagesc(rad2deg(angle_mtrx))
set(gca,'FontSize',14)
set(gca,'Xtick',1:nbr_spaces,'XTickLabel',labels)
set(gca,'Ytick',1:nbr_spaces,'YTickLabel',labels)
title(['angle between ' num2str(nbr_eigenvectors) '-D neural spaces (deg)'])
colorbar('FontSize',14), caxis([0 90])
