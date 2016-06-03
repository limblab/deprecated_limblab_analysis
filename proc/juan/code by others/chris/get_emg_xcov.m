function c = get_emg_xcov(force,emg,varargin)
% Returns a (num_lags*2+1 x num_emgs x num_force_sig) array
% of the covariance between
% each muscle 'emg' and each component in 'force'.
% 
%
%   emg             : column-wise array of emg activity (MxNum_emg)
%   force           : MxP array, with P signals to which we want to correlate with the spikes
%   varargins
%       plot_flag   : whether or not to plot the results
%
% 12/2014 Chris
%%

num_lags = 10; plot_flag = false;
if nargin >2 num_lags  = varargin{1}; end
if nargin >3 plot_flag = varargin{2}; end

num_emgs        = size(emg,2);
num_force_sig   = size(force,2);

c = zeros(num_lags*2+1,num_force_sig,num_emgs); %covariance matrix

for e = 1:num_emgs
    for f = 1:num_force_sig
        c(:,f,e) = xcorr(force(:,f),emg(:,e),num_lags,'coef');
    end
    if plot_flag
        figure;
        plotLM(c(:,:,e));
        title(sprintf('muscle %d',e));
        legend('Fx','Fy');
    end
end
 