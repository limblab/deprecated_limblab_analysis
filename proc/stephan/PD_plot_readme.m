% how to plot with PD_plot, PD_plot_selection.

% run *\s1_analysis\load_paths
% make current folder my the proc folder in s1_analysis -> this has the
% PD_plot and PD_plot_selection mfiles in it.
% load the data you want to analyze into matlab (in bdf format)

% PD_plot:
% % PD_PLOT = PD_plot(BDF,ARRAY_MAP_FILEPATH,INCLUDE_UNSORTED,INCLUDE_HISTOGRAMS,DESELECTED_CHANNELS)
% so inputs are:
%       BDF: name of the bdf you loaded into matlab; the one you want to
%       analyze
%       ARRAY_MAP_FILEPATH: for kramer you can just make this 'Kramer'
%       INCLUDE_UNSORTED: 1 if yes, you want to include unsorted channels
%       in your analysis (we do at this point because we have defined no
%       neurons). 0 if you don't (not applicable at 10-11-2012)
%       INCLUDE_HISTOGRAMS: 1 if you want to have PD_plot plot the
%       histograms of the PDs, confidence intervals and moddulation depths
%       of the bdf
%       DESELECTED_CHANNELS: an 1xn array of channels you do not want to
%       consider in this analysis. these channels will show up red in the
%       PD_plot if there is a PD for them. 

% Example:
%   PD_plot(sunday7102012,'Kramer',1,1,[96, 47])
%   -> will analyze dataset sunday7102012, use Kramer's the array mapping
%   file, will include unsorted channels, will plot the histograms, will
%   deselect channels 96 and 47 from the anlysis.

%       The polar plots show the PD as a thicker line, the length of which
%       indicates the modulation depth, scaled to the maximum of the
%       moddepths present, excluding the deselected channels.
%       The area between two 95% confidence bounds will be shaded. 

%   

% PD_plot_selection
% %  PD_PLOT_SELECTION(CHANNEL_SELECTION,BDF,INCLUDE_UNSORTED)
%       CHANNEL_SELECTION: the channels you want to select out of the
%       current bdf to plot the PDs of in one polar plot. 1xn array
%       INCLUDE_UNSORTED: 1 if you want to include unsorted channels in the
%       analysis.

% Example:
%   PD_plot_selection([45,47,53],sunday7102012,1)
%   -> will plot the PDs with their CIs of channels 45, 47, and 53 from
%   bdf sunday7102012 in one polar plot, including if they are unsorted
%   channels or not.
