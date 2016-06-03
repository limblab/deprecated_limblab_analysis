function [pds, errs, moddepth] = glm_pds(bdf)
% GLM_PDS returns PDS calculated using a velocity GLM
%   PDS = GLM_PDS(BDF) returns the velocity PDs from each unit in the
%       supplied BDF object

% $Id: glm_pds.m 835 2012-05-11 22:31:31Z brian $

ul = unit_list(bdf);
pds = zeros(length(ul),1);
errs = zeros(length(ul),1);
moddepth = zeros(length(ul),1);

tic;
for i = 1:length(ul)
    et = toc;
    fprintf(1, 'ET: %f (%d of %d)\n', et, i, length(ul));
    
    [b, dev, stats] = glm_kin(bdf, ul(i,1), ul(i,2), 0, 'posvel'); %#ok<ASGLU>
    bv = [b(4) b(5)];
    dbv = [stats.se(4) stats.se(5)];
    J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
    moddepth(i) = norm(bv,2);
    pds(i,:) = atan2(bv(2), bv(1));
    errs(i,:) = dbv*J;
    moddepth(i,:) = sqrt(bv(1).^2 + bv(2).^2);
end


