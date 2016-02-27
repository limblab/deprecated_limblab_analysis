%
% Transform neural data from task 1 ('within') into the PC space of task 2
% ('across'), and compare the projections they yield 
%
%   pc_proj_across_tasks = transform_and_compare_dim_red_data( dim_red_FR, ...
%                               smoothed_FR, labels, neural_chs, within_task, ...
%                               across_task, comp_nbr )
%
% Inputs:
%   dim_red_FR              : cell array with reduced neural data
%   smoothed_FR             : cell array with smoothed FRs
%   labels                  : cell array with a label describing each trial
%   neural_chs              : channels that will be analyzed. If empty, it
%                               will look at all
%   within_task             : task which data will be projected using the
%                               PC matrix for 'across_task' (scalar)
%   across_task             : task which PC decomposition will be used to
%                               project the 'within_task' data
%   comp_nbr                : 1-D vector with the components that will be
%                               compared, or,
%                             2-D vector that established which transformed
%                             dimensions in 'within' will be compared to
%                             which dimensions in 'across'
%
% Note: if one of the eigenvectors has opposite orientation in the two
% tasks, the function already fixes that
%
%

function pc_proj_across_tasks = transform_and_compare_dim_red_data( dim_red_FR, ...
                            smoothed_FR, labels, neural_chs, within_task, ...
                            across_task, comp_nbr )


% some stuff that should be a parameter
% min_t and max_t for the plot
t_lims                  = [0 30];


% some checks
if length(dim_red_FR) ~= length(smoothed_FR)
    error('length of dim_red_FR and smoothed_FR has to be the same');
end
if length(dim_red_FR) ~= length(labels)
    error('labels has wrong size');
end

% populate a 2-D array that establishes which components in within will be
% comapred to which components in across (1st and 2nd columns)
[nbr_rows, nbr_cols]    = size(comp_nbr);
if min(size(comp_nbr)) > 1
    if nbr_cols ~= 2
        error('comp_nbr can only have 1 or 2 columns');
    else
        comp_nbr_array  = comp_nbr;
    end
else % if comp_nbr is a row vector (=> will comp dim X to dim X)
    if nbr_rows < nbr_cols, comp_nbr = comp_nbr'; end;
    comp_nbr_array      = [comp_nbr, comp_nbr];
end

% -------------------------------------------------------------------------
% some definitions
                        
nbr_comps               = length(comp_nbr);

% get bin width
bin_width_neurons       = mean(diff(dim_red_FR{1}.t));

% interval for the xcorr, in nbr of bins
int_xcorr               = 30; 
% time axis for xcorr
t_axis_xcorr            = bin_width_neurons*(-int_xcorr:1:int_xcorr);
% nbr points coherence
nfft_coh                = 1024/2+1;


% initalize struct for returning results
pc_proj_across_tasks    = struct('within_task',within_task,'across_task',across_task,...
                            'comp_nbr',comp_nbr_array,'scores_within',[],'scores_across',[],...
                            'xcorr',zeros(length(t_axis_xcorr),nbr_comps),...
                            't_axis_xcorr',t_axis_xcorr', ...
                            'coh',zeros(nfft_coh,nbr_comps), ...
                            'f_coh',zeros(nfft_coh,1), ...
                            'inverted_eigenv',zeros(1,nbr_comps));

                        
% -------------------------------------------------------------------------
% do
for i = 1:nbr_comps
   
    % Transform the data from task number 'within_task' using the
    % transformation matrix of task number 'across_task,' and remove mean
    % (for comparison, since matlab does remove the mean)
    % -- in smoothed_FR, add 1 to neural_chs because dim 1 is time
    pca_this_comb       = (smoothed_FR{within_task}(:,neural_chs+1))*...
                            dim_red_FR{across_task}.w(:,comp_nbr_array(i,2))...
                            - mean(smoothed_FR{within_task}(:,neural_chs+1))*...
                            dim_red_FR{across_task}.w(:,comp_nbr_array(i,2));

    % compute cross-correlation
    xcorr_this_comb     = xcorr( dim_red_FR{within_task}.scores(:,comp_nbr_array(i,1)), ...
                                pca_this_comb, int_xcorr);

    % compute coherence
    [coh_this_comb, f_coh] = mscohere( dim_red_FR{within_task}.scores(:,comp_nbr_array(i,1)),...
                                pca_this_comb, 20, 16, 1024, 20 );
                            
    % store results in return struct
    pc_proj_across_tasks.scores_within(:,i)     = dim_red_FR{within_task}.scores(:,comp_nbr_array(i,1));
    pc_proj_across_tasks.scores_across(:,i)     = pca_this_comb;
    pc_proj_across_tasks.xcorr(:,i)             = xcorr_this_comb;
    pc_proj_across_tasks.coh(:,i)               = coh_this_comb;
    if i == 1
        pc_proj_across_tasks.f_coh              = f_coh;
    end
end


% ------------------------------------------------------------------------
% PLOTS

% invert the components that need to be inverted for the plots
for i = 1:nbr_comps
    [~, indx_max_xcorr ]    = max(abs(pc_proj_across_tasks.xcorr(:,i)));
    if pc_proj_across_tasks.xcorr(indx_max_xcorr,i) < 0
        pc_proj_across_tasks.inverted_eigenv(i) = 1;
        pc_proj_across_tasks.scores_across(:,i) = - pc_proj_across_tasks.scores_across(:,i);
        pc_proj_across_tasks.xcorr(:,i)         = - pc_proj_across_tasks.xcorr(:,i);
    end
end


% plot
for i = 1:nbr_comps
    figure,
    subplot(211),hold on
    plot(dim_red_FR{within_task}.t,[ pc_proj_across_tasks.scores_within(:,i), ...
        pc_proj_across_tasks.scores_across(:,i) ], 'LineWidth',2)
    %plot(dim_red_FR{within_task}.t,dim_red_FR{within_task}.scores(:,comp_nbr(i)),'LineWidth',2)
    legend(labels{within_task},labels{across_task})
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    ylabel(['neural comp.' num2str(comp_nbr(i))]),xlabel('time (s)'), xlim(t_lims)
    subplot(223)
    plot(t_axis_xcorr,pc_proj_across_tasks.xcorr(:,i),'LineWidth',2)
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    ylabel('crosscorrelation'), xlabel('time (s)')
    subplot(224)
    plot(f_coh,pc_proj_across_tasks.coh(:,i),'LineWidth',2)
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    ylabel('coherence'), xlabel('frequency (Hz)'), ylim([0 1])
    set(gcf,'Colormap',winter)
end