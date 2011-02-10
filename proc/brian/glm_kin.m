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

% $:Id $

if nargin < 5
    mdl = 'posvel';
end

ts = 5; % time step (ms)

vt = bdf.vel(:,1);
t = vt(floor(vt*ts)==vt*ts);
spike_times = get_unit(bdf,chan,unit)-offset;
spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
s = train2bins(spike_times, t);

glmv = bdf.vel(floor(vt*ts)==vt*ts,2:3);
glmx = bdf.pos(floor(vt*ts)==vt*ts,2:3);

if strcmp(mdl, 'pos')
    glm_input = glmx;
elseif strcmp(mdl, 'vel')
    glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'posvel')
    glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'nospeed')
    glm_input = [glmx glmv];
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
