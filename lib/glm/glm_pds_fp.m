function [pds, errs, moddepth] = glm_pds_fp(bdf,chanlist,fband)
% GLM_PDS returns PDS calculated using a velocity GLM
%   PDS = GLM_PDS_fp(BDF) returns the velocity PDs from the specified
%   channels and freq bands in the BDF object

% $Id: glm_pds.m 642 2011-11-22 18:17:02Z brian $

% ul = unit_list(bdf);
pds = zeros(length(chanlist),1);
errs = zeros(length(chanlist),1);

tic;
for i = 1:length(chanlist)
    et = toc;
    fprintf(1, 'ET: %f (%d of %d)', et, i, length(chanlist));
    
    [b, dev, stats] = glm_kin_fp(bdf, chanlist{i}, fband, 0, 'posvel'); %#ok<ASGLU>
    bv = [b(4) b(5)];
    dbv = [stats.se(4) stats.se(5)];
    
    J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
    moddepth(i) = norm(bv,2);
    pds(i,:) = atan2(bv(2), bv(1));
    errs(i,:) = dbv*J;
end


