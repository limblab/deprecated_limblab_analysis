%
% Dimensionality reduction of neural activity. 
%
%   function dim_red_FR = dim_reduction( smoothed_FR, method, varargin )
%
% Inputs (opt)              : [defaults]
%       smoothed_FR         : matrix with smoothed FRs (1 col is time)
%       method              : 'pca' or 'fa'
%       (discard_neurons)   : array with the nbr of the neural channels
%                               to be excluded from the analysis
%       (show_plot)         : bool to plot the variance explained by the
%                               components
%
% Outputs:
%       dim_red_FR          : struct with fields:
%       	w               : weights PCA decomposition (cov matrix)
%           eigen           : eigenvalues of w
%           scores          : result of applying w to smoothed_FR
%           t_axis          : time axis for scores
%           chs             : neural channels included in the analysis
%                               

function dim_red_FR = dim_reduction( smoothed_FR, method, varargin )


% read time vector in smoothed_FR and delete it from the matrix for further
% analysis
t_axis                      = smoothed_FR(:,1);
smoothed_FR(:,1)            = [];

% read input arguments
if nargin >= 3 
    % discard selected neurons for analysis
    discard_neurons         = varargin{1};
    original_neurons        = size(smoothed_FR,2); % for later
    smoothed_FR(:,discard_neurons) = [];
end

if nargin == 4
    show_plot               = varargin{2};
else
    show_plot               = true;
end


% do it!
switch method
    case 'pca'
        % do pca of the smoothed firing rates
        [w, scores, eigen]  = pca(smoothed_FR);        
    case 'fa'
        disp('to be programmed...')
    otherwise
        disp('choose either pca or fa...')
end


% ----------------
% plot summary results
if show_plot
    figure,
    subplot(121),bar(eigen/sum(eigen)),
    xlabel('neural input nbr.','FontSize',14),ylabel('norm. eigenvalue','FontSize',14)
    set(gca,'TickDir','out'),set(gca,'FontSize',14);
    xlim([0 size(smoothed_FR,2)+1])
    subplot(122),bar(cumsum(eigen/sum(eigen))),
    hold on, plot([0 size(smoothed_FR,2)+1],[0.8 0.8],'r','LineWidth',2), hold off
    xlabel('neural input nbr.','FontSize',14),ylabel('explained variance','FontSize',14)
    set(gca,'TickDir','out'),set(gca,'FontSize',14);
    xlim([0 size(smoothed_FR,2)+1])
    ylim([0 1])
end


% -----------------
% create struct to return
dim_red_FR.method           = method;
switch method
    case 'pca'
        dim_red_FR.w        = w;
        dim_red_FR.t        = t_axis;
        dim_red_FR.scores   = scores;
        dim_red_FR.eigen    = eigen;
        if exist('discard_neurons','var')
            dim_red_FR.chs  = setdiff(original_neurons,discard_neurons);
        end
        case 'fa'
        disp('to be programmed...')
end