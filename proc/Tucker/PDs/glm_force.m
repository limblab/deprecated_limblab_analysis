function [b, dev, stats, L, L0] = glm_force(tdf, unit_num, offset)

    % GLM_FORCE fits a glm model of the handle force to the requested neuron
    %
    %   B = GLM_FORCE(BDF, CHAN, UNIT, OFFSET) returns B the vector of glm
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

    if nargin < 3
        offset = 0;
    end

    %interpolate the force values to the timestamps in the firing rate data
    glmf = interp1(tdf.force(:,1), tdf.force(:,2:3), tdf.units(unit_num).fr(:,1));

   [b, dev, stats] = glmfit(glmf, s, 'poisson');

    if nargout > 3
        lambda = glmval(b, glmf, 'log');
        L = sum(log(lambda.^(s')) - lambda - log(factorial(s')));
    end

    if nargout > 4
        lambda = sum(s)/length(s);
        L0 = sum(log(lambda.^(s')) - lambda - log(factorial(s')));
    end

end