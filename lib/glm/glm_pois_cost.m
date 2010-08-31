function [L, dL] = glm_pois_cost(a, x, I)

nzp_w = 0; % weight for the non-zero penalty term
sm_w = 0;  % weight for the smoothness penalty term

% Penalties
nzp = -sum(abs(a(2:end)));
sm = sum(diff(a(2:end)).^2);

% Raw likelihood
log_lambda = x*a;
lambda = exp(x*a);
L = -sum(I.*log_lambda - lambda - log(factorial(I)));

% Add penalties
L = nzp_w*nzp + sm_w*sm + L;

% Gradient
if nargout > 1
    dL = zeros(size(a));
    for v = 1:size(a)
        dLv = -sum(x(:,v).*(I - lambda));

        if v == 1
            dnzp = 0;
            dsm = 0;
        else
            dnzp = -sign(a(v));
            tmp = [a; 0];
            dsm = .5*(tmp(v+1)-tmp(v-1));
        end
        
        dL(v) = nzp_w*dnzp + sm_w*dsm + dLv;
    end
end
