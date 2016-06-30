function rate = calcFR( ti, ts, kw, method)
% usage: rate = calcFR( ti, ts, kw, method);
% this function converts a spike train into firing 
% rate time-series 
% OUTPUTS: 
%   rate: time series of firing rates
% INPUTS:
%   ti: reference time index for output vector
%   ts: spike times
%   kw: kernel width (seconds)
%   method: specifies kernel type
%       -> 'boxcar'
%       -> 'gaussian'
%       -> 'triangle' (not implemented yet)
dt = mean(diff(ti));

switch method,
    case 'boxcar',
        %standard rate histogram method
%         rate = hist( ts, ti ) ./ kw;
        for i = 1:length(ti),
            tStart = ti(i) - kw/2;
            tEnd = ti(i) + kw/2;
            rate(i) = sum(ts >= tStart & ts < tEnd)/kw;
        end
    case 'gaussian',      
        sigma = kw/pi;
        for i = 1:length( ti ),
            curT = ti(i);
            tau = curT - ts( find( ts >= curT-5*sigma & ts < curT+5*sigma) );
            rate(i) = sum( exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma) );

        end
    case 'triangle'
        disp('Triangle is not implemented yet');

end

if size( rate, 1) < size(rate,2),
    rate = rate';
end
