function c = get_emg_cov(force,emg,varargin)
% Returns a (num_lags*2+1 x num_emgs x num_force_sig) array
% of the covariance between
% each muscle 'emg' and each component in 'force'.
% 
%
%   emg             : column-wise array of emg activity (MxNum_emg)
%   force           : MxP array, with P signals to which we want to correlate with the spikes
%   varargins
%      []           : nothing
%
% 12/2014 Chris
%%

num_lags = 10;
if nargin >2
    num_lags = varargin{1};
end

num_emgs        = size(emg,2);
num_force_sig   = size(force,2);

c = zeros(num_lags*2+1,num_force_sig,num_emgs); %covariance matrix

for e = 1:num_emgs
    for f = 1:num_force_sig
        c(:,f,e) = xcov(force(:,f),emg(:,e),num_lags,'unbiased');
    end
end

