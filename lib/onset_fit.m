function [beta, ci] = onset_fit( curve )
%ONSET_FIT returns a description of the fit to curve
%   OUT = ONSET_FIT( CURVE )
%
%   ONSET_FIT fits a curve (flat then parabolic).  The point at which the
%   fit transitions from flat to parabolic is defined as the onset.
%
%   OUT contains:
%       1) transition point
%       2) value for flat section
%       3) scale for parabolic section

% $Id$

% x = 1:20;
% y = [5*ones(1,10) .3*x(1:10).^2+5];
% y = y+randn(size(y));
% 
% %x = 1:length(curve);
% %y = curve;
% beta0 = [1 1 1];
% F = @(beta,xdata) (xdata<beta(1)).*beta(2) + (xdata>=beta(1)).*(beta(3)*(xdata-beta(1)).^2+beta(2));
% %out = lsqcurvefit(F,x0,x,y);
% [beta,r,J] = nlinfit(x, y, F, beta0);
% ci = nlparci(beta, r, 'jacobian', J);
% 
% plot(x, y, 'ko', x, F(beta,x), 'r-', ci(1,:), [beta(2) beta(2)], 'r*')

%frt = -.75:.05:1.25;

%frt = -.75:.025:1.25;
%y = hist(sort(cell2mat(curve)), frt);


%t = -.5:0.005:1;
%y = mean(curve);
%dy = diff(y);
%idx = find(dy == max(dy), 1, 'first');
%beta = [t(idx) t(idx) t(idx)];
%ci = beta;
%return;

frt = -.5:0.005:1;
y = mean(curve);
plot(frt,y,'ko');
%x = 1:find(y==max(y),1,'first'); y = y(x);

%%% BEGIN NEW INDEXING %%%
dd = diff(y);
peaks = find(dd(1:end-1) > 0 & dd(2:end) < 0) + 1;
troughs = find(dd(1:end-1) < 0 & dd(2:end) > 0) + 1;

% Keep only from first trough to last peak
peaks = peaks(peaks > troughs(1));
troughs = troughs(troughs < peaks(end));

swings = y(peaks) - y(troughs);
ms = find(swings == max(swings));
%bigswing = troughs(ms):peaks(ms);

idx = peaks(ms); %find(y(bigswing) > thr, 1, 'first') + bigswing(1) - 1;
x = 1:idx; y = y(x);
%%% END NEW INDEXING %%%

beta0 = [1 1 1];
betalb = [0 1 0];
betaub = [+Inf length(x) 20];

F = @(beta,xdata) (xdata<beta(1)).*beta(2) + (xdata>=beta(1)).*(beta(3)*(xdata-beta(1)).^2+beta(2));
%[beta,r,J] = nlinfit(x, y, F, beta0);
[beta,rn,r,xf,out,lambda,jacobian] = lsqcurvefit(F, beta0, x, y);
ci = nlparci(beta, r, 'jacobian', jacobian);

%plot(x, y, 'ko', x, F(beta,x), 'r-')
plot(x, y, 'ko', min(x):.1:max(x), F(beta,min(x):.1:max(x)), 'r-', [ci(1,1) beta(1) ci(1,2)], [beta(2) beta(2) beta(2)], 'r*')

tmpt = min(x):.01:max(x);
thr = (beta(2) + F(beta,max(x)))/2;
idx = find(F(beta,tmpt)>thr, 1, 'first');
beta(1) = tmpt(idx);

err = (ci(1,2) - ci(1,1))/2;
ci(1,:) = [beta(1)-err beta(1)+err] * .005 - .5;
beta(1) = beta(1) * .005 - .5;

%disp(frt(floor(beta(1))));


