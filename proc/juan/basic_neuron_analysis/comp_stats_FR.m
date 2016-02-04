%
% Basic statistic comparison (paired two-sided test) of firing rate
% statistics between two or more trials. 
%
%   function stats_neurons = comp_stats_FR( binned_FR, varargin )
%
% Inputs (opt):             [defaults]
%   binned_FR               : binned_FR cell array, obtained with
%                               calculate_FR.m
%   (alpha)                 : [0.05] significance threshold
%   (neural_chs)            : [1:96] array with channels to be analyzed
%   (show_plots)            : [false] plots that summarize across trial
%                               comparisons
%   (labels)                : [trial nbr] labels that define each
%                               binned_FR; for plotting purposes 
% 
%
% Syntax:
%   stats_neurons = comp_stats_FR( bin_FR, alpha )
%   stats_neurons = comp_stats_FR( bin_FR, neural_chs )
%   stats_neurons = comp_stats_FR( bin_FR, alpha, neural_chs )
%   stats_neurons = comp_stats_FR( bin_FR, alpha, neural_chs, show_plots )
%   stats_neurons = comp_stats_FR( bin_FR, alpha, neural_chs, show_plots, labels )
%
%
% Notes: Current version works for one Utah array only. It also gets rid of
% channels >= 97, which appear in some old lab 1 recordings as artefacts
%

function stats_neurons = comp_stats_FR( bin_FR, varargin )


nbr_bdfs                    = length(bin_FR);

% Input params
if nargin == 2
    if length(varargin{1}) == 1
        alpha               = varargin{1};
    else
        neural_chs          = varargin{1};
    end
elseif nargin >= 3
    alpha                   = varargin{1};
    neural_chs              = varargin{2};
end
if nargin >= 4
    show_plots              = varargin{3};
end

if nargin == 5
    labels                  = varargin{4};    
elseif show_plots
    for i = 1:nbr_bdfs  
        labels{i}           = ['trial ' num2str(i)];
    end
end

if ~exist('show_plots','var')
    show_plots              = false;
end



% Some BDFs have funny data in channels >=97, get rid of them
for i = 1:nbr_bdfs
    if size(bin_FR{i}.binned_FR,2) > 97
        bin_FR{i}.binned_FR(:,98:end) = [];
    end
end


% ---------
% Some other preliminary stuff
nbr_chs                     = length(neural_chs);
if nbr_bdfs == 1
    error('Need >= 2 trials to compare');
elseif nbr_bdfs > 5
    warning('This is giong to give too many permutations!!!');
end

chs_to_delete               = setdiff(1:96,neural_chs);
for i = 1:nbr_bdfs
    % get rid of the time vector
    bin_FR{i}.binned_FR(:,1) = [];
    % ... and of the channels that we don't want to use
    bin_FR{i}.binned_FR(:,chs_to_delete) = [];
end

% the number of tests equals the number of permutations (e.g, with 3 bdfs,
% bdf 1 and 2, bdf 1 and 3, and bdf 2 and 3)
comps                       = nchoosek(1:nbr_bdfs,2);
nbr_comps                   = size(comps,1);


% ---------
% stat testing
for i = 1:nbr_comps
    % init some matrices
    st{i}.signrank_p        = zeros(nbr_chs,1);
    st{i}.signrank_h        = zeros(nbr_chs,1);
    
    % retrieve trials to compare
    cur_bdf1                = comps(i,1);
    cur_bdf2                = comps(i,2);
        
    % compare across chs for these two trials
    for ii = 1:nbr_chs
        [st{i}.single_chs.ttest_h(ii), st{i}.single_chs.ttest_p(ii)]  = ttest( ...
            bin_FR{cur_bdf1}.binned_FR(:,ii), bin_FR{cur_bdf2}.binned_FR(:,ii), 'alpha', alpha );
    end
    
    % compare entire populations
%     FR_pop1                 = reshape(bin_FR{cur_bdf1}.binned_FR, ...
%                             size(bin_FR{cur_bdf1}.binned_FR,1)*size(bin_FR{cur_bdf1}.binned_FR,2),1);
%     FR_pop2                 = reshape(bin_FR{cur_bdf2}.binned_FR, ...
%                             size(bin_FR{cur_bdf2}.binned_FR,1)*size(bin_FR{cur_bdf2}.binned_FR,2),1);
%                         
%     [st{i}.pop_act.ttest2.h, st{i}.pop_act.ttest2.p ] = ttest2( FR_pop1, FR_pop2 );
    [st{i}.pop_act.signrank.p, st{i}.pop_act.signrank.h ] = signrank( bin_FR{cur_bdf1}.mean_FR(neural_chs),...
                                bin_FR{cur_bdf2}.mean_FR(neural_chs),'alpha',alpha );
    
                        
    % add some meta data
    st{i}.meta.filename1    = bin_FR{cur_bdf1}.meta.filename;
    st{i}.meta.filename2    = bin_FR{cur_bdf2}.meta.filename;
    st{i}.test              = 'paired t test'; % for compatibility with new future tests
    st{i}.neural_chs        = neural_chs;
end


% assign output argument
if nbr_bdfs == 2
    stats_neurons           = st{1};
else
    stats_neurons           = st;
end


% plot
if show_plots
    % fill a confusion matrix
    confusion_pop_act        = zeros(nbr_bdfs);
    % for the binary result of hypothesis testing. Signif threshold = 0.05
    confusion_pop_act_h      = zeros(nbr_bdfs); 
    for i = 1:nbr_comps
        confusion_pop_act(comps(i,1),comps(i,2))     = st{i}.pop_act.signrank.p;
        confusion_pop_act_h(comps(i,1),comps(i,2))   = st{i}.pop_act.signrank.h;
    end
    % copy to lower diagonal
    confusion_pop_act        = confusion_pop_act + confusion_pop_act';
    confusion_pop_act_h      = confusion_pop_act_h + confusion_pop_act_h';
    
    % plot
    figure('units','normalized','outerposition',[0 1/3 1 2/3]),
    subplot(121),imagesc(confusion_pop_act),
    colorbar, caxis([0 1])
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    set(gca,'Xtick',1:nbr_bdfs,'XTickLabel',labels)
    set(gca,'Ytick',1:nbr_bdfs,'YTickLabel',labels)
    title(['P values, median population FRs are different if P < ' num2str(alpha)])
    subplot(122),imagesc(confusion_pop_act_h),
    colorbar, caxis([0 1])
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    set(gca,'Xtick',1:nbr_bdfs,'XTickLabel',labels)
    set(gca,'Ytick',1:nbr_bdfs,'YTickLabel',labels)
    title(['result hypothesis testing (H = 0, medians are equal at alpha: ' num2str(alpha) ')'])

end