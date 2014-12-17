function [neuronIDs_s,c_s,max_c_s] = get_most_corr_neurons(binnedData,varargin)
% Calculates the normalized cross-covariance between the spikes and
% the cursor position (default) or emg data, and returns a neuronID
% array specifying the most correlated neurons. This function can be
% used to plot the calculated covariance of each neuron, using the array
% map. Right now, this function works only for unsorted neural data (units 0)
% 
% usage:
% [neuronIDs, cov] = get_most_corr_neurons(binnedData,varargin);
% 
%   neuronIDs_s     : Array [chanel unit], sorted in decreasing order of max xcov
%   c_s             : xcov measured between each neural channel and the target
%                     signals (e.g. Force or EMG) array is size
%                     [num_lags*2+1,num_signals,num_neurons]. c_s is also
%                     sorted in decreasing order of max xcov, in the same
%                     order as neuronIDs_s
%   max_c_s         : corresponding vector of max xcov, also decreasing
%                     order.
%
%   binnedData      : standard binnedData format
%   varargin{signals, num_lags, cmp_file}
%       signals     : string, either 'cursor' (default) or 'emg', to
%                     specifying what to correlate spikes with.
%       num_lags    : number of lags to evaluate (default = 10);
%       array_map   : if present, will plot xcov for each neurons with the spatial
%                     mapping provided by the cmp file 'array_map'
%
% 06/2014 Chris
%%

num_lags    = 10;
spikes      = binnedData.spikeratedata;
signals     = binnedData.cursorposbin;
sig_labels  = binnedData.cursorposlabels;
array_map_Jaco   = '/Volumes/data/Jaco_8I1/Array_Maps/SN_6250-001275_LH2.cmp';
array_map_Jango  = '/Volumes/data/Jango_12a1/Array_Maps/Jango_RightM1_utahArrayMap.cmp';
array_map_JangoFMA = '/Volumes/data/Jango_12a1/Array_Maps/Jango_RightM1_UtahAndFMA_arrayMap.cmp';
plot_flag   = false;

if nargin > 1
    if strcmpi(varargin{1},'emg')
        signals    = binnedData.emgdatabin;
        sig_labels = binnedData.emgguide;
    end
end

if nargin > 2
    num_lags = varargin{2};
end
if nargin > 3
    plot_flag = true;
    array_map = varargin{3};
    switch array_map
        case 'Jango'
            array_map = array_map_Jango;
        case 'JangoFMA'
            array_map = array_map_JangoFMA;
        case 'Jaco'
            array_map = array_map_Jaco;
    end
end

num_sig     = size(signals,2);

c = get_spikes_corr(signals,spikes,num_lags);
m = squeeze(max(max(c)));
[max_c_s, c_idx] = sort(m,1,'descend');

neuronIDs_s = binnedData.neuronIDs(c_idx,:);
c_s = c(:,:,c_idx);


if plot_flag
    lgd = cell(1,num_sig);
    for s = 1:num_sig
        lgd{s} = sig_labels(s,:);
    end
    
    ymax = max(max_c_s);
    
    figure;
    [array_map, ~] = get_array_mapping(array_map);
    [numrows,numcol] = size(array_map);
    array_ch_rows = array_map';
    for n = 1:numel(array_map)
        ch_id = array_ch_rows(n);
        if ~ch_id
            continue;
        end
        subplot(numrows,numcol,n);
        plot(c(:,:,ch_id));
        hold on; axis off;
        plot([num_lags+1 num_lags+1],[0 ymax],'k--');
        ylim([0 ymax]); xlim([1 2*num_lags+1]);
        title(sprintf('ch %d',ch_id));
    end
 
    legend(lgd{:},'location','BestOutside');
end
    
    % 
% [m,l] = max(c);
% 
% [c,idx] = sort();

% %%%
% for n = 1:96
%      ch_id = array_ch_rows(n);
%     if ~ch_id
%         continue;
%     end
%     plot(c(:,:,ch_id));
%     hold on;
%     plot([num_lags+1 num_lags+1],[0 ymax],'k--');
%     ylim([0 ymax]); xlim([1 2*num_lags+1]);
%     title(sprintf('ch %d',ch_id));
%     pause;
%     hold off;
% end