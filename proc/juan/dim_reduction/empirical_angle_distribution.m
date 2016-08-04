%
% Create a random distribution of angles between n-dimensional hyperplanes
% in an m-dimensional hyperspace (n<=m)
%
%   function [dist_angles angle_non_orth] = empirical_angle_distribution( space_dim, plane_dim, samples )
%
% Inputs (opt)      : [default]
%   space_dim       : dimensionality of the space. Can be a scalar or
%                       a vector; if it is a scalar, the function will
%                       create a distribution of angles between hyperplanes
%                       in spaces with each of these dimensionalities, if
%                       it is a vector, it will create one distribution of
%                       'samples' samples for each of the combination of in
%                       plane_dim x space_dime
%   plane_dim       : dimensionality of the hyperplanes. Can be a scalar or
%                       a vector; if it is a scalar, the function will
%                       create a distribution of angles between hyperplanes
%                       with that dimensionality, if it is a vector, it
%                       will create one distribution of 'samples' samples
%                       for each of the dimensionalities in plane_dim
%   samples         : number of angles in the distribution
%   P_orth          : [0.01] area under the PDF above which we'll consider
%                       the hyperplanes not to be different from orthogonal
%   plot_yn         : [false] plot the PDF (bool)
%
% Outputs:
%   dist_angles     : vector or matrix with the dist_angles
%   angle_non_orth  : maximum angle at which P < P_orth
%
%

function [dist_angles, angle_non_orth] = empirical_angle_distribution( space_dim, plane_dim, samples, varargin )


% input parameters
if nargin >= 4
    if ~isempty(varargin{1}), P_orth = varargin{1}; else
    P_orth          = 0.01; end
else
    P_orth          = 0.01;
end
if nargin == 5
    plot_yn         = varargin{2};
else
    plot_yn         = false;
end

% preallocate to store results
dist_angles       	= zeros(samples,length(plane_dim),length(space_dim));


% 1. create random planes and compute their dist_angles. Note that the
% planes don't need to be defined by unitary vectors (i.e. the columns of
% matrices A and B don't need to be unitary vectors), as 'subspace'
% orthogonalizes the matrices 
for n = 1:length(space_dim)
    for d = 1:length(plane_dim)
        for s = 1:samples
            % create planes
            A       = randn(space_dim(n),plane_dim(d));
            B       = randn(space_dim(n),plane_dim(d));
            dist_angles(s,d,n) = subspace(A,B);
        end
    end
end

% turn the angles into a distribution of angles
hist_x              = 0:pi/2/90:pi/2;
hist_dist_angles    = zeros(length(hist_x)-1,length(plane_dim),length(space_dim));
for n = 1:length(space_dim)
    for d = 1:length(plane_dim)
        hist_dist_angles(:,d,n) = histcounts(dist_angles(:,d,n), hist_x)/samples;
    end
end
    
% find the maximum angle at which P < 0.01
angle_non_orth      = zeros(length(plane_dim),length(space_dim));
for n = 1:length(space_dim)
    for d = 1:length(plane_dim)
        angle_non_orth(d,n) = find(cumsum(hist_dist_angles(:,d,n))>P_orth, 1);
    end
end
% turn into degrees
% note: the histogram starts in 1 deg and hist_x in 0, which means we'd
% have to add 1 to max_angle_non_orth, but we compensate for that by
% looking for the first bin at which P>P_orth
angle_non_orth      = rad2deg(hist_x(angle_non_orth)); 


% plot distributions ---very messy, needs to be fixed
if plot_yn
    % for one space dimensioality and one or several hyperplane
    % dimensionalities
    if length(space_dim) == 1
        figure,
        if length(plane_dim) > 1, subplot(211); end
        plot(hist_dist_angles,'linewidth',2)
        set(gca,'TickDir','out'),set(gca,'FontSize',14);
%        if length(plane_dim) > 1
            lgnd        = cell(1,length(plane_dim));
            for d = 1:length(plane_dim)
                lgnd{d} = ['hyperp dim ' num2str(plane_dim(d))];
            end
            legend(lgnd,'location','NorthWest')
%        end
        xlim([0 91]), xlabel('angle (deg)')
        y_max           = ceil(max(max(hist_dist_angles))*10)/10;
        ylim([0 y_max]), ylabel('normalized counts')
        title(['empirical distribution angle btw. hyperplanes in ' ...
            num2str(space_dim) 'D space '])
        if length(plane_dim) > 1, subplot(212); end
        plot(plane_dim, angle_non_orth,'marker','o','markersize',12,'linewidth',2)
        ylim([0 90]), ylabel(['max angle P < ' num2str(P_orth)])
        xlim([0 max(plane_dim)+1]), xlabel('hyperplane dimensionality')
        set(gca,'TickDir','out'),set(gca,'FontSize',14);

    % for one hyperplane dimensioality and one or several space
    % dimensionalities
    elseif length(plane_dim) == 1
        figure,
        if length(space_dim) > 1, subplot(211); end
        plot(squeeze(hist_dist_angles(:,1,:)),'linewidth',2)
        set(gca,'TickDir','out'),set(gca,'FontSize',14);
        lgnd        = cell(1,length(space_dim));
        for n = 1:length(space_dim)
            lgnd{n} = ['space dim ' num2str(space_dim(n))];
        end
        legend(lgnd,'location','NorthWest')
        xlim([0 91]), xlabel('angle (deg)')
        y_max           = ceil(max(max(hist_dist_angles))*10)/10;
        ylim([0 y_max]), ylabel('normalized counts')
        title(['empirical distribution angle btw. ' num2str(plane_dim) ...
            'D hyperplanes in hypersspaces ']);
        if length(space_dim) > 1, subplot(212); end
        plot(space_dim, angle_non_orth,'marker','o','markersize',12,'linewidth',2)
        ylim([0 90]), ylabel(['max angle P < ' num2str(P_orth)])
        set(gca,'TickDir','out'),set(gca,'FontSize',14);
        xlim([0 max(space_dim)+1]), xlabel('space dimensionality')

    % for several space dimensionalities and several hyperplane
    % dimensionalities
    else
        for i = 1:length(space_dim)
            figure,
            if length(plane_dim) > 1, subplot(211); end
            plot(squeeze(hist_dist_angles(:,:,i)),'linewidth',2)
            set(gca,'TickDir','out'),set(gca,'FontSize',14);
    %        if length(plane_dim) > 1
                lgnd        = cell(1,length(plane_dim));
                for d = 1:length(plane_dim)
                    lgnd{d} = ['plane dim ' num2str(plane_dim(d))];
                end
                legend(lgnd,'location','Northwest')
    %        end
            xlim([0 91]), xlabel('angle (deg)')
            y_max           = max(ceil(max(max(hist_dist_angles))*10)/10);
            ylim([0 y_max]), ylabel('normalized counts')
            title(['empirical distribution angle btw. hyperplanes in ' ...
            num2str(space_dim(i)) 'D space '])
            if length(plane_dim) > 1, subplot(212); end
            plot(plane_dim, angle_non_orth(i,:),'marker','o','markersize',12,'linewidth',2)
            set(gca,'TickDir','out'),set(gca,'FontSize',14);
            ylim([0 90]), ylabel(['max angle P < ' num2str(P_orth)])
            xlim([0 max(plane_dim)+1]), xlabel('hyperplane dimensionality')
        end
    end
end