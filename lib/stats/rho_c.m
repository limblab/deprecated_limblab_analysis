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

x = cos(alpha);
y = sin(alpha);
mu = atan2(sum(y), sum(x));

x = cos(beta);
y = sin(beta);
nu = atan2(sum(y), sum(x));

E = mean(sin(alpha-mu) .* sin(beta-nu));
V = var(sin(alpha-mu)) .* var(sin(beta-nu));

r = E / sqrt(V);

%r = sum( sin(alpha-mu) .* sin(beta-nu) ) / sqrt( sum( sin(alpha-mu).^2 .* sin(beta-nu).^2 ) );

