function [c_s] = get_most_corr_spikes(binnedData,varargin)
% Calculates the normalized cross-covariance between the spikes and
% the cursor position (default) or emg data, and returns a neuronID
% array specifying the most correlated neurons. This function can be
% used to plot the calculated covariance of each neuron, using the array
% map. Right now, this function works only for unsorted neural data (units 0)
% 
% usage:
% [neuronIDs, cov] = get_most_corr_neurons(binnedData,varargin);
% 
%   neuronIDs       : [Sx2] array of [chanel unit], containing S most correlated spikes
%   cov             : [Nspikes x 
%
%   binnedData      : standard binnedData format
%   varargin{signals, num_lags, cmp_file}
%       signals     : string, either 'cursor' (default) or 'emg', to
%                     specifying what to correlate spikes with.
%       num_lags    : number of lags to evaluate (default = 10);
%       array_map   : if present, will plot xcov for each neurons with the spatial
%                     mapping provided by the cmp file 'array_map'
%%

num_lags    = 10;
spikes      = binnedData.spikeratedata;
signals     = binnedData.cursorposbin;
sig_labels  = binnedData.cursorposlabels;
% array_map   = '/Volumes/data/Jaco_8I1/Array_Maps/SN_6250-001275_LH2.cmp';
array_map   = '/Volumes/data/Jango_12a1/Array_Maps/Jango_RightM1_utahArrayMap.cmp';

if nargin > 1
    signals = varargin{2};
    if strcmpi(signals,'emg')
        signals = binnedData.emgdatabin;
    end
end
if nargin > 2
    num_lags = varargin{3};
end
if nargin > 3
    plot_flag = true;
    array_map = varargin{4};
end

num_sig     = size(signals,2);
num_spikes  = size(spikes, 2);

c = get_spikes_corr(signals,spikes,num_lags);
m = squeeze(max(max(c)));
[c_s, c_idx] = sort(m);

lgd = cell(1,num_sig);
for s = 1:num_sig
    lgd{s} = sig_labels(s,:);
end


if plot_flag
    ymax = max(max(max(c)));
    figure;
    [array_map, ~] = get_array_mapping(array_map);
    array_ch_rows = array_map';
    for n = 1:100
        ch_id = array_ch_rows(n);
        if ~ch_id
            continue;
        end
        subplot(10,10,n);
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