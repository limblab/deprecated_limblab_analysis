%
% Dimensionality reduction of EMGs using PCA or NNMF
%
% function dim_red_emg = dim_reduction_muscles( binned_data, varargin )
%
% Inputs (opt)          : [default]
%   binned_data         : binned_data struct or array of structs. Can be
%                           cropped 
%   (method)            : ['pca'] dim reduction method ('pca','nnmf')
%   (chosen_emgs)       : [all] EMGs to be used for the analysis. 'all'
%                           will chose all
%   (labels)            : name of the task in each binned_data struct
%
% Outputs
%   dim_red_emg         : cell with fields:
%       w               : weights PCA decomposition (cov matrix)
%       eigen           : eigenvalues of w
%       scores          : result of applying w to smoothed_FR
%       t_axis          : time axis for scores
%       chs             : EMG signals included in the analysis
%       method          : method used (stores input)
%

function dim_red_emg = dim_reduction_muscles( binned_data, varargin )

% get input params
if nargin == 1
    method              = 'pca';
    chosen_emgs         = 'all';
elseif nargin >= 2
    method              = varargin{1};
end
if nargin >= 3
    chosen_emgs         = varargin{2};
end
if nargin >= 4
    labels              = varargin{3};
end
if nargin == 5
    nbr_factors         = numel(varargin{4});
end


% get all EMGs
if strcmp(chosen_emgs,'all')
    chosen_emgs         = 1:length(binned_data(1).emgguide);
end


% nbr of BDFs
nbr_bdfs                = length(binned_data);
% nbr of EMGs
nbr_emgs                = length(chosen_emgs);


% ------------------------------------------------------------------------
% Dim reduction
dim_red_emg             = cell(1,nbr_bdfs);
switch method
    % PCA
    case 'pca'
        for i = 1:nbr_bdfs
            [w_emg, scores_emg, eigen_emg] = pca(binned_data(i).emgdatabin(:,chosen_emgs));

            % store results
            dim_red_emg{i}.w        = w_emg;
            dim_red_emg{i}.eigen    = eigen_emg;
            dim_red_emg{i}.scores   = scores_emg;
            dim_red_emg{i}.t_axis   = binned_data(i).timeframe;
            dim_red_emg{i}.chs      = chosen_emgs;
            dim_red_emg{i}.method   = 'pca';
            clear w_emg scores_emg eigen_emg
        end
    case 'nnmf'
        if ~exist('nbr_factors','var')
            disp('you need to pass the number of factors for NNMF');
        end
        for i = 1:nbr_bdfs
            [scores_emg, w_emg]     = nnmf(binned_data(i).emgdatabin(:,chosen_emgs),...
                                        nbr_factors);
                                    
            % store results
            dim_red_emg{i}.w        = w_emg;
            dim_red_emg{i}.scores   = scores_emg;
            dim_red_emg{i}.t_axis   = binned_data(i).timeframe;
            dim_red_emg{i}.chs      = chosen_emgs;
            dim_red_emg{i}.method   = 'nnmf';
            clear w_emg scores_emg
        end
end

% ------------------------------------------------------------------------
% Plot variance
if exist('labels','var')
    
    switch method
        case 'pca'
            rows_plot               = floor(sqrt(nbr_bdfs));
            cols_plot               = ceil(sqrt(nbr_bdfs));
    
            f1h                     = figure;
            f2h                     = figure;

            % plots
            for i = 1:nbr_bdfs
                figure(f1h), subplot(rows_plot,cols_plot,i)
                bar(dim_red_emg{i}.eigen/sum(dim_red_emg{i}.eigen)),set(gca,'TickDir','out'),set(gca,'FontSize',14)
                xlim([0 nbr_emgs+1]),ylim([0 1])
                title(labels{i})
                if rem(i-1,cols_plot) == 0
                    ylabel('norm. explained variance','FontSize',14)
                end
                if i >= ( (rows_plot-1)*cols_plot + 1 )
                    xlabel('component nbr.','FontSize',14)
                end

                figure(f2h), subplot(rows_plot,cols_plot,i)
                bar(cumsum(dim_red_emg{i}.eigen)/sum(dim_red_emg{i}.eigen))
                set(gca,'TickDir','out'),set(gca,'FontSize',14)
                xlim([0 nbr_emgs+1]),ylim([0 1])
                title(labels{i})
                if rem(i-1,cols_plot) == 0
                    ylabel('% norm. explained variance','FontSize',14)
                end
                if i >= ( (rows_plot-1)*cols_plot + 1 )
                    xlabel('component nbr.','FontSize',14)
                end
            end
            clear rows_plot cols_plot
            
        case 'nnmf'
            colors_bars                 = parula(nbr_factors);
            
            figure('units','normalized','outerposition',[0 0 1 1])
            for i = 1:nbr_bdfs
                for ii = 1:nbr_factors
                    subplot(nbr_bdfs,nbr_factors,(i-1)*nbr_factors+ii)
                    bar(dim_red_emg{i}.w(ii,:),'FaceColor',colors_bars(ii,:))
                    set(gca,'TickDir','out'),set(gca,'FontSize',14)
                    xlim([-1 nbr_emgs+1])
                    if ii == 1
                        ylabel(['weights --' labels{i}]);
                    end
                    if i == 1
                        title(['synergy ' num2str(ii)])
                    end
                    if i == nbr_bdfs
                        set(gca,'XTick',1:nbr_emgs)
                        set(gca,'XTickLabel',binned_data(1).emgguide(chosen_emgs))
                        set(gca,'XTickLabelRotation',45)
                    else
                        set(gca,'XTick',[]);
                    end
                end
            end
    end
end