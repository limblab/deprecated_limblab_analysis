function r = rho_c(alpha, beta)
% RHO_C - The circular-circular correlation coeficient
%   R = RHO_C(ALPHA, BETA) returns the circular correlation coefficient of
%   the two sets of angles ALPHA and BETA.
%
%   In general RHO_C is between -1 and 1, where RHO_C is 0 when ALPHA and
%   BETA are independed, although the converse it not true in general.
%   Where RHO_C = 1, ALPHA = BETA + K (mod 2 PI).
%
%   See also: Topics in Circular Statistics, Jamalamadaka p 176 et Seq.
%   and Jamalamadaka and Sarma (1988).

% $Id$

alpha = mod(2*pi, alpha);
beta = mod(2*pi, beta);

x = cos(alpha);
y = sin(alpha);
mu = mod(2*pi, atan2(sum(y), sum(x)));

x = cos(beta);
y = sin(beta);
nu = mod(2*pi, atan2(sum(y), sum(x)));

%E = mean(sin(alpha-mu) .* sin(beta-nu));
%V = mean(sin(alpha-mu).^2) * mean(sin(beta-nu).^2);

%r = E / sqrt(V);

%E = mean( sin(alpha-mu).*sin(beta-nu) );
%V = mean( sin(alpha-mu).^2 ).*mean( sin(beta-nu).^2 );

%r = E/sqrt(V);




a=alpha(:);
b=beta(:);
n=length(a);
r=4*(sum(cos(a).*cos(b))*sum(sin(a).*sin(b))-sum(cos(a).*sin(b))*sum(sin(a).*cos(b)))/sqrt((n.^2-sum(cos(2*a)).^2-sum(sin(2*a)).^2)*(n.^2-sum(cos(2*b)).^2-sum(sin(2*b)).^2));