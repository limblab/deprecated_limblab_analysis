function [pds, errs, moddepth] = glm_force_pds(tdf)
% GLM_FORCE_PDS returns PDS calculated using a velocity GLM
%   PDS = GLM_FORCE_PDS(TDF) returns the force PDs from each unit in the
%       supplied TDF object (TDF is a BDF extended with the trial table as
%       a major field and the firing rate as a minor field of each unit 
%       structure)



ul = unit_list(tdf);
pds = zeros(length(ul),1);
errs = zeros(length(ul),1);
moddepth = zeros(length(ul),1);

for i = 1:length(ul)
    et = toc;
    fprintf(1, 'ET: %f (%d of %d)\n', et, i, length(ul));
    
    [b, dev, stats] = glm_force(tdf, ul(i,1), ul(i,2), 0); %#ok<ASGLU>
    
    db = [stats.se(1) stats.se(2)];
    J = [-b(2)/(b(1)^2+b(2)^2); b(1)/(b(1)^2+b(2)^2)];
    %modulation depth
    moddepth(i) = norm(b,2);
    %pds
    pds(i,:) = atan2(b(2), b(1));
    %standard errors in rad
    errs(i,:) = db*J;
    
end