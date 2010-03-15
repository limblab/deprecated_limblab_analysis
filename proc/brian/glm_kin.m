function [b, dev, stats, L, L0] = glm_kin(bdf, chan, unit, offset, mdl, tmp)
%function [L_final, mdl, success] = glm_kin(bdf, chan, unit, offset)

if nargin < 5
    mdl = 'posvel';
end

offset = floor(1000 * offset);

vt = bdf.vel(:,1);
t = vt(floor(vt*20)==vt*20);
%spike_times = get_unit(bdf,chan,unit)-offset;
spike_times = tmp-offset;
spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
s = train2bins(spike_times, t);

glmv = bdf.vel(floor(vt*20)==vt*20,2:3);
glmx = bdf.pos(floor(vt*20)==vt*20,2:3);

if strcmp(mdl, 'pos')
    glm_input = glmx;
elseif strcmp(mdl, 'vel')
    glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'posvel')
    glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
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
