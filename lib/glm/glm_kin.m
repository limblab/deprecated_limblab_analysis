function [b, dev, stats, L, L0] = glm_kin(bdf, chan, unit, offset, mdl)
% GLM_KIN fits the kinematic glm model to the requeted neuron
%
%   B = GLM_KIN(BDF, CHAN, UNIT, OFFSET) returns B the vector of glm
%       weights for the fit GLM for the specified CHANnel and UNIT number
%       in the supplied BDF structure.  Offset will shift the spike train
%       relative to the kinematics.
%
%   [B, DEV, STATS] = GLM_KIN( ... ) also returns DEV and STATS from glmfit
%
%   [B, DEV, STATS, L, L0] = GLM_KIN( ... ) also returns the negative log
%       liklihood L of the model fit given the spike train and L0 the
%       negative log liklihood under the null hypothesis of constant firing
%       rate.
%
%   [B ... ] = GLM_KIN(BDF, CHAN, UNIT, OFFSET, MDL) will use the speficied
%       model MDL as follows:
%         'pos'    -- position only (X, Y)
%         'vel'    -- velocity and speed (Vx, Vy, sqrt(Vx^2 + Vy^2)
%         'posvel' -- full kinematic model (X, Y, Vx, Vy, sqrt(Vx^2 + Vy^2)
%         'nospeed' -- no speed term (X, Y, Vx, Vy)

% $Id$

if nargin < 5
    mdl = 'posvel';
end

if nargin < 4
    offset = 0;
end

%ts = 200; % time step (ms)
ts = 50;

vt = bdf.vel(:,1);
t = vt(1):ts/1000:vt(end);
spike_times = get_unit(bdf,chan,unit)-offset;
spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
s = train2bins(spike_times, t);

glmx = interp1(bdf.pos(:,1), bdf.pos(:,2:3), t);
glmv = interp1(bdf.vel(:,1), bdf.vel(:,2:3), t);
glmf = interp1(bdf.force(:,1), bdf.force(:,2:3), t);
glmp = sum(glmf .* glmv,2);
glmpp = [sum( glmf .* glmv , 2)./sqrt(sum(glmv.^2,2)) ...
    sum( glmf .* [-glmv(:,2), glmv(:,1)] , 2)./sqrt(sum(glmv.^2,2))];

if strcmp(mdl, 'pos')
    glm_input = glmx;
elseif strcmp(mdl, 'vel')
    glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'posvel')
    glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'nospeed')
    glm_input = [glmx glmv];
elseif strcmp(mdl, 'forcevel')
    glm_input = [glmv glmf];
elseif strcmp(mdl, 'forceposvel')
    glm_input = [glmx glmv glmf];
elseif strcmp(mdl, 'ppforcevel');
    glm_input = [glmv glmf];
elseif strcmp(mdl, 'ppforceposvel');
    glm_input = [glmx glmv glmf];
else
    error('unknown model: %s', mdl);
end

[b, dev, stats] = glmfit(glm_input, s, 'poisson');

if nargout > 3
    lambda = glmval(b, glm_input, 'log');
    L = sum(log(lambda.^(s')) - lambda - log(factorial(s')));
end

if nargout > 4
    lambda = sum(s)/length(s);
    L0 = sum(log(lambda.^(s')) - lambda - log(factorial(s')));
end
